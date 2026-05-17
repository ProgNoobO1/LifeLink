package com.lifelink.model;

import java.math.BigDecimal;
import java.time.LocalDate;

public class Donor {
    private Integer userId;
    private Integer bloodGroupId;
    private Integer districtId;
    private String address;
    private LocalDate dateOfBirth;
    private String gender;
    private BigDecimal weightKg;
    private boolean available = true;
    private LocalDate lastDonatedAt;
    private Integer totalDonations = 0;

    // Join fields
    private String bloodGroupName;
    private String districtName;

    public Donor() {}

    public Integer getUserId() { return userId; }
    public void setUserId(Integer userId) { this.userId = userId; }

    public Integer getBloodGroupId() { return bloodGroupId; }
    public void setBloodGroupId(Integer bloodGroupId) { this.bloodGroupId = bloodGroupId; }

    public Integer getDistrictId() { return districtId; }
    public void setDistrictId(Integer districtId) { this.districtId = districtId; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public BigDecimal getWeightKg() { return weightKg; }
    public void setWeightKg(BigDecimal weightKg) { this.weightKg = weightKg; }

    public boolean isAvailable() { return available; }
    public void setAvailable(boolean available) { this.available = available; }

    public LocalDate getLastDonatedAt() { return lastDonatedAt; }
    public void setLastDonatedAt(LocalDate lastDonatedAt) { this.lastDonatedAt = lastDonatedAt; }

    public Integer getTotalDonations() { return totalDonations; }
    public void setTotalDonations(Integer totalDonations) { this.totalDonations = totalDonations; }

    public String getBloodGroupName() { return bloodGroupName; }
    public void setBloodGroupName(String bloodGroupName) { this.bloodGroupName = bloodGroupName; }

    public String getDistrictName() { return districtName; }
    public void setDistrictName(String districtName) { this.districtName = districtName; }
}
