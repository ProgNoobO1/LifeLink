package backend.servlet;

import backend.dao.UserDAO;
import backend.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.util.*;

public class AdminDashboardServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();

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

        // User counts
        long totalDonors = userDAO.countByRole(User.Role.DONOR);
        long totalRecipients = userDAO.countByRole(User.Role.RECIPIENT);
        long totalHospitals = userDAO.countByRole(User.Role.HOSPITAL);
        long totalUsers = userDAO.countAll();

        // Blood group distribution from donor/recipient users
        String[] bloodGroups = {"A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"};
        Map<String, Long> bloodGroupCounts = new LinkedHashMap<>();
        long maxBloodGroup = 0;
        for (String bg : bloodGroups) {
            long count = userDAO.countByBloodGroup(bg);
            bloodGroupCounts.put(bg, count);
            if (count > maxBloodGroup) maxBloodGroup = count;
        }

        // Recent users (last 5)
        List<User> recentUsers = userDAO.findRecent(5);

        // Recent activity: derive from recent users + their roles
        List<Map<String, String>> recentActivities = new ArrayList<>();
        for (User u : recentUsers) {
            Map<String, String> act = new HashMap<>();
            act.put("title", "New " + u.getRole().toString().toLowerCase() + " registered");
            act.put("desc", u.getFullName() + " joined as a " + u.getRole().toString().toLowerCase());
            act.put("time", "Recently");
            act.put("iconBg", u.getRole() == User.Role.DONOR ? "#d1fae5" :
                              u.getRole() == User.Role.RECIPIENT ? "#dbeafe" :
                              u.getRole() == User.Role.HOSPITAL ? "#fef3c7" : "#f3e8ff");
            act.put("iconColor", u.getRole() == User.Role.DONOR ? "#059669" :
                                   u.getRole() == User.Role.RECIPIENT ? "#2563eb" :
                                   u.getRole() == User.Role.HOSPITAL ? "#d97706" : "#7c3aed");
            recentActivities.add(act);
        }

        req.setAttribute("totalDonors", totalDonors);
        req.setAttribute("totalRecipients", totalRecipients);
        req.setAttribute("totalHospitals", totalHospitals);
        req.setAttribute("totalUsers", totalUsers);
        req.setAttribute("bloodGroupCounts", bloodGroupCounts);
        req.setAttribute("maxBloodGroup", maxBloodGroup);
        req.setAttribute("recentUsers", recentUsers);
        req.setAttribute("recentActivities", recentActivities);

        req.getRequestDispatcher("/views/Admin/adminDashboard.jsp").forward(req, resp);
    }
}
