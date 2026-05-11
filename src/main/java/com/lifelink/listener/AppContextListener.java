package com.lifelink.listener;

import com.lifelink.utils.DBConnection;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;

public class AppContextListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        // Validate database connectivity on startup
        if (DBConnection.getConnection() != null) {
            System.out.println("✅ Database pool initialized successfully.");
        } else {
            System.err.println("❌ Failed to initialize database pool.");
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        DBConnection.close();
    }
}
