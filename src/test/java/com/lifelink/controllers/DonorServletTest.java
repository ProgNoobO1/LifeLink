package com.lifelink.controllers;

import com.lifelink.dao.DonorDAO;
import com.lifelink.models.Donor;
import com.lifelink.models.User;
import com.lifelink.models.BloodRequest;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import static org.mockito.Mockito.*;

public class DonorServletTest {

    private DonorServlet servlet;

    @Mock
    private DonorDAO donorDAO;

    @Mock
    private HttpServletRequest request;

    @Mock
    private HttpServletResponse response;

    @Mock
    private HttpSession session;

    @Mock
    private RequestDispatcher dispatcher;

    @Before
    public void setUp() {
        MockitoAnnotations.openMocks(this);
        servlet = new DonorServlet();
        servlet.setDonorDAO(donorDAO);
        
        when(request.getSession()).thenReturn(session);
        when(request.getContextPath()).thenReturn("/lifelink");
    }

    @Test
    public void testDoGetWithoutAuthenticationRedirectsToLogin() throws ServletException, IOException {
        when(session.getAttribute("user")).thenReturn(null);
        when(request.getPathInfo()).thenReturn("/dashboard");

        servlet.doGet(request, response);

        verify(response).sendRedirect("/lifelink/login");
    }

    @Test
    public void testDoGetWithInvalidRoleRedirectsToLogin() throws ServletException, IOException {
        User user = new User(1, "test@test.com", "pass", "Hospital");
        when(session.getAttribute("user")).thenReturn(user);
        when(request.getPathInfo()).thenReturn("/dashboard");

        servlet.doGet(request, response);

        verify(response).sendRedirect("/lifelink/login");
    }

    @Test
    public void testDoGetDashboardSuccess() throws ServletException, IOException {
        User user = new User(1, "donor@lifelink.com", "pass", "Donor");
        when(session.getAttribute("user")).thenReturn(user);
        when(request.getPathInfo()).thenReturn("/dashboard");

        Donor donor = new Donor(1, "Alex Morgan", "donor@lifelink.com", "123456", "O+", "New York", true, null);
        List<BloodRequest> requests = new ArrayList<>();
        List<BloodRequest> history = new ArrayList<>();

        when(donorDAO.getDonorById(1)).thenReturn(donor);
        when(donorDAO.getRequestsForDonor(1)).thenReturn(requests);
        when(donorDAO.getDonationHistory(1)).thenReturn(history);
        when(request.getRequestDispatcher("/views/donor_dashboard.jsp")).thenReturn(dispatcher);

        servlet.doGet(request, response);

        verify(request).setAttribute(eq("donor"), eq(donor));
        verify(request).setAttribute(eq("requests"), eq(requests));
        verify(request).setAttribute(eq("history"), eq(history));
        verify(request).setAttribute(eq("totalDonations"), eq(0));
        verify(dispatcher).forward(request, response);
    }

    @Test
    public void testDoPostToggleAvailabilitySuccess() throws ServletException, IOException {
        User user = new User(1, "donor@lifelink.com", "pass", "Donor");
        when(session.getAttribute("user")).thenReturn(user);
        when(request.getPathInfo()).thenReturn("/toggleAvailability");
        when(request.getParameter("isAvailable")).thenReturn("true");
        when(donorDAO.updateAvailability(1, true)).thenReturn(true);

        servlet.doPost(request, response);

        verify(response).sendRedirect("/lifelink/donor/dashboard");
    }

    @Test
    public void testDoPostToggleAvailabilityFailureCooldown() throws ServletException, IOException {
        User user = new User(1, "donor@lifelink.com", "pass", "Donor");
        when(session.getAttribute("user")).thenReturn(user);
        when(request.getPathInfo()).thenReturn("/toggleAvailability");
        when(request.getParameter("isAvailable")).thenReturn("true");
        when(donorDAO.updateAvailability(1, true)).thenReturn(false);

        servlet.doPost(request, response);

        verify(response).sendRedirect("/lifelink/donor/dashboard?error=donation_limit");
    }

    @Test
    public void testDoPostUpdateRequestStatusSuccess() throws ServletException, IOException {
        User user = new User(1, "donor@lifelink.com", "pass", "Donor");
        when(session.getAttribute("user")).thenReturn(user);
        when(request.getPathInfo()).thenReturn("/updateStatus");
        when(request.getParameter("requestId")).thenReturn("12");
        when(request.getParameter("status")).thenReturn("Accepted");
        when(donorDAO.updateRequestStatus(12, 1, "Accepted")).thenReturn(true);

        servlet.doPost(request, response);

        verify(response).sendRedirect("/lifelink/donor/dashboard?success=accepted");
    }
}
