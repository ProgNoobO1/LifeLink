package lifelink.model;

import java.util.Date;

public class DonorSearchDTO {
    private int userId;
    private String fullName;
    private String email;
    private String phone;
    private String bloodGroup;
    private String district;
    private String address;
    private Date lastDonatedAt;
    private int totalDonations;

    // Getters and Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }
    public String getDistrict() { return district; }
    public void setDistrict(String district) { this.district = district; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public Date getLastDonatedAt() { return lastDonatedAt; }
    public void setLastDonatedAt(Date lastDonatedAt) { this.lastDonatedAt = lastDonatedAt; }
    public int getTotalDonations() { return totalDonations; }
    public void setTotalDonations(int totalDonations) { this.totalDonations = totalDonations; }
}
