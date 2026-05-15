package com.lifelink.servlet;

import com.lifelink.dao.BloodRequestDAO;
import com.lifelink.model.BloodRequest;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;

public class AdminRequestServlet extends HttpServlet {

    private final BloodRequestDAO requestDAO = new BloodRequestDAO();
    private static final int PAGE_SIZE = 7;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
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

        String statusParam = req.getParameter("status");
        String bgParam = req.getParameter("bg");
        String searchParam = req.getParameter("search");
        String sortParam = req.getParameter("sort");
        String pageParam = req.getParameter("page");

        int currentPage = 1;
        if (pageParam != null && !pageParam.isEmpty()) {
            try { currentPage = Integer.parseInt(pageParam); } catch (NumberFormatException ignored) {}
        }

        List<BloodRequest> allRequests;
        String activeFilter = "all";
        String activeBloodGroup = "all";
        String activeSort = sortParam != null ? sortParam : "newest";

        if (searchParam != null && !searchParam.trim().isEmpty()) {
            allRequests = requestDAO.search(searchParam.trim());
            req.setAttribute("searchQuery", searchParam.trim());
        } else if (bgParam != null && !bgParam.isEmpty()) {
            activeBloodGroup = bgParam;
            allRequests = requestDAO.findByBloodGroup(bgParam);
        } else if (statusParam != null && !statusParam.isEmpty()) {
            activeFilter = statusParam.toLowerCase();
            try {
                BloodRequest.Status status = BloodRequest.Status.valueOf(statusParam.toUpperCase());
                allRequests = requestDAO.findByStatus(status);
            } catch (IllegalArgumentException e) {
                allRequests = requestDAO.findAll();
            }
        } else if (sortParam != null && !sortParam.isEmpty()) {
            allRequests = requestDAO.findAllSorted(sortParam);
        } else {
            allRequests = requestDAO.findAll();
        }

        // Pagination
        int totalItems = allRequests.size();
        int totalPages = (int) Math.ceil((double) totalItems / PAGE_SIZE);
        if (totalPages < 1) totalPages = 1;
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;

        int start = (currentPage - 1) * PAGE_SIZE;
        int end = Math.min(start + PAGE_SIZE, totalItems);
        List<BloodRequest> pageItems = allRequests.subList(start, end);

        long totalRequests = requestDAO.countAll();
        long pendingCount = requestDAO.countByStatus(BloodRequest.Status.PENDING);
        long approvedCount = requestDAO.countByStatus(BloodRequest.Status.APPROVED);
        long rejectedCount = requestDAO.countByStatus(BloodRequest.Status.REJECTED);

        req.setAttribute("requests", pageItems);
        req.setAttribute("totalRequests", totalRequests);
        req.setAttribute("pendingCount", pendingCount);
        req.setAttribute("approvedCount", approvedCount);
        req.setAttribute("rejectedCount", rejectedCount);
        req.setAttribute("activeFilter", activeFilter);
        req.setAttribute("activeBloodGroup", activeBloodGroup);
        req.setAttribute("activeSort", activeSort);
        req.setAttribute("currentPage", currentPage);
        req.setAttribute("totalPages", totalPages);
        req.setAttribute("showingStart", totalItems > 0 ? start + 1 : 0);
        req.setAttribute("showingEnd", end);
        req.setAttribute("filteredTotal", totalItems);

        req.getRequestDispatcher("/views/Admin/adminRequest.jsp").forward(req, resp);
    }
}
