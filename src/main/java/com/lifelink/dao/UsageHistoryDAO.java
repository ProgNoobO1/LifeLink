package com.lifelink.dao;

import com.lifelink.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class UsageHistoryDAO {

    private static final int PAGE_SIZE = 12;
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ofPattern("dd MMM yyyy");

    public List<Map<String, Object>> getRecords(int hospitalId, String filter, String dateRange, int page) {
        List<Map<String, Object>> records = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(buildRecordQuery(true, true));

            int parameterIndex = bindSharedFilters(statement, hospitalId, filter, dateRange);
            statement.setInt(parameterIndex++, PAGE_SIZE);
            statement.setInt(parameterIndex, Math.max(0, (page - 1) * PAGE_SIZE));

            resultSet = statement.executeQuery();
            while (resultSet.next()) {
                records.add(mapRecord(resultSet));
            }
        } catch (SQLException e) {
            System.err.println("[UsageHistoryDAO] getRecords: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return records;
    }

    public int getTotalCount(int hospitalId, String filter, String dateRange) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(buildCountQuery());
            bindSharedFilters(statement, hospitalId, filter, dateRange);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("total_count");
            }
        } catch (SQLException e) {
            System.err.println("[UsageHistoryDAO] getTotalCount: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return 0;
    }

    public Map<String, Object> getStatCards(int hospitalId) {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("totalUnits", 0);
        stats.put("surgeryCount", 0);
        stats.put("emergencyCount", 0);
        stats.put("transferCount", 0);

        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(
                    "SELECT " +
                            "COALESCE(SUM(usage_rows.units), 0) AS total_units, " +
                            "COALESCE(SUM(CASE WHEN usage_rows.verified = 1 THEN 1 ELSE 0 END), 0) AS surgery_count, " +
                            "COALESCE(SUM(CASE WHEN usage_rows.verified = 0 THEN 1 ELSE 0 END), 0) AS emergency_count, " +
                            "COALESCE(SUM(CASE WHEN usage_rows.request_id IS NOT NULL THEN 1 ELSE 0 END), 0) AS transfer_count " +
                            "FROM (" + buildUsageSourceQuery() + ") usage_rows"
            );
            bindUsageSourceParams(statement, hospitalId);
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                stats.put("totalUnits", resultSet.getInt("total_units"));
                stats.put("surgeryCount", resultSet.getInt("surgery_count"));
                stats.put("emergencyCount", resultSet.getInt("emergency_count"));
                stats.put("transferCount", resultSet.getInt("transfer_count"));
            }
        } catch (SQLException e) {
            System.err.println("[UsageHistoryDAO] getStatCards: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return stats;
    }

    public List<Map<String, Object>> exportCsv(int hospitalId, String filter, String dateRange) {
        List<Map<String, Object>> records = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(buildRecordQuery(true, false));
            bindSharedFilters(statement, hospitalId, filter, dateRange);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                records.add(mapRecord(resultSet));
            }
        } catch (SQLException e) {
            System.err.println("[UsageHistoryDAO] exportCsv: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return records;
    }

    public int getQueuedNotificationCount(int hospitalId) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(
                    "SELECT COUNT(*) AS queued_count FROM email_notifications WHERE user_id = ? AND status = ?"
            );
            statement.setInt(1, hospitalId);
            statement.setString(2, "queued");
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                return resultSet.getInt("queued_count");
            }
        } catch (SQLException e) {
            System.err.println("[UsageHistoryDAO] getQueuedNotificationCount: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return 0;
    }

    private String buildRecordQuery(boolean includeOrderBy, boolean includePagination) {
        String query = "SELECT usage_rows.id, usage_rows.request_id, usage_rows.units, usage_rows.usage_date, usage_rows.verified, " +
                "usage_rows.blood_group, usage_rows.recipient_name, usage_rows.processed_by " +
                "FROM (" + buildUsageSourceQuery() + ") usage_rows " +
                "WHERE 1 = 1 " +
                "AND ( " +
                "    ? = 'all' " +
                "    OR (? = 'verified' AND usage_rows.verified = 1) " +
                "    OR (? = 'unverified' AND usage_rows.verified = 0) " +
                "    OR (? = 'with_request' AND usage_rows.request_id IS NOT NULL) " +
                "    OR (? = 'without_request' AND usage_rows.request_id IS NULL) " +
                ") " +
                "AND ( " +
                "    ? = 'all_time' " +
                "    OR (? = 'this_month' AND YEAR(usage_rows.usage_date) = YEAR(CURDATE()) AND MONTH(usage_rows.usage_date) = MONTH(CURDATE())) " +
                "    OR (? = 'last_month' AND usage_rows.usage_date >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01') AND usage_rows.usage_date < DATE_FORMAT(CURDATE(), '%Y-%m-01')) " +
                "    OR (? = 'last_3_months' AND usage_rows.usage_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)) " +
                "    OR (? = 'last_6_months' AND usage_rows.usage_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)) " +
                "    OR (? = 'this_year' AND YEAR(usage_rows.usage_date) = YEAR(CURDATE())) " +
                ") ";

        if (includeOrderBy) {
            query += "ORDER BY usage_rows.usage_date DESC, usage_rows.id DESC ";
        }

        if (includePagination) {
            query += "LIMIT ? OFFSET ?";
        }

        return query;
    }

    private String buildCountQuery() {
        return "SELECT COUNT(*) AS total_count " +
                "FROM (" + buildUsageSourceQuery() + ") usage_rows " +
                "WHERE 1 = 1 " +
                "AND ( " +
                "    ? = 'all' " +
                "    OR (? = 'verified' AND usage_rows.verified = 1) " +
                "    OR (? = 'unverified' AND usage_rows.verified = 0) " +
                "    OR (? = 'with_request' AND usage_rows.request_id IS NOT NULL) " +
                "    OR (? = 'without_request' AND usage_rows.request_id IS NULL) " +
                ") " +
                "AND ( " +
                "    ? = 'all_time' " +
                "    OR (? = 'this_month' AND YEAR(usage_rows.usage_date) = YEAR(CURDATE()) AND MONTH(usage_rows.usage_date) = MONTH(CURDATE())) " +
                "    OR (? = 'last_month' AND usage_rows.usage_date >= DATE_FORMAT(DATE_SUB(CURDATE(), INTERVAL 1 MONTH), '%Y-%m-01') AND usage_rows.usage_date < DATE_FORMAT(CURDATE(), '%Y-%m-01')) " +
                "    OR (? = 'last_3_months' AND usage_rows.usage_date >= DATE_SUB(CURDATE(), INTERVAL 3 MONTH)) " +
                "    OR (? = 'last_6_months' AND usage_rows.usage_date >= DATE_SUB(CURDATE(), INTERVAL 6 MONTH)) " +
                "    OR (? = 'this_year' AND YEAR(usage_rows.usage_date) = YEAR(CURDATE())) " +
                ") ";
    }

    private int bindSharedFilters(PreparedStatement statement, int hospitalId, String filter, String dateRange)
            throws SQLException {
        String safeFilter = normalizeFilter(filter);
        String safeDateRange = normalizeDateRange(dateRange);

        int index = 1;
        index = bindUsageSourceParams(statement, hospitalId);
        statement.setString(index++, safeFilter);
        statement.setString(index++, safeFilter);
        statement.setString(index++, safeFilter);
        statement.setString(index++, safeFilter);
        statement.setString(index++, safeFilter);
        statement.setString(index++, safeDateRange);
        statement.setString(index++, safeDateRange);
        statement.setString(index++, safeDateRange);
        statement.setString(index++, safeDateRange);
        statement.setString(index++, safeDateRange);
        statement.setString(index++, safeDateRange);
        return index;
    }

    private int bindUsageSourceParams(PreparedStatement statement, int hospitalId) throws SQLException {
        int index = 1;
        statement.setInt(index++, hospitalId);
        statement.setInt(index++, hospitalId);
        statement.setInt(index++, hospitalId);
        return index;
    }

    private String buildUsageSourceQuery() {
        // donation_history alone does not capture most hospital-side usage,
        // so we combine it with accepted hospital-to-hospital transfers received by this hospital.
        return "SELECT dh.id AS id, dh.request_id, dh.units_donated AS units, dh.donated_at AS usage_date, " +
                "dh.verified, bg.name AS blood_group, " +
                "COALESCE(NULLIF(target_hospital.hospital_name, ''), hospital_user.full_name, 'Hospital') AS recipient_name, " +
                "COALESCE(NULLIF(target_hospital.hospital_name, ''), hospital_user.full_name, 'Hospital') AS processed_by " +
                "FROM donation_history dh " +
                "LEFT JOIN hospitals target_hospital ON target_hospital.user_id = dh.hospital_id " +
                "LEFT JOIN users hospital_user ON hospital_user.id = dh.hospital_id " +
                "JOIN blood_groups bg ON bg.id = dh.blood_group_id " +
                "WHERE dh.hospital_id = ? " +
                "UNION ALL " +
                "SELECT rr.id + 1000000 AS id, br.id AS request_id, " +
                "COALESCE(NULLIF(rr.units_provided, 0), br.units_needed) AS units, DATE(rr.responded_at) AS usage_date, " +
                "1 AS verified, bg.name AS blood_group, " +
                "COALESCE(NULLIF(requester_hospital.hospital_name, ''), requester_user.full_name, 'Hospital') AS recipient_name, " +
                "COALESCE(NULLIF(responder_hospital.hospital_name, ''), responder_user.full_name, 'Hospital') AS processed_by " +
                "FROM request_responses rr " +
                "JOIN blood_requests br ON br.id = rr.request_id " +
                "JOIN users requester_user ON requester_user.id = br.requester_id " +
                "LEFT JOIN hospitals requester_hospital ON requester_hospital.user_id = br.requester_id " +
                "LEFT JOIN users responder_user ON responder_user.id = rr.responder_id " +
                "LEFT JOIN hospitals responder_hospital ON responder_hospital.user_id = rr.responder_id " +
                "JOIN blood_groups bg ON bg.id = br.blood_group_id " +
                "WHERE br.requester_id = ? " +
                "AND rr.responder_type = 'hospital' " +
                "AND rr.response = 'accepted' " +
                "AND NOT EXISTS ( " +
                "    SELECT 1 FROM donation_history dh2 " +
                "    WHERE dh2.hospital_id = ? AND dh2.request_id = br.id" +
                ")";
    }

    private Map<String, Object> mapRecord(ResultSet resultSet) throws SQLException {
        Map<String, Object> record = new LinkedHashMap<>();
        LocalDate donatedAt = resultSet.getDate("usage_date").toLocalDate();
        String bloodGroup = resultSet.getString("blood_group");
        String recipientName = resultSet.getString("recipient_name");
        boolean verified = resultSet.getInt("verified") == 1;
        Integer requestId = resultSet.getObject("request_id") != null ? resultSet.getInt("request_id") : null;
        int units = resultSet.getInt("units");

        record.put("id", resultSet.getInt("id"));
        record.put("donatedAt", donatedAt.format(DATE_FORMAT));
        record.put("donatedAtSubtext", "Recorded");
        record.put("bloodGroup", bloodGroup);
        record.put("units", units);
        record.put("unitLabel", units == 1 ? "unit" : "units");
        record.put("verified", verified);
        record.put("requestId", requestId);
        record.put("requestIdDisplay", requestId != null ? "#REQ-" + requestId : "N/A");
        record.put("recipientName", recipientName);
        record.put("recipientInitials", buildInitials(recipientName));
        record.put("purpose", resolvePurpose(verified, requestId));
        record.put("processedBy", resultSet.getString("processed_by"));
        record.put("searchText", (recipientName + " " + bloodGroup).toLowerCase());
        return record;
    }

    private String resolvePurpose(boolean verified, Integer requestId) {
        if (requestId != null) {
            return "Transfer";
        }
        if (verified) {
            return "Surgery";
        }
        return "Emergency";
    }

    private String buildInitials(String fullName) {
        if (fullName == null || fullName.trim().isEmpty()) {
            return "?";
        }

        String[] parts = fullName.trim().split("\\s+");
        if (parts.length == 1) {
            return parts[0].substring(0, 1).toUpperCase();
        }

        return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
    }

    private String normalizeFilter(String filter) {
        if ("verified".equalsIgnoreCase(filter)) {
            return "verified";
        }
        if ("unverified".equalsIgnoreCase(filter)) {
            return "unverified";
        }
        if ("with_request".equalsIgnoreCase(filter)) {
            return "with_request";
        }
        if ("without_request".equalsIgnoreCase(filter)) {
            return "without_request";
        }
        return "all";
    }

    private String normalizeDateRange(String dateRange) {
        if ("last_month".equalsIgnoreCase(dateRange)) {
            return "last_month";
        }
        if ("last_3_months".equalsIgnoreCase(dateRange)) {
            return "last_3_months";
        }
        if ("last_6_months".equalsIgnoreCase(dateRange)) {
            return "last_6_months";
        }
        if ("this_year".equalsIgnoreCase(dateRange)) {
            return "this_year";
        }
        if ("all_time".equalsIgnoreCase(dateRange)) {
            return "all_time";
        }
        return "this_month";
    }

    private void closeQuietly(AutoCloseable closeable) {
        if (closeable != null) {
            try {
                closeable.close();
            } catch (Exception e) {
                System.err.println("[UsageHistoryDAO] closeQuietly: " + e.getMessage());
            }
        }
    }
}
