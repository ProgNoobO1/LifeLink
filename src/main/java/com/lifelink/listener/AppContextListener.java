package com.lifelink.listener;

import com.lifelink.utils.DBConnection;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

import java.sql.Connection;
import java.sql.SQLException;

public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Validate database connectivity on startup
        try (Connection conn = DBConnection.getConnection()) {
            if (conn != null) {
                System.out.println("✅ Database pool initialized successfully.");
            } else {
                System.err.println("❌ Failed to initialize database pool.");
            }
        } catch (SQLException e) {
            System.err.println("❌ Failed to initialize database pool: " + e.getMessage());
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DBConnection.close();
    }
}
