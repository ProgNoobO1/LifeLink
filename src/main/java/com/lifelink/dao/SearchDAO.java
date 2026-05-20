package com.lifelink.dao;

import com.lifelink.utils.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class SearchDAO {

    public List<BloodGroupOption> findAllBloodGroups() throws SQLException {
        String sql = "SELECT id, name FROM blood_groups ORDER BY id";
        List<BloodGroupOption> groups = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                groups.add(new BloodGroupOption(rs.getInt("id"), rs.getString("name")));
            }
        }
        return groups;
    }

    public Integer findBloodGroupId(String bloodGroup) throws SQLException {
        if (bloodGroup == null || bloodGroup.trim().isEmpty()) {
            return null;
        }
        String sql = "SELECT id FROM blood_groups WHERE name = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, bloodGroup.trim());
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }
        return null;
    }

    public List<DonorResult> searchDonors(Integer bloodGroupId, String location) throws SQLException {
        String sql =
            "SELECT u.id, u.full_name, bg.name AS blood_group, d.name AS district, " +
            "       COALESCE(dn.is_available, 1) AS is_available, dn.last_donated_at, " +
            "       COALESCE(dn.total_donations, 0) AS total_donations, d.latitude, d.longitude " +
            "FROM users u " +
            "LEFT JOIN donors dn ON dn.user_id = u.id " +
            "JOIN blood_groups bg ON bg.id = COALESCE(dn.blood_group_id, u.blood_group_id) " +
            "LEFT JOIN districts d ON d.id = dn.district_id " +
            "WHERE u.is_active = 1 AND u.is_approved = 1 " +
            "  AND u.role = 'donor' " +
            "  AND (? IS NULL OR COALESCE(dn.blood_group_id, u.blood_group_id) = ?) " +
            "  AND (? IS NULL OR d.name LIKE ? OR dn.district_id IS NULL) " +
            "ORDER BY dn.is_available DESC, dn.last_donated_at ASC";
        List<DonorResult> donors = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            LocationPoint origin = findLocationPoint(conn, location);
            bindNullableFilters(stmt, bloodGroupId, location);
            try (ResultSet rs = stmt.executeQuery()) {
                int index = 0;
                while (rs.next()) {
                    DonorResult donor = new DonorResult();
                    donor.setId(rs.getLong("id"));
                    donor.setFullName(rs.getString("full_name"));
                    donor.setBloodGroup(rs.getString("blood_group"));
                    donor.setDistrict(valueOrDefault(rs.getString("district"), "Unknown"));
                    donor.setAvailable(rs.getInt("is_available") == 1);
                    donor.setLastDonatedAt(rs.getDate("last_donated_at"));
                    donor.setTotalDonations(rs.getInt("total_donations"));
                    donor.setDistanceKm(resolveDistance(index++, origin, nullableDouble(rs, "latitude"), nullableDouble(rs, "longitude"), rs.getString("district"), location));
                    donors.add(donor);
                }
            }
        }
        return donors;
    }

    public List<HospitalResult> searchHospitals(Integer bloodGroupId, String location) throws SQLException {
        String sql =
            "SELECT h.user_id, h.hospital_name, h.contact_person, d.name AS district, " +
            "       bg.name AS blood_group, COALESCE(bs.units_available, 0) AS units_available, " +
            "       COALESCE(bs.low_stock_threshold, 5) AS low_stock_threshold, " +
            "       COALESCE(h.latitude, d.latitude) AS latitude, COALESCE(h.longitude, d.longitude) AS longitude " +
            "FROM hospitals h " +
            "LEFT JOIN blood_stock bs ON bs.hospital_id = h.user_id AND (? IS NULL OR bs.blood_group_id = ?) " +
            "LEFT JOIN blood_groups bg ON bg.id = COALESCE(bs.blood_group_id, ?) " +
            "LEFT JOIN districts d ON d.id = h.district_id " +
            "WHERE (? IS NULL OR d.name LIKE ? OR h.district_id IS NULL) " +
            "ORDER BY h.hospital_name";
        Map<Long, HospitalResult> hospitals = new LinkedHashMap<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            LocationPoint origin = findLocationPoint(conn, location);
            String cleanedLocation = location == null || location.trim().isEmpty() ? null : "%" + location.trim() + "%";
            if (bloodGroupId == null) {
                stmt.setNull(1, java.sql.Types.INTEGER);
                stmt.setNull(2, java.sql.Types.INTEGER);
                stmt.setNull(3, java.sql.Types.INTEGER);
            } else {
                stmt.setInt(1, bloodGroupId);
                stmt.setInt(2, bloodGroupId);
                stmt.setInt(3, bloodGroupId);
            }
            if (cleanedLocation == null) {
                stmt.setNull(4, java.sql.Types.VARCHAR);
                stmt.setNull(5, java.sql.Types.VARCHAR);
            } else {
                stmt.setString(4, cleanedLocation);
                stmt.setString(5, cleanedLocation);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                int index = 0;
                while (rs.next()) {
                    long id = rs.getLong("user_id");
                    HospitalResult hospital = hospitals.get(id);
                    if (hospital == null) {
                        hospital = new HospitalResult();
                        hospital.setId(id);
                        hospital.setHospitalName(rs.getString("hospital_name"));
                        hospital.setContactPerson(rs.getString("contact_person"));
                        hospital.setDistrict(valueOrDefault(rs.getString("district"), "Unknown"));
                        hospital.setDistanceKm(resolveDistance(index++, origin, nullableDouble(rs, "latitude"), nullableDouble(rs, "longitude"), rs.getString("district"), location));
                        hospitals.put(id, hospital);
                    }
                    int units = rs.getInt("units_available");
                    int threshold = rs.getInt("low_stock_threshold");
                    String stockBloodGroup = rs.getString("blood_group");
                    if (stockBloodGroup != null) {
                        hospital.getStock().add(new StockItem(stockBloodGroup, units, threshold));
                        hospital.setTotalUnits(hospital.getTotalUnits() + units);
                    }
                    if (units > threshold) {
                        hospital.setOpen(true);
                    }
                }
            }
        }
        return new ArrayList<>(hospitals.values());
    }

    public List<HospitalResult> findTopHospitals() throws SQLException {
        List<HospitalResult> hospitals = searchHospitals(null, null);
        return hospitals.size() > 4 ? hospitals.subList(0, 4) : hospitals;
    }

    public List<DonorResult> findTopAvailableDonors() throws SQLException {
        List<DonorResult> donors = searchDonors(null, null);
        List<DonorResult> top = new ArrayList<>();
        for (DonorResult donor : donors) {
            if (donor.isAvailable()) {
                top.add(donor);
            }
            if (top.size() == 5) {
                break;
            }
        }
        return top;
    }

    public List<PopularSearch> findPopularSearchCounts() throws SQLException {
        String sql =
            "SELECT bg.name, COALESCE(SUM(CASE WHEN u.id IS NOT NULL " +
            "    AND COALESCE(dn.is_available, 1) = 1 THEN 1 ELSE 0 END), 0) AS donor_count " +
            "FROM blood_groups bg " +
            "LEFT JOIN users u ON u.blood_group_id = bg.id " +
            "    AND u.role = 'donor' AND u.is_active = 1 AND u.is_approved = 1 " +
            "LEFT JOIN donors dn ON dn.user_id = u.id " +
            "GROUP BY bg.id, bg.name " +
            "ORDER BY donor_count DESC";
        List<PopularSearch> popular = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                popular.add(new PopularSearch(rs.getString("name"), rs.getInt("donor_count")));
            }
        }
        return popular;
    }

    private void bindNullableFilters(PreparedStatement stmt, Integer bloodGroupId, String location) throws SQLException {
        String cleanedLocation = location == null || location.trim().isEmpty() ? null : "%" + location.trim() + "%";
        if (bloodGroupId == null) {
            stmt.setNull(1, java.sql.Types.INTEGER);
            stmt.setNull(2, java.sql.Types.INTEGER);
        } else {
            stmt.setInt(1, bloodGroupId);
            stmt.setInt(2, bloodGroupId);
        }
        if (cleanedLocation == null) {
            stmt.setNull(3, java.sql.Types.VARCHAR);
            stmt.setNull(4, java.sql.Types.VARCHAR);
        } else {
            stmt.setString(3, cleanedLocation);
            stmt.setString(4, cleanedLocation);
        }
    }

    private LocationPoint findLocationPoint(Connection conn, String location) throws SQLException {
        if (location == null || location.trim().isEmpty()) {
            return null;
        }
        String sql =
            "SELECT latitude, longitude FROM districts " +
            "WHERE name LIKE ? AND latitude IS NOT NULL AND longitude IS NOT NULL " +
            "ORDER BY CASE WHEN LOWER(name) = LOWER(?) THEN 0 ELSE 1 END, name LIMIT 1";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            String cleaned = location.trim();
            stmt.setString(1, "%" + cleaned + "%");
            stmt.setString(2, cleaned);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new LocationPoint(rs.getDouble("latitude"), rs.getDouble("longitude"));
                }
            }
        }
        return null;
    }

    private double resolveDistance(int index, LocationPoint origin, Double latitude, Double longitude, String district, String location) {
        if (origin != null && latitude != null && longitude != null) {
            return haversineKm(origin.latitude, origin.longitude, latitude, longitude);
        }
        if (district != null && location != null && district.toLowerCase().contains(location.toLowerCase().trim())) {
            return 1.2 + (index * 0.6);
        }
        return 1.2 + (index * 1.3);
    }

    private double haversineKm(double lat1, double lon1, double lat2, double lon2) {
        final double radiusKm = 6371.0;
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        return radiusKm * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    }

    private Double nullableDouble(ResultSet rs, String column) throws SQLException {
        double value = rs.getDouble(column);
        return rs.wasNull() ? null : value;
    }

    private String valueOrDefault(String value, String fallback) {
        return value == null || value.trim().isEmpty() ? fallback : value;
    }

    private static class LocationPoint {
        private final double latitude;
        private final double longitude;
        private LocationPoint(double latitude, double longitude) {
            this.latitude = latitude;
            this.longitude = longitude;
        }
    }

    public static class BloodGroupOption {
        private final int id;
        private final String name;
        public BloodGroupOption(int id, String name) { this.id = id; this.name = name; }
        public int getId() { return id; }
        public String getName() { return name; }
    }

    public static class PopularSearch {
        private final String bloodGroup;
        private final int donorCount;
        public PopularSearch(String bloodGroup, int donorCount) { this.bloodGroup = bloodGroup; this.donorCount = donorCount; }
        public String getBloodGroup() { return bloodGroup; }
        public int getDonorCount() { return donorCount; }
    }

    public static class DonorResult {
        private long id;
        private String fullName;
        private String bloodGroup;
        private String district;
        private boolean available;
        private Date lastDonatedAt;
        private int totalDonations;
        private double distanceKm;
        public long getId() { return id; }
        public void setId(long id) { this.id = id; }
        public String getFullName() { return fullName; }
        public void setFullName(String fullName) { this.fullName = fullName; }
        public String getBloodGroup() { return bloodGroup; }
        public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }
        public String getDistrict() { return district; }
        public void setDistrict(String district) { this.district = district; }
        public boolean isAvailable() { return available; }
        public void setAvailable(boolean available) { this.available = available; }
        public Date getLastDonatedAt() { return lastDonatedAt; }
        public void setLastDonatedAt(Date lastDonatedAt) { this.lastDonatedAt = lastDonatedAt; }
        public int getTotalDonations() { return totalDonations; }
        public void setTotalDonations(int totalDonations) { this.totalDonations = totalDonations; }
        public double getDistanceKm() { return distanceKm; }
        public void setDistanceKm(double distanceKm) { this.distanceKm = distanceKm; }
    }

    public static class HospitalResult {
        private long id;
        private String hospitalName;
        private String contactPerson;
        private String district;
        private boolean open;
        private int totalUnits;
        private double distanceKm;
        private final List<StockItem> stock = new ArrayList<>();
        public long getId() { return id; }
        public void setId(long id) { this.id = id; }
        public String getHospitalName() { return hospitalName; }
        public void setHospitalName(String hospitalName) { this.hospitalName = hospitalName; }
        public String getContactPerson() { return contactPerson; }
        public void setContactPerson(String contactPerson) { this.contactPerson = contactPerson; }
        public String getDistrict() { return district; }
        public void setDistrict(String district) { this.district = district; }
        public boolean isOpen() { return open; }
        public void setOpen(boolean open) { this.open = open; }
        public int getTotalUnits() { return totalUnits; }
        public void setTotalUnits(int totalUnits) { this.totalUnits = totalUnits; }
        public double getDistanceKm() { return distanceKm; }
        public void setDistanceKm(double distanceKm) { this.distanceKm = distanceKm; }
        public List<StockItem> getStock() { return stock; }
    }

    public static class StockItem {
        private final String bloodGroup;
        private final int unitsAvailable;
        private final int lowStockThreshold;
        public StockItem(String bloodGroup, int unitsAvailable, int lowStockThreshold) {
            this.bloodGroup = bloodGroup;
            this.unitsAvailable = unitsAvailable;
            this.lowStockThreshold = lowStockThreshold;
        }
        public String getBloodGroup() { return bloodGroup; }
        public int getUnitsAvailable() { return unitsAvailable; }
        public int getLowStockThreshold() { return lowStockThreshold; }
        public boolean isLowStock() { return unitsAvailable <= lowStockThreshold; }
    }
}
