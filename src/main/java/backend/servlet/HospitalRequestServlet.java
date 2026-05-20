package lifelink.servlet;

import lifelink.dao.BloodRequestDAO;
import lifelink.dao.HospitalDAO;
import lifelink.model.BloodRequest;
import lifelink.model.Hospital;
import lifelink.service.HospitalService;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;


public class HospitalRequestServlet extends HttpServlet {

    private BloodRequestDAO requestDAO = new BloodRequestDAO();
    private HospitalDAO hospitalDAO = new HospitalDAO();
    private HospitalService hospitalService = new HospitalService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int hospitalId = getHospitalId(request);
        String statusFilter = request.getParameter("status");

        List<BloodRequest> requests = null;
        if ("outgoing".equals(statusFilter)) {
            // We just need the outgoing requests, handled below
        } else if (statusFilter != null && !statusFilter.isEmpty() && !"all".equals(statusFilter)) {
            requests = requestDAO.getRequestsByStatus(hospitalId, statusFilter);
        } else {
            requests = requestDAO.getRequestsByHospital(hospitalId);
            statusFilter = "all";
        }

        // Count by status for filter tabs
        request.setAttribute("requests", requests);
        request.setAttribute("statusFilter", statusFilter);
        request.setAttribute("pendingCount", requestDAO.getPendingCount(hospitalId));
        request.setAttribute("totalCount", requestDAO.getTotalRequestCount(hospitalId));
        request.setAttribute("acceptedCount", requestDAO.getCountByStatus(hospitalId, "accepted"));
        request.setAttribute("rejectedCount", requestDAO.getCountByStatus(hospitalId, "rejected"));
        request.setAttribute("completedCount", requestDAO.getCountByStatus(hospitalId, "completed"));
        request.setAttribute("hospital", hospitalDAO.getHospitalByUserId(
                1 /* INTEGRATION POINT: (int) request.getSession().getAttribute("userId") */));

        // Fetch outgoing requests (from hospital to donor)
        /* INTEGRATION POINT: Member 2 (Donor) provides DonorRequestDAO
        backend.dao.DonorRequestDAO donorRequestDAO = new backend.dao.DonorRequestDAO();
        request.setAttribute("outgoingRequests", donorRequestDAO.getRequestsByHospital(hospitalId));
        */

        request.getRequestDispatcher("/views/Hospital/hospital_requests.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        int hospitalId = getHospitalId(request);

        if ("accept".equals(action)) {
            String result = hospitalService.acceptRequest(requestId, hospitalId);
            if ("insufficient_stock".equals(result)) {
                response.sendRedirect(request.getContextPath() +
                        "/hospital/requests?error=insufficient_stock");
                return;
            }
        } else if ("reject".equals(action)) {
            hospitalService.rejectRequest(requestId);
        } else if ("complete".equals(action)) {
            hospitalService.completeRequest(requestId);
        }

        response.sendRedirect(request.getContextPath() +
                "/hospital/requests?msg=" + action + "_success");
    }

    private int getHospitalId(HttpServletRequest request) {
        int userId = 1 /* INTEGRATION POINT: (int) request.getSession().getAttribute("userId") */;
        Hospital hospital = hospitalDAO.getHospitalByUserId(userId);
        return hospital != null ? hospital.getId() : -1;
    }
}
