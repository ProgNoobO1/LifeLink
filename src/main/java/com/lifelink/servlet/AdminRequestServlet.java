package com.lifelink.servlet;

import com.lifelink.dao.UserDAO;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class AdminRequestServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

        String statusFilter = req.getParameter("status");
        String sortParam = req.getParameter("sort");
        String pageParam = req.getParameter("page");

        List<User> allUsers = userDAO.findAll(0, 1000);

        // Filter non-admin users only (registrations needing approval)
        List<User> registrationRequests = allUsers.stream()
            .filter(u -> u.getRole() != User.Role.ADMIN)
            .collect(Collectors.toList());

        List<User> filteredList;
        String activeFilter = "all";

        if ("pending".equalsIgnoreCase(statusFilter)) {
            activeFilter = "pending";
            filteredList = registrationRequests.stream()
                .filter(u -> !u.isApproved())
                .collect(Collectors.toList());
        } else if ("approved".equalsIgnoreCase(statusFilter)) {
            activeFilter = "approved";
            filteredList = registrationRequests.stream()
                .filter(u -> u.isApproved() && u.getStatus() == User.Status.ACTIVE)
                .collect(Collectors.toList());
        } else if ("rejected".equalsIgnoreCase(statusFilter)) {
            activeFilter = "rejected";
            filteredList = registrationRequests.stream()
                .filter(u -> u.getStatus() == User.Status.SUSPENDED)
                .collect(Collectors.toList());
        } else {
            filteredList = registrationRequests;
        }

        // Sorting
        String activeSort = "newest";
        if ("oldest".equalsIgnoreCase(sortParam)) {
            activeSort = "oldest";
            filteredList.sort(Comparator.comparing(User::getCreatedAt, Comparator.nullsLast(Comparator.naturalOrder())));
        } else {
            filteredList.sort(Comparator.comparing(User::getCreatedAt, Comparator.nullsLast(Comparator.reverseOrder())));
        }

        // Pagination
        int currentPage = 1;
        try {
            if (pageParam != null) {
                currentPage = Integer.parseInt(pageParam);
            }
        } catch (NumberFormatException ignored) {}

        int totalItems = filteredList.size();
        int totalPages = Math.max(1, (int) Math.ceil((double) totalItems / PAGE_SIZE));
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        int startIndex = (currentPage - 1) * PAGE_SIZE;
        int endIndex = Math.min(startIndex + PAGE_SIZE, totalItems);

        List<User> pageItems = filteredList.subList(startIndex, endIndex);

        long totalRequests = registrationRequests.size();
        long pendingCount = registrationRequests.stream().filter(u -> !u.isApproved()).count();
        long approvedCount = registrationRequests.stream().filter(u -> u.isApproved() && u.getStatus() == User.Status.ACTIVE).count();
        long rejectedCount = registrationRequests.stream().filter(u -> u.getStatus() == User.Status.SUSPENDED).count();

        req.setAttribute("requests", pageItems);
        req.setAttribute("totalRequests", totalRequests);
        req.setAttribute("pendingCount", pendingCount);
        req.setAttribute("approvedCount", approvedCount);
        req.setAttribute("rejectedCount", rejectedCount);
        req.setAttribute("activeFilter", activeFilter);
        req.setAttribute("activeSort", activeSort);
        req.setAttribute("filteredTotal", totalItems);
        req.setAttribute("currentPage", currentPage);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("showingStart", totalItems == 0 ? 0 : startIndex + 1);
        req.setAttribute("showingEnd", endIndex);

        req.getRequestDispatcher("/views/Admin/adminRequest.jsp").forward(req, resp);
    }
}
