package com.lifelink.models;

public class Donor {
    private int id;
    private String name;
    private String email;
    private String phone;
    private String bloodGroup;
    private String location;
    private boolean isAvailable;
    private java.sql.Timestamp lastDonationDate;

    // Expanded normalized properties
    private Integer districtId;
    private String districtName;
    private String address;
    private String gender;
    private double weightKg;

    public Donor() {}

    public Donor(int id, String name, String email, String phone, String bloodGroup, String location, boolean isAvailable, java.sql.Timestamp lastDonationDate) {
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

    public java.sql.Timestamp getLastDonationDate() { return lastDonationDate; }
    public void setLastDonationDate(java.sql.Timestamp lastDonationDate) { this.lastDonationDate = lastDonationDate; }

    // Expanded Getters & Setters
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
}
