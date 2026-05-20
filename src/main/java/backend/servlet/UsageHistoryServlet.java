package lifelink.servlet;

import lifelink.dao.BloodRequestDAO;
import lifelink.dao.HospitalDAO;
import lifelink.model.Hospital;
import lifelink.model.UsageHistory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@WebServlet("/hospital/usage")
public class UsageHistoryServlet extends HttpServlet {

    private BloodRequestDAO requestDAO = new BloodRequestDAO();
    private HospitalDAO hospitalDAO = new HospitalDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int hospitalId = getHospitalId(request);

        // Optional blood group filter
        String bloodGroupFilter = request.getParameter("bloodGroup");

        List<UsageHistory> history = requestDAO.getUsageHistory(hospitalId);

        // Filter by blood group if specified
        if (bloodGroupFilter != null && !bloodGroupFilter.isEmpty()) {
            history = history.stream()
                    .filter(h -> h.getBloodGroup().equals(bloodGroupFilter))
                    .collect(Collectors.toList());
        }

        // Total units used per blood group — for summary cards
        Map<String, Integer> usageSummary = new LinkedHashMap<>();
        // Initialize all blood groups to 0
        String[] allGroups = {"A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"};
        for (String g : allGroups) {
            usageSummary.put(g, 0);
        }
        // Sum from all history (not just filtered)
        List<UsageHistory> allHistory = requestDAO.getUsageHistory(hospitalId);
        for (UsageHistory h : allHistory) {
            usageSummary.merge(h.getBloodGroup(), h.getUnitsUsed(), Integer::sum);
        }

        // Grand total
        int totalUsed = usageSummary.values().stream().mapToInt(Integer::intValue).sum();

        request.setAttribute("history", history);
        request.setAttribute("usageSummary", usageSummary);
        request.setAttribute("totalUsed", totalUsed);
        request.setAttribute("bloodGroupFilter", bloodGroupFilter);
        request.setAttribute("hospital", hospitalDAO.getHospitalByUserId(
                1 /* INTEGRATION POINT: (int) request.getSession().getAttribute("userId") */));

        request.getRequestDispatcher("/views/Hospital/usage_history.jsp")
               .forward(request, response);
    }

    private int getHospitalId(HttpServletRequest request) {
        int userId = 1 /* INTEGRATION POINT: (int) request.getSession().getAttribute("userId") */;
        Hospital hospital = hospitalDAO.getHospitalByUserId(userId);
        return hospital != null ? hospital.getId() : -1;
    }
}
