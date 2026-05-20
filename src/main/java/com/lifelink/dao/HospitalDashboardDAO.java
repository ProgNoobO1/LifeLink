package com.lifelink.dao;

import com.lifelink.utils.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class HospitalDashboardDAO {

    private static final SimpleDateFormat LAST_UPDATED_FORMAT = new SimpleDateFormat("dd MMM yyyy, hh:mm a");

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
            System.err.println("[HospitalDashboardDAO] getHospitalName: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return "";
    }

    public int getTotalStock(int hospitalId) {
        String sql = "SELECT COALESCE(SUM(units_available), 0) AS total_stock FROM blood_stock WHERE hospital_id = ?";
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("total_stock");
            }
        } catch (SQLException e) {
            System.err.println("[HospitalDashboardDAO] getTotalStock: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return 0;
    }

    public int getLowStockAlertCount(int hospitalId) {
        String sql = "SELECT COUNT(*) AS alert_count " +
                "FROM blood_shortage_alerts " +
                "WHERE hospital_id = ? AND is_resolved = 0";
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("alert_count");
            }
        } catch (SQLException e) {
            System.err.println("[HospitalDashboardDAO] getLowStockAlertCount: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return 0;
    }

    public int getPendingRequestCount(int hospitalId) {
        String sql = "SELECT COUNT(DISTINCT br.id) AS pending_count " +
                "FROM blood_requests br " +
                "JOIN request_responses rr ON rr.request_id = br.id " +
                "WHERE rr.responder_id = ? AND rr.responder_type = 'hospital' " +
                "AND br.status = 'pending'";
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();
            if (resultSet.next()) {
                return resultSet.getInt("pending_count");
            }
        } catch (SQLException e) {
            System.err.println("[HospitalDashboardDAO] getPendingRequestCount: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return 0;
    }

    public List<Map<String, Object>> getStockOverview(int hospitalId) {
        String sql = "SELECT bg.name AS blood_group, bs.units_available, bs.low_stock_threshold, bs.last_updated " +
                "FROM blood_stock bs " +
                "JOIN blood_groups bg ON bg.id = bs.blood_group_id " +
                "WHERE bs.hospital_id = ? " +
                "ORDER BY bg.id";
        List<Map<String, Object>> stockList = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                int units = resultSet.getInt("units_available");
                int threshold = resultSet.getInt("low_stock_threshold");
                Timestamp lastUpdated = resultSet.getTimestamp("last_updated");

                Map<String, Object> stockItem = new LinkedHashMap<>();
                stockItem.put("bloodGroup", resultSet.getString("blood_group"));
                stockItem.put("units", units);
                stockItem.put("threshold", threshold);
                stockItem.put("status", units <= threshold ? "Low" : "Normal");
                stockItem.put("lastUpdated", lastUpdated != null ? LAST_UPDATED_FORMAT.format(lastUpdated) : "N/A");
                stockList.add(stockItem);
            }
        } catch (SQLException e) {
            System.err.println("[HospitalDashboardDAO] getStockOverview: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return stockList;
    }

    public List<Map<String, Object>> getLowStockAlerts(int hospitalId) {
        String sql = "SELECT bg.name AS blood_group, bsa.units_at_alert, MAX(bsa.created_at) AS latest_created " +
                "FROM blood_shortage_alerts bsa " +
                "JOIN blood_groups bg ON bg.id = bsa.blood_group_id " +
                "WHERE bsa.hospital_id = ? AND bsa.is_resolved = 0 " +
                "GROUP BY bsa.blood_group_id, bg.name, bsa.units_at_alert " +
                "ORDER BY bsa.units_at_alert ASC, latest_created DESC";
        List<Map<String, Object>> alertList = new ArrayList<>();
        Connection connection = null;
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(sql);
            statement.setInt(1, hospitalId);
            resultSet = statement.executeQuery();

            while (resultSet.next()) {
                Map<String, Object> alertItem = new LinkedHashMap<>();
                alertItem.put("bloodGroup", resultSet.getString("blood_group"));
                alertItem.put("unitsAtAlert", resultSet.getInt("units_at_alert"));
                alertList.add(alertItem);
            }
        } catch (SQLException e) {
            System.err.println("[HospitalDashboardDAO] getLowStockAlerts: " + e.getMessage());
        } finally {
            closeQuietly(resultSet);
            closeQuietly(statement);
            closeQuietly(connection);
        }

        return alertList;
    }

    public void createOrUpdateLowStockAlert(int hospitalId, int bloodGroupId, int unitsAtAlert) {
        Connection connection = null;
        PreparedStatement updateStatement = null;
        PreparedStatement insertStatement = null;

        try {
            connection = DBConnection.getConnection();

            updateStatement = connection.prepareStatement(
                    "UPDATE blood_shortage_alerts " +
                            "SET units_at_alert = ?, created_at = NOW() " +
                            "WHERE hospital_id = ? AND blood_group_id = ? AND is_resolved = 0"
            );
            updateStatement.setInt(1, Math.max(0, unitsAtAlert));
            updateStatement.setInt(2, hospitalId);
            updateStatement.setInt(3, bloodGroupId);

            int updated = updateStatement.executeUpdate();
            if (updated > 0) {
                return;
            }

            insertStatement = connection.prepareStatement(
                    "INSERT INTO blood_shortage_alerts (hospital_id, blood_group_id, units_at_alert) VALUES (?, ?, ?)"
            );
            insertStatement.setInt(1, hospitalId);
            insertStatement.setInt(2, bloodGroupId);
            insertStatement.setInt(3, Math.max(0, unitsAtAlert));
            insertStatement.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[HospitalDashboardDAO] createOrUpdateLowStockAlert: " + e.getMessage());
        } finally {
            closeQuietly(updateStatement);
            closeQuietly(insertStatement);
            closeQuietly(connection);
        }
    }

    public void resolveLowStockAlert(int hospitalId, int bloodGroupId) {
        Connection connection = null;
        PreparedStatement statement = null;

        try {
            connection = DBConnection.getConnection();
            statement = connection.prepareStatement(
                    "UPDATE blood_shortage_alerts " +
                            "SET is_resolved = 1, resolved_at = NOW() " +
                            "WHERE hospital_id = ? AND blood_group_id = ? AND is_resolved = 0"
            );
            statement.setInt(1, hospitalId);
            statement.setInt(2, bloodGroupId);
            statement.executeUpdate();
        } catch (SQLException e) {
            System.err.println("[HospitalDashboardDAO] resolveLowStockAlert: " + e.getMessage());
        } finally {
            closeQuietly(statement);
            closeQuietly(connection);
        }
    }

    private void closeQuietly(ResultSet resultSet) {
        if (resultSet != null) {
            try {
                resultSet.close();
            } catch (SQLException e) {
                System.err.println("[HospitalDashboardDAO] close ResultSet: " + e.getMessage());
            }
        }
    }

    private void closeQuietly(PreparedStatement statement) {
        if (statement != null) {
            try {
                statement.close();
            } catch (SQLException e) {
                System.err.println("[HospitalDashboardDAO] close PreparedStatement: " + e.getMessage());
            }
        }
    }

    private void closeQuietly(Connection connection) {
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException e) {
                System.err.println("[HospitalDashboardDAO] close Connection: " + e.getMessage());
            }
        }
    }
}
