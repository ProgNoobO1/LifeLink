package com.lifelink.model;

import java.time.LocalDateTime;

public class BloodStock {
    private Integer id;
    private Integer hospitalId;
    private Integer bloodGroupId;
    private Integer unitsAvailable;
    private Integer lowStockThreshold;
    private LocalDateTime lastUpdated;

    // Join fields
    private String hospitalName;
    private String bloodGroupName;

    public BloodStock() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getHospitalId() { return hospitalId; }
    public void setHospitalId(Integer hospitalId) { this.hospitalId = hospitalId; }

    public Integer getBloodGroupId() { return bloodGroupId; }
    public void setBloodGroupId(Integer bloodGroupId) { this.bloodGroupId = bloodGroupId; }

    public Integer getUnitsAvailable() { return unitsAvailable; }
    public void setUnitsAvailable(Integer unitsAvailable) { this.unitsAvailable = unitsAvailable; }

    public Integer getLowStockThreshold() { return lowStockThreshold; }
    public void setLowStockThreshold(Integer lowStockThreshold) { this.lowStockThreshold = lowStockThreshold; }

    public LocalDateTime getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(LocalDateTime lastUpdated) { this.lastUpdated = lastUpdated; }

    public String getHospitalName() { return hospitalName; }
    public void setHospitalName(String hospitalName) { this.hospitalName = hospitalName; }

    public String getBloodGroupName() { return bloodGroupName; }
    public void setBloodGroupName(String bloodGroupName) { this.bloodGroupName = bloodGroupName; }
}
