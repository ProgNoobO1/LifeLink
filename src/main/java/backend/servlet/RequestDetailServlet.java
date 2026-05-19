package backend.servlet;

import backend.dao.BloodRequestDAO;
import backend.dao.BloodStockDAO;
import backend.dao.HospitalDAO;
import backend.model.BloodRequest;
import backend.model.BloodStock;
import backend.model.Hospital;
import backend.service.HospitalService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;


public class RequestDetailServlet extends HttpServlet {

    private BloodRequestDAO requestDAO = new BloodRequestDAO();
    private BloodStockDAO stockDAO = new BloodStockDAO();
    private HospitalDAO hospitalDAO = new HospitalDAO();
    private HospitalService hospitalService = new HospitalService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String idParam = request.getParameter("id");
        if (idParam == null || idParam.isEmpty()) {
            response.sendRedirect(request.getContextPath() + "/hospital/requests");
            return;
        }

        int requestId = Integer.parseInt(idParam);
        BloodRequest req = requestDAO.getRequestById(requestId);

        if (req == null) {
            response.sendRedirect(request.getContextPath() + "/hospital/requests");
            return;
        }

        int hospitalId = getHospitalId(request);

        // Get current stock for the requested blood group
        BloodStock currentStock = stockDAO.getStockByBloodGroup(hospitalId, req.getBloodGroup());

        // Get all stock for sidebar display
        java.util.List<BloodStock> allStock = stockDAO.getAllStock(hospitalId);

        request.setAttribute("bloodRequest", req);
        request.setAttribute("currentStock", currentStock);
        request.setAttribute("allStock", allStock);
        request.setAttribute("hospital", hospitalDAO.getHospitalByUserId(
                1 /* INTEGRATION POINT: (int) request.getSession().getAttribute("userId") */));

        request.getRequestDispatcher("/views/Hospital/request_detail.jsp")
               .forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        int hospitalId = getHospitalId(request);

        String result = "success";
        if ("accept".equals(action)) {
            result = hospitalService.acceptRequest(requestId, hospitalId);
        } else if ("reject".equals(action)) {
            hospitalService.rejectRequest(requestId);
        } else if ("complete".equals(action)) {
            hospitalService.completeRequest(requestId);
        }

        response.sendRedirect(request.getContextPath() +
                "/hospital/requests/detail?id=" + requestId + "&msg=" + result);
    }

    private int getHospitalId(HttpServletRequest request) {
        int userId = 1 /* INTEGRATION POINT: (int) request.getSession().getAttribute("userId") */;
        Hospital hospital = hospitalDAO.getHospitalByUserId(userId);
        return hospital != null ? hospital.getId() : -1;
    }
}
