package com.lifelink.servlet;

import com.lifelink.dao.UserDAO;
import com.lifelink.model.User;
import com.lifelink.service.AuthException;
import com.lifelink.service.EmailService;
import com.lifelink.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

public class DeleteUserServlet extends HttpServlet {

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
                // Send rejection email before deleting
                String subject = "Your LifeLink Registration Has Been Rejected";
                String body = EmailService.buildHtmlBody(
                    "Registration Rejected",
                    "Hi " + user.getFullName() + ",\n\nWe regret to inform you that your registration on LifeLink has been rejected by an administrator. If you believe this was a mistake, please contact our support team.",
                    null,
                    null
                );
                EmailService.sendEmail(user.getEmail(), subject, body);
            }
            userService.deleteUser(userId, admin);
            session.setAttribute("successMessage", "User deleted successfully! Rejection email sent.");
            resp.sendRedirect(req.getContextPath() + "/admin/users?ts=" + System.currentTimeMillis());
        } catch (AuthException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode("Invalid user ID.", "UTF-8"));
        }
    }
}
