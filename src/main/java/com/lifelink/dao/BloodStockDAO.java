package com.lifelink.dao;

import com.lifelink.model.BloodStock;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class BloodStockDAO {

    private BloodStock mapResultSet(ResultSet rs) throws SQLException {
        BloodStock bs = new BloodStock();
        bs.setId(rs.getInt("id"));
        bs.setHospitalId(rs.getInt("hospital_id"));
        bs.setBloodGroupId(rs.getInt("blood_group_id"));
        bs.setUnitsAvailable(rs.getInt("units_available"));
        bs.setLowStockThreshold(rs.getInt("low_stock_threshold"));
        Timestamp lastUpdated = rs.getTimestamp("last_updated");
        if (lastUpdated != null) bs.setLastUpdated(lastUpdated.toLocalDateTime());
        bs.setHospitalName(rs.getString("hospital_name"));
        bs.setBloodGroupName(rs.getString("blood_group_name"));
        return bs;
    }

    public boolean save(BloodStock stock) {
        String sql = "INSERT INTO blood_stock (hospital_id, blood_group_id, units_available, low_stock_threshold) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, stock.getHospitalId());
            stmt.setInt(2, stock.getBloodGroupId());
            stmt.setInt(3, stock.getUnitsAvailable());
            stmt.setInt(4, stock.getLowStockThreshold());
            int affected = stmt.executeUpdate();
            if (affected == 0) return false;
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) stock.setId(keys.getInt(1));
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public BloodStock findById(Integer id) {
        String sql = "SELECT bs.*, h.hospital_name, bg.name as blood_group_name " +
                     "FROM blood_stock bs " +
                     "JOIN hospitals h ON bs.hospital_id = h.user_id " +
                     "JOIN blood_groups bg ON bs.blood_group_id = bg.id " +
                     "WHERE bs.id = ?";
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

    public List<BloodStock> findAll() {
        String sql = "SELECT bs.*, h.hospital_name, bg.name as blood_group_name " +
                     "FROM blood_stock bs " +
                     "JOIN hospitals h ON bs.hospital_id = h.user_id " +
                     "JOIN blood_groups bg ON bs.blood_group_id = bg.id " +
                     "ORDER BY bs.id DESC";
        List<BloodStock> list = new ArrayList<>();
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

    public boolean update(BloodStock stock) {
        String sql = "UPDATE blood_stock SET hospital_id = ?, blood_group_id = ?, units_available = ?, low_stock_threshold = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, stock.getHospitalId());
            stmt.setInt(2, stock.getBloodGroupId());
            stmt.setInt(3, stock.getUnitsAvailable());
            stmt.setInt(4, stock.getLowStockThreshold());
            stmt.setInt(5, stock.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Integer id) {
        String sql = "DELETE FROM blood_stock WHERE id = ?";
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
