package com.lifelink.dao;

import com.lifelink.model.AdminActivityLog;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class AdminActivityLogDAO {

    private AdminActivityLog mapResultSet(ResultSet rs) throws SQLException {
        AdminActivityLog log = new AdminActivityLog();
        log.setId(rs.getInt("id"));
        log.setAdminId(rs.getInt("admin_id"));
        log.setAction(rs.getString("action"));
        log.setTargetType(rs.getString("target_type"));
        log.setTargetId(rs.getObject("target_id") != null ? rs.getInt("target_id") : null);
        log.setDetail(rs.getString("detail"));
        Timestamp performedAt = rs.getTimestamp("performed_at");
        if (performedAt != null) log.setPerformedAt(performedAt.toLocalDateTime());
        return log;
    }

    public boolean save(AdminActivityLog log) {
        String sql = "INSERT INTO admin_activity_log (admin_id, action, target_type, target_id, detail, performed_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, log.getAdminId());
            stmt.setString(2, log.getAction());
            stmt.setString(3, log.getTargetType());
            if (log.getTargetId() != null) stmt.setInt(4, log.getTargetId()); else stmt.setNull(4, Types.INTEGER);
            stmt.setString(5, log.getDetail());
            stmt.setTimestamp(6, Timestamp.valueOf(log.getPerformedAt() != null ? log.getPerformedAt() : LocalDateTime.now()));
            int affected = stmt.executeUpdate();
            if (affected == 0) return false;
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) log.setId(keys.getInt(1));
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public AdminActivityLog findById(Integer id) {
        String sql = "SELECT * FROM admin_activity_log WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<AdminActivityLog> findByAdminId(Integer adminId) {
        String sql = "SELECT * FROM admin_activity_log WHERE admin_id = ? ORDER BY performed_at DESC";
        List<AdminActivityLog> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, adminId);
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

    public List<AdminActivityLog> findAll() {
        String sql = "SELECT * FROM admin_activity_log ORDER BY performed_at DESC";
        List<AdminActivityLog> list = new ArrayList<>();
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

    public boolean update(AdminActivityLog log) {
        String sql = "UPDATE admin_activity_log SET admin_id = ?, action = ?, target_type = ?, target_id = ?, detail = ?, performed_at = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, log.getAdminId());
            stmt.setString(2, log.getAction());
            stmt.setString(3, log.getTargetType());
            if (log.getTargetId() != null) stmt.setInt(4, log.getTargetId()); else stmt.setNull(4, Types.INTEGER);
            stmt.setString(5, log.getDetail());
            stmt.setTimestamp(6, Timestamp.valueOf(log.getPerformedAt() != null ? log.getPerformedAt() : LocalDateTime.now()));
            stmt.setInt(7, log.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Integer id) {
        String sql = "DELETE FROM admin_activity_log WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
