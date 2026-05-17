package com.lifelink.servlet;

import com.lifelink.dao.RequestDAO;
import com.lifelink.dao.RequestDAO.CreateRequestData;
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

@WebServlet(urlPatterns = {"/recipient/create-request", "/recipient/requests"})
public class RequestServlet extends HttpServlet {

    private static final int MAX_NAME_LENGTH = 150;
    private static final int MAX_HOSPITAL_LENGTH = 200;
    private final RequestDAO requestDAO = new RequestDAO();

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
        resp.sendRedirect(req.getContextPath() + "/recipient/requests");
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
