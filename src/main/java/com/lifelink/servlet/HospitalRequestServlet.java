package com.lifelink.servlet;

import com.lifelink.dao.BloodStockDAO;
import com.lifelink.dao.HospitalDashboardDAO;
import com.lifelink.dao.HospitalRequestDAO;
import com.lifelink.dao.NotificationDAO;
import com.lifelink.model.User;
import com.lifelink.utils.DBConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

@WebServlet({"/hospital/requests", "/hospital/requests/create"})
public class HospitalRequestServlet extends HttpServlet {

    private static final int PAGE_SIZE = 7;
    private static final int MAX_NOTES_LENGTH = 500;

    private final HospitalRequestDAO requestDAO = new HospitalRequestDAO();
    private final HospitalDashboardDAO dashboardDAO = new HospitalDashboardDAO();
    private final BloodStockDAO bloodStockDAO = new BloodStockDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer hospitalId = requireHospital(session, request, response);
        if (hospitalId == null) {
            return;
        }

        String action = valueOrDefault(request.getParameter("action"), "list");
        String servletPath = request.getServletPath();

        if ("/hospital/requests/create".equals(servletPath) || "create".equalsIgnoreCase(action)) {
            showCreateForm(request, response, hospitalId);
            return;
        }

        if ("detail".equalsIgnoreCase(action)) {
            showRequestDetail(request, response, hospitalId);
            return;
        }

        showRequestList(request, response, hospitalId);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Integer hospitalId = requireHospital(session, request, response);
        if (hospitalId == null) {
            return;
        }

        String action = request.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            handleCreate(request, response, hospitalId);
            return;
        }

        Integer requestId = parseInteger(request.getParameter("id"));
        if (requestId == null) {
            response.sendRedirect(request.getContextPath() + "/hospital/requests?error=transaction_failed");
            return;
        }

        if ("approve".equalsIgnoreCase(action)) {
            handleApprove(request, response, hospitalId, requestId);
            return;
        }

        if ("reject".equalsIgnoreCase(action)) {
            handleReject(request, response, hospitalId, requestId);
            return;
        }

        response.sendRedirect(request.getContextPath() + "/hospital/requests");
    }

    private void showRequestList(HttpServletRequest request, HttpServletResponse response, int hospitalId)
            throws ServletException, IOException {
        int currentPage = parseInteger(request.getParameter("page")) != null ? Math.max(1, parseInteger(request.getParameter("page"))) : 1;
        Integer bloodGroupFilter = parseInteger(request.getParameter("bloodGroup"));

        List<Map<String, Object>> incomingRequests = requestDAO.getIncomingRequests(hospitalId, currentPage, PAGE_SIZE, bloodGroupFilter);
        int totalIncomingCount = requestDAO.getIncomingRequestsCount(hospitalId, bloodGroupFilter);
        int totalPages = Math.max(1, (int) Math.ceil(totalIncomingCount / (double) PAGE_SIZE));

        request.setAttribute("incomingRequests", incomingRequests);
        request.setAttribute("incomingCount", totalIncomingCount);
        request.setAttribute("myRequests", requestDAO.getMyRequests(hospitalId));
        request.setAttribute("summaryStats", requestDAO.getSummaryStats(hospitalId));
        request.setAttribute("pendingCount", dashboardDAO.getPendingRequestCount(hospitalId));
        request.setAttribute("lowStockCount", dashboardDAO.getLowStockAlertCount(hospitalId));
        request.setAttribute("notificationCount", getNotificationCount(hospitalId));
        request.setAttribute("hospitalName", dashboardDAO.getHospitalName(hospitalId));
        request.setAttribute("hospitalEmail", resolveHospitalEmail(request.getSession(false)));
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("pageSize", PAGE_SIZE);
        request.setAttribute("bloodGroupFilter", bloodGroupFilter);
        request.setAttribute("filterGroups", bloodStockDAO.getAllBloodGroups());

        request.getRequestDispatcher("/hospital/hospital_requests.jsp").forward(request, response);
    }

    private void showCreateForm(HttpServletRequest request, HttpServletResponse response, int hospitalId)
            throws ServletException, IOException {
        request.setAttribute("bloodGroups", bloodStockDAO.getAllBloodGroups());
        request.setAttribute("sidebarStock", bloodStockDAO.getCurrentStockSidebar(hospitalId));
        request.setAttribute("pendingCount", dashboardDAO.getPendingRequestCount(hospitalId));
        request.setAttribute("lowStockCount", dashboardDAO.getLowStockAlertCount(hospitalId));
        request.setAttribute("notificationCount", getNotificationCount(hospitalId));
        request.setAttribute("hospitalName", dashboardDAO.getHospitalName(hospitalId));
        request.setAttribute("hospitalEmail", resolveHospitalEmail(request.getSession(false)));
        request.getRequestDispatcher("/hospital/create_request.jsp").forward(request, response);
    }

    private void showRequestDetail(HttpServletRequest request, HttpServletResponse response, int hospitalId)
            throws ServletException, IOException {
        Integer requestId = parseInteger(request.getParameter("id"));
        if (requestId == null) {
            response.sendRedirect(request.getContextPath() + "/hospital/requests");
            return;
        }

        Map<String, Object> requestDetail = requestDAO.getRequestById(requestId);
        if (requestDetail == null) {
            response.sendRedirect(request.getContextPath() + "/hospital/requests");
            return;
        }

        Map<String, Object> availableStock = requestDAO.getStockForBloodGroup(hospitalId, ((Number) requestDetail.get("bloodGroupId")).intValue());
        if (availableStock == null) {
            availableStock = new LinkedHashMap<>();
            availableStock.put("stockId", null);
            availableStock.put("units", 0);
            availableStock.put("threshold", 5);
            availableStock.put("status", "Low Stock");
        }

        int availableUnits = ((Number) availableStock.get("units")).intValue();
        int requestedUnits = ((Number) requestDetail.get("units")).intValue();
        availableStock.put("remaining", availableUnits - requestedUnits);
        availableStock.put("canFulfill", availableUnits >= requestedUnits);

        request.setAttribute("requestDetail", requestDetail);
        request.setAttribute("availableStock", availableStock);
        request.setAttribute("otherStock", requestDAO.getOtherStock(hospitalId, ((Number) requestDetail.get("bloodGroupId")).intValue()));
        request.setAttribute("activityTimeline", buildTimeline(requestDetail, dashboardDAO.getHospitalName(hospitalId)));
        request.setAttribute("requestSummary", buildRequestSummary(requestDetail));
        request.setAttribute("pendingCount", dashboardDAO.getPendingRequestCount(hospitalId));
        request.setAttribute("lowStockCount", dashboardDAO.getLowStockAlertCount(hospitalId));
        request.setAttribute("notificationCount", getNotificationCount(hospitalId));
        request.setAttribute("hospitalName", dashboardDAO.getHospitalName(hospitalId));
        request.setAttribute("hospitalEmail", resolveHospitalEmail(request.getSession(false)));

        request.getRequestDispatcher("/hospital/request_detail.jsp").forward(request, response);
    }

    private void handleApprove(HttpServletRequest request, HttpServletResponse response, int hospitalId, int requestId)
            throws IOException {
        Map<String, Object> requestDetail = requestDAO.getRequestById(requestId);
        if (requestDetail == null || !"pending".equalsIgnoreCase(String.valueOf(requestDetail.get("status")))) {
            response.sendRedirect(request.getContextPath() + "/hospital/requests?action=detail&id=" + requestId + "&error=already_actioned");
            return;
        }

        Map<String, Object> stock = requestDAO.getStockForBloodGroup(hospitalId, ((Number) requestDetail.get("bloodGroupId")).intValue());
        int unitsNeeded = ((Number) requestDetail.get("units")).intValue();
        if (stock == null || ((Number) stock.get("units")).intValue() < unitsNeeded) {
            response.sendRedirect(request.getContextPath() + "/hospital/requests?action=detail&id=" + requestId + "&error=insufficient_stock");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Existing BloodStockDAO manages its own connection, so this decrement happens through the shared DAO API
            // before the rest of the transaction is committed.
            boolean stockUpdated = bloodStockDAO.updateStock(
                    ((Number) stock.get("stockId")).intValue(),
                    hospitalId,
                    ((Number) requestDetail.get("bloodGroupId")).intValue(),
                    ((Number) stock.get("units")).intValue() - unitsNeeded,
                    LocalDate.now(),
                    LocalDate.now().plusDays(35)
            );

            if (!stockUpdated) {
                throw new SQLException("Unable to decrement hospital stock.");
            }

            int remainingUnits = ((Number) stock.get("units")).intValue() - unitsNeeded;
            int threshold = ((Number) stock.get("threshold")).intValue();
            if (remainingUnits <= threshold) {
                dashboardDAO.createOrUpdateLowStockAlert(
                        hospitalId,
                        ((Number) requestDetail.get("bloodGroupId")).intValue(),
                        remainingUnits
                );
                String subject = "Low stock alert: " + requestDetail.get("bloodGroup");
                String body = "Your " + requestDetail.get("bloodGroup") + " stock is at " + remainingUnits +
                        " units after approving " + requestDetail.get("formattedId") + ". Please restock soon.";
                if (!notificationDAO.hasQueuedNotification(hospitalId, subject)) {
                    notificationDAO.insertNotification(hospitalId, subject, body);
                }
            }

            requestDAO.insertResponse(conn, requestId, hospitalId, "accepted", unitsNeeded);
            requestDAO.updateRequestStatus(conn, requestId, "accepted");
            requestDAO.queueEmailNotification(
                    conn,
                    ((Number) requestDetail.get("requesterId")).intValue(),
                    "Your blood request has been approved",
                    "Request " + requestDetail.get("formattedId") + " for " + unitsNeeded + " units of " +
                            requestDetail.get("bloodGroup") + " has been approved by " +
                            dashboardDAO.getHospitalName(hospitalId) + ". Units will be dispatched shortly."
            );

            conn.commit();
            queueHospitalNotification(hospitalId,
                    "Request approved: " + requestDetail.get("formattedId"),
                    "You approved " + unitsNeeded + " units of " + requestDetail.get("bloodGroup") +
                            " for " + requestDetail.get("requesterName") + ".");
            response.sendRedirect(request.getContextPath() + "/hospital/requests?action=detail&id=" + requestId + "&success=approved");
        } catch (SQLException e) {
            rollbackQuietly(conn);
            System.err.println("[HospitalRequestServlet] handleApprove: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/hospital/requests?action=detail&id=" + requestId + "&error=transaction_failed");
        } finally {
            resetAutoCommitAndClose(conn);
        }
    }

    private void handleReject(HttpServletRequest request, HttpServletResponse response, int hospitalId, int requestId)
            throws IOException {
        Map<String, Object> requestDetail = requestDAO.getRequestById(requestId);
        if (requestDetail == null || !"pending".equalsIgnoreCase(String.valueOf(requestDetail.get("status")))) {
            response.sendRedirect(request.getContextPath() + "/hospital/requests?action=detail&id=" + requestId + "&error=already_actioned");
            return;
        }

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            requestDAO.insertResponse(conn, requestId, hospitalId, "rejected", 0);
            requestDAO.updateRequestStatus(conn, requestId, "rejected");
            requestDAO.queueEmailNotification(
                    conn,
                    ((Number) requestDetail.get("requesterId")).intValue(),
                    "Your blood request has been rejected",
                    "Request " + requestDetail.get("formattedId") + " has been rejected by " +
                            dashboardDAO.getHospitalName(hospitalId) + "."
            );

            conn.commit();
            queueHospitalNotification(hospitalId,
                    "Request rejected: " + requestDetail.get("formattedId"),
                    "You rejected the request from " + requestDetail.get("requesterName") +
                            " for " + requestDetail.get("bloodGroup") + ".");
            response.sendRedirect(request.getContextPath() + "/hospital/requests?action=detail&id=" + requestId + "&success=rejected");
        } catch (SQLException e) {
            rollbackQuietly(conn);
            System.err.println("[HospitalRequestServlet] handleReject: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/hospital/requests?action=detail&id=" + requestId + "&error=transaction_failed");
        } finally {
            resetAutoCommitAndClose(conn);
        }
    }

    private void handleCreate(HttpServletRequest request, HttpServletResponse response, int hospitalId)
            throws ServletException, IOException {
        Map<String, String> errors = new LinkedHashMap<>();
        Map<String, Object> formData = new LinkedHashMap<>();

        Integer bloodGroupId = parseInteger(request.getParameter("bloodGroupId"));
        Integer unitsNeeded = parseInteger(request.getParameter("unitsNeeded"));
        String urgency = valueOrDefault(request.getParameter("urgency"), "").toLowerCase();
        String notes = valueOrDefault(request.getParameter("notes"), "");

        formData.put("bloodGroupId", bloodGroupId);
        formData.put("unitsNeeded", request.getParameter("unitsNeeded"));
        formData.put("urgency", urgency);
        formData.put("notes", notes);

        if (bloodGroupId == null || bloodGroupId < 1 || bloodGroupId > 8) {
            errors.put("bloodGroupId", "Please select a valid blood group.");
        }

        if (unitsNeeded == null || unitsNeeded < 1 || unitsNeeded > 20) {
            errors.put("unitsNeeded", "Units needed must be between 1 and 20.");
        }

        if (!"normal".equals(urgency) && !"urgent".equals(urgency) && !"critical".equals(urgency)) {
            errors.put("urgency", "Please choose a valid urgency level.");
        }

        if (notes.length() > MAX_NOTES_LENGTH) {
            errors.put("notes", "Notes must be 500 characters or fewer.");
        }

        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("formData", formData);
            request.setAttribute("formError", "Please correct the highlighted fields and try again.");
            showCreateForm(request, response, hospitalId);
            return;
        }

        boolean created = requestDAO.createRequest(hospitalId, bloodGroupId, unitsNeeded, urgency, notes);
        if (!created) {
            request.setAttribute("errors", errors);
            request.setAttribute("formData", formData);
            request.setAttribute("formError", "Unable to create the request right now. Please try again.");
            showCreateForm(request, response, hospitalId);
            return;
        }

        queueHospitalNotification(
                hospitalId,
                "Request submitted: " + unitsNeeded + " units of " + resolveBloodGroupName(bloodGroupId),
                "Your hospital request for " + unitsNeeded + " units of " + resolveBloodGroupName(bloodGroupId) +
                        " has been created with " + urgency + " urgency."
        );
        response.sendRedirect(request.getContextPath() + "/hospital/requests?success=created");
    }

    private List<Map<String, Object>> buildTimeline(Map<String, Object> requestDetail, String hospitalName) {
        List<Map<String, Object>> timeline = new ArrayList<>();
        Timestamp requestedAt = (Timestamp) requestDetail.get("requestedAtRaw");
        Timestamp updatedAt = (Timestamp) requestDetail.get("updatedAtRaw");
        String requesterName = String.valueOf(requestDetail.get("requesterName"));
        String status = String.valueOf(requestDetail.get("status"));

        timeline.add(timelineItem("Request Submitted", formatTimelineTime(requestedAt),
                requesterName + " submitted this request.", true, false));

        LocalDateTime reviewTime = requestedAt != null ? requestedAt.toLocalDateTime().plusMinutes(45) : LocalDateTime.now();
        timeline.add(timelineItem("Under Review", formatTimelineTime(Timestamp.valueOf(reviewTime)),
                hospitalName + " reviewing the request.", true, false));

        if ("pending".equalsIgnoreCase(status)) {
            timeline.add(timelineItem("Awaiting Approval", "Now",
                    "Pending admin decision.", false, true));
            timeline.add(timelineItem("Dispatch", "Pending",
                    "Units dispatched to requester.", false, false));
        } else if ("accepted".equalsIgnoreCase(status)) {
            timeline.add(timelineItem("Approved", formatTimelineTime(updatedAt),
                    "Request approved by " + hospitalName, true, false));
            timeline.add(timelineItem("Dispatch", "Pending",
                    "Units dispatched to requester.", false, false));
        } else if ("rejected".equalsIgnoreCase(status)) {
            timeline.add(timelineItem("Rejected", formatTimelineTime(updatedAt),
                    "Request rejected by " + hospitalName, true, false));
        } else {
            timeline.add(timelineItem("Awaiting Approval", "Pending",
                    "Pending admin decision.", false, false));
        }

        return timeline;
    }

    private Map<String, Object> buildRequestSummary(Map<String, Object> requestDetail) {
        Map<String, Object> summary = new LinkedHashMap<>();
        summary.put("requestId", requestDetail.get("formattedId"));
        summary.put("contact", requestDetail.get("requesterName"));
        summary.put("phone", requestDetail.get("requesterPhone") != null ? requestDetail.get("requesterPhone") : "N/A");
        summary.put("entityType", requestDetail.get("requesterRole"));

        String urgency = String.valueOf(requestDetail.get("urgency"));
        if ("critical".equalsIgnoreCase(urgency)) {
            summary.put("priority", "High");
        } else if ("urgent".equalsIgnoreCase(urgency)) {
            summary.put("priority", "Medium");
        } else {
            summary.put("priority", "Low");
        }
        return summary;
    }

    private Map<String, Object> timelineItem(String stage, String time, String desc, boolean done, boolean active) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("stage", stage);
        item.put("time", time);
        item.put("desc", desc);
        item.put("done", done);
        item.put("active", active);
        return item;
    }

    private String formatTimelineTime(Timestamp timestamp) {
        if (timestamp == null) {
            return "Pending";
        }
        return timestamp.toLocalDateTime().format(DateTimeFormatter.ofPattern("MMM dd, yyyy - hh:mm a"));
    }

    private int getNotificationCount(int hospitalId) {
        try {
            return notificationDAO.getUnreadCount(hospitalId);
        } catch (SQLException e) {
            System.err.println("[HospitalRequestServlet] getNotificationCount: " + e.getMessage());
            return 0;
        }
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
                System.err.println("[HospitalRequestServlet] Invalid session userId: " + e.getMessage());
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

    private Integer parseInteger(String value) {
        if (value == null || value.trim().isEmpty()) {
            return null;
        }
        try {
            return Integer.valueOf(value.trim());
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String valueOrDefault(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value.trim();
    }

    private void rollbackQuietly(Connection connection) {
        if (connection != null) {
            try {
                connection.rollback();
            } catch (SQLException e) {
                System.err.println("[HospitalRequestServlet] rollback: " + e.getMessage());
            }
        }
    }

    private void resetAutoCommitAndClose(Connection connection) {
        if (connection != null) {
            try {
                connection.setAutoCommit(true);
            } catch (SQLException e) {
                System.err.println("[HospitalRequestServlet] reset auto-commit: " + e.getMessage());
            }
            try {
                connection.close();
            } catch (SQLException e) {
                System.err.println("[HospitalRequestServlet] close connection: " + e.getMessage());
            }
        }
    }

    private void queueHospitalNotification(int hospitalId, String subject, String body) {
        try {
            notificationDAO.insertNotification(hospitalId, subject, body);
        } catch (SQLException e) {
            System.err.println("[HospitalRequestServlet] queueHospitalNotification: " + e.getMessage());
        }
    }

    private String resolveBloodGroupName(int bloodGroupId) {
        for (Map<String, Object> group : bloodStockDAO.getAllBloodGroups()) {
            Object id = group.get("id");
            if (id instanceof Number && ((Number) id).intValue() == bloodGroupId) {
                return String.valueOf(group.get("name"));
            }
        }
        return "selected blood group";
    }
}
