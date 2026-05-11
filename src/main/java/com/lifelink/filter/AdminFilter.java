package com.lifelink.filter;

import com.lifelink.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;

import java.io.IOException;

public class AdminFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // No initialization required
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        // Check if user is logged in
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp?error=Please login first");
            return;
        }

        // Check if user is an admin
        User user = (User) session.getAttribute("currentUser");
        if (user.getRole() != User.Role.ADMIN) {
            resp.sendRedirect(req.getContextPath() + "/index.jsp?error=AccessDenied");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
        // No cleanup required
    }
}
