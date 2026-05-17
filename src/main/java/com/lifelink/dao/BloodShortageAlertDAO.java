package com.lifelink.dao;

import com.lifelink.model.BloodShortageAlert;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class BloodShortageAlertDAO {

    private BloodShortageAlert mapResultSet(ResultSet rs) throws SQLException {
        BloodShortageAlert alert = new BloodShortageAlert();
        alert.setId(rs.getInt("id"));
        alert.setHospitalId(rs.getInt("hospital_id"));
        alert.setBloodGroupId(rs.getInt("blood_group_id"));
        alert.setUnitsAtAlert(rs.getInt("units_at_alert"));
        alert.setResolved(rs.getInt("is_resolved") == 1);
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) alert.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp resolvedAt = rs.getTimestamp("resolved_at");
        if (resolvedAt != null) alert.setResolvedAt(resolvedAt.toLocalDateTime());
        alert.setHospitalName(rs.getString("hospital_name"));
        alert.setBloodGroupName(rs.getString("blood_group_name"));
        return alert;
    }

    public boolean save(BloodShortageAlert alert) {
        String sql = "INSERT INTO blood_shortage_alerts (hospital_id, blood_group_id, units_at_alert, is_resolved, resolved_at) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, alert.getHospitalId());
            stmt.setInt(2, alert.getBloodGroupId());
            stmt.setInt(3, alert.getUnitsAtAlert());
            stmt.setInt(4, alert.isResolved() ? 1 : 0);
            if (alert.getResolvedAt() != null) stmt.setTimestamp(5, Timestamp.valueOf(alert.getResolvedAt())); else stmt.setNull(5, Types.TIMESTAMP);
            int affected = stmt.executeUpdate();
            if (affected == 0) return false;
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) alert.setId(keys.getInt(1));
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public BloodShortageAlert findById(Integer id) {
        String sql = "SELECT a.*, h.hospital_name, bg.name as blood_group_name " +
                     "FROM blood_shortage_alerts a " +
                     "JOIN hospitals h ON a.hospital_id = h.user_id " +
                     "JOIN blood_groups bg ON a.blood_group_id = bg.id " +
                     "WHERE a.id = ?";
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

    public List<BloodShortageAlert> findAll() {
        String sql = "SELECT a.*, h.hospital_name, bg.name as blood_group_name " +
                     "FROM blood_shortage_alerts a " +
                     "JOIN hospitals h ON a.hospital_id = h.user_id " +
                     "JOIN blood_groups bg ON a.blood_group_id = bg.id " +
                     "ORDER BY a.created_at DESC";
        List<BloodShortageAlert> list = new ArrayList<>();
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

    public List<BloodShortageAlert> findUnresolved() {
        String sql = "SELECT a.*, h.hospital_name, bg.name as blood_group_name " +
                     "FROM blood_shortage_alerts a " +
                     "JOIN hospitals h ON a.hospital_id = h.user_id " +
                     "JOIN blood_groups bg ON a.blood_group_id = bg.id " +
                     "WHERE a.is_resolved = 0 ORDER BY a.created_at DESC";
        List<BloodShortageAlert> list = new ArrayList<>();
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

    public boolean update(BloodShortageAlert alert) {
        String sql = "UPDATE blood_shortage_alerts SET hospital_id = ?, blood_group_id = ?, units_at_alert = ?, is_resolved = ?, resolved_at = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, alert.getHospitalId());
            stmt.setInt(2, alert.getBloodGroupId());
            stmt.setInt(3, alert.getUnitsAtAlert());
            stmt.setInt(4, alert.isResolved() ? 1 : 0);
            if (alert.getResolvedAt() != null) stmt.setTimestamp(5, Timestamp.valueOf(alert.getResolvedAt())); else stmt.setNull(5, Types.TIMESTAMP);
            stmt.setInt(6, alert.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Integer id) {
        String sql = "DELETE FROM blood_shortage_alerts WHERE id = ?";
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
