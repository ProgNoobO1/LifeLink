package backend.servlet;

import backend.model.User;
import backend.service.AuthException;
import backend.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URLEncoder;

public class DeleteUserServlet extends HttpServlet {

    private final UserService userService = new UserService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp");
            return;
        }

        User admin = (User) session.getAttribute("currentUser");
        if (admin.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String idParam = req.getParameter("id");
        try {
            Long userId = Long.parseLong(idParam);
            userService.deleteUser(userId, admin);
            session.setAttribute("successMessage", "User deleted successfully!");
            resp.sendRedirect(req.getContextPath() + "/admin/users");
        } catch (AuthException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode(e.getMessage(), "UTF-8"));
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/admin/users?error=" + URLEncoder.encode("Invalid user ID.", "UTF-8"));
        }
    }
}
