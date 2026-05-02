package com.lifelink.controllers;

import com.lifelink.dao.DonorDAO;
import com.lifelink.models.BloodRequest;
import com.lifelink.models.Donor;

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

    @Override
    public void init() throws ServletException {
        donorDAO = new DonorDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getPathInfo();
        if (path == null) path = "/dashboard";
        
        // Simulating logged-in user for demonstration (id=1)
        HttpSession session = request.getSession();
        Integer donorId = (Integer) session.getAttribute("donorId");
        if (donorId == null) {
            donorId = 1; // Default to 1 for testing purposes
            session.setAttribute("donorId", donorId);
        }

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
        request.setAttribute("donor", donor);
        request.setAttribute("req", req);
        request.setAttribute("pageTitle", "Request Details");
        request.setAttribute("pageSubtitle", "Review the full details before taking action.");
        request.getRequestDispatcher("/views/donor_request_details.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String path = request.getPathInfo();
        HttpSession session = request.getSession();
        Integer donorId = (Integer) session.getAttribute("donorId");
        if (donorId == null) donorId = 1;

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
                break;
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response, int donorId) throws ServletException, IOException {
        Donor donor = donorDAO.getDonorById(donorId);
        List<BloodRequest> requests = donorDAO.getRequestsForDonor(donorId);
        
        request.setAttribute("donor", donor);
        request.setAttribute("requests", requests);
        request.setAttribute("pageTitle", "Donor Dashboard");
        request.setAttribute("pageSubtitle", "Welcome back, " + (donor != null ? donor.getName() : "Hero") + "! You're making a difference.");
        request.getRequestDispatcher("/views/donor_dashboard.jsp").forward(request, response);
    }

    private void showProfile(HttpServletRequest request, HttpServletResponse response, int donorId) throws ServletException, IOException {
        Donor donor = donorDAO.getDonorById(donorId);
        request.setAttribute("donor", donor);
        request.setAttribute("pageTitle", "My Profile");
        request.setAttribute("pageSubtitle", "Manage your personal and medical information.");
        request.getRequestDispatcher("/views/donor_profile.jsp").forward(request, response);
    }

    private void showHistory(HttpServletRequest request, HttpServletResponse response, int donorId) throws ServletException, IOException {
        List<BloodRequest> history = donorDAO.getDonationHistory(donorId);
        Donor donor = donorDAO.getDonorById(donorId);
        request.setAttribute("donor", donor);
        request.setAttribute("history", history);
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
        donor.setLocation(request.getParameter("location"));
        
        donorDAO.updateProfile(donor);
        response.sendRedirect(request.getContextPath() + "/donor/profile?success=true");
    }

    private void toggleAvailability(HttpServletRequest request, HttpServletResponse response, int donorId) throws IOException {
        boolean isAvailable = Boolean.parseBoolean(request.getParameter("isAvailable"));
        donorDAO.updateAvailability(donorId, isAvailable);
        response.sendRedirect(request.getContextPath() + "/donor/dashboard");
    }

    private void updateRequestStatus(HttpServletRequest request, HttpServletResponse response) throws IOException {
        int requestId = Integer.parseInt(request.getParameter("requestId"));
        String status = request.getParameter("status"); // 'Accepted' or 'Rejected'
        donorDAO.updateRequestStatus(requestId, status);
        response.sendRedirect(request.getContextPath() + "/donor/dashboard");
    }
}
