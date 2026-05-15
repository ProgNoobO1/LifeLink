package com.lifelink.servlet;

import com.lifelink.dao.BloodRequestDAO;
import com.lifelink.model.BloodRequest;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

public class RequestActionServlet extends HttpServlet {

    private final BloodRequestDAO requestDAO = new BloodRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp?error=Please login first");
            return;
        }

        User admin = (User) session.getAttribute("currentUser");
        if (admin.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String idParam = req.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/requests?error=Invalid request");
            return;
        }

        long requestId;
        try {
            requestId = Long.parseLong(idParam);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/requests?error=Invalid request ID");
            return;
        }

        BloodRequest request = requestDAO.findById(requestId);
        if (request == null) {
            resp.sendRedirect(req.getContextPath() + "/admin/requests?error=Request not found");
            return;
        }

        req.setAttribute("requestDetail", request);
        req.getRequestDispatcher("/views/Admin/adminRequestDetail.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp?error=Please login first");
            return;
        }

        User admin = (User) session.getAttribute("currentUser");
        if (admin.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String action = req.getParameter("action");
        String idParam = req.getParameter("id");

        if (idParam == null || idParam.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/admin/requests?error=Invalid request");
            return;
        }

        long requestId;
        try {
            requestId = Long.parseLong(idParam);
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/requests?error=Invalid request ID");
            return;
        }

        boolean success = false;
        String message = "";

        if ("approve".equalsIgnoreCase(action)) {
            success = requestDAO.updateStatus(requestId, BloodRequest.Status.APPROVED);
            message = success ? "Request approved successfully." : "Failed to approve request.";
        } else if ("reject".equalsIgnoreCase(action)) {
            success = requestDAO.updateStatus(requestId, BloodRequest.Status.REJECTED);
            message = success ? "Request rejected successfully." : "Failed to reject request.";
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/requests?error=Invalid action");
            return;
        }

        resp.sendRedirect(req.getContextPath() + "/admin/requests?" + (success ? "success=" : "error=") + java.net.URLEncoder.encode(message, "UTF-8"));
    }
}
