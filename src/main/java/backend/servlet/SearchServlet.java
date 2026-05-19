package backend.servlet;

import backend.dao.DonorDAO;
import backend.dao.HospitalDAO;
import backend.model.DonorSearchDTO;
import backend.model.Hospital;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

public class SearchServlet extends HttpServlet {

    private DonorDAO donorDAO = new DonorDAO();
    private HospitalDAO hospitalDAO = new HospitalDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get filter inputs
        String bloodGroup = request.getParameter("bloodGroup");
        String district = request.getParameter("district");

        // Set filters as request attributes to preserve form values
        request.setAttribute("selectedGroup", bloodGroup);
        request.setAttribute("selectedDistrict", district);

        // Fetch matching donors
        List<DonorSearchDTO> donorList = donorDAO.searchDonors(bloodGroup, district);
        request.setAttribute("donorList", donorList);

        // Fetch hospital profile for sidebar alignment
        int userId = 1 /* INTEGRATION POINT: (int) request.getSession().getAttribute("userId") */;
        Hospital hospital = hospitalDAO.getHospitalByUserId(userId);
        request.setAttribute("hospital", hospital != null ? hospital : new Hospital());

        request.getRequestDispatcher("/views/Hospital/search_donors.jsp")
               .forward(request, response);
    }
}
