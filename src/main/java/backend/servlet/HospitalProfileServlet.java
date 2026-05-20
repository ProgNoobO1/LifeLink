package lifelink.servlet;

import lifelink.dao.HospitalDAO;
import lifelink.model.Hospital;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

public class HospitalProfileServlet extends HttpServlet {

    private HospitalDAO hospitalDAO = new HospitalDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = lifelink.utils.SessionUtil.getUserId(request);
        Hospital hospital = hospitalDAO.getHospitalByUserId(userId);

        if (hospital == null) {
            hospital = new Hospital();
            hospital.setUserId(userId);
        }

        request.setAttribute("hospital", hospital);
        request.getRequestDispatcher("/views/Hospital/hospital_profile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int userId = lifelink.utils.SessionUtil.getUserId(request);
        
        Hospital hospital = new Hospital();
        hospital.setUserId(userId);
        hospital.setHospitalName(request.getParameter("hospitalName"));
        hospital.setLicenseNo(request.getParameter("licenseNo"));
        
        String districtIdStr = request.getParameter("districtId");
        if (districtIdStr != null && !districtIdStr.isEmpty()) {
            hospital.setDistrictId(Integer.parseInt(districtIdStr));
        }
        
        hospital.setAddress(request.getParameter("address"));
        
        String latStr = request.getParameter("latitude");
        if (latStr != null && !latStr.isEmpty()) {
            hospital.setLatitude(Double.parseDouble(latStr));
        }
        
        String lngStr = request.getParameter("longitude");
        if (lngStr != null && !lngStr.isEmpty()) {
            hospital.setLongitude(Double.parseDouble(lngStr));
        }
        
        hospital.setContactPerson(request.getParameter("contactPerson"));
        hospital.setWebsite(request.getParameter("website"));

        boolean success = hospitalDAO.updateHospitalProfile(hospital);

        if (success) {
            response.sendRedirect(request.getContextPath() + "/hospital/profile?msg=success");
        } else {
            String err = hospitalDAO.getLastError();
            response.sendRedirect(request.getContextPath() + "/hospital/profile?error=failed&detail=" + 
                java.net.URLEncoder.encode(err.isEmpty() ? "Unknown error" : err, "UTF-8"));
        }
    }
}
