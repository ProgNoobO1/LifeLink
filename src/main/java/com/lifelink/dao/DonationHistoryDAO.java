package com.lifelink.dao;

import com.lifelink.model.DonationHistory;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class DonationHistoryDAO {

    private DonationHistory mapResultSet(ResultSet rs) throws SQLException {
        DonationHistory dh = new DonationHistory();
        dh.setId(rs.getInt("id"));
        dh.setDonorId(rs.getInt("donor_id"));
        dh.setHospitalId(rs.getObject("hospital_id") != null ? rs.getInt("hospital_id") : null);
        dh.setRequestId(rs.getObject("request_id") != null ? rs.getInt("request_id") : null);
        dh.setBloodGroupId(rs.getInt("blood_group_id"));
        dh.setUnitsDonated(rs.getInt("units_donated"));
        Date donatedAt = rs.getDate("donated_at");
        if (donatedAt != null) dh.setDonatedAt(donatedAt.toLocalDate());
        dh.setVerified(rs.getInt("verified") == 1);
        dh.setDonorName(rs.getString("donor_name"));
        dh.setDonorEmail(rs.getString("donor_email"));
        dh.setHospitalName(rs.getString("hospital_name"));
        dh.setBloodGroupName(rs.getString("blood_group_name"));
        return dh;
    }

    public boolean save(DonationHistory dh) {
        String sql = "INSERT INTO donation_history (donor_id, hospital_id, request_id, blood_group_id, units_donated, donated_at, verified) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, dh.getDonorId());
            if (dh.getHospitalId() != null) stmt.setInt(2, dh.getHospitalId()); else stmt.setNull(2, Types.INTEGER);
            if (dh.getRequestId() != null) stmt.setInt(3, dh.getRequestId()); else stmt.setNull(3, Types.INTEGER);
            stmt.setInt(4, dh.getBloodGroupId());
            stmt.setInt(5, dh.getUnitsDonated());
            stmt.setDate(6, Date.valueOf(dh.getDonatedAt()));
            stmt.setInt(7, dh.isVerified() ? 1 : 0);
            int affected = stmt.executeUpdate();
            if (affected == 0) return false;
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) dh.setId(keys.getInt(1));
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public DonationHistory findById(Integer id) {
        String sql = "SELECT dh.*, u.full_name as donor_name, u.email as donor_email, h.hospital_name, bg.name as blood_group_name " +
                     "FROM donation_history dh " +
                     "JOIN donors d ON dh.donor_id = d.user_id " +
                     "JOIN users u ON d.user_id = u.id " +
                     "LEFT JOIN hospitals h ON dh.hospital_id = h.user_id " +
                     "JOIN blood_groups bg ON dh.blood_group_id = bg.id " +
                     "WHERE dh.id = ?";
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

    public List<DonationHistory> findAll() {
        String sql = "SELECT dh.*, u.full_name as donor_name, u.email as donor_email, h.hospital_name, bg.name as blood_group_name " +
                     "FROM donation_history dh " +
                     "JOIN donors d ON dh.donor_id = d.user_id " +
                     "JOIN users u ON d.user_id = u.id " +
                     "LEFT JOIN hospitals h ON dh.hospital_id = h.user_id " +
                     "JOIN blood_groups bg ON dh.blood_group_id = bg.id " +
                     "ORDER BY dh.donated_at DESC";
        List<DonationHistory> list = new ArrayList<>();
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

    public List<DonationHistory> findByDonorId(Integer donorId) {
        String sql = "SELECT dh.*, u.full_name as donor_name, u.email as donor_email, h.hospital_name, bg.name as blood_group_name " +
                     "FROM donation_history dh " +
                     "JOIN donors d ON dh.donor_id = d.user_id " +
                     "JOIN users u ON d.user_id = u.id " +
                     "LEFT JOIN hospitals h ON dh.hospital_id = h.user_id " +
                     "JOIN blood_groups bg ON dh.blood_group_id = bg.id " +
                     "WHERE dh.donor_id = ? ORDER BY dh.donated_at DESC";
        List<DonationHistory> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, donorId);
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

    public boolean update(DonationHistory dh) {
        String sql = "UPDATE donation_history SET donor_id = ?, hospital_id = ?, request_id = ?, blood_group_id = ?, units_donated = ?, donated_at = ?, verified = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, dh.getDonorId());
            if (dh.getHospitalId() != null) stmt.setInt(2, dh.getHospitalId()); else stmt.setNull(2, Types.INTEGER);
            if (dh.getRequestId() != null) stmt.setInt(3, dh.getRequestId()); else stmt.setNull(3, Types.INTEGER);
            stmt.setInt(4, dh.getBloodGroupId());
            stmt.setInt(5, dh.getUnitsDonated());
            stmt.setDate(6, Date.valueOf(dh.getDonatedAt()));
            stmt.setInt(7, dh.isVerified() ? 1 : 0);
            stmt.setInt(8, dh.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Integer id) {
        String sql = "DELETE FROM donation_history WHERE id = ?";
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
