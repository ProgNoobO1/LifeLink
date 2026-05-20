package com.lifelink.dao;

import com.lifelink.model.EmailNotification;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class EmailNotificationDAO {

    private EmailNotification mapResultSet(ResultSet rs) throws SQLException {
        EmailNotification en = new EmailNotification();
        en.setId(rs.getInt("id"));
        en.setUserId(rs.getInt("user_id"));
        en.setSubject(rs.getString("subject"));
        en.setBody(rs.getString("body"));
        en.setStatus(rs.getString("status"));
        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) en.setCreatedAt(createdAt.toLocalDateTime());
        Timestamp sentAt = rs.getTimestamp("sent_at");
        if (sentAt != null) en.setSentAt(sentAt.toLocalDateTime());
        en.setErrorMessage(rs.getString("error_message"));
        return en;
    }

    public boolean save(EmailNotification notification) {
        String sql = "INSERT INTO email_notifications (user_id, subject, body, status, sent_at, error_message) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setInt(1, notification.getUserId());
            stmt.setString(2, notification.getSubject());
            stmt.setString(3, notification.getBody());
            stmt.setString(4, notification.getStatus());
            if (notification.getSentAt() != null) stmt.setTimestamp(5, Timestamp.valueOf(notification.getSentAt())); else stmt.setNull(5, Types.TIMESTAMP);
            stmt.setString(6, notification.getErrorMessage());
            int affected = stmt.executeUpdate();
            if (affected == 0) return false;
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) notification.setId(keys.getInt(1));
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public EmailNotification findById(Integer id) {
        String sql = "SELECT * FROM email_notifications WHERE id = ?";
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

    public List<EmailNotification> findByUserId(Integer userId) {
        String sql = "SELECT * FROM email_notifications WHERE user_id = ? ORDER BY created_at DESC";
        List<EmailNotification> list = new ArrayList<>();
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

    public List<EmailNotification> findByStatus(String status) {
        String sql = "SELECT * FROM email_notifications WHERE status = ? ORDER BY created_at DESC";
        List<EmailNotification> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status);
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

    public List<EmailNotification> findAll() {
        String sql = "SELECT * FROM email_notifications ORDER BY created_at DESC";
        List<EmailNotification> list = new ArrayList<>();
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

    public boolean update(EmailNotification notification) {
        String sql = "UPDATE email_notifications SET user_id = ?, subject = ?, body = ?, status = ?, sent_at = ?, error_message = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, notification.getUserId());
            stmt.setString(2, notification.getSubject());
            stmt.setString(3, notification.getBody());
            stmt.setString(4, notification.getStatus());
            if (notification.getSentAt() != null) stmt.setTimestamp(5, Timestamp.valueOf(notification.getSentAt())); else stmt.setNull(5, Types.TIMESTAMP);
            stmt.setString(6, notification.getErrorMessage());
            stmt.setInt(7, notification.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Integer id) {
        String sql = "DELETE FROM email_notifications WHERE id = ?";
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
