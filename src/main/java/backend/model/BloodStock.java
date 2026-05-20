package lifelink.model;

import java.sql.Timestamp;

public class BloodStock {
    private int id;
    private int hospitalId;
    private String bloodGroup;   // A+, A-, B+, B-, AB+, AB-, O+, O-
    private int unitsAvailable;
    private Timestamp lastUpdated;

    public BloodStock() {}

    // Helper method for stock level status
    public String getStockLevel() {
        if (unitsAvailable < 5) return "critical";    // red
        if (unitsAvailable < 15) return "low";         // yellow
        return "normal";                                // green
    }

    // Helper for Bootstrap badge class
    public String getStockBadgeClass() {
        if (unitsAvailable < 5) return "bg-danger";
        if (unitsAvailable < 15) return "bg-warning text-dark";
        return "bg-success";
    }

    // Helper for stock level display text
    public String getStockLevelDisplay() {
        if (unitsAvailable < 5) return "Critical";
        if (unitsAvailable < 15) return "Low";
        return "Normal";
    }

    // Helper for progress bar width (max 50 units = 100%)
    public int getProgressWidth() {
        return Math.min(unitsAvailable * 2, 100);
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getHospitalId() { return hospitalId; }
    public void setHospitalId(int hospitalId) { this.hospitalId = hospitalId; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public int getUnitsAvailable() { return unitsAvailable; }
    public void setUnitsAvailable(int unitsAvailable) { this.unitsAvailable = unitsAvailable; }

    public Timestamp getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(Timestamp lastUpdated) { this.lastUpdated = lastUpdated; }

    // Joined fields for search results
    private String hospitalName;
    private String hospitalAddress;

    public String getHospitalName() { return hospitalName; }
    public void setHospitalName(String hospitalName) { this.hospitalName = hospitalName; }

    public String getHospitalAddress() { return hospitalAddress; }
    public void setHospitalAddress(String hospitalAddress) { this.hospitalAddress = hospitalAddress; }
}
