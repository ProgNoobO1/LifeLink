package com.lifelink.dao;

import com.lifelink.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class RequestDAO {

    public static class BloodGroupOption {
        private final int id;
        private final String name;

        public BloodGroupOption(int id, String name) {
            this.id = id;
            this.name = name;
        }

        public int getId() {
            return id;
        }

        public String getName() {
            return name;
        }
    }

    public Integer findRecipientBloodGroupId(long userId) throws SQLException {
        String sql = "SELECT blood_group_id FROM recipients WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    int bloodGroupId = rs.getInt("blood_group_id");
                    return rs.wasNull() ? null : bloodGroupId;
                }
            }
        }
        return null;
    }

    public List<BloodGroupOption> findAllBloodGroups() throws SQLException {
        String sql = "SELECT id, name FROM blood_groups ORDER BY id";
        List<BloodGroupOption> groups = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                groups.add(new BloodGroupOption(rs.getInt("id"), rs.getString("name")));
            }
        }
        return groups;
    }

    public boolean bloodGroupExists(int bloodGroupId) throws SQLException {
        String sql = "SELECT 1 FROM blood_groups WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, bloodGroupId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        }
    }

    public long createRequest(CreateRequestData data) throws SQLException {
        String requestSql =
            "INSERT INTO blood_requests (requester_id, blood_group_id, units_needed, urgency, status, notes) " +
            "VALUES (?, ?, ?, ?, 'pending', ?)";
        String emailSql =
            "INSERT INTO email_notifications (user_id, subject, body, status) VALUES (?, ?, ?, 'queued')";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            long requestId;
            try (PreparedStatement stmt = conn.prepareStatement(requestSql, Statement.RETURN_GENERATED_KEYS)) {
                stmt.setLong(1, data.getRequesterId());
                stmt.setInt(2, data.getBloodGroupId());
                stmt.setInt(3, data.getUnitsNeeded());
                stmt.setString(4, data.getUrgency());
                stmt.setString(5, buildNotes(data));
                stmt.executeUpdate();

                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (!keys.next()) {
                        throw new SQLException("Blood request insert did not return an id.");
                    }
                    requestId = keys.getLong(1);
                }
            }

            try (PreparedStatement stmt = conn.prepareStatement(emailSql)) {
                stmt.setLong(1, data.getRequesterId());
                stmt.setString(2, "Blood request submitted");
                stmt.setString(3, "Your blood request #" + requestId + " has been submitted and is awaiting donor matching.");
                stmt.executeUpdate();
            }

            conn.commit();
            return requestId;
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    e.addSuppressed(rollbackEx);
                }
            }
            throw e;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException closeEx) {
                    System.err.println("[RequestDAO] Error closing connection: " + closeEx.getMessage());
                }
            }
        }
    }

    private String buildNotes(CreateRequestData data) {
        // The current schema has no patient/hospital columns, so request-specific form details live in notes.
        return "Patient Name: " + data.getPatientName() + "\n" +
               "Hospital Name: " + data.getHospitalName() + "\n" +
               "Urgency Level: " + data.getUrgencyLabel();
    }

    public static class CreateRequestData {
        private long requesterId;
        private String patientName;
        private int bloodGroupId;
        private int unitsNeeded;
        private String hospitalName;
        private String urgency;
        private String urgencyLabel;

        public long getRequesterId() {
            return requesterId;
        }

        public void setRequesterId(long requesterId) {
            this.requesterId = requesterId;
        }

        public String getPatientName() {
            return patientName;
        }

        public void setPatientName(String patientName) {
            this.patientName = patientName;
        }

        public int getBloodGroupId() {
            return bloodGroupId;
        }

        public void setBloodGroupId(int bloodGroupId) {
            this.bloodGroupId = bloodGroupId;
        }

        public int getUnitsNeeded() {
            return unitsNeeded;
        }

        public void setUnitsNeeded(int unitsNeeded) {
            this.unitsNeeded = unitsNeeded;
        }

        public String getHospitalName() {
            return hospitalName;
        }

        public void setHospitalName(String hospitalName) {
            this.hospitalName = hospitalName;
        }

        public String getUrgency() {
            return urgency;
        }

        public void setUrgency(String urgency) {
            this.urgency = urgency;
        }

        public String getUrgencyLabel() {
            return urgencyLabel;
        }

        public void setUrgencyLabel(String urgencyLabel) {
            this.urgencyLabel = urgencyLabel;
        }
    }
}
