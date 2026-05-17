package com.lifelink.dao;

import com.lifelink.models.Donor;
import com.lifelink.models.BloodRequest;
import com.lifelink.models.District;
import com.lifelink.utils.DBConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class DonorDAO {

    public Donor getDonorById(int id) {
        String sql = "SELECT d.*, u.id as user_id, u.full_name, u.email, u.phone, bg.name as blood_group, dist.name as district_name " +
                     "FROM users u " +
                     "LEFT JOIN donors d ON u.id = d.user_id " +
                     "LEFT JOIN blood_groups bg ON d.blood_group_id = bg.id " +
                     "LEFT JOIN districts dist ON d.district_id = dist.id " +
                     "WHERE u.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, id);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    Donor donor = new Donor();
                    donor.setId(rs.getInt("user_id"));
                    donor.setName(rs.getString("full_name"));
                    donor.setEmail(rs.getString("email"));
                    donor.setPhone(rs.getString("phone"));
                    
                    String bg = rs.getString("blood_group");
                    donor.setBloodGroup(bg != null ? bg : "Not Set");
                    
                    String addr = rs.getString("address");
                    String distName = rs.getString("district_name");
                    donor.setAddress(addr != null ? addr : "");
                    donor.setDistrictName(distName != null ? distName : "");
                    
                    if (addr != null && !addr.isEmpty() && distName != null && !distName.isEmpty()) {
                        donor.setLocation(addr + ", " + distName);
                    } else if (addr != null && !addr.isEmpty()) {
                        donor.setLocation(addr);
                    } else if (distName != null && !distName.isEmpty()) {
                        donor.setLocation(distName);
                    } else {
                        donor.setLocation("Not Set");
                    }
                    
                    donor.setAvailable(rs.getInt("is_available") == 1);
                    
                    java.sql.Date lastDonated = rs.getDate("last_donated_at");
                    if (lastDonated != null) {
                        donor.setLastDonationDate(new Timestamp(lastDonated.getTime()));
                    }
                    
                    donor.setDistrictId(rs.getObject("district_id") != null ? rs.getInt("district_id") : null);
                    donor.setGender(rs.getString("gender") != null ? rs.getString("gender") : "");
                    donor.setWeightKg(rs.getDouble("weight_kg"));
                    
                    return donor;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateProfile(Donor donor) {
        String sqlUser = "UPDATE users SET full_name = ? WHERE id = ?";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Update users table
            try (PreparedStatement pstmt1 = conn.prepareStatement(sqlUser)) {
                pstmt1.setString(1, donor.getName());
                pstmt1.setInt(2, donor.getId());
                pstmt1.executeUpdate();
            }
            
            // 2. Resolve blood group ID
            int bloodGroupId = 1; // Default fallback to A+
            String sqlBG = "SELECT id FROM blood_groups WHERE name = ?";
            if (donor.getBloodGroup() != null && !"Not Set".equals(donor.getBloodGroup())) {
                try (PreparedStatement pstmtBG = conn.prepareStatement(sqlBG)) {
                    pstmtBG.setString(1, donor.getBloodGroup());
                    try (ResultSet rs = pstmtBG.executeQuery()) {
                        if (rs.next()) {
                            bloodGroupId = rs.getInt("id");
                        }
                    }
                }
            }

            // 3. Check if donor row exists
            boolean exists = false;
            String sqlCheck = "SELECT 1 FROM donors WHERE user_id = ?";
            try (PreparedStatement pstmtCheck = conn.prepareStatement(sqlCheck)) {
                pstmtCheck.setInt(1, donor.getId());
                try (ResultSet rs = pstmtCheck.executeQuery()) {
                    exists = rs.next();
                }
            }

            if (exists) {
                // Update existing donor row
                String sqlDonor = "UPDATE donors SET district_id = ?, address = ?, gender = ?, weight_kg = ?, blood_group_id = ? WHERE user_id = ?";
                try (PreparedStatement pstmt2 = conn.prepareStatement(sqlDonor)) {
                    if (donor.getDistrictId() != null && donor.getDistrictId() > 0) {
                        pstmt2.setInt(1, donor.getDistrictId());
                    } else {
                        pstmt2.setNull(1, java.sql.Types.SMALLINT);
                    }
                    pstmt2.setString(2, donor.getAddress());
                    pstmt2.setString(3, donor.getGender());
                    pstmt2.setDouble(4, donor.getWeightKg());
                    pstmt2.setInt(5, bloodGroupId);
                    pstmt2.setInt(6, donor.getId());
                    pstmt2.executeUpdate();
                }
            } else {
                // Insert new donor row
                String sqlInsert = "INSERT INTO donors (user_id, blood_group_id, district_id, address, gender, weight_kg, is_available) VALUES (?, ?, ?, ?, ?, ?, 1)";
                try (PreparedStatement pstmtInsert = conn.prepareStatement(sqlInsert)) {
                    pstmtInsert.setInt(1, donor.getId());
                    pstmtInsert.setInt(2, bloodGroupId);
                    if (donor.getDistrictId() != null && donor.getDistrictId() > 0) {
                        pstmtInsert.setInt(3, donor.getDistrictId());
                    } else {
                        pstmtInsert.setNull(3, java.sql.Types.SMALLINT);
                    }
                    pstmtInsert.setString(4, donor.getAddress());
                    pstmtInsert.setString(5, donor.getGender());
                    pstmtInsert.setDouble(6, donor.getWeightKg());
                    pstmtInsert.executeUpdate();
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
                try { conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }

    public boolean updateAvailability(int donorId, boolean isAvailable) {
        if (isAvailable) {
            Donor donor = getDonorById(donorId);
            if (donor != null && donor.getLastDonationDate() != null) {
                long diffInMillies = Math.abs(System.currentTimeMillis() - donor.getLastDonationDate().getTime());
                long diffInDays = diffInMillies / (1000 * 60 * 60 * 24);
                if (diffInDays < 90) {
                    return false; // Cannot be available within 90 days cooldown
                }
            }
        }
        
        String sql = "UPDATE donors SET is_available = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, isAvailable ? 1 : 0);
            pstmt.setInt(2, donorId);
            
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<District> getNepalDistricts() {
        List<District> list = new ArrayList<>();
        String sql = "SELECT * FROM districts ORDER BY name ASC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            
            while (rs.next()) {
                list.add(new District(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("province")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<BloodRequest> getRequestsForDonor(int donorId) {
        List<BloodRequest> requests = new ArrayList<>();
        // Fetch requests that are directly targeted to this donor_id OR general requests matching the donor's blood group
        String sql = "SELECT br.id as request_id, br.requester_id, br.units_needed, br.urgency, br.status, br.requested_at as request_date, " +
                     "u.full_name as patient_name, bg.name as blood_group, br.notes " +
                     "FROM blood_requests br " +
                     "JOIN users u ON br.requester_id = u.id " +
                     "JOIN blood_groups bg ON br.blood_group_id = bg.id " +
                     "JOIN donors d ON d.blood_group_id = br.blood_group_id " +
                     "WHERE (br.donor_id = ? OR (br.donor_id IS NULL AND d.user_id = ?)) " +
                     "AND br.status = 'pending' " +
                     "ORDER BY br.requested_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, donorId);
            pstmt.setInt(2, donorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    BloodRequest br = new BloodRequest();
                    br.setId(rs.getInt("request_id"));
                    br.setDonorId(donorId);
                    br.setRequesterId(rs.getInt("requester_id"));
                    br.setBloodGroup(rs.getString("blood_group"));
                    
                    String notes = rs.getString("notes");
                    String patientName = "Patient";
                    String hospitalName = "Hospital";
                    if (notes != null && notes.contains("|")) {
                        String[] parts = notes.split("\\|");
                        for (String part : parts) {
                            if (part.contains("Patient:")) {
                                patientName = part.replace("Patient:", "").trim();
                            }
                            if (part.contains("Location/Hospital:")) {
                                hospitalName = part.replace("Location/Hospital:", "").trim();
                            }
                        }
                    } else if (notes != null) {
                        hospitalName = notes;
                    }
                    
                    br.setPatientName(patientName);
                    br.setHospitalName(hospitalName);
                    br.setLocation(hospitalName);
                    br.setStatus(rs.getString("status"));
                    br.setRequestDate(rs.getTimestamp("request_date"));
                    br.setUnitsNeeded(rs.getInt("units_needed"));
                    br.setUrgency(rs.getString("urgency"));
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

            // 1. Update Request Status in blood_requests
            String sqlRequest = "UPDATE blood_requests SET status = ?, completed_at = CASE WHEN ? = 'Accepted' THEN CURRENT_TIMESTAMP ELSE completed_at END WHERE id = ?";
            String dbStatus = status.equals("Accepted") ? "completed" : "rejected";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlRequest)) {
                pstmt.setString(1, dbStatus);
                pstmt.setString(2, status);
                pstmt.setInt(3, requestId);
                pstmt.executeUpdate();
            }

            // 2. If Accepted, update Donor status and insert to donation history
            if (status.equals("Accepted")) {
                int targetDonorId = 0;
                int bloodGroupId = 0;
                int unitsNeeded = 1;
                String queryRequest = "SELECT donor_id, blood_group_id, units_needed FROM blood_requests WHERE id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(queryRequest)) {
                    pstmt.setInt(1, requestId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        if (rs.next()) {
                            targetDonorId = rs.getInt("donor_id");
                            bloodGroupId = rs.getInt("blood_group_id");
                            unitsNeeded = rs.getInt("units_needed");
                        }
                    }
                }

                if (targetDonorId > 0) {
                    // Update the target donor's status
                    String sqlDirect = "UPDATE donors SET is_available = 0, last_donated_at = CURRENT_DATE WHERE user_id = ?";
                    try (PreparedStatement pstmt = conn.prepareStatement(sqlDirect)) {
                        pstmt.setInt(1, targetDonorId);
                        pstmt.executeUpdate();
                    }

                    // Insert record into donation_history
                    String sqlHistory = "INSERT INTO donation_history (donor_id, request_id, blood_group_id, units_donated, donated_at, verified) " +
                                        "VALUES (?, ?, ?, ?, CURRENT_DATE, 1)";
                    try (PreparedStatement pstmt = conn.prepareStatement(sqlHistory)) {
                        pstmt.setInt(1, targetDonorId);
                        pstmt.setInt(2, requestId);
                        pstmt.setInt(3, bloodGroupId);
                        pstmt.setInt(4, unitsNeeded);
                        pstmt.executeUpdate();
                    }
                } else {
                    // Fallback to select donor by joining on blood_group (just in case)
                    String sqlDirect = "UPDATE donors SET is_available = 0, last_donated_at = CURRENT_DATE " +
                                       "WHERE user_id = (SELECT d.user_id FROM (SELECT d.user_id FROM donors d JOIN blood_requests br ON d.blood_group_id = br.blood_group_id WHERE br.id = ? LIMIT 1) as t)";
                    try (PreparedStatement pstmt = conn.prepareStatement(sqlDirect)) {
                        pstmt.setInt(1, requestId);
                        pstmt.executeUpdate();
                    }
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
        String sql = "SELECT br.id as request_id, br.requester_id, br.units_needed, br.urgency, br.status, br.requested_at as request_date, " +
                     "u.full_name as patient_name, bg.name as blood_group, br.notes " +
                     "FROM blood_requests br " +
                     "JOIN users u ON br.requester_id = u.id " +
                     "JOIN blood_groups bg ON br.blood_group_id = bg.id " +
                     "WHERE br.donor_id = ? AND br.status = 'completed' " +
                     "ORDER BY br.requested_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, donorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    BloodRequest br = new BloodRequest();
                    br.setId(rs.getInt("request_id"));
                    br.setDonorId(donorId);
                    br.setBloodGroup(rs.getString("blood_group"));
                    
                    String notes = rs.getString("notes");
                    String patientName = "Patient";
                    String hospitalName = "Hospital";
                    if (notes != null && notes.contains("|")) {
                        String[] parts = notes.split("\\|");
                        for (String part : parts) {
                            if (part.contains("Patient:")) {
                                patientName = part.replace("Patient:", "").trim();
                            }
                            if (part.contains("Location/Hospital:")) {
                                hospitalName = part.replace("Location/Hospital:", "").trim();
                            }
                        }
                    } else if (notes != null) {
                        hospitalName = notes;
                    }
                    
                    br.setPatientName(patientName);
                    br.setHospitalName(hospitalName);
                    br.setLocation(hospitalName);
                    br.setStatus(rs.getString("status"));
                    br.setRequestDate(rs.getTimestamp("request_date"));
                    history.add(br);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return history;
    }

    public boolean registerDonor(String email, String password, String name, String phone, String bloodGroup, String location) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // Fetch blood group ID
            int bloodGroupId = 1; // Fallback to A+
            String sqlBG = "SELECT id FROM blood_groups WHERE name = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlBG)) {
                pstmt.setString(1, bloodGroup);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        bloodGroupId = rs.getInt("id");
                    }
                }
            }

            // 1. Insert into users table
            String sqlUser = "INSERT INTO users (full_name, email, password_hash, confirm_password_hash, phone, role, is_active, is_approved) " +
                             "VALUES (?, ?, ?, ?, ?, 'donor', 1, 1)";
            int userId = -1;
            try (PreparedStatement pstmt = conn.prepareStatement(sqlUser, Statement.RETURN_GENERATED_KEYS)) {
                pstmt.setString(1, name);
                pstmt.setString(2, email);
                pstmt.setString(3, password);
                pstmt.setString(4, password);
                pstmt.setString(5, phone);
                pstmt.executeUpdate();
                
                try (ResultSet rs = pstmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        userId = rs.getInt(1);
                    }
                }
            }

            if (userId == -1) {
                conn.rollback();
                return false;
            }

            // 2. Insert into donors table
            String sqlDonor = "INSERT INTO donors (user_id, blood_group_id, address, is_available) VALUES (?, ?, ?, 1)";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlDonor)) {
                pstmt.setInt(1, userId);
                pstmt.setInt(2, bloodGroupId);
                pstmt.setString(3, location);
                pstmt.executeUpdate();
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
                try { conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
        return false;
    }
}
