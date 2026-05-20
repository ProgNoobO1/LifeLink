package com.lifelink.dao;

import com.lifelink.model.Recipient;
import com.lifelink.utils.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

public class RecipientProfileDAO {

    public Recipient findByUserId(long userId) throws SQLException {
        String sql =
            "SELECT r.*, bg.name AS blood_group_name, d.name AS district_name " +
            "FROM recipients r " +
            "JOIN blood_groups bg ON bg.id = r.blood_group_id " +
            "LEFT JOIN districts d ON d.id = r.district_id " +
            "WHERE r.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRecipient(rs);
                }
            }
        }
        return null;
    }

    public int findUserBloodGroupId(long userId) throws SQLException {
        String sql = "SELECT blood_group_id FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int bloodGroupId = rs.getInt("blood_group_id");
                    if (!rs.wasNull() && bloodGroupId > 0) {
                        return bloodGroupId;
                    }
                }
            }
        }
        return 0;
    }

    public boolean districtExists(int districtId) throws SQLException {
        String sql = "SELECT 1 FROM districts WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, districtId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void upsertProfile(Recipient recipient) throws SQLException {
        String sql =
            "INSERT INTO recipients (user_id, blood_group_id, district_id, address, date_of_birth, gender, medical_notes) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?) " +
            "ON DUPLICATE KEY UPDATE " +
            "district_id = VALUES(district_id), " +
            "address = VALUES(address), " +
            "date_of_birth = VALUES(date_of_birth), " +
            "gender = VALUES(gender), " +
            "medical_notes = VALUES(medical_notes)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, recipient.getUserId());
            stmt.setInt(2, recipient.getBloodGroupId());
            if (recipient.getDistrictId() == null) {
                stmt.setNull(3, Types.SMALLINT);
            } else {
                stmt.setInt(3, recipient.getDistrictId());
            }
            stmt.setString(4, recipient.getAddress());
            if (recipient.getDateOfBirth() == null) {
                stmt.setNull(5, Types.DATE);
            } else {
                stmt.setDate(5, Date.valueOf(recipient.getDateOfBirth()));
            }
            stmt.setString(6, recipient.getGender());
            stmt.setString(7, recipient.getMedicalNotes());
            stmt.executeUpdate();
        }
    }

    private Recipient mapRecipient(ResultSet rs) throws SQLException {
        Recipient recipient = new Recipient();
        recipient.setUserId(rs.getInt("user_id"));
        recipient.setBloodGroupId(rs.getInt("blood_group_id"));
        int districtId = rs.getInt("district_id");
        recipient.setDistrictId(rs.wasNull() ? null : districtId);
        recipient.setAddress(rs.getString("address"));
        Date dob = rs.getDate("date_of_birth");
        if (dob != null) {
            recipient.setDateOfBirth(dob.toLocalDate());
        }
        recipient.setGender(rs.getString("gender"));
        recipient.setMedicalNotes(rs.getString("medical_notes"));
        recipient.setBloodGroupName(rs.getString("blood_group_name"));
        recipient.setDistrictName(rs.getString("district_name"));
        return recipient;
    }
}
