package com.lifelink.dao;

import com.lifelink.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class RequestDetailDAO {

    public RequestDetail findByIdForRecipient(long requestId, long requesterId) throws SQLException {
        String sql =
            "SELECT br.id, br.units_needed, br.urgency, br.status, br.notes, br.requested_at, br.updated_at, br.completed_at, " +
            "       bg.name AS blood_group, u.full_name AS patient_name, h.hospital_name " +
            "FROM blood_requests br " +
            "JOIN blood_groups bg ON bg.id = br.blood_group_id " +
            "JOIN users u ON u.id = br.requester_id " +
            "LEFT JOIN hospitals h ON h.user_id = br.requester_id " +
            "WHERE br.id = ? AND br.requester_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, requestId);
            stmt.setLong(2, requesterId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    RequestDetail detail = new RequestDetail();
                    detail.setId(rs.getLong("id"));
                    detail.setUnitsNeeded(rs.getInt("units_needed"));
                    detail.setUrgency(rs.getString("urgency"));
                    detail.setStatus(rs.getString("status"));
                    detail.setNotes(rs.getString("notes"));
                    detail.setRequestedAt(rs.getTimestamp("requested_at"));
                    detail.setUpdatedAt(rs.getTimestamp("updated_at"));
                    detail.setCompletedAt(rs.getTimestamp("completed_at"));
                    detail.setBloodGroup(rs.getString("blood_group"));
                    detail.setPatientName(valueOrParsed(rs.getString("patient_name"), detail.getNotes(), "Patient Name"));
                    detail.setHospitalName(valueOrParsed(rs.getString("hospital_name"), detail.getNotes(), "Hospital Name"));
                    detail.setAdditionalNotes(stripGeneratedNoteLines(detail.getNotes()));
                    return detail;
                }
            }
        }
        return null;
    }

    public List<MatchedResponder> findAcceptedResponders(long requestId) throws SQLException {
        String sql =
            "SELECT rr.id, rr.response, rr.units_provided, rr.responded_at, rr.responder_type, rr.responder_id, " +
            "       u.full_name, u.phone, d.is_available, bg.name AS blood_group " +
            "FROM request_responses rr " +
            "JOIN users u ON u.id = rr.responder_id " +
            "LEFT JOIN donors d ON d.user_id = rr.responder_id " +
            "LEFT JOIN blood_groups bg ON bg.id = COALESCE(d.blood_group_id, u.blood_group_id) " +
            "WHERE rr.request_id = ? AND rr.response = 'accepted' " +
            "ORDER BY rr.responded_at ASC";
        List<MatchedResponder> responders = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, requestId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    MatchedResponder responder = new MatchedResponder();
                    responder.setId(rs.getLong("id"));
                    responder.setResponderId(rs.getLong("responder_id"));
                    responder.setResponse(rs.getString("response"));
                    responder.setUnitsProvided(rs.getInt("units_provided"));
                    responder.setRespondedAt(rs.getTimestamp("responded_at"));
                    responder.setResponderType(rs.getString("responder_type"));
                    responder.setFullName(rs.getString("full_name"));
                    responder.setPhone(rs.getString("phone"));
                    int available = rs.getInt("is_available");
                    responder.setAvailable(rs.wasNull() || available == 1);
                    responder.setBloodGroup(rs.getString("blood_group"));
                    responders.add(responder);
                }
            }
        }
        return responders;
    }

    public boolean completeAcceptedRequest(long requestId, long requesterId) throws SQLException {
        String sql =
            "UPDATE blood_requests SET status = 'completed', completed_at = NOW() " +
            "WHERE id = ? AND requester_id = ? AND status = 'accepted'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, requestId);
            stmt.setLong(2, requesterId);
            return stmt.executeUpdate() > 0;
        }
    }

    public boolean cancelPendingRequest(long requestId, long requesterId) throws SQLException {
        String sql =
            "UPDATE blood_requests SET status = 'cancelled' " +
            "WHERE id = ? AND requester_id = ? AND status = 'pending'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, requestId);
            stmt.setLong(2, requesterId);
            return stmt.executeUpdate() > 0;
        }
    }

    public List<Long> findAcceptedResponderIds(long requestId) throws SQLException {
        String sql = "SELECT responder_id FROM request_responses WHERE request_id = ? AND response = 'accepted'";
        List<Long> ids = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, requestId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    ids.add(rs.getLong("responder_id"));
                }
            }
        }
        return ids;
    }

    private String valueOrParsed(String value, String notes, String key) {
        if (value != null && !value.trim().isEmpty()) {
            return value;
        }
        String parsed = parseNoteValue(notes, key);
        return parsed != null && !parsed.isEmpty() ? parsed : "Not provided";
    }

    private String parseNoteValue(String notes, String key) {
        if (notes == null) {
            return null;
        }
        String prefix = key + ":";
        String[] lines = notes.split("\\r?\\n");
        for (String line : lines) {
            if (line.startsWith(prefix)) {
                return line.substring(prefix.length()).trim();
            }
        }
        return null;
    }

    private String stripGeneratedNoteLines(String notes) {
        if (notes == null || notes.trim().isEmpty()) {
            return "";
        }
        StringBuilder kept = new StringBuilder();
        String[] lines = notes.split("\\r?\\n");
        for (String line : lines) {
            if (!line.startsWith("Patient Name:") && !line.startsWith("Hospital Name:") && !line.startsWith("Urgency Level:")) {
                if (kept.length() > 0) {
                    kept.append('\n');
                }
                kept.append(line);
            }
        }
        return kept.length() == 0 ? "No additional notes were added." : kept.toString();
    }

    public static class RequestDetail {
        private long id;
        private int unitsNeeded;
        private String urgency;
        private String status;
        private String notes;
        private String additionalNotes;
        private Timestamp requestedAt;
        private Timestamp updatedAt;
        private Timestamp completedAt;
        private String bloodGroup;
        private String patientName;
        private String hospitalName;

        public long getId() { return id; }
        public void setId(long id) { this.id = id; }
        public int getUnitsNeeded() { return unitsNeeded; }
        public void setUnitsNeeded(int unitsNeeded) { this.unitsNeeded = unitsNeeded; }
        public String getUrgency() { return urgency; }
        public void setUrgency(String urgency) { this.urgency = urgency; }
        public String getStatus() { return status; }
        public void setStatus(String status) { this.status = status; }
        public String getNotes() { return notes; }
        public void setNotes(String notes) { this.notes = notes; }
        public String getAdditionalNotes() { return additionalNotes; }
        public void setAdditionalNotes(String additionalNotes) { this.additionalNotes = additionalNotes; }
        public Timestamp getRequestedAt() { return requestedAt; }
        public void setRequestedAt(Timestamp requestedAt) { this.requestedAt = requestedAt; }
        public Timestamp getUpdatedAt() { return updatedAt; }
        public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }
        public Timestamp getCompletedAt() { return completedAt; }
        public void setCompletedAt(Timestamp completedAt) { this.completedAt = completedAt; }
        public String getBloodGroup() { return bloodGroup; }
        public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }
        public String getPatientName() { return patientName; }
        public void setPatientName(String patientName) { this.patientName = patientName; }
        public String getHospitalName() { return hospitalName; }
        public void setHospitalName(String hospitalName) { this.hospitalName = hospitalName; }
    }

    public static class MatchedResponder {
        private long id;
        private long responderId;
        private String response;
        private int unitsProvided;
        private Timestamp respondedAt;
        private String responderType;
        private String fullName;
        private String phone;
        private boolean available;
        private String bloodGroup;

        public long getId() { return id; }
        public void setId(long id) { this.id = id; }
        public long getResponderId() { return responderId; }
        public void setResponderId(long responderId) { this.responderId = responderId; }
        public String getResponse() { return response; }
        public void setResponse(String response) { this.response = response; }
        public int getUnitsProvided() { return unitsProvided; }
        public void setUnitsProvided(int unitsProvided) { this.unitsProvided = unitsProvided; }
        public Timestamp getRespondedAt() { return respondedAt; }
        public void setRespondedAt(Timestamp respondedAt) { this.respondedAt = respondedAt; }
        public String getResponderType() { return responderType; }
        public void setResponderType(String responderType) { this.responderType = responderType; }
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getPhone() { return phone; }
        public void setPhone(String phone) { this.phone = phone; }
        public boolean isAvailable() { return available; }
        public void setAvailable(boolean available) { this.available = available; }
        public String getBloodGroup() { return bloodGroup; }
        public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }
    }
}
