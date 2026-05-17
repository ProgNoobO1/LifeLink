package com.lifelink.model;

import java.time.LocalDate;

public class Recipient {
    private Integer userId;
    private Integer bloodGroupId;
    private Integer districtId;
    private String address;
    private LocalDate dateOfBirth;
    private String gender;
    private String medicalNotes;

    // Join fields
    private String bloodGroupName;
    private String districtName;

    public Recipient() {}

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

    public String getMedicalNotes() { return medicalNotes; }
    public void setMedicalNotes(String medicalNotes) { this.medicalNotes = medicalNotes; }

    public String getBloodGroupName() { return bloodGroupName; }
    public void setBloodGroupName(String bloodGroupName) { this.bloodGroupName = bloodGroupName; }

    public String getDistrictName() { return districtName; }
    public void setDistrictName(String districtName) { this.districtName = districtName; }
}
