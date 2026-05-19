package backend.model;

import java.sql.Timestamp;

public class BloodRequest {
    private int id;
    private int requesterId;
    private int hospitalId;
    private String bloodGroup;
    private int unitsNeeded;
    private String status;      // pending, accepted, rejected, completed, cancelled
    private String message;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    // Joined fields from users table:
    private String requesterName;
    private String requesterPhone;
    private String requesterEmail;
    private String requesterLocation;
    private String hospitalName;  // Joined from hospitals table

    public BloodRequest() {}

    // Helper for status badge class
    public String getStatusBadgeClass() {
        switch (status != null ? status : "") {
            case "pending":   return "bg-warning text-dark";
            case "accepted":  return "bg-success";
            case "rejected":  return "bg-danger";
            case "completed": return "bg-primary";
            case "cancelled": return "bg-secondary";
            default:          return "bg-secondary";
        }
    }

    // Helper for status display text
    public String getStatusDisplay() {
        if (status == null) return "Unknown";
        return status.substring(0, 1).toUpperCase() + status.substring(1);
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getRequesterId() { return requesterId; }
    public void setRequesterId(int requesterId) { this.requesterId = requesterId; }

    public int getHospitalId() { return hospitalId; }
    public void setHospitalId(int hospitalId) { this.hospitalId = hospitalId; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public int getUnitsNeeded() { return unitsNeeded; }
    public void setUnitsNeeded(int unitsNeeded) { this.unitsNeeded = unitsNeeded; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    public String getRequesterName() { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }

    public String getRequesterPhone() { return requesterPhone; }
    public void setRequesterPhone(String requesterPhone) { this.requesterPhone = requesterPhone; }

    public String getRequesterEmail() { return requesterEmail; }
    public void setRequesterEmail(String requesterEmail) { this.requesterEmail = requesterEmail; }

    public String getRequesterLocation() { return requesterLocation; }
    public void setRequesterLocation(String requesterLocation) { this.requesterLocation = requesterLocation; }

    public String getHospitalName() { return hospitalName; }
    public void setHospitalName(String hospitalName) { this.hospitalName = hospitalName; }
}
