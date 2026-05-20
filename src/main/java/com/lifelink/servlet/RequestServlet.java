package com.lifelink.servlet;

import com.lifelink.dao.NotificationDAO;
import com.lifelink.dao.RequestDAO;
import com.lifelink.dao.RequestDAO.CreateRequestData;
import com.lifelink.dao.RequestDetailDAO;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.Locale;
import java.util.Map;

@WebServlet(urlPatterns = {"/recipient/create-request", "/recipient/requests", "/recipient/request-detail"})
public class RequestServlet extends HttpServlet {

    private static final int MAX_NAME_LENGTH = 150;
    private static final int MAX_HOSPITAL_LENGTH = 200;
    private final RequestDAO requestDAO = new RequestDAO();
    private final RequestDetailDAO requestDetailDAO = new RequestDetailDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User currentUser = getCurrentUser(session);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRole() != User.Role.RECIPIENT) {
            resp.sendRedirect(req.getContextPath() + "/403");
            return;
        }

        if ("cancel".equals(req.getParameter("action"))) {
            handleCancel(req, resp, session, currentUser);
            return;
        }
        if ("complete".equals(req.getParameter("action"))) {
            handleComplete(req, resp, session, currentUser);
            return;
        }
        if ("markNotificationsRead".equals(req.getParameter("action"))) {
            handleMarkNotificationsRead(req, resp, session, currentUser);
            return;
        }

        String csrfFromSession = (String) session.getAttribute("csrfToken");
        String csrfFromRequest = req.getParameter("csrfToken");
        if (csrfFromSession == null || csrfFromRequest == null || !csrfFromSession.equals(csrfFromRequest)) {
            forwardWithError(req, resp, "Your session expired. Please reload the form and try again.");
            return;
        }

        try {
            CreateRequestData data = validateRequest(req, currentUser.getId());
            if (!requestDAO.bloodGroupExists(data.getBloodGroupId())) {
                forwardWithError(req, resp, "Please select a valid blood group.");
                return;
            }

            long requestId = requestDAO.createRequest(data);
            session.removeAttribute("csrfToken");
            session.setAttribute("requestSuccess", "Blood request #" + requestId + " submitted successfully.");
            resp.sendRedirect(req.getContextPath() + "/recipient/requests");
        } catch (IllegalArgumentException e) {
            forwardWithError(req, resp, e.getMessage());
        } catch (SQLException e) {
            System.err.println("[RequestServlet] Error creating blood request: " + e.getMessage());
            e.printStackTrace(System.err);
            forwardWithError(req, resp, "We could not submit your request right now. Please try again shortly.");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = getCurrentUser(session);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRole() != User.Role.RECIPIENT) {
            resp.sendRedirect(req.getContextPath() + "/403");
            return;
        }

        try {
            if (req.getServletPath().contains("/request-detail")) {
                showRequestDetail(req, resp, currentUser);
                return;
            }

            Map<String, Integer> requestCounts = requestDAO.countRequestsByStatus(currentUser.getId());
            List<RequestDAO.RequestListItem> requests = requestDAO.findRequestsByRecipient(currentUser.getId());
            req.setAttribute("requestCounts", requestCounts);
            req.setAttribute("requests", requests);
            req.setAttribute("currentUser", currentUser);
            req.getRequestDispatcher("/views/recipient/my_requests.jsp").forward(req, resp);
        } catch (SQLException e) {
            System.err.println("[RequestServlet] Error loading recipient requests: " + e.getMessage());
            e.printStackTrace(System.err);
            req.setAttribute("requestListError", "Unable to load your requests right now. Please try again shortly.");
            req.getRequestDispatcher("/views/recipient/my_requests.jsp").forward(req, resp);
        }
    }

    private void showRequestDetail(HttpServletRequest req, HttpServletResponse resp, User currentUser)
            throws ServletException, IOException, SQLException {
        long requestId;
        try {
            requestId = Long.parseLong(clean(req.getParameter("id")));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/recipient/requests");
            return;
        }

        RequestDetailDAO.RequestDetail detail = requestDetailDAO.findByIdForRecipient(requestId, currentUser.getId());
        if (detail == null) {
            resp.sendRedirect(req.getContextPath() + "/recipient/requests");
            return;
        }

        List<RequestDetailDAO.MatchedResponder> responders = requestDetailDAO.findAcceptedResponders(requestId);
        int unreadCount = notificationDAO.getUnreadCount(currentUser.getId().intValue());
        List<NotificationDAO.NotificationItem> recentNotifications = notificationDAO.getRecent(currentUser.getId().intValue());
        req.setAttribute("requestDetail", detail);
        req.setAttribute("matchedResponders", responders);
        req.setAttribute("unreadNotificationCount", unreadCount);
        req.setAttribute("recentNotifications", recentNotifications);
        req.setAttribute("currentUser", currentUser);
        req.getRequestDispatcher("/views/recipient/request_detail.jsp").forward(req, resp);
    }

    private User getCurrentUser(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object user = session.getAttribute("currentUser");
        return user instanceof User ? (User) user : null;
    }

    private CreateRequestData validateRequest(HttpServletRequest req, long requesterId) {
        String patientName = clean(req.getParameter("patientName"));
        String hospitalName = clean(req.getParameter("hospitalName"));
        String bloodGroupRaw = clean(req.getParameter("bloodGroupId"));
        String unitsRaw = clean(req.getParameter("unitsNeeded"));
        String urgencyRaw = clean(req.getParameter("urgencyLevel"));

        if (patientName.isEmpty()) {
            throw new IllegalArgumentException("Patient name is required.");
        }
        if (patientName.length() > MAX_NAME_LENGTH) {
            throw new IllegalArgumentException("Patient name must be 150 characters or fewer.");
        }
        if (hospitalName.isEmpty()) {
            throw new IllegalArgumentException("Hospital name is required.");
        }
        if (hospitalName.length() > MAX_HOSPITAL_LENGTH) {
            throw new IllegalArgumentException("Hospital name must be 200 characters or fewer.");
        }

        int bloodGroupId = parsePositiveInt(bloodGroupRaw, "Please select a blood group.");
        int unitsNeeded = parsePositiveInt(unitsRaw, "Units needed must be a positive number.");
        if (unitsNeeded > 20) {
            throw new IllegalArgumentException("Units needed must be 20 or fewer.");
        }

        String urgencyLabel = normalizeUrgencyLabel(urgencyRaw);
        String dbUrgency = toDatabaseUrgency(urgencyLabel);

        CreateRequestData data = new CreateRequestData();
        data.setRequesterId(requesterId);
        data.setPatientName(patientName);
        data.setHospitalName(hospitalName);
        data.setBloodGroupId(bloodGroupId);
        data.setUnitsNeeded(unitsNeeded);
        data.setUrgency(dbUrgency);
        data.setUrgencyLabel(urgencyLabel);
        return data;
    }

    private int parsePositiveInt(String value, String errorMessage) {
        try {
            int parsed = Integer.parseInt(value);
            if (parsed > 0) {
                return parsed;
            }
        } catch (NumberFormatException ignored) {
            // Fall through to the friendly validation message.
        }
        throw new IllegalArgumentException(errorMessage);
    }

    private String normalizeUrgencyLabel(String urgencyRaw) {
        String value = urgencyRaw.toLowerCase(Locale.ROOT);
        if ("critical".equals(value) || "high".equals(value) || "medium".equals(value) || "low".equals(value)) {
            return value;
        }
        throw new IllegalArgumentException("Please select an urgency level.");
    }

    private String toDatabaseUrgency(String urgencyLabel) {
        if ("critical".equals(urgencyLabel)) {
            return "critical";
        }
        if ("high".equals(urgencyLabel)) {
            return "urgent";
        }
        return "normal";
    }

    private String clean(String value) {
        return value == null ? "" : value.trim().replaceAll("\\s+", " ");
    }

    private void handleCancel(HttpServletRequest req, HttpServletResponse resp, HttpSession session, User currentUser)
            throws IOException {
        String csrfFromSession = (String) session.getAttribute("csrfToken");
        String csrfFromRequest = req.getParameter("csrfToken");
        if (csrfFromSession == null || csrfFromRequest == null || !csrfFromSession.equals(csrfFromRequest)) {
            session.setAttribute("requestError", "Your session expired. Please try cancelling again.");
            resp.sendRedirect(req.getContextPath() + "/recipient/requests");
            return;
        }

        try {
            long requestId = Long.parseLong(clean(req.getParameter("requestId")));
            boolean cancelled = requestDAO.cancelPendingRequest(requestId, currentUser.getId());
            if (cancelled) {
                notifyRespondersOfCancellation(requestId);
                session.setAttribute("requestSuccess", "Request #REQ-" + String.format("%03d", requestId) + " was cancelled.");
            } else {
                session.setAttribute("requestError", "Only pending requests can be cancelled.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("requestError", "Invalid request selected.");
        } catch (SQLException e) {
            System.err.println("[RequestServlet] Error cancelling request: " + e.getMessage());
            e.printStackTrace(System.err);
            session.setAttribute("requestError", "We could not cancel that request right now. Please try again shortly.");
        }
        String returnTo = clean(req.getParameter("returnTo"));
        if ("detail".equals(returnTo)) {
            resp.sendRedirect(req.getContextPath() + "/recipient/request-detail?id=" + clean(req.getParameter("requestId")));
        } else {
            resp.sendRedirect(req.getContextPath() + "/recipient/requests");
        }
    }

    private void handleComplete(HttpServletRequest req, HttpServletResponse resp, HttpSession session, User currentUser)
            throws IOException {
        String csrfFromSession = (String) session.getAttribute("csrfToken");
        String csrfFromRequest = req.getParameter("csrfToken");
        String requestIdRaw = clean(req.getParameter("requestId"));
        if (csrfFromSession == null || csrfFromRequest == null || !csrfFromSession.equals(csrfFromRequest)) {
            session.setAttribute("requestError", "Your session expired. Please try again.");
            resp.sendRedirect(req.getContextPath() + "/recipient/request-detail?id=" + requestIdRaw);
            return;
        }

        try {
            long requestId = Long.parseLong(requestIdRaw);
            boolean completed = requestDetailDAO.completeAcceptedRequest(requestId, currentUser.getId());
            if (completed) {
                notifyRespondersOfCompletion(requestId);
                session.setAttribute("requestSuccess", "Request #REQ-" + String.format("%03d", requestId) + " was marked completed.");
            } else {
                session.setAttribute("requestError", "Only accepted requests can be marked completed.");
            }
        } catch (NumberFormatException e) {
            session.setAttribute("requestError", "Invalid request selected.");
        } catch (SQLException e) {
            System.err.println("[RequestServlet] Error completing request: " + e.getMessage());
            e.printStackTrace(System.err);
            session.setAttribute("requestError", "We could not complete that request right now. Please try again shortly.");
        }
        resp.sendRedirect(req.getContextPath() + "/recipient/request-detail?id=" + requestIdRaw);
    }

    private void handleMarkNotificationsRead(HttpServletRequest req, HttpServletResponse resp, HttpSession session, User currentUser)
            throws IOException {
        String csrfFromSession = (String) session.getAttribute("csrfToken");
        String csrfFromRequest = req.getParameter("csrfToken");
        String requestIdRaw = clean(req.getParameter("requestId"));
        String returnUrl = clean(req.getParameter("returnUrl"));
        if (csrfFromSession == null || csrfFromRequest == null || !csrfFromSession.equals(csrfFromRequest)) {
            redirectAfterNotificationRead(req, resp, requestIdRaw, returnUrl);
            return;
        }
        try {
            notificationDAO.markAllAsRead(currentUser.getId().intValue());
        } catch (SQLException e) {
            System.err.println("[RequestServlet] Error marking notifications read: " + e.getMessage());
        }
        redirectAfterNotificationRead(req, resp, requestIdRaw, returnUrl);
    }

    private void redirectAfterNotificationRead(HttpServletRequest req, HttpServletResponse resp, String requestIdRaw, String returnUrl)
            throws IOException {
        if (returnUrl != null && returnUrl.startsWith(req.getContextPath() + "/")) {
            if (returnUrl.contains("/views/recipient/recipient_dashboard.jsp")) {
                resp.sendRedirect(req.getContextPath() + "/recipient/dashboard");
                return;
            }
            resp.sendRedirect(returnUrl);
            return;
        }
        if (requestIdRaw != null && !requestIdRaw.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/recipient/request-detail?id=" + requestIdRaw);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/recipient/requests");
    }

    private void notifyRespondersOfCancellation(long requestId) throws SQLException {
        List<Long> responderIds = requestDetailDAO.findAcceptedResponderIds(requestId);
        for (Long responderId : responderIds) {
            notificationDAO.insertNotification(
                responderId.intValue(),
                "Blood request has been cancelled",
                "Request #REQ-" + requestId + " has been cancelled by the recipient"
            );
        }
    }

    private void notifyRespondersOfCompletion(long requestId) throws SQLException {
        List<Long> responderIds = requestDetailDAO.findAcceptedResponderIds(requestId);
        for (Long responderId : responderIds) {
            notificationDAO.insertNotification(
                responderId.intValue(),
                "Thank you for your donation!",
                "The recipient has confirmed donation for request #REQ-" + requestId
            );
        }
    }

    private void forwardWithError(HttpServletRequest req, HttpServletResponse resp, String message)
            throws ServletException, IOException {
        req.setAttribute("error", message);
        req.setAttribute("patientNameValue", req.getParameter("patientName"));
        req.setAttribute("bloodGroupValue", req.getParameter("bloodGroupId"));
        req.setAttribute("unitsNeededValue", req.getParameter("unitsNeeded"));
        req.setAttribute("hospitalNameValue", req.getParameter("hospitalName"));
        req.setAttribute("urgencyLevelValue", req.getParameter("urgencyLevel"));
        req.getRequestDispatcher("/views/recipient/create_request.jsp").forward(req, resp);
    }
}
