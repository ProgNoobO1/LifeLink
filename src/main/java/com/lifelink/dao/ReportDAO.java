package com.lifelink.dao;

import com.lifelink.model.BloodRequest;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.*;


public class ReportDAO {

    public List<Map<String, Object>> getMonthlyDonations(LocalDate fromDate, LocalDate toDate) {
        String sql = "SELECT DATE_FORMAT(donated_at, '%Y-%m') AS month, COUNT(*) AS count, SUM(units_donated) AS units " +
                     "FROM donation_history WHERE donated_at BETWEEN ? AND ? " +
                     "GROUP BY DATE_FORMAT(donated_at, '%Y-%m') ORDER BY month";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, java.sql.Date.valueOf(fromDate));
            stmt.setDate(2, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("month", rs.getString("month"));
                    m.put("count", rs.getInt("count"));
                    m.put("units", rs.getInt("units"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Map<String, Object>> getBloodGroupDistribution() {
        String sql = "SELECT bg.name as blood_group, COUNT(*) AS count FROM users u JOIN blood_groups bg ON u.blood_group_id = bg.id WHERE u.blood_group_id IS NOT NULL GROUP BY bg.name ORDER BY count DESC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new HashMap<>();
                m.put("bloodGroup", rs.getString("blood_group"));
                m.put("count", rs.getInt("count"));
                list.add(m);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Map<String, Long> getRequestFulfillmentStats() {
        String sql = "SELECT status, COUNT(*) AS count FROM blood_requests GROUP BY status";
        Map<String, Long> map = new HashMap<>();
        map.put("FULFILLED", 0L);
        map.put("PENDING", 0L);
        map.put("REJECTED", 0L);
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                String status = rs.getString("status");
                long count = rs.getLong("count");
                if ("completed".equalsIgnoreCase(status) || "accepted".equalsIgnoreCase(status)) {
                    map.put("FULFILLED", map.get("FULFILLED") + count);
                } else if ("pending".equalsIgnoreCase(status)) {
                    map.put("PENDING", map.get("PENDING") + count);
                } else if ("rejected".equalsIgnoreCase(status) || "cancelled".equalsIgnoreCase(status)) {
                    map.put("REJECTED", map.get("REJECTED") + count);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    public List<Map<String, Object>> getTopDonors(int limit, LocalDate fromDate, LocalDate toDate) {
        String sql = "SELECT u.full_name as donor_name, u.email as donor_email, bg.name as blood_group, SUM(dh.units_donated) AS total_units, COUNT(*) AS total_donations " +
                     "FROM donation_history dh " +
                     "JOIN donors d ON dh.donor_id = d.user_id " +
                     "JOIN users u ON d.user_id = u.id " +
                     "JOIN blood_groups bg ON dh.blood_group_id = bg.id " +
                     "WHERE dh.donated_at BETWEEN ? AND ? " +
                     "GROUP BY u.full_name, u.email, bg.name " +
                     "ORDER BY total_units DESC LIMIT ?";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, java.sql.Date.valueOf(fromDate));
            stmt.setDate(2, java.sql.Date.valueOf(toDate));
            stmt.setInt(3, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", rs.getString("donor_name"));
                    m.put("email", rs.getString("donor_email"));
                    m.put("bloodGroup", rs.getString("blood_group"));
                    m.put("totalUnits", rs.getInt("total_units"));
                    m.put("totalDonations", rs.getInt("total_donations"));
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public int getTotalDonationsInRange(LocalDate fromDate, LocalDate toDate) {
        String sql = "SELECT COALESCE(SUM(units_donated), 0) AS total FROM donation_history WHERE donated_at BETWEEN ? AND ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, java.sql.Date.valueOf(fromDate));
            stmt.setDate(2, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return rs.getInt("total");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<Map<String, Object>> getDonationsForExport(LocalDate fromDate, LocalDate toDate) {
        String sql = "SELECT u.full_name as donor_name, u.email as donor_email, bg.name as blood_group, dh.units_donated as units, dh.donated_at as donation_date " +
                     "FROM donation_history dh " +
                     "JOIN donors d ON dh.donor_id = d.user_id " +
                     "JOIN users u ON d.user_id = u.id " +
                     "JOIN blood_groups bg ON dh.blood_group_id = bg.id " +
                     "WHERE dh.donated_at BETWEEN ? AND ? ORDER BY dh.donated_at DESC";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setDate(1, java.sql.Date.valueOf(fromDate));
            stmt.setDate(2, java.sql.Date.valueOf(toDate));
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> m = new HashMap<>();
                    m.put("name", rs.getString("donor_name"));
                    m.put("email", rs.getString("donor_email"));
                    m.put("bloodGroup", rs.getString("blood_group"));
                    m.put("units", rs.getInt("units"));
                    m.put("date", rs.getDate("donation_date").toLocalDate());
                    list.add(m);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
