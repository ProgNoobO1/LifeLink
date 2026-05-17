package com.lifelink.dao;

import com.lifelink.model.Notification;
import com.lifelink.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * In-memory notification store.
 * The user's schema does not include a {@code notifications} table;
 * only {@code email_notifications} exists.  This DAO keeps recent
 * in-app notifications in memory for the SSE feed and unread counts.
 */
public class NotificationDAO {

    private static final List<Notification> STORE = new CopyOnWriteArrayList<>();
    private static final int MAX_SIZE = 200;

    public boolean save(Notification notification) {
        STORE.add(0, notification);
        if (STORE.size() > MAX_SIZE) {
            STORE.remove(STORE.size() - 1);
        }
        return true;
    }

    public List<Notification> findUnread() {
        List<Notification> unread = new ArrayList<>();
        for (Notification n : STORE) {
            if (!n.isRead()) {
                unread.add(n);
            }
        }
        return unread;
    }

    public long countUnread() {
        int count = 0;
        for (Notification n : STORE) {
            if (!n.isRead()) {
                count++;
            }
        }
        return count;
    }

    public boolean markRead(Long id) {
        for (Notification n : STORE) {
            if (n.getId() != null && n.getId().equals(id)) {
                n.setRead(true);
                return true;
            }
        }
        return false;
    }

    public boolean markAllRead() {
        for (Notification n : STORE) {
            n.setRead(true);
        }
        return true;
    }

    public List<Notification> findAll() {
        return new ArrayList<>(STORE);
    }

    public int getUnreadCount(int userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM email_notifications WHERE user_id = ? AND status = 'queued'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

    public List<NotificationItem> getRecent(int userId) throws SQLException {
        String sql =
            "SELECT subject, body, created_at " +
            "FROM email_notifications " +
            "WHERE user_id = ? " +
            "ORDER BY created_at DESC " +
            "LIMIT 10";
        List<NotificationItem> items = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Timestamp createdAt = rs.getTimestamp("created_at");
                    items.add(new NotificationItem(
                        rs.getString("subject"),
                        rs.getString("body"),
                        createdAt != null ? createdAt.toLocalDateTime() : null
                    ));
                }
            }
        }
        return items;
    }

    public boolean markAllAsRead(int userId) throws SQLException {
        String sql = "UPDATE email_notifications SET status = 'sent' WHERE user_id = ? AND status = 'queued'";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.executeUpdate();
            return true;
        }
    }

    public boolean insertNotification(int userId, String subject, String body) throws SQLException {
        String sql = "INSERT INTO email_notifications (user_id, subject, body, status) VALUES (?, ?, ?, 'queued')";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            stmt.setString(2, subject);
            stmt.setString(3, body);
            return stmt.executeUpdate() > 0;
        }
    }

    public static class NotificationItem {
        private final String subject;
        private final String body;
        private final LocalDateTime createdAt;

        public NotificationItem(String subject, String body, LocalDateTime createdAt) {
            this.subject = subject;
            this.body = body;
            this.createdAt = createdAt;
        }

        public String getSubject() {
            return subject;
        }

        public String getBody() {
            return body;
        }

        public LocalDateTime getCreatedAt() {
            return createdAt;
        }
    }
}
