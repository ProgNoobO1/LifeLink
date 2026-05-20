package com.lifelink.model;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

public class BloodRequest {
    private Long id;
    private int hospitalId;
    private int donorId;
    private String bloodGroup;
    private String location;
    private String status;
    private Timestamp requestDate;
    
    // For UI display
    private String hospitalName; 
    
    // Recipient / Donor fields
    private int requesterId;
    private String patientName;
    private int unitsNeeded;
    private String urgency;
    private String requesterRole;
    private int patientAge;
    
    private String requesterName;
    private String requesterEmail;
    private int units;
    private String notes;
    private LocalDateTime updatedAt;
    private LocalDateTime completedAt;

    public enum Status {
        PENDING, APPROVED, REJECTED
    }

    public BloodRequest() {}

    public BloodRequest(String requesterName, String requesterEmail, String bloodGroup,
                        int units, LocalDate requestLocalDate, Status status) {
        this.requesterName = requesterName;
        this.requesterEmail = requesterEmail;
        this.bloodGroup = bloodGroup;
        this.units = units;
        this.unitsNeeded = units;
        this.requestDate = requestLocalDate != null ? Timestamp.valueOf(requestLocalDate.atStartOfDay()) : null;
        this.status = status == Status.APPROVED ? "completed" : (status == Status.REJECTED ? "rejected" : "pending");
    }

    public int getId() { return id != null ? id.intValue() : 0; }
    public void setId(int id) { this.id = (long) id; }
    public Long getLongId() { return id; }
    public void setId(Long id) { this.id = id; }

    public int getHospitalId() { return hospitalId; }
    public void setHospitalId(int hospitalId) { this.hospitalId = hospitalId; }

    public int getDonorId() { return donorId; }
    public void setDonorId(int donorId) { this.donorId = donorId; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public void setStatus(Status enumStatus) {
        if (enumStatus == Status.PENDING) this.status = "pending";
        else if (enumStatus == Status.APPROVED) this.status = "completed";
        else if (enumStatus == Status.REJECTED) this.status = "rejected";
    }

    public Timestamp getRequestDate() { return requestDate; }
    public void setRequestDate(Timestamp requestDate) { this.requestDate = requestDate; }
    public void setRequestDate(LocalDate localDate) {
        this.requestDate = localDate != null ? Timestamp.valueOf(localDate.atStartOfDay()) : null;
    }

    public String getHospitalName() { return hospitalName; }
    public void setHospitalName(String hospitalName) { this.hospitalName = hospitalName; }

    public int getRequesterId() { return requesterId; }
    public void setRequesterId(int requesterId) { this.requesterId = requesterId; }

    public String getPatientName() { return patientName; }
    public void setPatientName(String patientName) { this.patientName = patientName; }

    public int getUnitsNeeded() { return unitsNeeded; }
    public void setUnitsNeeded(int unitsNeeded) {
        this.unitsNeeded = unitsNeeded;
        this.units = unitsNeeded;
    }

    public String getUrgency() { return urgency; }
    public void setUrgency(String urgency) { this.urgency = urgency; }

    public String getRequesterRole() { return requesterRole; }
    public void setRequesterRole(String requesterRole) { this.requesterRole = requesterRole; }

    public int getPatientAge() { return patientAge; }
    public void setPatientAge(int patientAge) { this.patientAge = patientAge; }

    public String getRequesterName() { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }

    public String getRequesterEmail() { return requesterEmail; }
    public void setRequesterEmail(String requesterEmail) { this.requesterEmail = requesterEmail; }

    public int getUnits() { return units; }
    public void setUnits(int units) {
        this.units = units;
        this.unitsNeeded = units;
    }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public LocalDateTime getCompletedAt() { return completedAt; }
    public void setCompletedAt(LocalDateTime completedAt) { this.completedAt = completedAt; }

    public String getFormattedRequestId() {
        return String.format("#REQ-%03d", id);
    }

    public String getInitials() {
        if (requesterName == null || requesterName.isEmpty()) return "??";
        String[] parts = requesterName.trim().split("\\s+");
        if (parts.length == 1) {
            return parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();
        }
        return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
    }

    public String getFormattedDate() {
        if (requestDate == null) return "";
        LocalDate ld = requestDate.toLocalDateTime().toLocalDate();
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy");
        return ld.format(formatter);
    }
}
