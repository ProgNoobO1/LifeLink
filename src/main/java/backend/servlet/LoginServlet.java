package backend.servlet;

import backend.model.User;
import backend.service.AuthException;
import backend.service.AuthService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;

public class LoginServlet extends HttpServlet {

    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // If already logged in, redirect accordingly
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            redirectByRole(user, req, resp);
            return;
        }
        req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String password = req.getParameter("password");

        try {
            User user = authService.login(email, password);

            // Invalidate old session if exists (prevent session fixation)
            HttpSession oldSession = req.getSession(false);
            if (oldSession != null) {
                oldSession.invalidate();
            }

            HttpSession newSession = req.getSession(true);
            newSession.setAttribute("currentUser", user);
            newSession.setMaxInactiveInterval(30 * 60); // 30 minutes

            redirectByRole(user, req, resp);

        } catch (AuthException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/views/login.jsp").forward(req, resp);
        }
    }

    private void redirectByRole(User user, HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String contextPath = req.getContextPath();
        if (user.getRole() == User.Role.ADMIN) {
            resp.sendRedirect(contextPath + "/views/Admin/adminDashboard.jsp");
        } else {
            resp.sendRedirect(contextPath + "/index.jsp");
        }
    }
}
