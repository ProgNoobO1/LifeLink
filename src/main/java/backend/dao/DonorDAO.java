package lifelink.dao;

import lifelink.model.DonorSearchDTO;
import lifelink.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DonorDAO {

    /**
     * Search available donors by blood group and/or district.
     */
    public List<DonorSearchDTO> searchDonors(String bloodGroup, String district) {
        List<DonorSearchDTO> list = new ArrayList<>();
        
        StringBuilder sql = new StringBuilder(
            "SELECT d.user_id, d.blood_group, d.district, d.address, d.last_donated_at, d.total_donations, " +
            "u.full_name, u.email, u.phone " +
            "FROM donors d " +
            "JOIN users u ON d.user_id = u.id " +
            "WHERE d.is_available = 1 "
        );
        
        boolean hasBlood = bloodGroup != null && !bloodGroup.trim().isEmpty();
        boolean hasDistrict = district != null && !district.trim().isEmpty();
        
        if (hasBlood) {
            sql.append("AND d.blood_group = ? ");
        }
        if (hasDistrict) {
            sql.append("AND LOWER(d.district) LIKE LOWER(?) ");
        }
        sql.append("ORDER BY u.full_name ASC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            
            int index = 1;
            if (hasBlood) {
                ps.setString(index++, bloodGroup);
            }
            if (hasDistrict) {
                ps.setString(index++, "%" + district.trim() + "%");
            }
            
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    DonorSearchDTO d = new DonorSearchDTO();
                    d.setUserId(rs.getInt("user_id"));
                    d.setBloodGroup(rs.getString("blood_group"));
                    d.setDistrict(rs.getString("district"));
                    d.setAddress(rs.getString("address"));
                    d.setLastDonatedAt(rs.getDate("last_donated_at"));
                    d.setTotalDonations(rs.getInt("total_donations"));
                    d.setFullName(rs.getString("full_name"));
                    d.setEmail(rs.getString("email"));
                    d.setPhone(rs.getString("phone"));
                    list.add(d);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
