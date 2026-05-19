package backend.servlet;

/* INTEGRATION POINT: Member 2 (Donor) provides Donor models and DAO
import backend.dao.DonorDAO;
import backend.model.Donor;
*/
import backend.dao.HospitalDAO;
import backend.model.Hospital;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

public class HospitalNewRequestServlet extends HttpServlet {

    /* INTEGRATION POINT:
    private final DonorDAO donorDAO = new DonorDAO();
    */
    private final HospitalDAO hospitalDAO = new HospitalDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse res)
            throws ServletException, IOException {

        int userId = 1 /* INTEGRATION POINT: (int) req.getSession().getAttribute("userId") */;
        Hospital hospital = hospitalDAO.getHospitalByUserId(userId);
        req.setAttribute("hospital", hospital);

        backend.dao.DonorDAO donorDAO = new backend.dao.DonorDAO();
        String bloodGroup = req.getParameter("bloodGroup");
        String district = req.getParameter("district");

        if (bloodGroup != null && !bloodGroup.isBlank()) {
            List<backend.model.DonorSearchDTO> donors = donorDAO.searchDonors(bloodGroup, district);
            req.setAttribute("donors", donors);
            req.setAttribute("searchBloodGroup", bloodGroup);
            req.setAttribute("searchDistrict", district);
            req.setAttribute("searched", true);
        }

        req.getRequestDispatcher("/views/Hospital/hospital_new_request.jsp").forward(req, res);
    }
}
