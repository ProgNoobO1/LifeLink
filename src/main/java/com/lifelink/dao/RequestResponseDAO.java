package com.lifelink.dao;

import com.lifelink.model.RequestResponse;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class RequestResponseDAO {

    private RequestResponse mapResultSet(ResultSet rs) throws SQLException {
        RequestResponse r = new RequestResponse();
        r.setId(rs.getInt("id"));
        r.setRequestId(rs.getInt("request_id"));
        r.setResponderId(rs.getInt("responder_id"));
        r.setResponderType(rs.getString("responder_type"));
        r.setResponse(rs.getString("response"));
        r.setUnitsProvided(rs.getInt("units_provided"));
        Timestamp respondedAt = rs.getTimestamp("responded_at");
        if (respondedAt != null) r.setRespondedAt(respondedAt.toLocalDateTime());
        r.setNotes(rs.getString("notes"));
        return r;
    }

    public boolean save(RequestResponse response) {
        String sql = "INSERT INTO request_responses (request_id, responder_id, responder_type, response, units_provided, responded_at, notes) VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, response.getRequestId());
            stmt.setInt(2, response.getResponderId());
            stmt.setString(3, response.getResponderType());
            stmt.setString(4, response.getResponse());
            stmt.setInt(5, response.getUnitsProvided() != null ? response.getUnitsProvided() : 0);
            stmt.setTimestamp(6, Timestamp.valueOf(response.getRespondedAt() != null ? response.getRespondedAt() : LocalDateTime.now()));
            stmt.setString(7, response.getNotes());
            int affected = stmt.executeUpdate();
            if (affected == 0) return false;
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) response.setId(keys.getInt(1));
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public RequestResponse findById(Integer id) {
        String sql = "SELECT * FROM request_responses WHERE id = ?";
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

    public List<RequestResponse> findByRequestId(Integer requestId) {
        String sql = "SELECT * FROM request_responses WHERE request_id = ? ORDER BY responded_at DESC";
        List<RequestResponse> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, requestId);
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

    public List<RequestResponse> findAll() {
        String sql = "SELECT * FROM request_responses ORDER BY responded_at DESC";
        List<RequestResponse> list = new ArrayList<>();
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

    public boolean update(RequestResponse response) {
        String sql = "UPDATE request_responses SET request_id = ?, responder_id = ?, responder_type = ?, response = ?, units_provided = ?, responded_at = ?, notes = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, response.getRequestId());
            stmt.setInt(2, response.getResponderId());
            stmt.setString(3, response.getResponderType());
            stmt.setString(4, response.getResponse());
            stmt.setInt(5, response.getUnitsProvided() != null ? response.getUnitsProvided() : 0);
            stmt.setTimestamp(6, Timestamp.valueOf(response.getRespondedAt() != null ? response.getRespondedAt() : LocalDateTime.now()));
            stmt.setString(7, response.getNotes());
            stmt.setInt(8, response.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Integer id) {
        String sql = "DELETE FROM request_responses WHERE id = ?";
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
