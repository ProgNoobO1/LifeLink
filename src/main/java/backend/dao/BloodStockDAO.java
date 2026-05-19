package backend.dao;

import backend.model.BloodStock;
import backend.utils.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class BloodStockDAO {

    /**
     * Get all stock entries for a hospital (all 8 blood groups).
     */
    private int getBloodGroupId(String group) {
        if (group == null) return -1;
        switch(group.trim().toUpperCase()) {
            case "A+": return 1;
            case "A-": return 2;
            case "B+": return 3;
            case "B-": return 4;
            case "AB+": return 5;
            case "AB-": return 6;
            case "O+": return 7;
            case "O-": return 8;
            default: return -1;
        }
    }

    private String getBloodGroupName(int bgId) {
        switch(bgId) {
            case 1: return "A+";
            case 2: return "A-";
            case 3: return "B+";
            case 4: return "B-";
            case 5: return "AB+";
            case 6: return "AB-";
            case 7: return "O+";
            case 8: return "O-";
            default: return "";
        }
    }

    /**
     * Get all stock entries for a hospital (all 8 blood groups).
     */
    public List<BloodStock> getAllStock(int hospitalId) {
        List<BloodStock> list = new ArrayList<>();
        String sql = "SELECT bs.id, bs.hospital_id, bg.name AS blood_group, bs.units_available, bs.last_updated "
                   + "FROM blood_stock bs "
                   + "JOIN blood_groups bg ON bs.blood_group_id = bg.id "
                   + "WHERE bs.hospital_id = ? "
                   + "ORDER BY bg.name";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get one stock entry by its ID.
     */
    public BloodStock getStockById(int stockId) {
        String sql = "SELECT bs.id, bs.hospital_id, bg.name AS blood_group, bs.units_available, bs.last_updated "
                   + "FROM blood_stock bs "
                   + "JOIN blood_groups bg ON bs.blood_group_id = bg.id "
                   + "WHERE bs.id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, stockId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get stock by blood group for a specific hospital.
     */
    public BloodStock getStockByBloodGroup(int hospitalId, String bloodGroup) {
        String sql = "SELECT bs.id, bs.hospital_id, bg.name AS blood_group, bs.units_available, bs.last_updated "
                   + "FROM blood_stock bs "
                   + "JOIN blood_groups bg ON bs.blood_group_id = bg.id "
                   + "WHERE bs.hospital_id = ? AND bg.name = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            ps.setString(2, bloodGroup);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapResultSet(rs);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Add a new stock entry. If the blood group already exists, adds the units to the existing stock.
     */
    public boolean addStock(int hospitalId, String bloodGroup, int units) {
        // First check if this blood group already exists for this hospital
        BloodStock existing = getStockByBloodGroup(hospitalId, bloodGroup);
        if (existing != null) {
            // If it exists, simply add the new units to the current available units
            int newTotalUnits = existing.getUnitsAvailable() + units;
            return updateStock(existing.getId(), bloodGroup, newTotalUnits);
        }

        // If it doesn't exist, insert a new row
        String sql = "INSERT INTO blood_stock (hospital_id, blood_group_id, units_available) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            ps.setInt(2, getBloodGroupId(bloodGroup));
            ps.setInt(3, units);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Update stock units for an existing entry.
     */
    public boolean updateStock(int stockId, String bloodGroup, int units) {
        String sql = "UPDATE blood_stock SET blood_group_id = ?, units_available = ?, last_updated = NOW() WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, getBloodGroupId(bloodGroup));
            ps.setInt(2, units);
            ps.setInt(3, stockId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Delete a stock entry.
     */
    public boolean deleteStock(int stockId) {
        String sql = "DELETE FROM blood_stock WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, stockId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Atomically deduct units. Returns false if insufficient stock.
     * Uses WHERE units_available >= ? to prevent going negative.
     */
    public boolean deductStock(int hospitalId, String bloodGroup, int unitsToDeduct) {
        String sql = "UPDATE blood_stock SET units_available = units_available - ? "
                   + "WHERE hospital_id = ? AND blood_group_id = ? AND units_available >= ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, unitsToDeduct);
            ps.setInt(2, hospitalId);
            ps.setInt(3, getBloodGroupId(bloodGroup));
            ps.setInt(4, unitsToDeduct);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Get all low stock entries (units < 15) for alert display.
     */
    public List<BloodStock> getLowStock(int hospitalId) {
        List<BloodStock> list = new ArrayList<>();
        String sql = "SELECT bs.id, bs.hospital_id, bg.name AS blood_group, bs.units_available, bs.last_updated "
                   + "FROM blood_stock bs "
                   + "JOIN blood_groups bg ON bs.blood_group_id = bg.id "
                   + "WHERE bs.hospital_id = ? AND bs.units_available < 15";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapResultSet(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Get total units across all blood groups for a hospital.
     */
    public int getTotalUnits(int hospitalId) {
        String sql = "SELECT COALESCE(SUM(units_available), 0) AS total FROM blood_stock WHERE hospital_id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("total");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Get count of blood groups with low stock (< 15 units).
     */
    public int getLowStockCount(int hospitalId) {
        String sql = "SELECT COUNT(*) AS cnt FROM blood_stock WHERE hospital_id = ? AND units_available < 15";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, hospitalId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("cnt");
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * INTEGRATION POINT: Member 4 (Search/Request) 
     * Search blood stock across all hospitals by blood group.
     * Used by the SearchServlet for blood availability search.
     */
    /*
    public List<BloodStock> searchByBloodGroup(String bloodGroup) {
        List<BloodStock> list = new ArrayList<>();
        String sql = "SELECT bs.*, h.hospital_name, h.address AS hospital_address "
                   + "FROM blood_stock bs "
                   + "JOIN hospitals h ON bs.hospital_id = h.id "
                   + "WHERE bs.blood_group = ? AND bs.units_available > 0 "
                   + "ORDER BY bs.units_available DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, bloodGroup);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    BloodStock s = mapResultSet(rs);
                    try {
                        s.setHospitalName(rs.getString("hospital_name"));
                        s.setHospitalAddress(rs.getString("hospital_address"));
                    } catch (SQLException ignored) {}
                    list.add(s);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
    */

    /**
     * Map a ResultSet row to a BloodStock object.
     */
    private BloodStock mapResultSet(ResultSet rs) throws SQLException {
        BloodStock s = new BloodStock();
        s.setId(rs.getInt("id"));
        s.setHospitalId(rs.getInt("hospital_id"));
        
        String group = "";
        try {
            group = rs.getString("blood_group");
        } catch (SQLException e) {
            int bgId = rs.getInt("blood_group_id");
            group = getBloodGroupName(bgId);
        }
        s.setBloodGroup(group);
        
        s.setUnitsAvailable(rs.getInt("units_available"));
        s.setLastUpdated(rs.getTimestamp("last_updated"));
        return s;
    }
}
