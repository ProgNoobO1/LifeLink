package com.lifelink.dao;

import com.lifelink.model.Donor;
import com.lifelink.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class DonorDAO {

    private Donor mapResultSet(ResultSet rs) throws SQLException {
        Donor d = new Donor();
        d.setUserId(rs.getInt("user_id"));
        d.setBloodGroupId(rs.getInt("blood_group_id"));
        d.setDistrictId(rs.getObject("district_id") != null ? rs.getInt("district_id") : null);
        d.setAddress(rs.getString("address"));
        Date dob = rs.getDate("date_of_birth");
        if (dob != null) d.setDateOfBirth(dob.toLocalDate());
        d.setGender(rs.getString("gender"));
        d.setWeightKg(rs.getBigDecimal("weight_kg"));
        d.setAvailable(rs.getInt("is_available") == 1);
        Date lastDonated = rs.getDate("last_donated_at");
        if (lastDonated != null) d.setLastDonatedAt(lastDonated.toLocalDate());
        d.setTotalDonations(rs.getInt("total_donations"));
        d.setBloodGroupName(rs.getString("blood_group_name"));
        d.setDistrictName(rs.getString("district_name"));
        return d;
    }

    public boolean save(Donor donor) {
        String sql = "INSERT INTO donors (user_id, blood_group_id, district_id, address, date_of_birth, gender, weight_kg, is_available, last_donated_at, total_donations) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, donor.getUserId());
            stmt.setInt(2, donor.getBloodGroupId());
            if (donor.getDistrictId() != null) stmt.setInt(3, donor.getDistrictId()); else stmt.setNull(3, Types.SMALLINT);
            stmt.setString(4, donor.getAddress());
            if (donor.getDateOfBirth() != null) stmt.setDate(5, Date.valueOf(donor.getDateOfBirth())); else stmt.setNull(5, Types.DATE);
            stmt.setString(6, donor.getGender());
            stmt.setBigDecimal(7, donor.getWeightKg());
            stmt.setInt(8, donor.isAvailable() ? 1 : 0);
            if (donor.getLastDonatedAt() != null) stmt.setDate(9, Date.valueOf(donor.getLastDonatedAt())); else stmt.setNull(9, Types.DATE);
            stmt.setInt(10, donor.getTotalDonations());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Donor findByUserId(Integer userId) {
        String sql = "SELECT d.*, bg.name as blood_group_name, dist.name as district_name " +
                     "FROM donors d " +
                     "JOIN blood_groups bg ON d.blood_group_id = bg.id " +
                     "LEFT JOIN districts dist ON d.district_id = dist.id " +
                     "WHERE d.user_id = ?";
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

    public List<Donor> findAll() {
        String sql = "SELECT d.*, bg.name as blood_group_name, dist.name as district_name " +
                     "FROM donors d " +
                     "JOIN blood_groups bg ON d.blood_group_id = bg.id " +
                     "LEFT JOIN districts dist ON d.district_id = dist.id " +
                     "ORDER BY d.user_id DESC";
        List<Donor> list = new ArrayList<>();
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

    public boolean update(Donor donor) {
        String sql = "UPDATE donors SET blood_group_id = ?, district_id = ?, address = ?, date_of_birth = ?, gender = ?, weight_kg = ?, is_available = ?, last_donated_at = ?, total_donations = ? WHERE user_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, donor.getBloodGroupId());
            if (donor.getDistrictId() != null) stmt.setInt(2, donor.getDistrictId()); else stmt.setNull(2, Types.SMALLINT);
            stmt.setString(3, donor.getAddress());
            if (donor.getDateOfBirth() != null) stmt.setDate(4, Date.valueOf(donor.getDateOfBirth())); else stmt.setNull(4, Types.DATE);
            stmt.setString(5, donor.getGender());
            stmt.setBigDecimal(6, donor.getWeightKg());
            stmt.setInt(7, donor.isAvailable() ? 1 : 0);
            if (donor.getLastDonatedAt() != null) stmt.setDate(8, Date.valueOf(donor.getLastDonatedAt())); else stmt.setNull(8, Types.DATE);
            stmt.setInt(9, donor.getTotalDonations());
            stmt.setInt(10, donor.getUserId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public boolean delete(Integer userId) {
        String sql = "DELETE FROM donors WHERE user_id = ?";
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
