package com.lifelink.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String DB_URL_3306 = "jdbc:mysql://localhost:3306/lifelink_db";
    private static final String DB_URL_3307 = "jdbc:mysql://localhost:3307/lifelink_db";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = "Smita@123";

    public static Connection getConnection() throws SQLException {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new SQLException("MySQL JDBC Driver not found", e);
        }

        // 1. Try 3306 with password
        try {
            return DriverManager.getConnection(DB_URL_3306, DB_USER, DB_PASSWORD);
        } catch (SQLException e1) {
            // 2. Try 3306 passwordless
            try {
                return DriverManager.getConnection(DB_URL_3306, DB_USER, "");
            } catch (SQLException e2) {
                // 3. Try 3307 with password
                try {
                    return DriverManager.getConnection(DB_URL_3307, DB_USER, DB_PASSWORD);
                } catch (SQLException e3) {
                    // 4. Try 3307 passwordless
                    try {
                        return DriverManager.getConnection(DB_URL_3307, DB_USER, "");
                    } catch (SQLException e4) {
                        System.err.println("[DBConnection] Failed to connect to port 3306 and 3307.");
                        throw e4;
                    }
                }
            }
        }
    }
}
