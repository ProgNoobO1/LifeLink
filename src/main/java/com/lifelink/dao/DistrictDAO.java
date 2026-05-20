package com.lifelink.dao;

import com.lifelink.model.District;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class DistrictDAO {

    private District mapResultSet(ResultSet rs) throws SQLException {
        District d = new District();
        d.setId(rs.getInt("id"));
        d.setName(rs.getString("name"));
        d.setProvince(rs.getString("province"));
        d.setLatitude(rs.getBigDecimal("latitude"));
        d.setLongitude(rs.getBigDecimal("longitude"));
        return d;
    }

    public boolean save(District district) {
        String sql = "INSERT INTO districts (name, province, latitude, longitude) VALUES (?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, district.getName());
            stmt.setString(2, district.getProvince());
            stmt.setBigDecimal(3, district.getLatitude());
            stmt.setBigDecimal(4, district.getLongitude());
            int affected = stmt.executeUpdate();
            if (affected == 0) return false;
            try (ResultSet keys = stmt.getGeneratedKeys()) {
                if (keys.next()) district.setId(keys.getInt(1));
            }
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public District findById(Integer id) {
        String sql = "SELECT * FROM districts WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<District> findAll() {
        String sql = "SELECT * FROM districts ORDER BY name";
        List<District> list = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return Collections.emptyList();
        }
        return list;
    }

    public boolean update(District district) {
        String sql = "UPDATE districts SET name = ?, province = ?, latitude = ?, longitude = ? WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, district.getName());
            stmt.setString(2, district.getProvince());
            stmt.setBigDecimal(3, district.getLatitude());
            stmt.setBigDecimal(4, district.getLongitude());
            stmt.setInt(5, district.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Integer id) {
        String sql = "DELETE FROM districts WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
