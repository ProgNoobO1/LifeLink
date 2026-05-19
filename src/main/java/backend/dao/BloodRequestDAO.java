package backend.dao;

import backend.model.BloodRequest;
import backend.model.UsageHistory;
import backend.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BloodRequestDAO {

    /**
     * Get all requests for this hospital with requester info (joined from users table).
     */
    public List<BloodRequest> getRequestsByHospital(int hospitalId) {
        List<BloodRequest> list = new ArrayList<>();
        String sql = "SELECT br.*, u.full_name AS requester_name, u.phone AS requester_phone, "
                   + "u.email AS requester_email "
                   + "FROM blood_requests br "
                   + "JOIN users u ON br.requester_id = u.id "
                   + "WHERE br.hospital_id = ? "
                   + "ORDER BY br.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRequestResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get requests filtered by status.
     */
    public List<BloodRequest> getRequestsByStatus(int hospitalId, String status) {
        List<BloodRequest> list = new ArrayList<>();
        String sql = "SELECT br.*, u.full_name AS requester_name, u.phone AS requester_phone, "
                   + "u.email AS requester_email "
                   + "FROM blood_requests br "
                   + "JOIN users u ON br.requester_id = u.id "
                   + "WHERE br.hospital_id = ? AND br.status = ? "
                   + "ORDER BY br.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRequestResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get a single request by its ID with requester info.
     */
    public BloodRequest getRequestById(int requestId) {
        String sql = "SELECT br.*, u.full_name AS requester_name, u.phone AS requester_phone, "
                   + "u.email AS requester_email "
                   + "FROM blood_requests br "
                   + "JOIN users u ON br.requester_id = u.id "
                   + "WHERE br.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, requestId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRequestResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get count of pending requests for a hospital.
     */
    public int getPendingCount(int hospitalId) {
        String sql = "SELECT COUNT(*) AS cnt FROM blood_requests WHERE hospital_id = ? AND status = 'pending'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Update request status.
     */
    public boolean updateStatus(int requestId, String newStatus) {
        String sql = "UPDATE blood_requests SET status = ?, updated_at = NOW() WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, newStatus);
            ps.setInt(2, requestId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get all usage history for a hospital.
     */
    public List<UsageHistory> getUsageHistory(int hospitalId) {
        List<UsageHistory> list = new ArrayList<>();
        String sql = "SELECT uh.*, u.full_name AS requester_name "
                   + "FROM usage_history uh "
                   + "LEFT JOIN blood_requests br ON uh.request_id = br.id "
                   + "LEFT JOIN users u ON br.requester_id = u.id "
                   + "WHERE uh.hospital_id = ? "
                   + "ORDER BY uh.used_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UsageHistory h = new UsageHistory();
                    h.setId(rs.getInt("id"));
                    h.setHospitalId(rs.getInt("hospital_id"));
                    h.setBloodGroup(rs.getString("blood_group"));
                    h.setUnitsUsed(rs.getInt("units_used"));
                    int reqId = rs.getInt("request_id");
                    h.setRequestId(rs.wasNull() ? null : reqId);
                    h.setReason(rs.getString("reason"));
                    h.setUsedAt(rs.getTimestamp("used_at"));
                    h.setRequesterName(rs.getString("requester_name"));
                    list.add(h);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Insert a usage history record.
     */
    public boolean addUsageHistory(int hospitalId, String bloodGroup,
                                    int unitsUsed, Integer requestId, String reason) {
        String sql = "INSERT INTO usage_history (hospital_id, blood_group, units_used, request_id, reason) "
                   + "VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            ps.setString(2, bloodGroup);
            ps.setInt(3, unitsUsed);
            if (requestId != null) {
                ps.setInt(4, requestId);
            } else {
                ps.setNull(4, Types.INTEGER);
            }
            ps.setString(5, reason);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get total count of requests for a hospital.
     */
    public int getTotalRequestCount(int hospitalId) {
        String sql = "SELECT COUNT(*) AS cnt FROM blood_requests WHERE hospital_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get count of requests by status.
     */
    public int getCountByStatus(int hospitalId, String status) {
        String sql = "SELECT COUNT(*) AS cnt FROM blood_requests WHERE hospital_id = ? AND status = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            ps.setString(2, status);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt("cnt");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * INTEGRATION POINT: Member 4 (Search/Request) 
     * Get all requests by a specific requester (for recipient's "My Requests").
     */
    /*
    public List<BloodRequest> getByRequesterId(int requesterId) {
        List<BloodRequest> list = new ArrayList<>();
        String sql = "SELECT br.*, u.full_name AS requester_name, u.phone AS requester_phone, "
                   + "u.email AS requester_email, h.hospital_name "
                   + "FROM blood_requests br "
                   + "JOIN users u ON br.requester_id = u.id "
                   + "LEFT JOIN hospitals h ON br.hospital_id = h.id "
                   + "WHERE br.requester_id = ? "
                   + "ORDER BY br.created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, requesterId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BloodRequest r = mapRequestResultSet(rs);
                    try { r.setHospitalName(rs.getString("hospital_name")); }
                    catch (SQLException ignored) {}
                    list.add(r);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    */

    /**
     * INTEGRATION POINT: Member 2 (Donor)
     * Get recent requests matching a blood group (for donor awareness).
     */
    /*
    public List<BloodRequest> getByBloodGroup(String bloodGroup, int limit) {
        List<BloodRequest> list = new ArrayList<>();
        String sql = "SELECT br.*, u.full_name AS requester_name, u.phone AS requester_phone, "
                   + "u.email AS requester_email "
                   + "FROM blood_requests br "
                   + "JOIN users u ON br.requester_id = u.id "
                   + "WHERE br.blood_group = ? AND br.status IN ('pending','accepted') "
                   + "ORDER BY br.created_at DESC LIMIT ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, bloodGroup);
            ps.setInt(2, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRequestResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    */

    /**
     * Create a new blood request.
     */
    public boolean createRequest(BloodRequest br) {
        String sql = "INSERT INTO blood_requests (requester_id, hospital_id, blood_group, "
                   + "units_needed, status, message) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, br.getRequesterId());
            if (br.getHospitalId() > 0) {
                ps.setInt(2, br.getHospitalId());
            } else {
                ps.setNull(2, Types.INTEGER);
            }
            ps.setString(3, br.getBloodGroup());
            ps.setInt(4, br.getUnitsNeeded());
            ps.setString(5, br.getStatus() != null ? br.getStatus() : "pending");
            ps.setString(6, br.getMessage());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Map a ResultSet row to a BloodRequest object.
     */
    private BloodRequest mapRequestResultSet(ResultSet rs) throws SQLException {
        BloodRequest r = new BloodRequest();
        r.setId(rs.getInt("id"));
        r.setRequesterId(rs.getInt("requester_id"));
        r.setHospitalId(rs.getInt("hospital_id"));
        r.setBloodGroup(rs.getString("blood_group"));
        r.setUnitsNeeded(rs.getInt("units_needed"));
        r.setStatus(rs.getString("status"));
        r.setMessage(rs.getString("message"));
        r.setCreatedAt(rs.getTimestamp("created_at"));
        r.setUpdatedAt(rs.getTimestamp("updated_at"));
        r.setRequesterName(rs.getString("requester_name"));
        r.setRequesterPhone(rs.getString("requester_phone"));
        r.setRequesterEmail(rs.getString("requester_email"));
        return r;
    }
}
