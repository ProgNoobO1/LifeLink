package com.lifelink.servlet;

import com.lifelink.model.User;
import com.lifelink.service.AuthException;
import com.lifelink.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

public class EditUserServlet extends HttpServlet {

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

        String idParam = req.getParameter("editId");
        String fullName = req.getParameter("editFullName");
        String email = req.getParameter("editEmail");
        String phone = req.getParameter("editPhone");
        String bloodGroup = req.getParameter("editBloodGroup");
        String password = req.getParameter("editPassword");
        String roleStr = req.getParameter("editRole");
        String statusStr = req.getParameter("editStatus");

        try {
            Long userId = Long.parseLong(idParam);
            if (roleStr == null || roleStr.isEmpty() || statusStr == null || statusStr.isEmpty()) {
                throw new IllegalArgumentException("Role and status are required.");
            }
            User.Role role = User.Role.valueOf(roleStr);
            User.Status status = User.Status.valueOf(statusStr);

            userService.updateUser(userId, fullName, email, phone,
                    bloodGroup, password, role, status, admin);

            session.setAttribute("successMessage", "User updated successfully!");
            resp.sendRedirect(req.getContextPath() + "/admin/users?ts=" + System.currentTimeMillis());

        } catch (AuthException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (IllegalArgumentException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode(e.getMessage() != null ? e.getMessage() : "Invalid input provided.", "UTF-8"));
        }
    }
}
