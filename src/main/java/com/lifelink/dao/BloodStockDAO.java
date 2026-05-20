package com.lifelink.dao;

import com.lifelink.utils.DBConnection;

import java.sql.Connection;
import java.sql.DatabaseMetaData;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.Date;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class BloodStockDAO {

    private static final SimpleDateFormat DATE_TIME_FORMAT = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
    private static final SimpleDateFormat DATE_ONLY_FORMAT = new SimpleDateFormat("dd MMM yyyy");

    public List<Map<String, Object>> getAllStock(int hospitalId) {
        List<Map<String, Object>> stockList = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            boolean hasDateColumns = hasBloodStockDateColumns(connection);
            String sql = "SELECT bs.id, bg.id AS blood_group_id, bg.name AS blood_group, " +
                    "bs.units_available, bs.low_stock_threshold, " +
                    (hasDateColumns ? "bs.collection_date, bs.expiry_date, " : "") +
                    "bs.last_updated " +
                    "FROM blood_stock bs " +
                    "JOIN blood_groups bg ON bg.id = bs.blood_group_id " +
                    "WHERE bs.hospital_id = ? " +
                    "ORDER BY bg.id";
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                int units = resultSet.getInt("units_available");
                int threshold = resultSet.getInt("low_stock_threshold");
                LocalDate expiryDate = hasDateColumns ? toLocalDate(resultSet.getDate("expiry_date")) : null;

                Map<String, Object> row = new LinkedHashMap<>();
                row.put("id", resultSet.getInt("id"));
                row.put("bloodGroupId", resultSet.getInt("blood_group_id"));
                row.put("bloodGroupName", resultSet.getString("blood_group"));
                row.put("fullName", getBloodGroupFullName(resultSet.getString("blood_group")));
                row.put("units", units);
                row.put("threshold", threshold);
                row.put("status", units <= threshold ? "Low" : "Normal");
                row.put("lastUpdated", formatRelativeDateTime(resultSet.getTimestamp("last_updated")));
                row.put("expiryDate", formatLocalDate(expiryDate));
                row.put("expiryWarning", isExpiringSoon(expiryDate));
                stockList.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] getAllStock: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return stockList;
    }

    public Map<String, Object> getSummaryStats(int hospitalId) {
        Map<String, Object> stats = new LinkedHashMap<>();
        stats.put("totalUnits", 0);
        stats.put("normalGroups", 0);
        stats.put("lowStockCount", 0);
        stats.put("expiringSoon", 0);

        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            boolean hasDateColumns = hasBloodStockDateColumns(connection);
            String sql = "SELECT " +
                    "COALESCE(SUM(units_available), 0) AS total, " +
                    "SUM(CASE WHEN units_available > low_stock_threshold THEN 1 ELSE 0 END) AS normal_groups, " +
                    "SUM(CASE WHEN units_available <= low_stock_threshold THEN 1 ELSE 0 END) AS low_stock, " +
                    (hasDateColumns
                            ? "SUM(CASE WHEN expiry_date IS NOT NULL AND expiry_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY) THEN 1 ELSE 0 END)"
                            : "0") +
                    " AS expiring_soon " +
                    "FROM blood_stock WHERE hospital_id = ?";
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                stats.put("totalUnits", resultSet.getInt("total"));
                stats.put("normalGroups", resultSet.getInt("normal_groups"));
                stats.put("lowStockCount", resultSet.getInt("low_stock"));
                stats.put("expiringSoon", resultSet.getInt("expiring_soon"));
            }
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] getSummaryStats: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return stats;
    }

    public String getHospitalName(int hospitalId) {
        String sql = "SELECT hospital_name FROM hospitals WHERE user_id = ?";
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getString("hospital_name");
            }
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] getHospitalName: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return getFallbackHospitalName(hospitalId);
    }

    public List<Map<String, Object>> getAllBloodGroups() {
        String sql = "SELECT id, name FROM blood_groups ORDER BY id";
        List<Map<String, Object>> bloodGroups = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                Map<String, Object> row = new LinkedHashMap<>();
                String code = resultSet.getString("name");
                row.put("id", resultSet.getInt("id"));
                row.put("name", code);
                row.put("fullName", getBloodGroupFullName(code));
                bloodGroups.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] getAllBloodGroups: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return bloodGroups;
    }

    public List<Map<String, Object>> getCurrentStockSidebar(int hospitalId) {
        List<Map<String, Object>> sidebarStock = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            boolean hasDateColumns = hasBloodStockDateColumns(connection);
            String sql = "SELECT bg.id, bg.name AS blood_group, " +
                    "COALESCE(bs.units_available, 0) AS units_available, " +
                    "COALESCE(bs.low_stock_threshold, 5) AS low_stock_threshold" +
                    (hasDateColumns ? ", bs.expiry_date " : " ") +
                    "FROM blood_groups bg " +
                    "LEFT JOIN blood_stock bs ON bs.blood_group_id = bg.id AND bs.hospital_id = ? " +
                    "ORDER BY bg.id";
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                int units = resultSet.getInt("units_available");
                int threshold = resultSet.getInt("low_stock_threshold");
                String code = resultSet.getString("blood_group");

                Map<String, Object> row = new LinkedHashMap<>();
                row.put("bloodGroupName", code);
                row.put("fullName", getBloodGroupFullName(code));
                row.put("units", units);
                row.put("threshold", threshold);
                row.put("status", units <= threshold ? "Low" : "Normal");
                row.put("expiryDate", hasDateColumns
                        ? formatLocalDate(toLocalDate(resultSet.getDate("expiry_date")))
                        : "N/A");
                sidebarStock.add(row);
            }
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] getCurrentStockSidebar: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return sidebarStock;
    }

    public List<String> getLowStockGroupNames(int hospitalId) {
        String sql = "SELECT bg.name AS blood_group " +
                "FROM blood_stock bs " +
                "JOIN blood_groups bg ON bg.id = bs.blood_group_id " +
                "WHERE bs.hospital_id = ? AND bs.units_available <= bs.low_stock_threshold " +
                "ORDER BY bg.id";

        List<String> names = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                names.add(resultSet.getString("blood_group"));
            }
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] getLowStockGroupNames: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return names;
    }

    public Map<String, Object> getStockById(int id, int hospitalId) {
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            boolean hasDateColumns = hasBloodStockDateColumns(connection);
            String sql = "SELECT bs.id, bs.hospital_id, bg.id AS blood_group_id, bg.name AS blood_group, " +
                    "bs.units_available, bs.low_stock_threshold, " +
                    (hasDateColumns ? "bs.collection_date, bs.expiry_date, " : "") +
                    "bs.last_updated " +
                    "FROM blood_stock bs " +
                    "JOIN blood_groups bg ON bg.id = bs.blood_group_id " +
                    "WHERE bs.id = ? AND bs.hospital_id = ?";
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            statement.setInt(2, hospitalId);
            resultSet = statement.executeQuery();

            if (resultSet.next()) {
                Map<String, Object> stock = new LinkedHashMap<>();
                stock.put("id", resultSet.getInt("id"));
                stock.put("hospitalId", resultSet.getInt("hospital_id"));
                stock.put("bloodGroupId", resultSet.getInt("blood_group_id"));
                stock.put("bloodGroupName", resultSet.getString("blood_group"));
                stock.put("fullName", getBloodGroupFullName(resultSet.getString("blood_group")));
                stock.put("units", resultSet.getInt("units_available"));
                stock.put("threshold", resultSet.getInt("low_stock_threshold"));
                stock.put("status", resultSet.getInt("units_available") <= resultSet.getInt("low_stock_threshold") ? "Low" : "Normal");
                stock.put("lastUpdated", formatRelativeDateTime(resultSet.getTimestamp("last_updated")));
                stock.put("collectionDate", hasDateColumns ? toLocalDateString(resultSet.getDate("collection_date")) : "");
                stock.put("expiryDate", hasDateColumns ? toLocalDateString(resultSet.getDate("expiry_date")) : "");
                return stock;
            }
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] getStockById: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return null;
    }

    public boolean upsertStock(int hospitalId, int bloodGroupId, int units, LocalDate collectionDate, LocalDate expiryDate) {
        Connection connection = null;
        PreparedStatement statement = null;

        try {
            ensureHospitalRecordExists(hospitalId);
            connection = DBConnection.getConnection();
            boolean hasDateColumns = hasBloodStockDateColumns(connection);
            String sql;
            if (hasDateColumns) {
                sql = "INSERT INTO blood_stock (hospital_id, blood_group_id, units_available, low_stock_threshold, collection_date, expiry_date) " +
                        "VALUES (?, ?, ?, 5, ?, ?) " +
                        "ON DUPLICATE KEY UPDATE units_available = units_available + VALUES(units_available), " +
                        "collection_date = VALUES(collection_date), expiry_date = VALUES(expiry_date), last_updated = NOW()";
            } else {
                sql = "INSERT INTO blood_stock (hospital_id, blood_group_id, units_available, low_stock_threshold) " +
                        "VALUES (?, ?, ?, 5) " +
                        "ON DUPLICATE KEY UPDATE units_available = units_available + VALUES(units_available), last_updated = NOW()";
            }
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            statement.setInt(2, bloodGroupId);
            statement.setInt(3, units);
            if (hasDateColumns) {
                statement.setDate(4, java.sql.Date.valueOf(collectionDate));
                statement.setDate(5, java.sql.Date.valueOf(expiryDate));
            }
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] upsertStock: " + e.getMessage());
        } finally {
            closeQuietly(statement);
            closeQuietly(connection);
        }
        return false;
    }

    public boolean updateStock(int id, int hospitalId, int bloodGroupId, int units, LocalDate collectionDate, LocalDate expiryDate) {
        Connection connection = null;
        PreparedStatement statement = null;

        try {
            connection = DBConnection.getConnection();
            boolean hasDateColumns = hasBloodStockDateColumns(connection);
            String sql;
            if (hasDateColumns) {
                sql = "UPDATE blood_stock SET blood_group_id = ?, units_available = ?, collection_date = ?, expiry_date = ?, last_updated = NOW() " +
                        "WHERE id = ? AND hospital_id = ?";
            } else {
                sql = "UPDATE blood_stock SET blood_group_id = ?, units_available = ?, last_updated = NOW() " +
                        "WHERE id = ? AND hospital_id = ?";
            }
            statement = connection.prepareStatement(sql);
            statement.setInt(1, bloodGroupId);
            statement.setInt(2, units);
            if (hasDateColumns) {
                statement.setDate(3, java.sql.Date.valueOf(collectionDate));
                statement.setDate(4, java.sql.Date.valueOf(expiryDate));
                statement.setInt(5, id);
                statement.setInt(6, hospitalId);
            } else {
                statement.setInt(3, id);
                statement.setInt(4, hospitalId);
            }
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] updateStock: " + e.getMessage());
        } finally {
            closeQuietly(statement);
            closeQuietly(connection);
        }
        return false;
    }

    public boolean deleteStock(int id, int hospitalId) {
        String sql = "DELETE FROM blood_stock WHERE id = ? AND hospital_id = ?";

        Connection connection = null;
        PreparedStatement statement = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, id);
            statement.setInt(2, hospitalId);
            return statement.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] deleteStock: " + e.getMessage());
        } finally {
            closeQuietly(statement);
            closeQuietly(connection);
        }
        return false;
    }

    private void ensureHospitalRecordExists(int hospitalId) throws SQLException {
        Connection connection = null;
        PreparedStatement checkStatement = null;
        PreparedStatement insertStatement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            checkStatement = connection.prepareStatement("SELECT hospital_name FROM hospitals WHERE user_id = ?");
            checkStatement.setInt(1, hospitalId);
            resultSet = checkStatement.executeQuery();
            if (resultSet.next()) {
                return;
            }

            closeQuietly(resultSet);
            resultSet = null;

            insertStatement = connection.prepareStatement(
                    "INSERT INTO hospitals (user_id, hospital_name) VALUES (?, ?)");
            insertStatement.setInt(1, hospitalId);
            insertStatement.setString(2, getFallbackHospitalName(hospitalId));
            insertStatement.executeUpdate();
        } finally {
            closeQuietly(resultSet);
            closeQuietly(checkStatement);
            closeQuietly(insertStatement);
            closeQuietly(connection);
        }
    }

    private String getFallbackHospitalName(int hospitalId) {
        String sql = "SELECT full_name, email FROM users WHERE id = ?";
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                String fullName = resultSet.getString("full_name");
                if (fullName != null && !fullName.trim().isEmpty()) {
                    return fullName.trim();
                }
                String email = resultSet.getString("email");
                if (email != null && !email.trim().isEmpty()) {
                    return email.trim();
                }
            }
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] getFallbackHospitalName: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return "Hospital Account";
    }

    private String getBloodGroupFullName(String code) {
        if ("A+".equals(code)) {
            return "Type A Positive";
        }
        if ("A-".equals(code)) {
            return "Type A Negative";
        }
        if ("B+".equals(code)) {
            return "Type B Positive";
        }
        if ("B-".equals(code)) {
            return "Type B Negative";
        }
        if ("AB+".equals(code)) {
            return "Type AB Positive";
        }
        if ("AB-".equals(code)) {
            return "Type AB Negative";
        }
        if ("O+".equals(code)) {
            return "Type O Positive";
        }
        if ("O-".equals(code)) {
            return "Type O Negative";
        }
        return code;
    }

    private String formatRelativeDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return "N/A";
        }

        Date date = new Date(timestamp.getTime());
        LocalDate valueDate = timestamp.toLocalDateTime().toLocalDate();
        LocalDate today = LocalDate.now();

        if (valueDate.equals(today)) {
            return "Today, " + new SimpleDateFormat("hh:mm a").format(date);
        }
        if (valueDate.equals(today.minusDays(1))) {
            return "Yesterday, " + new SimpleDateFormat("hh:mm a").format(date);
        }
        return DATE_TIME_FORMAT.format(date);
    }

    @SuppressWarnings("unused")
    private String formatDate(Timestamp timestamp) {
        if (timestamp == null) {
            return "N/A";
        }
        return DATE_ONLY_FORMAT.format(new Date(timestamp.getTime()));
    }

    private String formatLocalDate(LocalDate value) {
        if (value == null) {
            return "N/A";
        }
        return DATE_ONLY_FORMAT.format(java.sql.Date.valueOf(value));
    }

    private String toLocalDateString(java.sql.Date value) {
        return value == null ? "" : value.toLocalDate().toString();
    }

    private LocalDate toLocalDate(java.sql.Date value) {
        return value == null ? null : value.toLocalDate();
    }

    private boolean isExpiringSoon(LocalDate expiryDate) {
        if (expiryDate == null) {
            return false;
        }
        long days = ChronoUnit.DAYS.between(LocalDate.now(), expiryDate);
        return days >= 0 && days <= 7;
    }

    private boolean hasBloodStockDateColumns(Connection connection) {
        ResultSet resultSet = null;
        try {
            DatabaseMetaData metaData = connection.getMetaData();
            String catalog = connection.getCatalog();
            boolean hasCollectionDate = false;
            boolean hasExpiryDate = false;

            resultSet = metaData.getColumns(catalog, null, "blood_stock", "collection_date");
            hasCollectionDate = resultSet.next();
            closeQuietly(resultSet);

            resultSet = metaData.getColumns(catalog, null, "blood_stock", "expiry_date");
            hasExpiryDate = resultSet.next();
            return hasCollectionDate && hasExpiryDate;
        } catch (SQLException e) {
            System.err.println("[BloodStockDAO] hasBloodStockDateColumns: " + e.getMessage());
            return false;
        } finally {
            closeQuietly(resultSet);
        }
    }

    private void closeQuietly(ResultSet resultSet) {
        if (resultSet != null) {
            try {
                resultSet.close();
            } catch (SQLException e) {
                System.err.println("[BloodStockDAO] close ResultSet: " + e.getMessage());
            }
        }
    }

    private void closeQuietly(PreparedStatement statement) {
        if (statement != null) {
            try {
                statement.close();
            } catch (SQLException e) {
                System.err.println("[BloodStockDAO] close PreparedStatement: " + e.getMessage());
            }
        }
    }

    private void closeQuietly(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                System.err.println("[BloodStockDAO] close Connection: " + e.getMessage());
            }
        }
    }
}
