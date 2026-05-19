package com.lifelink.servlet;

import com.lifelink.dao.UserDAO;
import com.lifelink.model.User;
import com.lifelink.service.AuthException;
import com.lifelink.model.Notification;
import com.lifelink.service.EmailService;
import com.lifelink.service.NotificationService;
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

            boolean updated;
            String message;
            String subject;
            String body;

            String notifType;
            String notifTitle;
            String notifMessage;
            String notifLink = req.getContextPath() + "/admin/requests/action?id=" + user.getId();

            if (user.getStatus() == User.Status.ACTIVE) {
                // Deactivate
                user.setStatus(User.Status.INACTIVE);
                user.setApproved(false);
                updated = userDAO.update(user);
                message = updated ? "User deactivated successfully!" : "Failed to deactivate user.";
                notifType = "USER_DEACTIVATED";
                notifTitle = "User Deactivated";
                notifMessage = user.getFullName() + " (" + user.getEmail() + ") has been deactivated.";
            } else {
                // Activate (from INACTIVE or SUSPENDED)
                user.setStatus(User.Status.ACTIVE);
                user.setApproved(true);
                updated = userDAO.update(user);
                message = updated ? "User activated successfully! Notification email sent." : "Failed to activate user.";
                notifType = "USER_ACTIVATED";
                notifTitle = "User Activated";
                notifMessage = user.getFullName() + " (" + user.getEmail() + ") has been activated.";

                if (updated) {
                    subject = "Your LifeLink Registration Has Been Approved";
                    body = EmailService.buildHtmlBody(
                        "Registration Approved",
                        "Hi " + user.getFullName() + ",<br><br>Your registration on LifeLink has been approved by an administrator. You can now log in and access all features.",
                        null,
                        null
                    );
                    EmailService.sendEmail(user.getEmail(), subject, body);
                }
            }

            if (updated) {
                Notification notification = new Notification(notifType, notifTitle, notifMessage, notifLink);
                NotificationService.getInstance().broadcast(notification);
            }

            if (updated) {
                session.setAttribute("successMessage", message);
                resp.sendRedirect(req.getContextPath() + "/admin/users?ts=" + System.currentTimeMillis());
            } else {
                resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode(message, "UTF-8") + "&ts=" + System.currentTimeMillis());
            }
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode("Invalid user ID.", "UTF-8"));
        }
    }
}
