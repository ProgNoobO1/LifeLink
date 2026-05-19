package backend.dao;

import backend.model.Hospital;
import backend.utils.DBConnection;

import java.sql.*;

public class HospitalDAO {

    /*
     * =========================================================================
     * INTEGRATION POINT:
     * This HospitalDAO is strictly for managing Hospital-specific data.
     * However, it relies heavily on the `users` table for common user data
     * (like email, password, role, etc.). 
     * 
     * IMPORTANT: The Admin/Auth module is responsible for creating records 
     * in the `users` table. Once a user is created with role='hospital',
     * they will have a `user_id`. This `user_id` is then linked here in the 
     * `hospitals` table. 
     * 
     * The `getHospitalByUserId` method below demonstrates this JOIN. 
     * Ensure your teammates maintaining the Admin module create and approve 
     * the user correctly before they log into the Hospital dashboard.
     * =========================================================================
     */

    /**
     * Get hospital profile by logged-in user's ID.
     * Joins with users table to get contact info.
     */
    public Hospital getHospitalByUserId(int userId) {
        String sql = "SELECT h.user_id AS hospital_id, h.user_id, h.hospital_name, h.license_no, h.district_id, h.address, "
                + "h.latitude, h.longitude, h.contact_person, h.website, "
                + "u.full_name AS name, u.email, u.phone "
                + "FROM hospitals h "
                + "JOIN users u ON h.user_id = u.id "
                + "WHERE h.user_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Hospital h = new Hospital();
                    h.setId(rs.getInt("hospital_id")); // hospitals.id (actual PK used by blood_stock FK)
                    h.setUserId(rs.getInt("user_id"));
                    h.setHospitalName(rs.getString("hospital_name"));
                    h.setLicenseNo(rs.getString("license_no"));
                    h.setDistrictId(rs.getInt("district_id"));
                    h.setAddress(rs.getString("address"));
                    
                    h.setLatitude(rs.getObject("latitude") != null ? rs.getDouble("latitude") : null);
                    h.setLongitude(rs.getObject("longitude") != null ? rs.getDouble("longitude") : null);
                    
                    h.setContactPerson(rs.getString("contact_person"));
                    h.setWebsite(rs.getString("website"));
                    
                    h.setName(rs.getString("name"));
                    h.setEmail(rs.getString("email"));
                    h.setPhone(rs.getString("phone"));
                    return h;
                }
            }
        } catch (SQLException e) {
            System.out.println("[LifeLink] Full profile query failed. Missing columns? Falling back to basic query.");
            
            // Fallback query without the new columns
            String fallbackSql = "SELECT h.user_id AS hospital_id, h.user_id, h.hospital_name, h.address, "
                               + "u.full_name AS name, u.email, u.phone "
                               + "FROM hospitals h JOIN users u ON h.user_id = u.id WHERE h.user_id = ?";
            try (Connection conn = DBConnection.getConnection();
                 PreparedStatement ps = conn.prepareStatement(fallbackSql)) {
                ps.setInt(1, userId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Hospital h = new Hospital();
                        h.setId(rs.getInt("hospital_id"));
                        h.setUserId(rs.getInt("user_id"));
                        h.setHospitalName(rs.getString("hospital_name"));
                        h.setAddress(rs.getString("address"));
                        h.setName(rs.getString("name"));
                        h.setEmail(rs.getString("email"));
                        h.setPhone(rs.getString("phone"));
                        return h;
                    }
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        return null;
    }

    // Stores the last error message for debugging
    private String lastError = "";
    public String getLastError() { return lastError; }

    /**
     * Update hospital profile information.
     * Uses check-then-insert-or-update logic for maximum compatibility.
     */
    public boolean updateHospitalProfile(Hospital h) {
        lastError = "";
        
        // First check if hospital row already exists for this user
        boolean exists = false;
        String checkSql = "SELECT COUNT(*) FROM hospitals WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(checkSql)) {
            ps.setInt(1, h.getUserId());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) exists = rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            lastError = "Check failed: " + e.getMessage();
            e.printStackTrace();
            return false;
        }

        String sql;
        if (exists) {
            sql = "UPDATE hospitals SET hospital_name=?, address=? WHERE user_id=?";
        } else {
            sql = "INSERT INTO hospitals (hospital_name, address, user_id) VALUES (?, ?, ?)";
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, h.getHospitalName());
            ps.setString(2, h.getAddress());
            ps.setInt(3, h.getUserId());

            boolean result = ps.executeUpdate() > 0;
            
            if (result) {
                // Now try to update the extra columns separately (they may not exist yet)
                updateExtraFields(h);
            }
            
            return result;

        } catch (SQLException e) {
            lastError = (exists ? "UPDATE" : "INSERT") + " failed: " + e.getMessage();
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Try to update the extra profile columns. 
     * If columns don't exist yet, this fails silently — base profile still saves.
     */
    private void updateExtraFields(Hospital h) {
        String sql = "UPDATE hospitals SET license_no=?, district_id=?, latitude=?, longitude=?, "
                   + "contact_person=?, website=? WHERE user_id=?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, h.getLicenseNo());
            if (h.getDistrictId() > 0) ps.setInt(2, h.getDistrictId()); else ps.setNull(2, Types.INTEGER);
            if (h.getLatitude() != null) ps.setDouble(3, h.getLatitude()); else ps.setNull(3, Types.DECIMAL);
            if (h.getLongitude() != null) ps.setDouble(4, h.getLongitude()); else ps.setNull(4, Types.DECIMAL);
            ps.setString(5, h.getContactPerson());
            ps.setString(6, h.getWebsite());
            ps.setInt(7, h.getUserId());

            ps.executeUpdate();
        } catch (SQLException e) {
            // Extra columns may not exist yet — log but don't fail
            System.out.println("[LifeLink] Extra profile columns not updated (columns may be missing): " + e.getMessage());
            System.out.println("[LifeLink] Run ALTER TABLE to add: license_no, district_id, latitude, longitude, contact_person, website");
        }
    }

    /**
     * Get all hospitals (for dropdowns in request forms).
     */
    public java.util.List<Hospital> getAllHospitals() {
        java.util.List<Hospital> list = new java.util.ArrayList<>();
        String sql = "SELECT h.user_id AS hospital_id, h.user_id, h.hospital_name, h.license_no, h.district_id, h.address, "
                   + "h.latitude, h.longitude, h.contact_person, h.website, "
                   + "u.full_name AS name, u.email, u.phone "
                   + "FROM hospitals h JOIN users u ON h.user_id = u.id "
                   + "WHERE u.is_approved = 1 ORDER BY h.hospital_name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Hospital h = new Hospital();
                h.setId(rs.getInt("hospital_id"));
                h.setUserId(rs.getInt("user_id"));
                h.setHospitalName(rs.getString("hospital_name"));
                h.setLicenseNo(rs.getString("license_no"));
                h.setDistrictId(rs.getInt("district_id"));
                h.setAddress(rs.getString("address"));
                h.setLatitude(rs.getObject("latitude") != null ? rs.getDouble("latitude") : null);
                h.setLongitude(rs.getObject("longitude") != null ? rs.getDouble("longitude") : null);
                h.setContactPerson(rs.getString("contact_person"));
                h.setWebsite(rs.getString("website"));
                h.setName(rs.getString("name"));
                h.setEmail(rs.getString("email"));
                h.setPhone(rs.getString("phone"));
                list.add(h);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
