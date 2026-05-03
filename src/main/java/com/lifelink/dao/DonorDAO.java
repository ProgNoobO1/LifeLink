package com.lifelink.dao;

import com.lifelink.models.Donor;
import com.lifelink.models.BloodRequest;
import com.lifelink.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DonorDAO {

    public Donor getDonorById(int id) {
        String sql = "SELECT * FROM donors WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    return new Donor(
                        rs.getInt("user_id"),
                        rs.getString("name"),
                        rs.getString("email"),
                        rs.getString("phone"),
                        rs.getString("blood_group"),
                        rs.getString("location"),
                        rs.getBoolean("is_available"),
                        rs.getTimestamp("last_donation_date")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateProfile(Donor donor) {
        String sql = "UPDATE donors SET name = ?, phone = ?, blood_group = ?, location = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setString(1, donor.getName());
            pstmt.setString(2, donor.getPhone());
            pstmt.setString(3, donor.getBloodGroup());
            pstmt.setString(4, donor.getLocation());
            pstmt.setInt(5, donor.getId());
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateAvailability(int donorId, boolean isAvailable) {
        if (isAvailable) {
            Donor donor = getDonorById(donorId);
            if (donor != null && donor.getLastDonationDate() != null) {
                long diffInMillies = Math.abs(System.currentTimeMillis() - donor.getLastDonationDate().getTime());
                long diffInDays = diffInMillies / (1000 * 60 * 60 * 24);
                if (diffInDays < 15) {
                    return false; // Cannot be available within 15 days
                }
            }
        }
        
        String sql = "UPDATE donors SET is_available = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setBoolean(1, isAvailable);
            pstmt.setInt(2, donorId);
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<BloodRequest> getRequestsForDonor(int donorId) {
        List<BloodRequest> requests = new ArrayList<>();
        String sql = "SELECT br.*, h.name as hospital_name FROM blood_requests br " +
                     "JOIN hospitals h ON br.hospital_id = h.hospital_id " +
                     "WHERE br.donor_id = ? AND br.status != 'Completed' " +
                     "ORDER BY br.request_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, donorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    BloodRequest br = new BloodRequest();
                    br.setId(rs.getInt("request_id"));
                    br.setHospitalId(rs.getInt("hospital_id"));
                    br.setDonorId(rs.getInt("donor_id"));
                    br.setBloodGroup(rs.getString("blood_group"));
                    br.setLocation(rs.getString("location"));
                    br.setStatus(rs.getString("status"));
                    br.setRequestDate(rs.getTimestamp("request_date"));
                    br.setHospitalName(rs.getString("hospital_name"));
                    requests.add(br);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }

    public boolean updateRequestStatus(int requestId, String status) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Update Request Status
            String sqlRequest = "UPDATE blood_requests SET status = ? WHERE request_id = ?";
            String finalStatus = status.equals("Accepted") ? "Completed" : status;
            try (PreparedStatement pstmt = conn.prepareStatement(sqlRequest)) {
                pstmt.setString(1, finalStatus);
                pstmt.setInt(2, requestId);
                pstmt.executeUpdate();
            }

            // 2. If Accepted (now Completed), update Donor status
            if (status.equals("Accepted")) {
                String sqlDonor = "UPDATE donors d JOIN blood_requests br ON d.user_id = br.donor_id " +
                                 "SET d.is_available = false, d.last_donation_date = CURRENT_TIMESTAMP " +
                                 "WHERE br.request_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlDonor)) {
                    pstmt.setInt(1, requestId);
                    pstmt.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            e.printStackTrace();
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
        }
        return false;
    }

    public List<BloodRequest> getDonationHistory(int donorId) {
        List<BloodRequest> history = new ArrayList<>();
        String sql = "SELECT br.*, h.name as hospital_name FROM blood_requests br " +
                     "JOIN hospitals h ON br.hospital_id = h.hospital_id " +
                     "WHERE br.donor_id = ? AND br.status = 'Completed' " +
                     "ORDER BY br.request_date DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, donorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    BloodRequest br = new BloodRequest();
                    br.setId(rs.getInt("request_id"));
                    br.setHospitalId(rs.getInt("hospital_id"));
                    br.setDonorId(rs.getInt("donor_id"));
                    br.setBloodGroup(rs.getString("blood_group"));
                    br.setLocation(rs.getString("location"));
                    br.setStatus(rs.getString("status"));
                    br.setRequestDate(rs.getTimestamp("request_date"));
                    br.setHospitalName(rs.getString("hospital_name"));
                    history.add(br);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return history;
    }
}
