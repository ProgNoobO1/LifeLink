package com.lifelink.servlet;

import com.lifelink.dao.ReportDAO;
import com.lifelink.model.User;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Map;

public class AdminReportsServlet extends HttpServlet {

    private final ReportDAO reportDAO = new ReportDAO();
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    private static final DateTimeFormatter MONTH_FMT = DateTimeFormatter.ofPattern("MMM yyyy");

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

        // Parse date range
        String period = req.getParameter("period");
        String fromDateStr = req.getParameter("fromDate");
        String toDateStr = req.getParameter("toDate");

        LocalDate toDate = LocalDate.now();
        LocalDate fromDate;

        if (fromDateStr != null && !fromDateStr.isEmpty() && toDateStr != null && !toDateStr.isEmpty()) {
            fromDate = LocalDate.parse(fromDateStr, DATE_FMT);
            toDate = LocalDate.parse(toDateStr, DATE_FMT);
        } else if ("3months".equals(period)) {
            fromDate = toDate.minusMonths(3);
        } else if ("year".equals(period)) {
            fromDate = toDate.minusYears(1);
        } else {
            // Default: this month
            fromDate = toDate.withDayOfMonth(1);
        }

        // Chart data
        List<Map<String, Object>> monthly = reportDAO.getMonthlyDonations(fromDate, toDate);
        List<Map<String, Object>> bloodGroupDist = reportDAO.getBloodGroupDistribution();
        Map<String, Long> fulfillment = reportDAO.getRequestFulfillmentStats();
        List<Map<String, Object>> topDonors = reportDAO.getTopDonors(5, fromDate, toDate);
        int totalDonated = reportDAO.getTotalDonationsInRange(fromDate, toDate);

        Gson gson = new Gson();

        // Set attributes
        req.setAttribute("fromDate", fromDate.format(DATE_FMT));
        req.setAttribute("toDate", toDate.format(DATE_FMT));
        req.setAttribute("period", period);
        req.setAttribute("monthlyDonations", monthly);
        req.setAttribute("bloodGroupDist", bloodGroupDist);
        req.setAttribute("fulfillmentStats", fulfillment);
        req.setAttribute("topDonors", topDonors);
        req.setAttribute("totalDonated", totalDonated);

        req.setAttribute("monthlyDonationsJson", gson.toJson(monthly));
        req.setAttribute("bloodGroupDistJson", gson.toJson(bloodGroupDist));
        req.setAttribute("fulfillmentStatsJson", gson.toJson(fulfillment));
        req.setAttribute("topDonorsJson", gson.toJson(topDonors));

        req.getRequestDispatcher("/views/Admin/adminReports.jsp").forward(req, resp);
    }
}
