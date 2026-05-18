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
                    // Self-healing check: if the donor row doesn't exist in donors table, insert a default one!
                    rs.getInt("blood_group_id");
                    if (rs.wasNull()) {
                        String sqlInsertDefault = "INSERT INTO donors (user_id, blood_group_id, address, is_available) VALUES (?, 1, 'Not Set', 1)";
                        try (Connection connSelfHeal = DBConnection.getConnection();
                             PreparedStatement pstmtHeal = connSelfHeal.prepareStatement(sqlInsertDefault)) {
                            pstmtHeal.setInt(1, id);
                            pstmtHeal.executeUpdate();
                        } catch (SQLException ex) {
                            ex.printStackTrace();
                        }
                        // Re-query now that the row exists!
                        return getDonorById(id);
                    }

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
        String sqlUser = "UPDATE users SET full_name = ?, phone = ? WHERE id = ?";
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Update users table
            try (PreparedStatement pstmt1 = conn.prepareStatement(sqlUser)) {
                pstmt1.setString(1, donor.getName());
                pstmt1.setString(2, donor.getPhone());
                pstmt1.setInt(3, donor.getId());
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
        // UNION of two branches:
        //   Branch 1: requests explicitly targeted at this donor (donor_id = ?)
        //   Branch 2: open requests (donor_id IS NULL) matching the donor's blood group
        String sql =
            // Branch 1 – directly targeted requests (no donors join needed)
            "SELECT br.id as request_id, br.requester_id, br.units_needed, br.urgency, br.status, br.requested_at as request_date, br.notes, " +
            "bg.name as blood_group, u.role as requester_role, u.full_name as user_full_name, " +
            "r.date_of_birth as recipient_dob, h.hospital_name as hospital_name, h.address as hospital_address " +
            "FROM blood_requests br " +
            "JOIN blood_groups bg ON br.blood_group_id = bg.id " +
            "JOIN users u ON br.requester_id = u.id " +
            "LEFT JOIN recipients r ON u.id = r.user_id " +
            "LEFT JOIN hospitals h ON u.id = h.user_id " +
            "WHERE br.donor_id = ? AND br.status = 'pending' " +
            "UNION " +
            // Branch 2 – open (untargeted) requests matching this donor's blood group
            "SELECT br.id as request_id, br.requester_id, br.units_needed, br.urgency, br.status, br.requested_at as request_date, br.notes, " +
            "bg.name as blood_group, u.role as requester_role, u.full_name as user_full_name, " +
            "r.date_of_birth as recipient_dob, h.hospital_name as hospital_name, h.address as hospital_address " +
            "FROM blood_requests br " +
            "JOIN blood_groups bg ON br.blood_group_id = bg.id " +
            "JOIN users u ON br.requester_id = u.id " +
            "LEFT JOIN recipients r ON u.id = r.user_id " +
            "LEFT JOIN hospitals h ON u.id = h.user_id " +
            "JOIN donors d ON d.blood_group_id = br.blood_group_id AND d.user_id = ? " +
            "WHERE br.donor_id IS NULL AND br.status = 'pending' " +
            "ORDER BY request_date DESC";
        
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
                    br.setStatus(rs.getString("status"));
                    br.setRequestDate(rs.getTimestamp("request_date"));
                    br.setUnitsNeeded(rs.getInt("units_needed"));
                    br.setUrgency(rs.getString("urgency"));
                    
                    String role = rs.getString("requester_role");
                    br.setRequesterRole(role != null ? role.toLowerCase() : "recipient");
                    
                    String notes = rs.getString("notes");
                    parseNotesAndProfile(
                        br, 
                        notes, 
                        rs.getString("user_full_name"), 
                        rs.getString("hospital_name"), 
                        rs.getString("hospital_address"), 
                        rs.getDate("recipient_dob")
                    );
                    requests.add(br);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return requests;
    }

    public boolean updateRequestStatus(int requestId, int donorId, String status) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Get request details
            int bloodGroupId = 0;
            int unitsNeeded = 1;
            int requesterId = 0;
            String queryRequest = "SELECT requester_id, blood_group_id, units_needed FROM blood_requests WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(queryRequest)) {
                pstmt.setInt(1, requestId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        requesterId = rs.getInt("requester_id");
                        bloodGroupId = rs.getInt("blood_group_id");
                        unitsNeeded = rs.getInt("units_needed");
                    }
                }
            }

            // 2. Fetch donor's full name
            String donorName = "Donor";
            String queryDonorName = "SELECT full_name FROM users WHERE id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(queryDonorName)) {
                pstmt.setInt(1, donorId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        donorName = rs.getString("full_name");
                    }
                }
            }

            if (status.equals("Accepted")) {
                // 3. Update blood_requests
                String sqlRequest = "UPDATE blood_requests SET status = 'completed', donor_id = ?, completed_at = CURRENT_TIMESTAMP WHERE id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlRequest)) {
                    pstmt.setInt(1, donorId);
                    pstmt.setInt(2, requestId);
                    pstmt.executeUpdate();
                }

                // 4. Update donors table to make unavailable and set last donation date
                String sqlDonor = "UPDATE donors SET is_available = 0, last_donated_at = CURRENT_DATE WHERE user_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlDonor)) {
                    pstmt.setInt(1, donorId);
                    pstmt.executeUpdate();
                }

                // 5. Insert into donation_history
                String sqlHistory = "INSERT INTO donation_history (donor_id, request_id, blood_group_id, units_donated, donated_at, verified) VALUES (?, ?, ?, ?, CURRENT_DATE, 1)";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlHistory)) {
                    pstmt.setInt(1, donorId);
                    pstmt.setInt(2, requestId);
                    pstmt.setInt(3, bloodGroupId);
                    pstmt.setInt(4, unitsNeeded);
                    pstmt.executeUpdate();
                }

                // 5b. Auto-reject any other pending requests targeted directly to this donor
                String sqlGetOtherRequests = "SELECT id, requester_id, units_needed FROM blood_requests WHERE donor_id = ? AND status = 'pending' AND id != ?";
                try (PreparedStatement pstmtGetOther = conn.prepareStatement(sqlGetOtherRequests)) {
                    pstmtGetOther.setInt(1, donorId);
                    pstmtGetOther.setInt(2, requestId);
                    try (ResultSet rsOther = pstmtGetOther.executeQuery()) {
                        while (rsOther.next()) {
                            int otherReqId = rsOther.getInt("id");
                            int otherRequesterId = rsOther.getInt("requester_id");
                            int otherUnits = rsOther.getInt("units_needed");

                            // Reject this other request
                            String sqlRejectOther = "UPDATE blood_requests SET status = 'rejected' WHERE id = ?";
                            try (PreparedStatement pstmtReject = conn.prepareStatement(sqlRejectOther)) {
                                pstmtReject.setInt(1, otherReqId);
                                pstmtReject.executeUpdate();
                            }

                            // Log in request_responses for the rejected request
                            String sqlResponseOther = "INSERT INTO request_responses (request_id, responder_id, responder_type, response, units_provided, notes) " +
                                                      "VALUES (?, ?, 'donor', 'rejected', 0, ?)";
                            try (PreparedStatement pstmtResp = conn.prepareStatement(sqlResponseOther)) {
                                pstmtResp.setInt(1, otherReqId);
                                pstmtResp.setInt(2, donorId);
                                pstmtResp.setString(3, "System auto-declined: donor accepted another request and is now in 90-day cooldown.");
                                pstmtResp.executeUpdate();
                            }

                            // Queue email notification targeting the other requester
                            if (otherRequesterId > 0) {
                                String sqlEmailOther = "INSERT INTO email_notifications (user_id, subject, body, status) VALUES (?, ?, ?, 'queued')";
                                try (PreparedStatement pstmtEmail = conn.prepareStatement(sqlEmailOther)) {
                                    pstmtEmail.setInt(1, otherRequesterId);
                                    pstmtEmail.setString(2, "LifeLink - Blood Request Declined");
                                    pstmtEmail.setString(3, "Dear User,\n\nYour blood request (ID: " + otherReqId + ") has been declined because donor " + donorName + " has committed to another donation and entered the safety cooldown period.\n\nPlease search for other available donors.\n\nThank you,\nLifeLink Team");
                                    pstmtEmail.executeUpdate();
                                }
                            }
                        }
                    }
                }
            } else {
                // Rejected request: update status to 'rejected'
                String sqlRequest = "UPDATE blood_requests SET status = 'rejected' WHERE id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlRequest)) {
                    pstmt.setInt(1, requestId);
                    pstmt.executeUpdate();
                }
            }

            // 6. Log in request_responses
            String sqlResponse = "INSERT INTO request_responses (request_id, responder_id, responder_type, response, units_provided, notes) " +
                                 "VALUES (?, ?, 'donor', ?, ?, ?)";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlResponse)) {
                pstmt.setInt(1, requestId);
                pstmt.setInt(2, donorId);
                pstmt.setString(3, status.toLowerCase()); // 'accepted' or 'rejected'
                pstmt.setInt(4, status.equals("Accepted") ? unitsNeeded : 0);
                pstmt.setString(5, "Blood request " + status.toLowerCase() + " by donor: " + donorName);
                pstmt.executeUpdate();
            }

            // 7. Queue email notification targeting requesterId
            if (requesterId > 0) {
                String sqlEmail = "INSERT INTO email_notifications (user_id, subject, body, status) VALUES (?, ?, ?, 'queued')";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlEmail)) {
                    pstmt.setInt(1, requesterId);
                    pstmt.setString(2, "LifeLink - Blood Request " + status);
                    pstmt.setString(3, "Dear User,\n\nYour blood request (ID: " + requestId + ") has been " + status.toLowerCase() + " by donor " + donorName + ".\n\nThank you,\nLifeLink Team");
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
        String sql = "SELECT br.id as request_id, br.requester_id, br.units_needed, br.urgency, br.status, br.requested_at as request_date, br.notes, " +
                     "bg.name as blood_group, u.role as requester_role, u.full_name as user_full_name, " +
                     "r.date_of_birth as recipient_dob, h.hospital_name as hospital_name, h.address as hospital_address " +
                     "FROM blood_requests br " +
                     "JOIN blood_groups bg ON br.blood_group_id = bg.id " +
                     "JOIN users u ON br.requester_id = u.id " +
                     "LEFT JOIN recipients r ON u.id = r.user_id " +
                     "LEFT JOIN hospitals h ON u.id = h.user_id " +
                     "WHERE br.donor_id = ? AND br.status = 'completed' " +
                     "ORDER BY br.completed_at DESC, br.requested_at DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            
            pstmt.setInt(1, donorId);
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    BloodRequest br = new BloodRequest();
                    br.setId(rs.getInt("request_id"));
                    br.setDonorId(donorId);
                    br.setRequesterId(rs.getInt("requester_id"));
                    br.setBloodGroup(rs.getString("blood_group"));
                    br.setStatus(rs.getString("status"));
                    br.setRequestDate(rs.getTimestamp("request_date"));
                    br.setUnitsNeeded(rs.getInt("units_needed"));
                    br.setUrgency(rs.getString("urgency"));
                    
                    String role = rs.getString("requester_role");
                    br.setRequesterRole(role != null ? role.toLowerCase() : "recipient");
                    
                    String notes = rs.getString("notes");
                    parseNotesAndProfile(
                        br, 
                        notes, 
                        rs.getString("user_full_name"), 
                        rs.getString("hospital_name"), 
                        rs.getString("hospital_address"), 
                        rs.getDate("recipient_dob")
                    );
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

    public void seedDummyHospitalRequest(int donorId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Resolve donor's blood group ID
            int donorBloodGroupId = 1; // Default to A+
            String sqlDonorBG = "SELECT blood_group_id FROM donors WHERE user_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlDonorBG)) {
                pstmt.setInt(1, donorId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        donorBloodGroupId = rs.getInt("blood_group_id");
                    }
                }
            }

            // 2. Check if the dummy hospital user exists
            int hospitalUserId = 0;
            String sqlCheckUser = "SELECT id FROM users WHERE email = 'hospital.test@lifelink.com'";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlCheckUser)) {
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        hospitalUserId = rs.getInt("id");
                    }
                }
            }

            // 3. Create dummy hospital user if not exists
            if (hospitalUserId == 0) {
                String sqlInsertUser = "INSERT INTO users (full_name, email, password_hash, confirm_password_hash, role, is_active, is_approved) " +
                                       "VALUES ('City Care Hospital', 'hospital.test@lifelink.com', 'password', 'password', 'hospital', 1, 1)";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlInsertUser, Statement.RETURN_GENERATED_KEYS)) {
                    pstmt.executeUpdate();
                    try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            hospitalUserId = generatedKeys.getInt(1);
                        }
                    }
                }
            }

            if (hospitalUserId > 0) {
                // 4. Create hospital profile if not exists
                boolean hospitalExists = false;
                String sqlCheckHospital = "SELECT 1 FROM hospitals WHERE user_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlCheckHospital)) {
                    pstmt.setInt(1, hospitalUserId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        hospitalExists = rs.next();
                    }
                }

                if (!hospitalExists) {
                    String sqlInsertHospital = "INSERT INTO hospitals (user_id, hospital_name, district_id, address) " +
                                               "VALUES (?, 'City Care Hospital', 27, 'Maharajgunj, Kathmandu')";
                    try (PreparedStatement pstmt = conn.prepareStatement(sqlInsertHospital)) {
                        pstmt.setInt(1, hospitalUserId);
                        pstmt.executeUpdate();
                    }
                }

                // 5. Check if there is already a pending request from this hospital for this donor
                boolean requestExists = false;
                String sqlCheckRequest = "SELECT 1 FROM blood_requests WHERE requester_id = ? AND donor_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlCheckRequest)) {
                    pstmt.setInt(1, hospitalUserId);
                    pstmt.setInt(2, donorId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        requestExists = rs.next();
                    }
                }

                if (!requestExists) {
                    String sqlInsertRequest = "INSERT INTO blood_requests (requester_id, donor_id, blood_group_id, units_needed, urgency, status, notes) " +
                                              "VALUES (?, ?, ?, 2, 'urgent', 'pending', 'Urgent surgical blood requirement.')";
                    try (PreparedStatement pstmt = conn.prepareStatement(sqlInsertRequest)) {
                        pstmt.setInt(1, hospitalUserId);
                        pstmt.setInt(2, donorId);
                        pstmt.setInt(3, donorBloodGroupId);
                        pstmt.executeUpdate();
                    }
                }
            }

            conn.commit();
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
    }

    public void seedDummyRecipientRequest(int donorId) {
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Resolve donor's blood group ID
            int donorBloodGroupId = 1; // Default to A+
            String sqlDonorBG = "SELECT blood_group_id FROM donors WHERE user_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlDonorBG)) {
                pstmt.setInt(1, donorId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        donorBloodGroupId = rs.getInt("blood_group_id");
                    }
                }
            }

            // 2. Check if the dummy recipient user exists
            int recipientUserId = 0;
            String sqlCheckUser = "SELECT id FROM users WHERE email = 'recipient.test@lifelink.com'";
            try (PreparedStatement pstmt = conn.prepareStatement(sqlCheckUser)) {
                try (ResultSet rs = pstmt.executeQuery()) {
                    if (rs.next()) {
                        recipientUserId = rs.getInt("id");
                    }
                }
            }

            // 3. Create dummy recipient user if not exists
            if (recipientUserId == 0) {
                String sqlInsertUser = "INSERT INTO users (full_name, email, password_hash, confirm_password_hash, role, is_active, is_approved) " +
                                       "VALUES ('Sarah Recipient', 'recipient.test@lifelink.com', 'password', 'password', 'recipient', 1, 1)";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlInsertUser, Statement.RETURN_GENERATED_KEYS)) {
                    pstmt.executeUpdate();
                    try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                        if (generatedKeys.next()) {
                            recipientUserId = generatedKeys.getInt(1);
                        }
                    }
                }
            }

            if (recipientUserId > 0) {
                // 4. Create recipient profile if not exists
                boolean recipientExists = false;
                String sqlCheckRecipient = "SELECT 1 FROM recipients WHERE user_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlCheckRecipient)) {
                    pstmt.setInt(1, recipientUserId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        recipientExists = rs.next();
                    }
                }

                if (!recipientExists) {
                    String sqlInsertRecipient = "INSERT INTO recipients (user_id, blood_group_id, address, date_of_birth, gender) " +
                                                "VALUES (?, ?, 'Kathmandu, Nepal', '1998-05-15', 'female')";
                    try (PreparedStatement pstmt = conn.prepareStatement(sqlInsertRecipient)) {
                        pstmt.setInt(1, recipientUserId);
                        pstmt.setInt(2, donorBloodGroupId);
                        pstmt.executeUpdate();
                    }
                }

                // 5. Check if there is already a pending request from this recipient for this donor
                boolean requestExists = false;
                String sqlCheckRequest = "SELECT 1 FROM blood_requests WHERE requester_id = ? AND donor_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(sqlCheckRequest)) {
                    pstmt.setInt(1, recipientUserId);
                    pstmt.setInt(2, donorId);
                    try (ResultSet rs = pstmt.executeQuery()) {
                        requestExists = rs.next();
                    }
                }

                if (!requestExists) {
                    String sqlInsertRequest = "INSERT INTO blood_requests (requester_id, donor_id, blood_group_id, units_needed, urgency, status, notes) " +
                                              "VALUES (?, ?, ?, 3, 'critical', 'pending', 'Urgent blood required for major surgery.')";
                    try (PreparedStatement pstmt = conn.prepareStatement(sqlInsertRequest)) {
                        pstmt.setInt(1, recipientUserId);
                        pstmt.setInt(2, donorId);
                        pstmt.setInt(3, donorBloodGroupId);
                        pstmt.executeUpdate();
                    }
                }
            }

            conn.commit();
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
    }

    private void parseNotesAndProfile(BloodRequest br, String notes, String userFullName, String hospitalNameDb, String hospitalAddressDb, java.sql.Date recipientDob) {
        if ("hospital".equals(br.getRequesterRole())) {
            String hName = hospitalNameDb;
            if (hName == null || hName.trim().isEmpty()) {
                hName = userFullName;
            }
            br.setHospitalName(hName != null ? hName : "Hospital");
            br.setLocation(hospitalAddressDb != null && !hospitalAddressDb.trim().isEmpty() ? hospitalAddressDb : "Hospital Location");
            br.setPatientName("N/A");
            br.setPatientAge(0);
        } else {
            // Recipient request
            String patientName = userFullName;
            String hospitalName = "Hospital";
            
            if (notes != null && !notes.trim().isEmpty()) {
                String trimmedNotes = notes.trim();
                // Check if it's JSON
                if (trimmedNotes.startsWith("{") && trimmedNotes.endsWith("}")) {
                    try {
                        if (trimmedNotes.contains("\"patientName\"")) {
                            patientName = extractJsonField(trimmedNotes, "patientName");
                        } else if (trimmedNotes.contains("\"patient_name\"")) {
                            patientName = extractJsonField(trimmedNotes, "patient_name");
                        }
                        if (trimmedNotes.contains("\"hospitalName\"")) {
                            hospitalName = extractJsonField(trimmedNotes, "hospitalName");
                        } else if (trimmedNotes.contains("\"hospital_name\"")) {
                            hospitalName = extractJsonField(trimmedNotes, "hospital_name");
                        } else if (trimmedNotes.contains("\"hospital\"")) {
                            hospitalName = extractJsonField(trimmedNotes, "hospital");
                        }
                    } catch (Exception e) {
                        // Fallback
                    }
                } else {
                    // Check pipe-separated, comma-separated, or newline-separated key-value pairs
                    String[] parts = trimmedNotes.split("[|,\n]");
                    boolean parsedAny = false;
                    for (String part : parts) {
                        String clean = part.trim();
                        if (clean.toLowerCase().startsWith("patient:")) {
                            patientName = clean.substring(8).trim();
                            parsedAny = true;
                        } else if (clean.toLowerCase().startsWith("patient name:")) {
                            patientName = clean.substring(13).trim();
                            parsedAny = true;
                        } else if (clean.toLowerCase().startsWith("hospital:")) {
                            hospitalName = clean.substring(9).trim();
                            parsedAny = true;
                        } else if (clean.toLowerCase().startsWith("hospital name:")) {
                            hospitalName = clean.substring(14).trim();
                            parsedAny = true;
                        } else if (clean.toLowerCase().startsWith("location/hospital:")) {
                            hospitalName = clean.substring(18).trim();
                            parsedAny = true;
                        } else if (clean.toLowerCase().startsWith("location:")) {
                            hospitalName = clean.substring(9).trim();
                            parsedAny = true;
                        }
                    }
                    // Fallback if no specific keys were parsed
                    if (!parsedAny) {
                        hospitalName = trimmedNotes;
                    }
                }
            }
            
            // Age calculation from DOB
            int age = 0;
            if (recipientDob != null) {
                java.time.LocalDate birthDate = recipientDob.toLocalDate();
                java.time.LocalDate currentDate = java.time.LocalDate.now();
                age = java.time.Period.between(birthDate, currentDate).getYears();
            }
            
            br.setPatientName(patientName != null && !patientName.isEmpty() ? patientName : (userFullName != null ? userFullName : "Patient"));
            br.setPatientAge(age);
            br.setHospitalName(hospitalName != null && !hospitalName.isEmpty() ? hospitalName : "Hospital");
            br.setLocation(br.getHospitalName());
        }
    }

    private String extractJsonField(String json, String field) {
        int idx = json.indexOf("\"" + field + "\"");
        if (idx != -1) {
            int colonIdx = json.indexOf(":", idx);
            if (colonIdx != -1) {
                int startQuote = json.indexOf("\"", colonIdx);
                if (startQuote != -1) {
                    int endQuote = json.indexOf("\"", startQuote + 1);
                    if (endQuote != -1) {
                        return json.substring(startQuote + 1, endQuote);
                    }
                }
            }
        }
        return "";
    }
}

