package com.lifelink.dao;

import com.lifelink.model.Recipient;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class RecipientDAO {

    private Recipient mapResultSet(ResultSet rs) throws SQLException {
        Recipient r = new Recipient();
        r.setUserId(rs.getInt("user_id"));
        r.setBloodGroupId(rs.getInt("blood_group_id"));
        r.setDistrictId(rs.getObject("district_id") != null ? rs.getInt("district_id") : null);
        r.setAddress(rs.getString("address"));
        Date dob = rs.getDate("date_of_birth");
        if (dob != null) r.setDateOfBirth(dob.toLocalDate());
        r.setGender(rs.getString("gender"));
        r.setMedicalNotes(rs.getString("medical_notes"));
        r.setBloodGroupName(rs.getString("blood_group_name"));
        r.setDistrictName(rs.getString("district_name"));
        return r;
    }

    public boolean save(Recipient recipient) {
        String sql = "INSERT INTO recipients (user_id, blood_group_id, district_id, address, date_of_birth, gender, medical_notes) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, recipient.getUserId());
            stmt.setInt(2, recipient.getBloodGroupId());
            if (recipient.getDistrictId() != null) stmt.setInt(3, recipient.getDistrictId()); else stmt.setNull(3, Types.SMALLINT);
            stmt.setString(4, recipient.getAddress());
            if (recipient.getDateOfBirth() != null) stmt.setDate(5, Date.valueOf(recipient.getDateOfBirth())); else stmt.setNull(5, Types.DATE);
            stmt.setString(6, recipient.getGender());
            stmt.setString(7, recipient.getMedicalNotes());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Recipient findByUserId(Integer userId) {
        String sql = "SELECT r.*, bg.name as blood_group_name, dist.name as district_name " +
                     "FROM recipients r " +
                     "JOIN blood_groups bg ON r.blood_group_id = bg.id " +
                     "LEFT JOIN districts dist ON r.district_id = dist.id " +
                     "WHERE r.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Recipient> findAll() {
        String sql = "SELECT r.*, bg.name as blood_group_name, dist.name as district_name " +
                     "FROM recipients r " +
                     "JOIN blood_groups bg ON r.blood_group_id = bg.id " +
                     "LEFT JOIN districts dist ON r.district_id = dist.id " +
                     "ORDER BY r.user_id DESC";
        List<Recipient> list = new ArrayList<>();
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

    public boolean update(Recipient recipient) {
        String sql = "UPDATE recipients SET blood_group_id = ?, district_id = ?, address = ?, date_of_birth = ?, gender = ?, medical_notes = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, recipient.getBloodGroupId());
            if (recipient.getDistrictId() != null) stmt.setInt(2, recipient.getDistrictId()); else stmt.setNull(2, Types.SMALLINT);
            stmt.setString(3, recipient.getAddress());
            if (recipient.getDateOfBirth() != null) stmt.setDate(4, Date.valueOf(recipient.getDateOfBirth())); else stmt.setNull(4, Types.DATE);
            stmt.setString(5, recipient.getGender());
            stmt.setString(6, recipient.getMedicalNotes());
            stmt.setInt(7, recipient.getUserId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Integer userId) {
        String sql = "DELETE FROM recipients WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
