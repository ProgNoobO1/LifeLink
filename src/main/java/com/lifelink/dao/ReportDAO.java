package com.lifelink.dao;

import com.lifelink.model.BloodRequest;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.*;


public class ReportDAO {

    public List<Map<String, Object>> getMonthlyDonations(LocalDate fromDate, LocalDate toDate) {
        String sql = "SELECT DATE_FORMAT(donation_date, '%Y-%m') AS month, COUNT(*) AS count, SUM(units) AS units " +
                     "FROM donations WHERE donation_date BETWEEN ? AND ? " +
                     "GROUP BY DATE_FORMAT(donation_date, '%Y-%m') ORDER BY month";
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
        String sql = "SELECT blood_group, COUNT(*) AS count FROM users WHERE blood_group IS NOT NULL AND blood_group != '' GROUP BY blood_group ORDER BY count DESC";
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
                if ("APPROVED".equalsIgnoreCase(status)) {
                    map.put("FULFILLED", count);
                } else if ("PENDING".equalsIgnoreCase(status)) {
                    map.put("PENDING", count);
                } else if ("REJECTED".equalsIgnoreCase(status)) {
                    map.put("REJECTED", count);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    public List<Map<String, Object>> getTopDonors(int limit, LocalDate fromDate, LocalDate toDate) {
        String sql = "SELECT donor_name, donor_email, blood_group, SUM(units) AS total_units, COUNT(*) AS total_donations " +
                     "FROM donations WHERE donation_date BETWEEN ? AND ? " +
                     "GROUP BY donor_name, donor_email, blood_group " +
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
        String sql = "SELECT COALESCE(SUM(units), 0) AS total FROM donations WHERE donation_date BETWEEN ? AND ?";
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
        String sql = "SELECT donor_name, donor_email, blood_group, units, donation_date FROM donations WHERE donation_date BETWEEN ? AND ? ORDER BY donation_date DESC";
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
