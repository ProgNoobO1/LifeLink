package com.lifelink.model;

import java.time.LocalDateTime;

public class BloodShortageAlert {
    private Integer id;
    private Integer hospitalId;
    private Integer bloodGroupId;
    private Integer unitsAtAlert;
    private boolean resolved;
    private LocalDateTime createdAt;
    private LocalDateTime resolvedAt;

    // Join fields
    private String hospitalName;
    private String bloodGroupName;

    public BloodShortageAlert() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getHospitalId() { return hospitalId; }
    public void setHospitalId(Integer hospitalId) { this.hospitalId = hospitalId; }

    public Integer getBloodGroupId() { return bloodGroupId; }
    public void setBloodGroupId(Integer bloodGroupId) { this.bloodGroupId = bloodGroupId; }

    public Integer getUnitsAtAlert() { return unitsAtAlert; }
    public void setUnitsAtAlert(Integer unitsAtAlert) { this.unitsAtAlert = unitsAtAlert; }

    public boolean isResolved() { return resolved; }
    public void setResolved(boolean resolved) { this.resolved = resolved; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getResolvedAt() { return resolvedAt; }
    public void setResolvedAt(LocalDateTime resolvedAt) { this.resolvedAt = resolvedAt; }

    public String getHospitalName() { return hospitalName; }
    public void setHospitalName(String hospitalName) { this.hospitalName = hospitalName; }

    public String getBloodGroupName() { return bloodGroupName; }
    public void setBloodGroupName(String bloodGroupName) { this.bloodGroupName = bloodGroupName; }
}
