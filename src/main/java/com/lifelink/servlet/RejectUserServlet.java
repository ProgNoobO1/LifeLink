package com.lifelink.servlet;

import com.lifelink.dao.UserDAO;
import com.lifelink.model.User;
import com.lifelink.service.AuthException;
import com.lifelink.service.EmailService;
import com.lifelink.model.Notification;
import com.lifelink.service.NotificationService;
import com.lifelink.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

public class RejectUserServlet extends HttpServlet {

    private final UserService userService = new UserService();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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
            if (user != null) {
                // Send rejection email
                String subject = "Your LifeLink Registration Has Been Rejected";
                String body = EmailService.buildHtmlBody(
                    "Registration Rejected",
                    "Hi " + user.getFullName() + ",<br><br>We regret to inform you that your registration on LifeLink has been rejected by an administrator. If you believe this was a mistake, please contact our support team.",
                    null,
                    null
                );
                EmailService.sendEmail(user.getEmail(), subject, body);

                // Update status to SUSPENDED (rejected) instead of deleting
                user.setStatus(User.Status.SUSPENDED);
                user.setApproved(true); // marks as processed/rejected
                userDAO.update(user);

                Notification notification = new Notification(
                    "USER_REJECTED",
                    "User Rejected",
                    user.getFullName() + " (" + user.getEmail() + ") has been rejected.",
                    req.getContextPath() + "/admin/requests/action?id=" + user.getId()
                );
                NotificationService.getInstance().broadcast(notification);
            }
            session.setAttribute("successMessage", "User rejected successfully!");
            resp.sendRedirect(req.getContextPath() + "/admin/requests?ts=" + System.currentTimeMillis());
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/requests?error=" + URLEncoder.encode("Invalid user ID.", "UTF-8"));
        }
    }
}
