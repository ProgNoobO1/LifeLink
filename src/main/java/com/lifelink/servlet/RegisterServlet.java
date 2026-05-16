package com.lifelink.servlet;

import com.lifelink.model.Notification;
import com.lifelink.model.User;
import com.lifelink.service.AuthException;
import com.lifelink.service.NotificationService;
import com.lifelink.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

public class RegisterServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/views/Register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String bloodGroup = req.getParameter("bloodGroup");
        String roleStr = req.getParameter("role");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // Validation
        if (fullName == null || fullName.trim().isEmpty()) {
            redirectWithError(req, resp, "Full name is required.");
            return;
        }
        if (email == null || email.trim().isEmpty()) {
            redirectWithError(req, resp, "Email is required.");
            return;
        }
        if (password == null || password.isEmpty()) {
            redirectWithError(req, resp, "Password is required.");
            return;
        }
        if (!password.equals(confirmPassword)) {
            redirectWithError(req, resp, "Passwords do not match.");
            return;
        }
        if (password.length() < 8) {
            redirectWithError(req, resp, "Password must be at least 8 characters.");
            return;
        }

        try {
            User.Role role = User.Role.valueOf(roleStr.toUpperCase());
            userService.registerUser(fullName.trim(), email.trim(), phone, bloodGroup, password, role, User.Status.ACTIVE);

            Notification notification = new Notification(
                "NEW_USER",
                "New user registered",
                fullName.trim() + " (" + email.trim() + ") registered as " + role.name().toLowerCase(),
                req.getContextPath() + "/admin/users"
            );
            NotificationService.getInstance().broadcast(notification);

            resp.sendRedirect(req.getContextPath() + "/login?registered=true");
        } catch (AuthException e) {
            redirectWithError(req, resp, e.getMessage());
        } catch (IllegalArgumentException e) {
            redirectWithError(req, resp, "Invalid role selected.");
        }
    }

    private void redirectWithError(HttpServletRequest req, HttpServletResponse resp, String message) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/register?error=" + URLEncoder.encode(message, "UTF-8"));
    }
}
