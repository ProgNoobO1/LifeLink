package com.lifelink.model;

import java.time.LocalDate;

public class DonationHistory {
    private Integer id;
    private Integer donorId;
    private Integer hospitalId;
    private Integer requestId;
    private Integer bloodGroupId;
    private Integer unitsDonated;
    private LocalDate donatedAt;
    private boolean verified;

    // Join fields
    private String donorName;
    private String donorEmail;
    private String hospitalName;
    private String bloodGroupName;

    public DonationHistory() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getDonorId() { return donorId; }
    public void setDonorId(Integer donorId) { this.donorId = donorId; }

    public Integer getHospitalId() { return hospitalId; }
    public void setHospitalId(Integer hospitalId) { this.hospitalId = hospitalId; }

    public Integer getRequestId() { return requestId; }
    public void setRequestId(Integer requestId) { this.requestId = requestId; }

    public Integer getBloodGroupId() { return bloodGroupId; }
    public void setBloodGroupId(Integer bloodGroupId) { this.bloodGroupId = bloodGroupId; }

    public Integer getUnitsDonated() { return unitsDonated; }
    public void setUnitsDonated(Integer unitsDonated) { this.unitsDonated = unitsDonated; }

    public LocalDate getDonatedAt() { return donatedAt; }
    public void setDonatedAt(LocalDate donatedAt) { this.donatedAt = donatedAt; }

    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }

    public String getDonorName() { return donorName; }
    public void setDonorName(String donorName) { this.donorName = donorName; }

    public String getDonorEmail() { return donorEmail; }
    public void setDonorEmail(String donorEmail) { this.donorEmail = donorEmail; }

    public String getHospitalName() { return hospitalName; }
    public void setHospitalName(String hospitalName) { this.hospitalName = hospitalName; }

    public String getBloodGroupName() { return bloodGroupName; }
    public void setBloodGroupName(String bloodGroupName) { this.bloodGroupName = bloodGroupName; }
}
