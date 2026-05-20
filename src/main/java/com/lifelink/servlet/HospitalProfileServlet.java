package com.lifelink.servlet;

import com.lifelink.dao.DistrictDAO;
import com.lifelink.dao.HospitalDAO;
import com.lifelink.dao.HospitalDashboardDAO;
import com.lifelink.dao.UsageHistoryDAO;
import com.lifelink.dao.UserDAO;
import com.lifelink.model.District;
import com.lifelink.model.Hospital;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/hospital/edit-details")
public class HospitalProfileServlet extends HttpServlet {

    private final HospitalDAO hospitalDAO = new HospitalDAO();
    private final DistrictDAO districtDAO = new DistrictDAO();
    private final HospitalDashboardDAO dashboardDAO = new HospitalDashboardDAO();
    private final UsageHistoryDAO usageHistoryDAO = new UsageHistoryDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        Integer hospitalId = requireHospital(session, request, response);
        if (hospitalId == null) {
            return;
        }

        Hospital profile = hospitalDAO.findByUserId(hospitalId);
        if (profile == null) {
            profile = buildDefaultProfile(hospitalId, resolveUser(session, hospitalId));
        }

        forwardForm(request, response, session, hospitalId, profile);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");

        HttpSession session = request.getSession(false);
        Integer hospitalId = requireHospital(session, request, response);
        if (hospitalId == null) {
            return;
        }

        User currentUser = resolveUser(session, hospitalId);
        Hospital form = buildHospitalFromRequest(request, hospitalId, currentUser);

        try {
            validateForm(form);

            District selectedDistrict = null;
            if (form.getDistrictId() != null) {
                selectedDistrict = districtDAO.findById(form.getDistrictId());
                if (selectedDistrict == null) {
                    throw new IllegalArgumentException("Please select a valid district.");
                }
                form.setLatitude(selectedDistrict.getLatitude());
                form.setLongitude(selectedDistrict.getLongitude());
            } else {
                form.setLatitude(null);
                form.setLongitude(null);
            }

            Hospital existing = hospitalDAO.findByUserId(hospitalId);
            boolean saved = existing == null ? hospitalDAO.save(form) : hospitalDAO.update(form);
            if (!saved) {
                throw new IllegalArgumentException("Unable to save hospital details right now. Please try again.");
            }

            response.sendRedirect(request.getContextPath() + "/hospital/edit-details?success=1");
        } catch (IllegalArgumentException e) {
            request.setAttribute("profileError", e.getMessage());
            forwardForm(request, response, session, hospitalId, form);
        }
    }

    private void forwardForm(HttpServletRequest request, HttpServletResponse response, HttpSession session,
                             int hospitalId, Hospital profile)
            throws ServletException, IOException {
        List<District> districts = districtDAO.findAll();
        request.setAttribute("hospitalProfile", profile);
        request.setAttribute("districts", districts);
        request.setAttribute("hospitalName", dashboardDAO.getHospitalName(hospitalId));
        request.setAttribute("hospitalEmail", resolveHospitalEmail(session));
        request.setAttribute("pendingCount", dashboardDAO.getPendingRequestCount(hospitalId));
        request.setAttribute("notificationCount", usageHistoryDAO.getQueuedNotificationCount(hospitalId));
        request.getRequestDispatcher("/hospital/edit_hospital_details.jsp").forward(request, response);
    }

    private Hospital buildHospitalFromRequest(HttpServletRequest request, int hospitalId, User currentUser) {
        Hospital hospital = new Hospital();
        hospital.setUserId(hospitalId);
        hospital.setHospitalName(clean(request.getParameter("hospitalName")));
        hospital.setLicenseNo(cleanLoose(request.getParameter("licenseNo")));
        hospital.setDistrictId(parseDistrictId(request.getParameter("districtId")));
        hospital.setAddress(cleanLoose(request.getParameter("address")));
        hospital.setContactPerson(cleanLoose(request.getParameter("contactPerson")));
        hospital.setWebsite(cleanLoose(request.getParameter("website")));
        hospital.setLatitude(null);
        hospital.setLongitude(null);
        if ((hospital.getHospitalName() == null || hospital.getHospitalName().isEmpty()) && currentUser != null) {
            hospital.setHospitalName(defaultHospitalName(currentUser));
        }
        return hospital;
    }

    private void validateForm(Hospital hospital) {
        if (hospital.getHospitalName() == null || hospital.getHospitalName().isEmpty()) {
            throw new IllegalArgumentException("Hospital name is required.");
        }
        if (hospital.getHospitalName().length() > 200) {
            throw new IllegalArgumentException("Hospital name must be 200 characters or fewer.");
        }
        if (hospital.getLicenseNo() != null && hospital.getLicenseNo().length() > 100) {
            throw new IllegalArgumentException("License number must be 100 characters or fewer.");
        }
        if (hospital.getAddress() != null && hospital.getAddress().length() > 255) {
            throw new IllegalArgumentException("Address must be 255 characters or fewer.");
        }
        if (hospital.getContactPerson() != null && hospital.getContactPerson().length() > 150) {
            throw new IllegalArgumentException("Contact person must be 150 characters or fewer.");
        }
        if (hospital.getWebsite() != null && hospital.getWebsite().length() > 255) {
            throw new IllegalArgumentException("Website must be 255 characters or fewer.");
        }
        if (hospital.getWebsite() != null
                && !(hospital.getWebsite().startsWith("http://") || hospital.getWebsite().startsWith("https://"))) {
            throw new IllegalArgumentException("Website must start with http:// or https://");
        }
    }

    private Hospital buildDefaultProfile(int hospitalId, User currentUser) {
        Hospital hospital = new Hospital();
        hospital.setUserId(hospitalId);
        hospital.setHospitalName(currentUser != null ? defaultHospitalName(currentUser) : "");
        return hospital;
    }

    private String defaultHospitalName(User currentUser) {
        if (currentUser == null) {
            return "";
        }
        String fullName = currentUser.getFullName();
        if (fullName != null && !fullName.trim().isEmpty() && !"Hospital Account".equalsIgnoreCase(fullName.trim())) {
            return fullName.trim();
        }
        String email = currentUser.getEmail();
        if (email != null && email.contains("@")) {
            return email.substring(0, email.indexOf('@'));
        }
        return "Hospital";
    }

    private User resolveUser(HttpSession session, int hospitalId) {
        Object currentUser = session != null ? session.getAttribute("currentUser") : null;
        if (currentUser instanceof User) {
            return (User) currentUser;
        }
        return userDAO.findById(Long.valueOf(hospitalId));
    }

    private Integer requireHospital(HttpSession session, HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        if (session == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        Object roleValue = session.getAttribute("role");
        if (roleValue == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return null;
        }

        if (!"hospital".equalsIgnoreCase(String.valueOf(roleValue))) {
            response.sendRedirect(request.getContextPath() + "/403");
            return null;
        }

        Object userIdValue = session.getAttribute("userId");
        if (userIdValue != null) {
            try {
                return Integer.valueOf(String.valueOf(userIdValue));
            } catch (NumberFormatException e) {
                System.err.println("[HospitalProfileServlet] Invalid session userId: " + e.getMessage());
            }
        }

        response.sendRedirect(request.getContextPath() + "/login");
        return null;
    }

    private String resolveHospitalEmail(HttpSession session) {
        if (session == null) {
            return "";
        }
        Object email = session.getAttribute("email");
        return email != null ? String.valueOf(email) : "";
    }

    private Integer parseDistrictId(String raw) {
        String cleaned = clean(raw);
        if (cleaned.isEmpty()) {
            return null;
        }
        try {
            int value = Integer.parseInt(cleaned);
            return value > 0 ? value : null;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Please select a valid district.");
        }
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private String cleanLoose(String value) {
        String cleaned = clean(value);
        return cleaned.isEmpty() ? null : cleaned;
    }
}
