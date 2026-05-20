package com.lifelink.servlet;

import com.lifelink.dao.HospitalDashboardDAO;
import com.lifelink.dao.UsageHistoryDAO;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

@WebServlet({"/usage-history", "/hospital/usage"})
public class UsageHistoryServlet extends HttpServlet {

    private static final int PAGE_SIZE = 12;

    private final UsageHistoryDAO usageHistoryDAO = new UsageHistoryDAO();
    private final HospitalDashboardDAO dashboardDAO = new HospitalDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer hospitalId = requireHospital(session, request, response);
        if (hospitalId == null) {
            return;
        }

        String filter = normalizeFilter(request.getParameter("filter"));
        String dateRange = normalizeDateRange(request.getParameter("dateRange"));

        if ("csv".equalsIgnoreCase(request.getParameter("export"))) {
            exportCsv(response, hospitalId, filter, dateRange, request.getParameter("search"));
            return;
        }

        int totalCount = usageHistoryDAO.getTotalCount(hospitalId, filter, dateRange);
        int totalPages = Math.max(1, (int) Math.ceil(totalCount / (double) PAGE_SIZE));
        int currentPage = parsePage(request.getParameter("page"), totalPages);

        request.setAttribute("stats", usageHistoryDAO.getStatCards(hospitalId));
        request.setAttribute("records", usageHistoryDAO.getRecords(hospitalId, filter, dateRange, currentPage));
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("startRecord", totalCount == 0 ? 0 : ((currentPage - 1) * PAGE_SIZE) + 1);
        request.setAttribute("endRecord", Math.min(currentPage * PAGE_SIZE, totalCount));
        request.setAttribute("selectedFilter", filter);
        request.setAttribute("selectedDateRange", dateRange);
        request.setAttribute("pendingCount", dashboardDAO.getPendingRequestCount(hospitalId));
        request.setAttribute("hospitalName", dashboardDAO.getHospitalName(hospitalId));
        request.setAttribute("hospitalEmail", resolveHospitalEmail(session));
        request.setAttribute("notificationCount", usageHistoryDAO.getQueuedNotificationCount(hospitalId));

        request.getRequestDispatcher("/hospital/usage_history.jsp").forward(request, response);
    }

    private void exportCsv(HttpServletResponse response, int hospitalId, String filter, String dateRange, String search)
            throws IOException {
        List<Map<String, Object>> allRecords = usageHistoryDAO.exportCsv(hospitalId, filter, dateRange);

        response.setContentType("text/csv");
        response.setHeader("Content-Disposition", "attachment; filename=\"usage_history.csv\"");

        PrintWriter writer = response.getWriter();
        writer.println("Date,Blood Group,Units,Recipient Name,Verified,Request ID");

        String searchTerm = search == null ? "" : search.trim().toLowerCase();
        for (Map<String, Object> record : allRecords) {
            String searchText = String.valueOf(record.get("searchText"));
            if (!searchTerm.isEmpty() && !searchText.contains(searchTerm)) {
                continue;
            }

            writer.println(
                    escapeCsv(String.valueOf(record.get("donatedAt"))) + "," +
                            escapeCsv(String.valueOf(record.get("bloodGroup"))) + "," +
                            escapeCsv(String.valueOf(record.get("units"))) + "," +
                            escapeCsv(String.valueOf(record.get("recipientName"))) + "," +
                            escapeCsv(Boolean.TRUE.equals(record.get("verified")) ? "Yes" : "No") + "," +
                            escapeCsv(String.valueOf(record.get("requestIdDisplay")))
            );
        }
        writer.flush();
    }

    private String escapeCsv(String value) {
        String safeValue = value == null ? "" : value.replace("\"", "\"\"");
        return "\"" + safeValue + "\"";
    }

    private Integer requireHospital(HttpSession session, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        Object roleValue = session.getAttribute("role");
        if (roleValue == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        if (!"hospital".equalsIgnoreCase(String.valueOf(roleValue))) {
            response.sendRedirect(request.getContextPath() + "/403");
            return null;
        }

        Object userIdValue = session.getAttribute("userId");
        if (userIdValue != null) {
            try {
                return Integer.valueOf(String.valueOf(userIdValue));
            } catch (NumberFormatException e) {
                System.err.println("[UsageHistoryServlet] Invalid session userId: " + e.getMessage());
            }
        }

        Object currentUser = session.getAttribute("currentUser");
        if (currentUser instanceof User) {
            User user = (User) currentUser;
            if (user.getId() != null) {
                return user.getId().intValue();
            }
        }

        response.sendRedirect(request.getContextPath() + "/login");
        return null;
    }

    private String resolveHospitalEmail(HttpSession session) {
        if (session == null) {
            return "";
        }

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

    private int parsePage(String pageValue, int totalPages) {
        int page = 1;
        if (pageValue != null && !pageValue.trim().isEmpty()) {
            try {
                page = Integer.parseInt(pageValue.trim());
            } catch (NumberFormatException e) {
                page = 1;
            }
        }
        if (page < 1) {
            return 1;
        }
        return Math.min(page, totalPages);
    }

    private String normalizeFilter(String filter) {
        if ("verified".equalsIgnoreCase(filter)) {
            return "verified";
        }
        if ("unverified".equalsIgnoreCase(filter)) {
            return "unverified";
        }
        if ("with_request".equalsIgnoreCase(filter)) {
            return "with_request";
        }
        if ("without_request".equalsIgnoreCase(filter)) {
            return "without_request";
        }
        return "all";
    }

    private String normalizeDateRange(String dateRange) {
        if ("last_month".equalsIgnoreCase(dateRange)) {
            return "last_month";
        }
        if ("last_3_months".equalsIgnoreCase(dateRange)) {
            return "last_3_months";
        }
        if ("last_6_months".equalsIgnoreCase(dateRange)) {
            return "last_6_months";
        }
        if ("this_year".equalsIgnoreCase(dateRange)) {
            return "this_year";
        }
        if ("all_time".equalsIgnoreCase(dateRange)) {
            return "all_time";
        }
        return "this_month";
    }
}
