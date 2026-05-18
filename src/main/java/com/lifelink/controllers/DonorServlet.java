package com.lifelink.controllers;

import com.lifelink.dao.DonorDAO;
import com.lifelink.models.BloodRequest;
import com.lifelink.models.Donor;
import com.lifelink.models.Notification;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/donor/*")
public class DonorServlet extends HttpServlet {

    private DonorDAO donorDAO;

    // For testing injection
    public void setDonorDAO(DonorDAO donorDAO) {
        this.donorDAO = donorDAO;
    }

    @Override
    public void init() throws ServletException {
        donorDAO = new DonorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getPathInfo();
        if (path == null) path = "/dashboard";
        
        // Authenticated user check - adapted for Donor-only branch
        HttpSession session = request.getSession();
        Integer donorIdObj = (Integer) session.getAttribute("donorId");
        if (donorIdObj == null) {
            donorIdObj = 1; // Default fallback for standalone / no-auth mode
            session.setAttribute("donorId", donorIdObj);
        }
        
        int donorId = donorIdObj;
        donorDAO.seedDummyHospitalRequest(donorId);
        donorDAO.seedDummyRecipientRequest(donorId);

        switch (path) {
            case "/dashboard":
                showDashboard(request, response, donorId);
                break;
            case "/profile":
                showProfile(request, response, donorId);
                break;
            case "/history":
                showHistory(request, response, donorId);
                break;
            case "/requests":
                showRequests(request, response, donorId);
                break;
            case "/requestDetails":
                showRequestDetails(request, response, donorId);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/donor/dashboard");
                break;
        }
    }

    private void showRequestDetails(HttpServletRequest request, HttpServletResponse response, int donorId) throws ServletException, IOException {
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        // For now, we simulate fetching request details. In a real app, DonorDAO would have getRequestById.
        BloodRequest req = null;
        List<BloodRequest> requests = donorDAO.getRequestsForDonor(donorId);
        for(BloodRequest r : requests) {
            if(r.getId() == requestId) {
                req = r;
                break;
            }
        }
        
        Donor donor = donorDAO.getDonorById(donorId);
        List<Notification> notifications = getNotifications(donor, requests);
        request.setAttribute("donor", donor);
        request.setAttribute("req", req);
        request.setAttribute("notifications", notifications);
        request.setAttribute("pageTitle", "Request Details");
        request.setAttribute("pageSubtitle", "Review the full details before taking action.");
        request.getRequestDispatcher("/views/donor_request_details.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getPathInfo();
        HttpSession session = request.getSession();
        Integer donorIdObj = (Integer) session.getAttribute("donorId");
        if (donorIdObj == null) {
            donorIdObj = 1;
            session.setAttribute("donorId", donorIdObj);
        }
        
        int donorId = donorIdObj;

        switch (path) {
            case "/profile":
                updateProfile(request, response, donorId);
                break;
            case "/toggleAvailability":
                toggleAvailability(request, response, donorId);
                break;
            case "/updateStatus":
                updateRequestStatus(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/donor/dashboard");
    }
    }

    private List<Notification> getNotifications(Donor donor, List<BloodRequest> requests) {
        List<Notification> notifications = new java.util.ArrayList<>();
        
        if (requests != null) {
            for (BloodRequest req : requests) {
                String message;
                if ("hospital".equals(req.getRequesterRole())) {
                    message = "New " + req.getBloodGroup() + " request from Hospital: " + req.getHospitalName();
                } else {
                    message = "New " + req.getBloodGroup() + " request for Patient: " + req.getPatientName() + " (Age: " + (req.getPatientAge() > 0 ? req.getPatientAge() : "N/A") + ")";
                }
                notifications.add(new Notification(
                    "Request",
                    message,
                    "fas fa-tint",
                    "Just now"
                ));
            }
        }
        
        if (donor != null && !donor.isAvailable() && donor.getLastDonationDate() != null) {
            long diffInMillies = Math.abs(System.currentTimeMillis() - donor.getLastDonationDate().getTime());
            long diffInDays = diffInMillies / (1000 * 60 * 60 * 24);
            if (diffInDays >= 90) {
                notifications.add(new Notification(
                    "Renewal",
                    "You are now eligible to donate again! Mark yourself as available.",
                    "fas fa-check-circle",
                    "Reminder"
                ));
            }
        }
        
        return notifications;
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response, int donorId) throws ServletException, IOException {
        Donor donor = donorDAO.getDonorById(donorId);
        List<BloodRequest> requests = donorDAO.getRequestsForDonor(donorId);
        List<BloodRequest> history = donorDAO.getDonationHistory(donorId);
        
        int totalDonations = history.size();
        
        List<Notification> notifications = getNotifications(donor, requests);
        
        if (donor != null && !donor.isAvailable() && donor.getLastDonationDate() != null) {
            long diffInMillies = Math.abs(System.currentTimeMillis() - donor.getLastDonationDate().getTime());
            long diffInDays = diffInMillies / (1000 * 60 * 60 * 24);
            if (diffInDays < 90) {
                request.setAttribute("cooldownDaysLeft", 90 - diffInDays);
            }
        }
        
        request.setAttribute("donor", donor);
        request.setAttribute("requests", requests);
        request.setAttribute("history", history);
        request.setAttribute("notifications", notifications);
        request.setAttribute("totalDonations", totalDonations);
        request.setAttribute("pageTitle", "Donor Dashboard");
        request.setAttribute("pageSubtitle", "Welcome back, " + (donor != null ? donor.getName() : "Hero") + "! You're making a difference.");
        request.getRequestDispatcher("/views/donor_dashboard.jsp").forward(request, response);
    }

    private void showRequests(HttpServletRequest request, HttpServletResponse response, int donorId) throws ServletException, IOException {
        Donor donor = donorDAO.getDonorById(donorId);
        List<BloodRequest> requests = donorDAO.getRequestsForDonor(donorId);
        List<Notification> notifications = getNotifications(donor, requests);
        request.setAttribute("donor", donor);
        request.setAttribute("requests", requests);
        request.setAttribute("notifications", notifications);
        request.setAttribute("pageTitle", "Incoming Requests");
        request.setAttribute("pageSubtitle", "Urgent blood requests matching your group.");
        request.getRequestDispatcher("/views/donor_requests.jsp").forward(request, response);
    }

    private void showProfile(HttpServletRequest request, HttpServletResponse response, int donorId) throws ServletException, IOException {
        Donor donor = donorDAO.getDonorById(donorId);
        List<BloodRequest> history = donorDAO.getDonationHistory(donorId);
        List<BloodRequest> requests = donorDAO.getRequestsForDonor(donorId);
        
        int totalDonations = history.size();
        
        List<Notification> notifications = getNotifications(donor, requests);
        
        List<com.lifelink.models.District> districts = donorDAO.getNepalDistricts();
        
        request.setAttribute("donor", donor);
        request.setAttribute("requests", requests);
        request.setAttribute("notifications", notifications);
        request.setAttribute("totalDonations", totalDonations);
        request.setAttribute("districts", districts);
        request.setAttribute("pageTitle", "My Profile");
        request.setAttribute("pageSubtitle", "Manage your personal and medical information.");
        request.getRequestDispatcher("/views/donor_profile.jsp").forward(request, response);
    }

    private void showHistory(HttpServletRequest request, HttpServletResponse response, int donorId) throws ServletException, IOException {
        List<BloodRequest> history = donorDAO.getDonationHistory(donorId);
        List<BloodRequest> requests = donorDAO.getRequestsForDonor(donorId);
        Donor donor = donorDAO.getDonorById(donorId);
        
        int totalDonations = history.size();
        
        request.setAttribute("donor", donor);
        request.setAttribute("history", history);
        request.setAttribute("requests", requests);
        request.setAttribute("notifications", getNotifications(donor, requests));
        request.setAttribute("totalDonations", totalDonations);
        request.setAttribute("pageTitle", "My Donation History");
        request.setAttribute("pageSubtitle", "A complete record of all your blood donations.");
        request.getRequestDispatcher("/views/donor_history.jsp").forward(request, response);
    }

    private void updateProfile(HttpServletRequest request, HttpServletResponse response, int donorId) throws IOException {
        Donor donor = new Donor();
        donor.setId(donorId);
        donor.setName(request.getParameter("name"));
        donor.setPhone(request.getParameter("phone"));
        donor.setBloodGroup(request.getParameter("bloodGroup"));
        
        String districtIdStr = request.getParameter("districtId");
        if (districtIdStr != null && !districtIdStr.trim().isEmpty()) {
            donor.setDistrictId(Integer.parseInt(districtIdStr));
        }
        
        donor.setAddress(request.getParameter("address"));
        donor.setGender(request.getParameter("gender"));
        
        String weightStr = request.getParameter("weightKg");
        if (weightStr != null && !weightStr.trim().isEmpty()) {
            donor.setWeightKg(Double.parseDouble(weightStr));
        }
        
        donorDAO.updateProfile(donor);
        response.sendRedirect(request.getContextPath() + "/donor/profile?success=true");
    }

    private void toggleAvailability(HttpServletRequest request, HttpServletResponse response, int donorId) throws IOException {
        boolean isAvailable = Boolean.parseBoolean(request.getParameter("isAvailable"));
        boolean success = donorDAO.updateAvailability(donorId, isAvailable);
        if (!success && isAvailable) {
            response.sendRedirect(request.getContextPath() + "/donor/dashboard?error=donation_limit");
        } else {
            response.sendRedirect(request.getContextPath() + "/donor/dashboard");
        }
    }

    private void updateRequestStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession();
        Integer donorIdObj = (session != null) ? (Integer) session.getAttribute("donorId") : null;
        if (donorIdObj == null) {
            donorIdObj = 1;
            if (session != null) {
                session.setAttribute("donorId", donorIdObj);
            }
        }
        int donorId = donorIdObj;
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        String status = request.getParameter("status"); // 'Accepted' or 'Rejected'
        boolean success = donorDAO.updateRequestStatus(requestId, donorId, status);
        
        if (success && status.equals("Accepted")) {
            response.sendRedirect(request.getContextPath() + "/donor/dashboard?success=accepted");
        } else {
            response.sendRedirect(request.getContextPath() + "/donor/dashboard");
        }
    }
}
