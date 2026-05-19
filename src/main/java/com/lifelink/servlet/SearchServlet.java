package com.lifelink.servlet;

import com.google.gson.Gson;
import com.lifelink.dao.SearchDAO;
import com.lifelink.dao.UserDAO;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet(urlPatterns = {"/search", "/recipient/search"})
public class SearchServlet extends HttpServlet {

    private final SearchDAO searchDAO = new SearchDAO();
    private final UserDAO userDAO = new UserDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = resolveCurrentUser(session);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (!canSearch(currentUser, session)) {
            resp.sendRedirect(req.getContextPath() + "/403");
            return;
        }

        String bloodGroup = clean(req.getParameter("bloodGroup"));
        String location = clean(req.getParameter("location"));
        String urgency = clean(req.getParameter("urgency"));

        try {
            if ("1".equals(req.getParameter("ajax"))) {
                writeAjaxResults(resp, bloodGroup, location);
                return;
            }

            req.setAttribute("currentUser", currentUser);
            req.setAttribute("bloodGroups", searchDAO.findAllBloodGroups());

            if (bloodGroup.isEmpty() && location.isEmpty() && urgency.isEmpty()) {
                req.setAttribute("nearbyHospitals", searchDAO.findTopHospitals());
                req.setAttribute("nearbyDonors", searchDAO.findTopAvailableDonors());
                req.setAttribute("popularSearches", searchDAO.findPopularSearchCounts());
                req.getRequestDispatcher("/views/recipient/search.jsp").forward(req, resp);
                return;
            }

            Integer bloodGroupId = searchDAO.findBloodGroupId(bloodGroup);
            List<SearchDAO.DonorResult> donors = searchDAO.searchDonors(bloodGroupId, location);
            List<SearchDAO.HospitalResult> hospitals = searchDAO.searchHospitals(bloodGroupId, location);

            req.setAttribute("selectedBloodGroup", bloodGroup);
            req.setAttribute("selectedLocation", location);
            req.setAttribute("selectedUrgency", urgency);
            req.setAttribute("donorResults", donors);
            req.setAttribute("hospitalResults", hospitals);
            req.setAttribute("availableNow", countAvailable(donors));
            req.setAttribute("nearestDistance", nearestDistance(donors, hospitals));
            req.getRequestDispatcher("/views/recipient/search_results.jsp").forward(req, resp);
        } catch (SQLException e) {
            System.err.println("[SearchServlet] Search failed: " + e.getMessage());
            req.setAttribute("searchError", "Unable to load search results right now. Please try again shortly.");
            req.getRequestDispatcher("/views/recipient/search.jsp").forward(req, resp);
        }
    }

    private User resolveCurrentUser(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object current = session.getAttribute("currentUser");
        if (current instanceof User) {
            return (User) current;
        }
        Object userId = session.getAttribute("userId");
        if (userId == null) {
            return null;
        }
        try {
            return userDAO.findById(Long.valueOf(String.valueOf(userId)));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private boolean canSearch(User user, HttpSession session) {
        if (user.getRole() != null) {
            return user.getRole() == User.Role.DONOR
                    || user.getRole() == User.Role.RECIPIENT
                    || user.getRole() == User.Role.HOSPITAL
                    || user.getRole() == User.Role.ADMIN;
        }
        Object role = session == null ? null : session.getAttribute("role");
        if (role == null) {
            return false;
        }
        String normalized = String.valueOf(role).trim().toLowerCase();
        return "donor".equals(normalized)
                || "recipient".equals(normalized)
                || "hospital".equals(normalized)
                || "admin".equals(normalized);
    }

    private void writeAjaxResults(HttpServletResponse resp, String bloodGroup, String location)
            throws IOException, SQLException {
        Integer bloodGroupId = searchDAO.findBloodGroupId(bloodGroup);
        List<SearchDAO.DonorResult> donors = searchDAO.searchDonors(bloodGroupId, location);
        List<SearchDAO.HospitalResult> hospitals = searchDAO.searchHospitals(bloodGroupId, location);
        Map<String, Object> payload = new HashMap<>();
        payload.put("donors", donors);
        payload.put("hospitals", hospitals);
        payload.put("availableNow", countAvailable(donors));
        payload.put("nearestDistance", nearestDistance(donors, hospitals));
        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write(gson.toJson(payload));
    }

    private int countAvailable(List<SearchDAO.DonorResult> donors) {
        int count = 0;
        for (SearchDAO.DonorResult donor : donors) {
            if (donor.isAvailable()) {
                count++;
            }
        }
        return count;
    }

    private double nearestDistance(List<SearchDAO.DonorResult> donors, List<SearchDAO.HospitalResult> hospitals) {
        double nearest = Double.MAX_VALUE;
        for (SearchDAO.DonorResult donor : donors) {
            nearest = Math.min(nearest, donor.getDistanceKm());
        }
        for (SearchDAO.HospitalResult hospital : hospitals) {
            nearest = Math.min(nearest, hospital.getDistanceKm());
        }
        return nearest == Double.MAX_VALUE ? 0 : nearest;
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }
}
