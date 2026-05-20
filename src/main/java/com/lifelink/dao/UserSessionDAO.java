package com.lifelink.dao;

import com.lifelink.model.UserSession;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class UserSessionDAO {

    private UserSession mapResultSet(ResultSet rs) throws SQLException {
        UserSession us = new UserSession();
        us.setSessionToken(rs.getString("session_token"));
        us.setUserId(rs.getInt("user_id"));
        us.setIpAddress(rs.getString("ip_address"));
        us.setUserAgent(rs.getString("user_agent"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) us.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp expiresAt = rs.getTimestamp("expires_at");
        if (expiresAt != null) us.setExpiresAt(expiresAt.toLocalDateTime());
        return us;
    }

    public boolean save(UserSession session) {
        String sql = "INSERT INTO user_sessions (session_token, user_id, ip_address, user_agent, expires_at) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, session.getSessionToken());
            stmt.setInt(2, session.getUserId());
            stmt.setString(3, session.getIpAddress());
            stmt.setString(4, session.getUserAgent());
            stmt.setTimestamp(5, Timestamp.valueOf(session.getExpiresAt()));
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public UserSession findByToken(String token) {
        String sql = "SELECT * FROM user_sessions WHERE session_token = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, token);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<UserSession> findByUserId(Integer userId) {
        String sql = "SELECT * FROM user_sessions WHERE user_id = ? ORDER BY created_at DESC";
        List<UserSession> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
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

    public List<UserSession> findAll() {
        String sql = "SELECT * FROM user_sessions ORDER BY created_at DESC";
        List<UserSession> list = new ArrayList<>();
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

    public boolean update(UserSession session) {
        String sql = "UPDATE user_sessions SET user_id = ?, ip_address = ?, user_agent = ?, expires_at = ? WHERE session_token = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, session.getUserId());
            stmt.setString(2, session.getIpAddress());
            stmt.setString(3, session.getUserAgent());
            stmt.setTimestamp(4, Timestamp.valueOf(session.getExpiresAt()));
            stmt.setString(5, session.getSessionToken());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(String token) {
        String sql = "DELETE FROM user_sessions WHERE session_token = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, token);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean deleteExpired() {
        String sql = "DELETE FROM user_sessions WHERE expires_at < NOW()";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            return stmt.executeUpdate() >= 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
