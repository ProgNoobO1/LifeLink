package com.lifelink.model;

import java.time.LocalDate;
import java.sql.Timestamp;

public class Donor {
    private int id;
    private String name;
    private String email;
    private String phone;
    private String bloodGroup;
    private String location;
    private boolean isAvailable;
    private Timestamp lastDonationDate;

    // Expanded normalized properties
    private Integer districtId;
    private String districtName;
    private String address;
    private String gender;
    private double weightKg;
    
    // Recipient fields
    private Integer bloodGroupId;
    private LocalDate dateOfBirth;
    private Integer totalDonations = 0;

    public Donor() {}

    public Donor(int id, String name, String email, String phone, String bloodGroup, String location, boolean isAvailable, Timestamp lastDonationDate) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.phone = phone;
        this.bloodGroup = bloodGroup;
        this.location = location;
        this.isAvailable = isAvailable;
        this.lastDonationDate = lastDonationDate;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public boolean isAvailable() { return isAvailable; }
    public void setAvailable(boolean isAvailable) { this.isAvailable = isAvailable; }

    public Timestamp getLastDonationDate() { return lastDonationDate; }
    public void setLastDonationDate(Timestamp lastDonationDate) { this.lastDonationDate = lastDonationDate; }

    public Integer getDistrictId() { return districtId; }
    public void setDistrictId(Integer districtId) { this.districtId = districtId; }

    public String getDistrictName() { return districtName; }
    public void setDistrictName(String districtName) { this.districtName = districtName; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }

    public double getWeightKg() { return weightKg; }
    public void setWeightKg(double weightKg) { this.weightKg = weightKg; }

    // Recipient branch compatibility helpers
    public Integer getUserId() { return id; }
    public void setUserId(Integer userId) { this.id = userId != null ? userId : 0; }

    public Integer getBloodGroupId() { return bloodGroupId; }
    public void setBloodGroupId(Integer bloodGroupId) { this.bloodGroupId = bloodGroupId; }

    public LocalDate getDateOfBirth() { return dateOfBirth; }
    public void setDateOfBirth(LocalDate dateOfBirth) { this.dateOfBirth = dateOfBirth; }

    public Integer getTotalDonations() { return totalDonations; }
    public void setTotalDonations(Integer totalDonations) { this.totalDonations = totalDonations; }

    public String getBloodGroupName() { return bloodGroup; }
    public void setBloodGroupName(String name) { this.bloodGroup = name; }

    public LocalDate getLastDonatedAt() {
        return lastDonationDate != null ? lastDonationDate.toLocalDateTime().toLocalDate() : null;
    }
    public void setLastDonatedAt(LocalDate lastDonatedAt) {
        this.lastDonationDate = lastDonatedAt != null ? Timestamp.valueOf(lastDonatedAt.atStartOfDay()) : null;
    }
}
