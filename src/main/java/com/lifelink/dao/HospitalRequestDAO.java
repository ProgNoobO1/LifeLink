package com.lifelink.dao;

import com.lifelink.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class HospitalRequestDAO {

    private static final SimpleDateFormat DATE_ONLY_FORMAT = new SimpleDateFormat("MMM dd, yyyy");
    private static final SimpleDateFormat DATE_TIME_FORMAT = new SimpleDateFormat("MMM dd, yyyy - hh:mm a");

    public List<Map<String, Object>> getIncomingRequests(int hospitalId, int page, int pageSize, Integer bloodGroupFilter) {
        String sql = "SELECT br.id, br.units_needed, br.urgency, br.status, br.requested_at, " +
                "u.full_name, u.role AS requester_role, bg.name AS blood_group, bg.id AS blood_group_id " +
                "FROM blood_requests br " +
                "JOIN blood_groups bg ON bg.id = br.blood_group_id " +
                "JOIN users u ON u.id = br.requester_id " +
                "WHERE br.blood_group_id IN (SELECT blood_group_id FROM blood_stock WHERE hospital_id = ?) " +
                "AND br.status != 'cancelled' " +
                (bloodGroupFilter != null ? "AND br.blood_group_id = ? " : "") +
                "ORDER BY CASE br.status WHEN 'pending' THEN 0 ELSE 1 END, " +
                "CASE br.urgency WHEN 'critical' THEN 0 WHEN 'urgent' THEN 1 ELSE 2 END, " +
                "br.requested_at DESC LIMIT ? OFFSET ?";

        List<Map<String, Object>> requests = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);

            int index = 1;
            statement.setInt(index++, hospitalId);
            if (bloodGroupFilter != null) {
                statement.setInt(index++, bloodGroupFilter);
            }
            statement.setInt(index++, pageSize);
            statement.setInt(index, Math.max(0, (page - 1) * pageSize));

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                long requestId = resultSet.getLong("id");
                String requesterName = resultSet.getString("full_name");
                String requesterRole = resultSet.getString("requester_role");

                row.put("id", requestId);
                row.put("formattedId", String.format("#REQ-%04d", requestId));
                row.put("requesterName", requesterName);
                row.put("requesterRole", formatEntityType(requesterRole));
                row.put("bloodGroup", resultSet.getString("blood_group"));
                row.put("bloodGroupId", resultSet.getInt("blood_group_id"));
                row.put("units", resultSet.getInt("units_needed"));
                row.put("urgency", resultSet.getString("urgency"));
                row.put("status", resultSet.getString("status"));
                row.put("requestedAt", formatDate(resultSet.getTimestamp("requested_at")));
                row.put("requestedAtRaw", resultSet.getTimestamp("requested_at"));
                row.put("avatarInitial", extractInitial(requesterName));
                requests.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[HospitalRequestDAO] getIncomingRequests: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return requests;
    }

    public int getIncomingRequestsCount(int hospitalId, Integer bloodGroupFilter) {
        String sql = "SELECT COUNT(*) AS total " +
                "FROM blood_requests br " +
                "WHERE br.blood_group_id IN (SELECT blood_group_id FROM blood_stock WHERE hospital_id = ?) " +
                "AND br.status != 'cancelled' " +
                (bloodGroupFilter != null ? "AND br.blood_group_id = ?" : "");

        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            if (bloodGroupFilter != null) {
                statement.setInt(2, bloodGroupFilter);
            }
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("total");
            }
        } catch (SQLException e) {
            System.err.println("[HospitalRequestDAO] getIncomingRequestsCount: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return 0;
    }

    public List<Map<String, Object>> getMyRequests(int hospitalId) {
        String sql = "SELECT br.id, br.units_needed, br.urgency, br.status, br.requested_at, " +
                "u.full_name AS responder_name, bg.name AS blood_group " +
                "FROM blood_requests br " +
                "JOIN blood_groups bg ON bg.id = br.blood_group_id " +
                "LEFT JOIN request_responses rr ON rr.request_id = br.id " +
                "LEFT JOIN users u ON u.id = rr.responder_id " +
                "WHERE br.requester_id = ? " +
                "ORDER BY br.requested_at DESC";

        List<Map<String, Object>> requests = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                long requestId = resultSet.getLong("id");
                String responderName = resultSet.getString("responder_name");
                String label = responderName != null && !responderName.trim().isEmpty() ? responderName : "Awaiting Response";
                row.put("id", requestId);
                row.put("formattedId", String.format("#REQ-%04d", requestId));
                row.put("requesterName", label);
                row.put("requesterRole", "Response");
                row.put("bloodGroup", resultSet.getString("blood_group"));
                row.put("units", resultSet.getInt("units_needed"));
                row.put("urgency", resultSet.getString("urgency"));
                row.put("status", resultSet.getString("status"));
                row.put("requestedAt", formatDate(resultSet.getTimestamp("requested_at")));
                row.put("avatarInitial", extractInitial(label));
                requests.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[HospitalRequestDAO] getMyRequests: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return requests;
    }

    public Map<String, Object> getSummaryStats(int hospitalId) {
        String sql = "SELECT COUNT(*) AS total, " +
                "SUM(CASE WHEN br.status = 'pending' THEN 1 ELSE 0 END) AS pending, " +
                "SUM(CASE WHEN br.status = 'accepted' THEN 1 ELSE 0 END) AS approved, " +
                "SUM(CASE WHEN br.status = 'rejected' THEN 1 ELSE 0 END) AS rejected " +
                "FROM blood_requests br " +
                "WHERE br.blood_group_id IN (SELECT blood_group_id FROM blood_stock WHERE hospital_id = ?)";

        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("totalRequests", 0);
        stats.put("pendingCount", 0);
        stats.put("approvedCount", 0);
        stats.put("rejectedCount", 0);

        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                stats.put("totalRequests", resultSet.getInt("total"));
                stats.put("pendingCount", resultSet.getInt("pending"));
                stats.put("approvedCount", resultSet.getInt("approved"));
                stats.put("rejectedCount", resultSet.getInt("rejected"));
            }
        } catch (SQLException e) {
            System.err.println("[HospitalRequestDAO] getSummaryStats: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return stats;
    }

    public Map<String, Object> getRequestById(int requestId) {
        String sql = "SELECT br.id, br.requester_id, br.units_needed, br.urgency, br.status, br.notes, " +
                "br.requested_at, br.updated_at, u.full_name, u.phone, u.role AS requester_role, " +
                "bg.name AS blood_group, bg.id AS blood_group_id " +
                "FROM blood_requests br " +
                "JOIN users u ON u.id = br.requester_id " +
                "JOIN blood_groups bg ON bg.id = br.blood_group_id " +
                "WHERE br.id = ?";

        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, requestId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                Map<String, Object> detail = new LinkedHashMap<>();
                long id = resultSet.getLong("id");
                String requesterName = resultSet.getString("full_name");
                String bloodGroup = resultSet.getString("blood_group");

                detail.put("id", id);
                detail.put("requesterId", resultSet.getInt("requester_id"));
                detail.put("formattedId", String.format("#REQ-%04d", id));
                detail.put("units", resultSet.getInt("units_needed"));
                detail.put("urgency", resultSet.getString("urgency"));
                detail.put("status", resultSet.getString("status"));
                detail.put("notes", resultSet.getString("notes"));
                detail.put("requestedAt", formatDateTime(resultSet.getTimestamp("requested_at")));
                detail.put("updatedAt", formatDateTime(resultSet.getTimestamp("updated_at")));
                detail.put("requestedAtRaw", resultSet.getTimestamp("requested_at"));
                detail.put("updatedAtRaw", resultSet.getTimestamp("updated_at"));
                detail.put("requesterName", requesterName);
                detail.put("requesterPhone", resultSet.getString("phone"));
                detail.put("requesterRole", formatEntityType(resultSet.getString("requester_role")));
                detail.put("requesterRoleRaw", resultSet.getString("requester_role"));
                detail.put("requesterInitial", extractInitial(requesterName));
                detail.put("bloodGroup", bloodGroup);
                detail.put("bloodGroupId", resultSet.getInt("blood_group_id"));
                detail.put("bloodGroupFullName", formatBloodGroupFullName(bloodGroup));
                detail.put("milliliters", resultSet.getInt("units_needed") * 450);
                return detail;
            }
        } catch (SQLException e) {
            System.err.println("[HospitalRequestDAO] getRequestById: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return null;
    }

    public Map<String, Object> getStockForBloodGroup(int hospitalId, int bloodGroupId) {
        String sql = "SELECT id, units_available, low_stock_threshold FROM blood_stock WHERE hospital_id = ? AND blood_group_id = ?";

        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            statement.setInt(2, bloodGroupId);
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                int units = resultSet.getInt("units_available");
                int threshold = resultSet.getInt("low_stock_threshold");
                Map<String, Object> stock = new LinkedHashMap<>();
                stock.put("stockId", resultSet.getInt("id"));
                stock.put("units", units);
                stock.put("threshold", threshold);
                stock.put("status", units > threshold ? "Sufficient Stock" : "Low Stock");
                return stock;
            }
        } catch (SQLException e) {
            System.err.println("[HospitalRequestDAO] getStockForBloodGroup: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return null;
    }

    public List<Map<String, Object>> getOtherStock(int hospitalId, int excludeBloodGroupId) {
        String sql = "SELECT bg.name AS blood_group, bs.units_available " +
                "FROM blood_stock bs " +
                "JOIN blood_groups bg ON bg.id = bs.blood_group_id " +
                "WHERE bs.hospital_id = ? AND bs.blood_group_id != ? " +
                "ORDER BY bs.units_available DESC LIMIT 4";

        List<Map<String, Object>> stockList = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            statement.setInt(2, excludeBloodGroupId);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                row.put("bloodGroup", resultSet.getString("blood_group"));
                row.put("units", resultSet.getInt("units_available"));
                stockList.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[HospitalRequestDAO] getOtherStock: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return stockList;
    }

    public void insertResponse(Connection conn, int requestId, int responderId, String response, int unitsProvided) throws SQLException {
        PreparedStatement statement = null;
        try {
            statement = conn.prepareStatement(
                    "INSERT INTO request_responses (request_id, responder_id, responder_type, response, units_provided) VALUES (?, ?, 'hospital', ?, ?)");
            statement.setInt(1, requestId);
            statement.setInt(2, responderId);
            statement.setString(3, response);
            statement.setInt(4, unitsProvided);
            statement.executeUpdate();
        } finally {
            closeQuietly(statement);
        }
    }

    public void updateRequestStatus(Connection conn, int requestId, String status) throws SQLException {
        PreparedStatement statement = null;
        try {
            statement = conn.prepareStatement("UPDATE blood_requests SET status = ?, updated_at = NOW() WHERE id = ?");
            statement.setString(1, status);
            statement.setInt(2, requestId);
            statement.executeUpdate();
        } finally {
            closeQuietly(statement);
        }
    }

    public void queueEmailNotification(Connection conn, int userId, String subject, String body) throws SQLException {
        PreparedStatement statement = null;
        try {
            statement = conn.prepareStatement(
                    "INSERT INTO email_notifications (user_id, subject, body, status) VALUES (?, ?, ?, 'queued')");
            statement.setInt(1, userId);
            statement.setString(2, subject);
            statement.setString(3, body);
            statement.executeUpdate();
        } finally {
            closeQuietly(statement);
        }
    }

    public boolean createRequest(int hospitalId, int bloodGroupId, int unitsNeeded, String urgency, String notes) {
        String sql = "INSERT INTO blood_requests (requester_id, blood_group_id, units_needed, urgency, notes, status) " +
                "VALUES (?, ?, ?, ?, ?, 'pending')";

        Connection connection = null;
        PreparedStatement statement = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            statement.setInt(2, bloodGroupId);
            statement.setInt(3, unitsNeeded);
            statement.setString(4, urgency);
            statement.setString(5, notes);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[HospitalRequestDAO] createRequest: " + e.getMessage());
        } finally {
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return false;
    }

    private String formatEntityType(String role) {
        if (role == null) {
            return "Entity";
        }
        if ("donor".equalsIgnoreCase(role)) {
            return "Blood Donor";
        }
        if ("recipient".equalsIgnoreCase(role)) {
            return "Blood Bank";
        }
        if ("hospital".equalsIgnoreCase(role)) {
            return "Hospital";
        }
        if ("admin".equalsIgnoreCase(role)) {
            return "Clinic";
        }
        return Character.toUpperCase(role.charAt(0)) + role.substring(1).toLowerCase();
    }

    private String extractInitial(String value) {
        if (value == null || value.trim().isEmpty()) {
            return "?";
        }
        return value.trim().substring(0, 1).toUpperCase();
    }

    private String formatBloodGroupFullName(String code) {
        if ("A+".equals(code)) return "Type A Positive";
        if ("A-".equals(code)) return "Type A Negative";
        if ("B+".equals(code)) return "Type B Positive";
        if ("B-".equals(code)) return "Type B Negative";
        if ("AB+".equals(code)) return "Type AB Positive";
        if ("AB-".equals(code)) return "Type AB Negative";
        if ("O+".equals(code)) return "Type O Positive";
        if ("O-".equals(code)) return "Type O Negative";
        return code;
    }

    private String formatDate(Timestamp timestamp) {
        if (timestamp == null) {
            return "N/A";
        }
        return DATE_ONLY_FORMAT.format(new Date(timestamp.getTime()));
    }

    private String formatDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return "N/A";
        }
        return DATE_TIME_FORMAT.format(new Date(timestamp.getTime()));
    }

    private void closeQuietly(ResultSet resultSet) {
        if (resultSet != null) {
            try {
                resultSet.close();
            } catch (SQLException e) {
                System.err.println("[HospitalRequestDAO] close ResultSet: " + e.getMessage());
            }
        }
    }

    private void closeQuietly(PreparedStatement statement) {
        if (statement != null) {
            try {
                statement.close();
            } catch (SQLException e) {
                System.err.println("[HospitalRequestDAO] close PreparedStatement: " + e.getMessage());
            }
        }
    }

    private void closeQuietly(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                System.err.println("[HospitalRequestDAO] close Connection: " + e.getMessage());
            }
        }
    }
}
