package com.lifelink.servlet;

import com.lifelink.dao.UserDAO;
import com.lifelink.model.User;
import com.lifelink.service.AuthException;
import com.lifelink.service.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

public class ApproveUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        User admin = (User) session.getAttribute("currentUser");
        if (admin == null || admin.getRole() == null || admin.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String idParam = req.getParameter("id");
        try {
            Long userId = Long.parseLong(idParam);
            User user = userDAO.findById(userId);
            if (user == null) {
                resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode("User not found.", "UTF-8"));
                return;
            }

            // Approve: set active + approved
            user.setStatus(User.Status.ACTIVE);
            user.setApproved(true);
            boolean updated = userDAO.update(user);

            if (updated) {
                // Send approval email
                String subject = "Your LifeLink Registration Has Been Approved";
                String body = EmailService.buildHtmlBody(
                    "Registration Approved",
                    "Hi " + user.getFullName() + ",\n\nYour registration on LifeLink has been approved by an administrator. You can now log in and access all features.",
                    null,
                    null
                );
                EmailService.sendEmail(user.getEmail(), subject, body);

                session.setAttribute("successMessage", "User approved successfully! Notification email sent.");
                resp.sendRedirect(req.getContextPath() + "/admin/users");
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode("Failed to approve user.", "UTF-8"));
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode("Invalid user ID.", "UTF-8"));
        }
    }
}
