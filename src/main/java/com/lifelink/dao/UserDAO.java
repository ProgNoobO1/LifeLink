package com.lifelink.dao;

import com.lifelink.model.User;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class UserDAO {

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getLong("id"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setBloodGroup(rs.getString("blood_group"));
        user.setPasswordHash(rs.getString("password_hash"));

        String roleStr = rs.getString("role");
        if (roleStr != null) {
            user.setRole(User.Role.valueOf(roleStr.toUpperCase()));
        }

        int isActive = rs.getInt("is_active");
        int isApproved = rs.getInt("is_approved");
        if (isActive == 1) {
            user.setStatus(User.Status.ACTIVE);
        } else if (isApproved == 1) {
            user.setStatus(User.Status.SUSPENDED); // rejected
        } else {
            user.setStatus(User.Status.INACTIVE); // pending
        }
        user.setApproved(isApproved == 1);

        Timestamp createdAt = rs.getTimestamp("created_at");
        if (createdAt != null) {
            user.setCreatedAt(createdAt.toLocalDateTime());
        }
        Timestamp updatedAt = rs.getTimestamp("updated_at");
        if (updatedAt != null) {
            user.setUpdatedAt(updatedAt.toLocalDateTime());
        }

        return user;
    }

    public User findByEmail(String email) {
        String sql = "SELECT u.*, bg.name as blood_group FROM users u LEFT JOIN blood_groups bg ON u.blood_group_id = bg.id WHERE u.email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public User findById(Long id) {
        String sql = "SELECT u.*, bg.name as blood_group FROM users u LEFT JOIN blood_groups bg ON u.blood_group_id = bg.id WHERE u.id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapResultSetToUser(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean save(User user) {
        String sql = "INSERT INTO users (full_name, email, phone, blood_group_id, password_hash, confirm_password_hash, role, is_active, is_approved) " +
                     "VALUES (?, ?, ?, (SELECT id FROM blood_groups WHERE name = ?), ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPhone());
            stmt.setString(4, user.getBloodGroup());
            stmt.setString(5, user.getPasswordHash());
            stmt.setString(6, user.getPasswordHash());
            stmt.setString(7, user.getRole().name().toLowerCase());
            int isActiveVal = user.getStatus() == User.Status.ACTIVE ? 1 : 0;
            int isApprovedVal = user.getStatus() == User.Status.SUSPENDED || user.isApproved() ? 1 : 0;
            stmt.setInt(8, isActiveVal);
            stmt.setInt(9, isApprovedVal);

            int affectedRows = stmt.executeUpdate();
            if (affectedRows == 0) {
                return false;
            }

            try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    user.setId(generatedKeys.getLong(1));
                }
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean update(User user) {
        String sql = "UPDATE users SET full_name = ?, email = ?, phone = ?, " +
                     "blood_group_id = (SELECT id FROM blood_groups WHERE name = ?), password_hash = ?, role = ?, is_active = ?, is_approved = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getFullName());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPhone());
            stmt.setString(4, user.getBloodGroup());
            stmt.setString(5, user.getPasswordHash());
            stmt.setString(6, user.getRole().name().toLowerCase());
            stmt.setInt(7, user.getStatus() == User.Status.ACTIVE ? 1 : 0);
            stmt.setInt(8, user.isApproved() ? 1 : 0);
            stmt.setLong(9, user.getId());

            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Long id) {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            int affectedRows = stmt.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public List<User> findAll(int offset, int limit) {
        String sql = "SELECT u.*, bg.name as blood_group FROM users u LEFT JOIN blood_groups bg ON u.blood_group_id = bg.id ORDER BY u.id DESC LIMIT ? OFFSET ?";
        List<User> users = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            stmt.setInt(2, offset);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
        return users;
    }

    public long countAll() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public long countByRole(User.Role role) {
        String sql = "SELECT COUNT(*) FROM users WHERE role = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role.name().toLowerCase());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public long countByBloodGroup(String bloodGroup) {
        String sql = "SELECT COUNT(*) FROM users u JOIN blood_groups bg ON u.blood_group_id = bg.id WHERE bg.name = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bloodGroup);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getLong(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    public List<User> findRecent(int limit) {
        String sql = "SELECT u.id, " +
                "CASE " +
                "    WHEN u.role = 'hospital' THEN COALESCE(NULLIF(h.hospital_name, ''), u.full_name) " +
                "    ELSE u.full_name " +
                "END AS full_name, " +
                "u.email, u.phone, bg.name as blood_group, u.password_hash, u.role, " +
                "u.is_active, u.is_approved, u.created_at, u.updated_at " +
                "FROM users u " +
                "LEFT JOIN blood_groups bg ON u.blood_group_id = bg.id " +
                "LEFT JOIN hospitals h ON h.user_id = u.id " +
                "ORDER BY u.id DESC LIMIT ?";
        List<User> users = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    users.add(mapResultSetToUser(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
        return users;
    }
}
