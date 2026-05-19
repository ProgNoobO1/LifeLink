package backend.servlet;

import backend.dao.HospitalDAO;
import backend.model.BloodStock;
import backend.model.Hospital;
import backend.service.HospitalService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;
import java.util.Map;

public class HospitalDashboardServlet extends HttpServlet {

    private HospitalDAO hospitalDAO = new HospitalDAO();
    private HospitalService hospitalService = new HospitalService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = backend.utils.SessionUtil.getUserId(request);
        Hospital hospital = hospitalDAO.getHospitalByUserId(userId);

        if (hospital == null) {
            // No hospital found for this user — show dashboard with empty data
            request.setAttribute("hospital", new Hospital());
            request.setAttribute("totalUnits", 0);
            request.setAttribute("lowStockCount", 0);
            request.setAttribute("pendingRequests", 0);
            request.setAttribute("unreadNotifCount", 0);
            request.setAttribute("notifications", java.util.Collections.emptyList());
            request.getRequestDispatcher("/views/Hospital/hospital_dashboard.jsp")
                    .forward(request, response);
            return;
        }

        int hospitalId = hospital.getId();

        // Get dashboard summary data from service
        Map<String, Object> data = hospitalService.getDashboardData(hospitalId);

        // Set all as request attributes for JSP
        request.setAttribute("hospital", hospital);
        request.setAttribute("totalUnits", data.get("totalUnits"));
        request.setAttribute("lowStockCount", data.get("lowStockCount"));
        request.setAttribute("pendingRequests", data.get("pendingRequests"));
        request.setAttribute("stockList", data.get("stockList"));
        request.setAttribute("recentRequests", data.get("recentRequests"));
        request.setAttribute("lowStockAlerts", data.get("lowStockAlerts"));

        // Fallbacks for notifications since they are cleaned up
        request.setAttribute("notifications", java.util.Collections.emptyList());
        request.setAttribute("unreadNotifCount", 0);

        request.getRequestDispatcher("/views/Hospital/hospital_dashboard.jsp")
                .forward(request, response);
    }
}

