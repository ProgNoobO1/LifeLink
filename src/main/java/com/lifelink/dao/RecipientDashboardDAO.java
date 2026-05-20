package com.lifelink.dao;

import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

/**
 * Data access layer for the Recipient Dashboard.
 * All queries are scoped to a specific recipient user_id.
 */
public class RecipientDashboardDAO {

    // ─────────────────────────────────────────────────────────────────────────
    // STAT COUNTS
    // ─────────────────────────────────────────────────────────────────────────

    /** Total blood requests ever submitted by this recipient. */
    public long countTotalRequests(long userId) {
        String sql = "SELECT COUNT(*) FROM blood_requests WHERE requester_id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        } catch (SQLException e) {
            System.err.println("[RecipientDashboardDAO] countTotalRequests: " + e.getMessage());
        }
        return 0;
    }

    /** Requests in 'pending' state for this recipient. */
    public long countPendingRequests(long userId) {
        String sql = "SELECT COUNT(*) FROM blood_requests WHERE requester_id = ? AND status = 'pending'";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        } catch (SQLException e) {
            System.err.println("[RecipientDashboardDAO] countPendingRequests: " + e.getMessage());
        }
        return 0;
    }

    /**
     * Requests that are 'completed' or 'accepted' — treated as "fulfilled" on the dashboard.
     */
    public long countFulfilledRequests(long userId) {
        String sql = "SELECT COUNT(*) FROM blood_requests " +
                     "WHERE requester_id = ? AND status IN ('completed', 'accepted')";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getLong(1);
            }
        } catch (SQLException e) {
            System.err.println("[RecipientDashboardDAO] countFulfilledRequests: " + e.getMessage());
        }
        return 0;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // RECENT REQUESTS (latest 5)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Returns the 5 most-recent blood requests for the recipient.
     * Each map has keys: id, blood_group, requested_at (Timestamp), status, units_needed, urgency.
     */
    public List<Map<String, Object>> findRecentRequests(long userId) {
        String sql =
            "SELECT br.id, bg.name AS blood_group, br.requested_at, br.status, " +
            "       br.units_needed, br.urgency " +
            "FROM   blood_requests br " +
            "JOIN   blood_groups   bg ON bg.id = br.blood_group_id " +
            "WHERE  br.requester_id = ? " +
            "ORDER  BY br.requested_at DESC " +
            "LIMIT  5";

        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> row = new LinkedHashMap<>();
                    row.put("id",           rs.getLong("id"));
                    row.put("blood_group",  rs.getString("blood_group"));
                    row.put("requested_at", rs.getTimestamp("requested_at")); // keep as Timestamp for JS
                    row.put("status",       rs.getString("status"));
                    row.put("units_needed", rs.getInt("units_needed"));
                    row.put("urgency",      rs.getString("urgency"));
                    list.add(row);
                }
            }
        } catch (SQLException e) {
            System.err.println("[RecipientDashboardDAO] findRecentRequests: " + e.getMessage());
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // ACTIVITY TIMELINE (recent 5 events)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Builds a timeline of key events for this recipient:
     *   – request submitted  (from blood_requests)
     *   – request response   (from request_responses)
     *   – account created    (from users)
     *
     * Returns up to 5 events ordered newest-first.
     * Each map has keys: event_type, label, detail, occurred_at (Timestamp), req_id.
     */
    public List<Map<String, Object>> findRecentActivity(long userId) {
        // UNION of three event sources, limited to 5 most recent
        String sql =
            "( SELECT 'request_submitted' AS event_type, " +
            "         CONCAT('Request submitted') AS label, " +
            "         CONCAT('#REQ-', LPAD(br.id,3,'0'), ' is awaiting review') AS detail, " +
            "         br.requested_at AS occurred_at, " +
            "         br.id AS req_id " +
            "  FROM   blood_requests br " +
            "  WHERE  br.requester_id = ? " +
            ") " +
            "UNION ALL " +
            "( SELECT CASE rr.response " +
            "           WHEN 'accepted' THEN 'request_fulfilled' " +
            "           ELSE 'request_rejected' END AS event_type, " +
            "         CASE rr.response " +
            "           WHEN 'accepted' THEN 'Request fulfilled' " +
            "           ELSE 'Request rejected' END AS label, " +
            "         CASE rr.response " +
            "           WHEN 'accepted' THEN CONCAT('#REQ-', LPAD(br.id,3,'0'), ' was successfully fulfilled') " +
            "           ELSE CONCAT('#REQ-', LPAD(br.id,3,'0'), ' was declined') END AS detail, " +
            "         rr.responded_at AS occurred_at, " +
            "         br.id AS req_id " +
            "  FROM   request_responses rr " +
            "  JOIN   blood_requests    br ON br.id = rr.request_id " +
            "  WHERE  br.requester_id = ? " +
            ") " +
            "UNION ALL " +
            "( SELECT 'account_created' AS event_type, " +
            "         'Account created' AS label, " +
            "         'Welcome to LifeLink!' AS detail, " +
            "         u.created_at AS occurred_at, " +
            "         NULL AS req_id " +
            "  FROM   users u " +
            "  WHERE  u.id = ? " +
            ") " +
            // Fetch donor_matched events (accepted responses) separately as 'donor_matched'
            "UNION ALL " +
            "( SELECT 'donor_matched' AS event_type, " +
            "         'Donor matched' AS label, " +
            "         CONCAT('A donor was matched for #REQ-', LPAD(br.id,3,'0')) AS detail, " +
            "         rr.responded_at AS occurred_at, " +
            "         br.id AS req_id " +
            "  FROM   request_responses rr " +
            "  JOIN   blood_requests    br ON br.id = rr.request_id " +
            "  WHERE  br.requester_id = ? AND rr.responder_type = 'donor' AND rr.response = 'accepted' " +
            ") " +
            "ORDER  BY occurred_at DESC " +
            "LIMIT  5";

        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            // bind three userId parameters (one per UNION branch that needs it)
            ps.setLong(1, userId);
            ps.setLong(2, userId);
            ps.setLong(3, userId);
            ps.setLong(4, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> ev = new LinkedHashMap<>();
                    ev.put("event_type",  rs.getString("event_type"));
                    ev.put("label",       rs.getString("label"));
                    ev.put("detail",      rs.getString("detail"));
                    ev.put("occurred_at", rs.getTimestamp("occurred_at"));
                    long reqId = rs.getLong("req_id");
                    ev.put("req_id", rs.wasNull() ? null : reqId);
                    list.add(ev);
                }
            }
        } catch (SQLException e) {
            System.err.println("[RecipientDashboardDAO] findRecentActivity: " + e.getMessage());
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────────────────────
    // RECIPIENT PROFILE (blood group for display)
    // ─────────────────────────────────────────────────────────────────────────

    /**
     * Returns the recipient's blood group name (e.g. "A+") or null if not set.
     */
    public String getRecipientBloodGroup(long userId) {
        String sql =
            "SELECT bg.name FROM recipients r " +
            "JOIN   blood_groups bg ON bg.id = r.blood_group_id " +
            "WHERE  r.user_id = ?";
        try (Connection c = DBConnection.getConnection();
             PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setLong(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString(1);
            }
        } catch (SQLException e) {
            System.err.println("[RecipientDashboardDAO] getRecipientBloodGroup: " + e.getMessage());
        }
        return null;
    }
}
