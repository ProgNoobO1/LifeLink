package backend.utils;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * Database Connection Utility.
 * STUB — Update credentials to match your MySQL setup.
 */
public class DBConnection {

    private static final String URL = "jdbc:mysql://localhost:3306/lifelink_db?useSSL=false";
    private static final String USER = "root";
    private static final String PASSWORD = "Herodai.com@123";  // Update with your MySQL password

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("MySQL Driver not found", e);
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
