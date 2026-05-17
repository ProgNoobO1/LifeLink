package com.lifelink.servlet;

import com.lifelink.model.Notification;
import com.lifelink.model.User;
import com.lifelink.service.AuthException;
import com.lifelink.service.NotificationService;
import com.lifelink.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

public class AddUserServlet extends HttpServlet {

    private final UserService userService = new UserService();

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

        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String phone = req.getParameter("phone");
        String bloodGroup = req.getParameter("bloodGroup");
        String password = req.getParameter("password");
        String roleStr = req.getParameter("role");
        String statusStr = req.getParameter("status");

        try {
            if (roleStr == null || roleStr.isEmpty() || statusStr == null || statusStr.isEmpty()) {
                throw new IllegalArgumentException("Role and status are required.");
            }
            User.Role role = User.Role.valueOf(roleStr);
            User.Status status = User.Status.valueOf(statusStr);

            userService.registerUser(fullName, email, phone,
                    bloodGroup, password, role, status);

            Notification notification = new Notification(
                "NEW_USER",
                "New user added",
                fullName + " (" + email + ") was added as " + role.name().toLowerCase(),
                req.getContextPath() + "/admin/users"
            );
            NotificationService.getInstance().broadcast(notification);

            session.setAttribute("successMessage", "User created successfully!");
            resp.sendRedirect(req.getContextPath() + "/admin/users");

        } catch (AuthException e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("fullName", fullName);
            req.setAttribute("email", email);
            req.setAttribute("phone", phone);
            req.setAttribute("bloodGroup", bloodGroup);
            req.setAttribute("role", roleStr);
            req.setAttribute("status", statusStr);
            req.getRequestDispatcher("/views/Admin/adminManageUsers.jsp").forward(req, resp);
        } catch (IllegalArgumentException e) {
            req.setAttribute("error", e.getMessage() != null ? e.getMessage() : "Invalid role or status selected.");
            req.setAttribute("fullName", fullName);
            req.setAttribute("email", email);
            req.setAttribute("phone", phone);
            req.setAttribute("bloodGroup", bloodGroup);
            req.setAttribute("role", roleStr);
            req.setAttribute("status", statusStr);
            req.getRequestDispatcher("/views/Admin/adminManageUsers.jsp").forward(req, resp);
        }
    }
}
