package com.lifelink.servlet;

import com.lifelink.dao.RecipientDashboardDAO;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * Serves the Recipient Dashboard page.
 * URL: /recipient/dashboard  (GET only — data is read-only here)
 *
 * Role guard: only 'recipient' may access; others are redirected.
 */
public class RecipientDashboardServlet extends HttpServlet {

    private final RecipientDashboardDAO dao = new RecipientDashboardDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // ── 1. Auth / role guard ──────────────────────────────────────────
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            // Not logged in → login page
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User currentUser = (User) session.getAttribute("currentUser");

        // Only recipients may view this page
        if (currentUser.getRole() != User.Role.RECIPIENT) {
            if (currentUser.getRole() == User.Role.ADMIN) {
                resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
            } else {
                // Donor / hospital → send to their own dashboard (stub redirect for now)
                resp.sendRedirect(req.getContextPath() + "/index.jsp");
            }
            return;
        }

        long userId = currentUser.getId();

        // ── 2. Fetch dashboard data ───────────────────────────────────────
        try {
            long totalRequests     = dao.countTotalRequests(userId);
            long pendingRequests   = dao.countPendingRequests(userId);
            long fulfilledRequests = dao.countFulfilledRequests(userId);
            String bloodGroup      = dao.getRecipientBloodGroup(userId);

            List<Map<String, Object>> recentRequests = dao.findRecentRequests(userId);
            List<Map<String, Object>> recentActivity  = dao.findRecentActivity(userId);

            // ── 3. Attach to request scope for JSP ───────────────────────
            req.setAttribute("totalRequests",     totalRequests);
            req.setAttribute("pendingRequests",   pendingRequests);
            req.setAttribute("fulfilledRequests", fulfilledRequests);
            req.setAttribute("bloodGroup",        bloodGroup != null ? bloodGroup : "N/A");
            req.setAttribute("recentRequests",    recentRequests);
            req.setAttribute("recentActivity",    recentActivity);
            req.setAttribute("currentUser",       currentUser); // already in session but convenient

        } catch (Exception e) {
            // Log to server err; never expose stack traces to the user
            System.err.println("[RecipientDashboardServlet] Error loading dashboard data: " + e.getMessage());
            e.printStackTrace(System.err);
            req.setAttribute("dashboardError", "Unable to load dashboard data. Please try again later.");
        }

        // ── 4. Forward to JSP ────────────────────────────────────────────
        req.getRequestDispatcher("/views/recipient/recipient_dashboard.jsp")
           .forward(req, resp);
    }
}
