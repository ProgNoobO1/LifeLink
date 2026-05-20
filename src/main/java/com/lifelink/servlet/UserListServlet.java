package com.lifelink.servlet;

import com.lifelink.dao.UserDAO;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class UserListServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final int PAGE_SIZE = 7;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
        resp.setHeader("Pragma", "no-cache");
        resp.setDateHeader("Expires", 0);

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

        int page = 1;
        try {
            String pageParam = req.getParameter("page");
            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
                if (page < 1) page = 1;
            }
        } catch (NumberFormatException ignored) {}

        long totalUsers = userDAO.countAll();
        long totalDonors = userDAO.countByRole(User.Role.DONOR);
        long totalRecipients = userDAO.countByRole(User.Role.RECIPIENT);
        long totalHospitals = userDAO.countByRole(User.Role.HOSPITAL);

        int offset = (page - 1) * PAGE_SIZE;
        List<User> users = userDAO.findAll(offset, PAGE_SIZE);

        int totalPages = (int) Math.ceil((double) totalUsers / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;

        List<Integer> pages = new ArrayList<>();
        for (int i = 1; i <= totalPages; i++) {
            pages.add(i);
        }

        req.setAttribute("users", users);
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("totalDonors", totalDonors);
        req.setAttribute("totalRecipients", totalRecipients);
        req.setAttribute("totalHospitals", totalHospitals);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("pages", pages);
        req.setAttribute("pageSize", PAGE_SIZE);

        String success = req.getParameter("success");
        String error = req.getParameter("error");
        if (success != null && !success.isEmpty()) {
            req.setAttribute("success", success);
        }
        if (error != null && !error.isEmpty()) {
            req.setAttribute("error", error);
        }

        req.getRequestDispatcher("/views/Admin/adminManageUsers.jsp").forward(req, resp);
    }
}
