package com.lifelink.dao;

import com.lifelink.model.BloodRequest;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class BloodRequestDAO {

    private static BloodRequest.Status dbToStatus(String dbStatus) {
        String s = dbStatus.toLowerCase();
        if ("pending".equals(s)) return BloodRequest.Status.PENDING;
        if ("accepted".equals(s) || "completed".equals(s)) return BloodRequest.Status.APPROVED;
        if ("rejected".equals(s) || "cancelled".equals(s)) return BloodRequest.Status.REJECTED;
        return BloodRequest.Status.PENDING;
    }

    private static String statusToDb(BloodRequest.Status status) {
        if (status == BloodRequest.Status.PENDING) return "pending";
        if (status == BloodRequest.Status.APPROVED) return "completed";
        return "rejected";
    }

    private BloodRequest mapResultSet(ResultSet rs) throws SQLException {
        BloodRequest req = new BloodRequest();
        req.setId(rs.getLong("id"));
        req.setRequesterName(rs.getString("requester_name"));
        req.setRequesterEmail(rs.getString("requester_email"));
        req.setBloodGroup(rs.getString("blood_group"));
        req.setUnits(rs.getInt("units_needed"));
        Timestamp requestedAt = rs.getTimestamp("requested_at");
        req.setRequestDate(requestedAt != null ? requestedAt.toLocalDateTime().toLocalDate() : null);
        req.setStatus(dbToStatus(rs.getString("status")));
        return req;
    }

    private static final String BASE_SQL =
        "SELECT br.*, u.full_name as requester_name, u.email as requester_email, bg.name as blood_group " +
        "FROM blood_requests br " +
        "JOIN users u ON br.requester_id = u.id " +
        "JOIN blood_groups bg ON br.blood_group_id = bg.id ";

    public List<BloodRequest> findAll() {
        String sql = BASE_SQL + "ORDER BY br.requested_at DESC, br.id DESC";
        List<BloodRequest> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
        return list;
    }

    public BloodRequest findById(Long id) {
        String sql = BASE_SQL + "WHERE br.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateStatus(Long id, BloodRequest.Status status) {
        String sql = "UPDATE blood_requests SET status = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, statusToDb(status));
            stmt.setLong(2, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public long countAll() {
        String sql = "SELECT COUNT(*) FROM blood_requests";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<BloodRequest> findByStatus(BloodRequest.Status status) {
        String sql = BASE_SQL + "WHERE br.status = ? ORDER BY br.requested_at DESC, br.id DESC";
        List<BloodRequest> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, statusToDb(status));
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
        return list;
    }

    public List<BloodRequest> findByBloodGroup(String bloodGroup) {
        String sql = BASE_SQL + "WHERE bg.name = ? ORDER BY br.requested_at DESC, br.id DESC";
        List<BloodRequest> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bloodGroup);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
        return list;
    }

    public List<BloodRequest> search(String keyword) {
        String sql = BASE_SQL +
            "WHERE u.full_name LIKE ? OR u.email LIKE ? OR bg.name LIKE ? " +
            "ORDER BY br.requested_at DESC, br.id DESC";
        List<BloodRequest> list = new ArrayList<>();
        String pattern = "%" + keyword + "%";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, pattern);
            stmt.setString(2, pattern);
            stmt.setString(3, pattern);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
        return list;
    }

    public List<BloodRequest> findAllSorted(String sortOrder) {
        String order = "DESC";
        if ("oldest".equalsIgnoreCase(sortOrder)) {
            order = "ASC";
        }
        String sql = BASE_SQL + "ORDER BY br.requested_at " + order + ", br.id " + order;
        List<BloodRequest> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
        return list;
    }

    public long countByStatus(BloodRequest.Status status) {
        String sql = "SELECT COUNT(*) FROM blood_requests WHERE status = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, statusToDb(status));
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }
}
