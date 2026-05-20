package com.lifelink.servlet;

import com.lifelink.dao.HospitalDashboardDAO;
import com.lifelink.dao.NotificationDAO;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/hospital/dashboard")
public class HospitalDashboardServlet extends HttpServlet {

    private final HospitalDashboardDAO dashboardDAO = new HospitalDashboardDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private static final DateTimeFormatter NOTIFICATION_TIME_FORMAT = DateTimeFormatter.ofPattern("MMM d, h:mm a");

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Object roleValue = session.getAttribute("role");
        if (roleValue == null || !"hospital".equalsIgnoreCase(String.valueOf(roleValue))) {
            response.sendRedirect(request.getContextPath() + "/403");
            return;
        }

        Integer hospitalId = resolveHospitalId(session);
        if (hospitalId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        if ("markNotificationsRead".equalsIgnoreCase(request.getParameter("action"))) {
            String csrfFromSession = (String) session.getAttribute("csrfToken");
            String csrfFromRequest = request.getParameter("csrfToken");
            if (csrfFromSession != null && csrfFromSession.equals(csrfFromRequest)) {
                try {
                    notificationDAO.markAllAsRead(hospitalId);
                } catch (SQLException e) {
                    System.err.println("[HospitalDashboardServlet] markNotificationsRead: " + e.getMessage());
                }
            }
        }

        redirectAfterNotificationRead(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        Object roleValue = session.getAttribute("role");
        if (roleValue == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String role = String.valueOf(roleValue);
        if (!"hospital".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/403");
            return;
        }

        Integer hospitalId = resolveHospitalId(session);
        if (hospitalId == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            request.setAttribute("hospitalName", dashboardDAO.getHospitalName(hospitalId));
            request.setAttribute("totalStock", dashboardDAO.getTotalStock(hospitalId));
            request.setAttribute("lowStockCount", dashboardDAO.getLowStockAlertCount(hospitalId));
            request.setAttribute("pendingCount", dashboardDAO.getPendingRequestCount(hospitalId));
            request.setAttribute("stockList", dashboardDAO.getStockOverview(hospitalId));
            request.setAttribute("alertList", dashboardDAO.getLowStockAlerts(hospitalId));
            request.setAttribute("hospitalEmail", resolveHospitalEmail(session));
            request.setAttribute("notificationCount", notificationDAO.getUnreadCount(hospitalId));
            request.setAttribute("recentNotifications", buildNotificationView(notificationDAO.getRecent(hospitalId)));
        } catch (Exception e) {
            System.err.println("[HospitalDashboardServlet] Error loading dashboard: " + e.getMessage());
            request.setAttribute("dashboardError", "Unable to load dashboard data right now. Please try again later.");
        }

        request.getRequestDispatcher("/hospital/hospital_dashboard.jsp").forward(request, response);
    }

    private Integer resolveHospitalId(HttpSession session) {
        Object userId = session.getAttribute("userId");
        if (userId != null) {
            try {
                return Integer.valueOf(String.valueOf(userId));
            } catch (NumberFormatException e) {
                System.err.println("[HospitalDashboardServlet] Invalid session userId: " + e.getMessage());
            }
        }

        Object currentUser = session.getAttribute("currentUser");
        if (currentUser instanceof User) {
            User user = (User) currentUser;
            if (user.getId() != null) {
                return user.getId().intValue();
            }
        }

        return null;
    }

    private String resolveHospitalEmail(HttpSession session) {
        Object email = session.getAttribute("email");
        if (email != null) {
            return String.valueOf(email);
        }

        Object currentUser = session.getAttribute("currentUser");
        if (currentUser instanceof User) {
            return ((User) currentUser).getEmail();
        }

        return "";
    }

    private List<Map<String, String>> buildNotificationView(List<NotificationDAO.NotificationItem> items) {
        List<Map<String, String>> notifications = new ArrayList<>();
        for (NotificationDAO.NotificationItem item : items) {
            Map<String, String> row = new LinkedHashMap<>();
            row.put("subject", item.getSubject());
            row.put("body", item.getBody());
            row.put("time", item.getCreatedAt() != null ? item.getCreatedAt().format(NOTIFICATION_TIME_FORMAT) : "Recent");
            notifications.add(row);
        }
        return notifications;
    }

    private void redirectAfterNotificationRead(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String returnUrl = request.getParameter("returnUrl");
        if (returnUrl != null && returnUrl.startsWith(request.getContextPath() + "/hospital")) {
            response.sendRedirect(returnUrl);
            return;
        }
        response.sendRedirect(request.getContextPath() + "/hospital/dashboard");
    }
}
