package com.lifelink.controllers;

import com.lifelink.dao.DonorDAO;
import com.lifelink.dao.RecipientDAO;
import com.lifelink.models.Donor;
import com.lifelink.utils.DBConnection;
import org.junit.Before;
import org.junit.Test;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Date;
import java.util.List;

import static org.junit.Assert.*;

public class RecipientDAOTest {

    private final RecipientDAO recipientDAO = new RecipientDAO();
    private final DonorDAO donorDAO = new DonorDAO();

    @Before
    public void cleanAndSeedDatabase() {
        try (Connection conn = DBConnection.getConnection()) {
            conn.createStatement().execute("DELETE FROM request_responses WHERE responder_id IN (888, 999)");
            conn.createStatement().execute("DELETE FROM donation_history WHERE donor_id IN (888, 999)");
            conn.createStatement().execute("DELETE FROM blood_requests WHERE donor_id IN (888, 999) OR requester_id IN (888, 999)");
            conn.createStatement().execute("DELETE FROM donors WHERE user_id IN (888, 999)");
            conn.createStatement().execute("DELETE FROM recipients WHERE user_id IN (888, 999)");
            conn.createStatement().execute("DELETE FROM users WHERE id IN (888, 999) OR email IN ('test_donor@lifelink.com', 'test_recipient@lifelink.com')");
            
            // Seed a test recipient user (blood_group_id = 7 is O+)
            conn.createStatement().execute(
                "INSERT INTO users (id, full_name, email, password_hash, confirm_password_hash, role, is_active, is_approved) " +
                "VALUES (999, 'Sarah Recipient', 'test_recipient@lifelink.com', 'pass', 'pass', 'recipient', 1, 1)"
            );
            conn.createStatement().execute(
                "INSERT INTO recipients (user_id, blood_group_id, address) " +
                "VALUES (999, 7, 'Boston')"
            );

            // Seed a test donor user
            conn.createStatement().execute(
                "INSERT INTO users (id, full_name, email, password_hash, confirm_password_hash, role, is_active, is_approved) " +
                "VALUES (888, 'Jack Donor', 'test_donor@lifelink.com', 'pass', 'pass', 'donor', 1, 1)"
            );
            conn.createStatement().execute(
                "INSERT INTO donors (user_id, blood_group_id, address, is_available) " +
                "VALUES (888, 7, 'Boston', 1)"
            );
        } catch (SQLException e) {
            e.printStackTrace();
            fail("Seeding failed: " + e.getMessage());
        }
    }

    @Test
    public void testSearchAvailableDonorsWithActive90DayCooldown() throws SQLException {
        // Set donor last_donated_at to 45 days ago (inside 90 days cooldown)
        long fortyFiveDaysAgo = System.currentTimeMillis() - (45L * 24 * 60 * 60 * 1000);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("UPDATE donors SET last_donated_at = ? WHERE user_id = 888")) {
            pstmt.setDate(1, new Date(fortyFiveDaysAgo));
            pstmt.executeUpdate();
        }

        // Search available donors
        List<Donor> results = recipientDAO.searchAvailableDonors("O+", "Boston");
        
        // Donor should NOT be visible due to the active 90-day cooldown!
        assertTrue("Donor inside 90-day cooldown should be filtered out from search", results.isEmpty());
    }

    @Test
    public void testSearchAvailableDonorsWithExpired90DayCooldown() throws SQLException {
        // Set donor last_donated_at to 95 days ago (outside 90 days cooldown)
        long ninetyFiveDaysAgo = System.currentTimeMillis() - (95L * 24 * 60 * 60 * 1000);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("UPDATE donors SET last_donated_at = ? WHERE user_id = 888")) {
            pstmt.setDate(1, new Date(ninetyFiveDaysAgo));
            pstmt.executeUpdate();
        }

        // Search available donors
        List<Donor> results = recipientDAO.searchAvailableDonors("O+", "Boston");
        
        // Donor should be visible because cooldown has fully expired!
        assertFalse("Donor outside 90-day cooldown should be visible in search results", results.isEmpty());
        assertEquals("Jack Donor", results.get(0).getName());
    }

    @Test
    public void testUpdateAvailabilityEnforces90DayCooldown() throws SQLException {
        // Set donor last_donated_at to 60 days ago
        long sixtyDaysAgo = System.currentTimeMillis() - (60L * 24 * 60 * 60 * 1000);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("UPDATE donors SET last_donated_at = ?, is_available = 0 WHERE user_id = 888")) {
            pstmt.setDate(1, new Date(sixtyDaysAgo));
            pstmt.executeUpdate();
        }

        // Attempt to mark as available should fail due to active cooldown (60 < 90)
        boolean updateResultInside = donorDAO.updateAvailability(888, true);
        assertFalse("Should fail to toggle availability inside 90-day cooldown", updateResultInside);

        // Set last_donated_at to 100 days ago
        long oneHundredDaysAgo = System.currentTimeMillis() - (100L * 24 * 60 * 60 * 1000);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement("UPDATE donors SET last_donated_at = ?, is_available = 0 WHERE user_id = 888")) {
            pstmt.setDate(1, new Date(oneHundredDaysAgo));
            pstmt.executeUpdate();
        }

        // Attempt to mark as available should now succeed because cooldown has expired (100 >= 90)
        boolean updateResultExpired = donorDAO.updateAvailability(888, true);
        assertTrue("Should successfully toggle availability after 90-day cooldown expires", updateResultExpired);
    }

    @Test
    public void testRecipientRequestVisibleOnDonorDashboard() {
        // 1. Recipient 999 creates a blood request targeted at donor 888's blood group
        boolean requestCreated = recipientDAO.createBloodRequest(
            999, 
            888, 
            "Sarah Recipient", 
            2, 
            "Boston City Hospital", 
            "critical"
        );
        
        assertTrue("Blood request should be successfully created", requestCreated);

        // 2. Donor 888 queries incoming requests matching their profile
        List<com.lifelink.models.BloodRequest> pendingRequests = donorDAO.getRequestsForDonor(888);

        // 3. Assertions to verify the request is visible and in "pending" status
        assertFalse("Donor should see the pending blood request matching their blood group", pendingRequests.isEmpty());
        
        com.lifelink.models.BloodRequest visibleReq = pendingRequests.get(0);
        assertEquals("pending", visibleReq.getStatus());
        assertEquals(2, visibleReq.getUnitsNeeded());
        assertEquals("critical", visibleReq.getUrgency());
        // Since patient name and hospital details are mapped dynamically:
        assertNotNull(visibleReq.getPatientName());
    }
}
