package com.lifelink.dao;

import com.lifelink.model.Hospital;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class HospitalDAO {

    private Hospital mapResultSet(ResultSet rs) throws SQLException {
        Hospital h = new Hospital();
        h.setUserId(rs.getInt("user_id"));
        h.setHospitalName(rs.getString("hospital_name"));
        h.setLicenseNo(rs.getString("license_no"));
        h.setDistrictId(rs.getObject("district_id") != null ? rs.getInt("district_id") : null);
        h.setAddress(rs.getString("address"));
        h.setLatitude(rs.getBigDecimal("latitude"));
        h.setLongitude(rs.getBigDecimal("longitude"));
        h.setContactPerson(rs.getString("contact_person"));
        h.setWebsite(rs.getString("website"));
        h.setDistrictName(rs.getString("district_name"));
        return h;
    }

    public boolean save(Hospital hospital) {
        String sql = "INSERT INTO hospitals (user_id, hospital_name, license_no, district_id, address, latitude, longitude, contact_person, website) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, hospital.getUserId());
            stmt.setString(2, hospital.getHospitalName());
            stmt.setString(3, hospital.getLicenseNo());
            if (hospital.getDistrictId() != null) stmt.setInt(4, hospital.getDistrictId()); else stmt.setNull(4, Types.SMALLINT);
            stmt.setString(5, hospital.getAddress());
            stmt.setBigDecimal(6, hospital.getLatitude());
            stmt.setBigDecimal(7, hospital.getLongitude());
            stmt.setString(8, hospital.getContactPerson());
            stmt.setString(9, hospital.getWebsite());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Hospital findByUserId(Integer userId) {
        String sql = "SELECT h.*, d.name as district_name FROM hospitals h LEFT JOIN districts d ON h.district_id = d.id WHERE h.user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Hospital> findAll() {
        String sql = "SELECT h.*, d.name as district_name FROM hospitals h LEFT JOIN districts d ON h.district_id = d.id ORDER BY h.user_id DESC";
        List<Hospital> list = new ArrayList<>();
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

    public boolean update(Hospital hospital) {
        String sql = "UPDATE hospitals SET hospital_name = ?, license_no = ?, district_id = ?, address = ?, latitude = ?, longitude = ?, contact_person = ?, website = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, hospital.getHospitalName());
            stmt.setString(2, hospital.getLicenseNo());
            if (hospital.getDistrictId() != null) stmt.setInt(3, hospital.getDistrictId()); else stmt.setNull(3, Types.SMALLINT);
            stmt.setString(4, hospital.getAddress());
            stmt.setBigDecimal(5, hospital.getLatitude());
            stmt.setBigDecimal(6, hospital.getLongitude());
            stmt.setString(7, hospital.getContactPerson());
            stmt.setString(8, hospital.getWebsite());
            stmt.setInt(9, hospital.getUserId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Integer userId) {
        String sql = "DELETE FROM hospitals WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}
