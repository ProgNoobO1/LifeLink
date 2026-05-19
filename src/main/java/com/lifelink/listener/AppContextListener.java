package com.lifelink.listener;

import com.lifelink.utils.DBConnection;
import com.mysql.cj.jdbc.AbandonedConnectionCleanupThread;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

import java.sql.Connection;
import java.sql.Driver;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Enumeration;

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
        // Close connection pool
        DBConnection.close();

        // Stop MySQL abandoned-connection cleanup thread to prevent memory leaks
        try {
            AbandonedConnectionCleanupThread.checkedShutdown();
        } catch (Exception e) {
            // Fallback via reflection for different driver versions
            try {
                java.lang.reflect.Method m = AbandonedConnectionCleanupThread.class.getDeclaredMethod("shutdown", boolean.class);
                m.setAccessible(true);
                m.invoke(null, true);
            } catch (Exception ex) {
                // ignore
            }
        }

        // Deregister JDBC drivers loaded by this webapp
        Enumeration<Driver> drivers = DriverManager.getDrivers();
        while (drivers.hasMoreElements()) {
            Driver driver = drivers.nextElement();
            try {
                DriverManager.deregisterDriver(driver);
            } catch (SQLException e) {
                // ignore
            }
        }
    }
}
