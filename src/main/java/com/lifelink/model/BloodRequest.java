package com.lifelink.model;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class BloodRequest {

    private Long id;
    private String requesterName;
    private String requesterEmail;
    private String bloodGroup;
    private int units;
    private LocalDate requestDate;
    private Status status = Status.PENDING;
    private String urgency;
    private String notes;
    private LocalDateTime updatedAt;
    private LocalDateTime completedAt;

    public enum Status {
        PENDING, APPROVED, REJECTED
    }

    public BloodRequest() {}

    public BloodRequest(String requesterName, String requesterEmail, String bloodGroup,
                        int units, LocalDate requestDate, Status status) {
        this.requesterName = requesterName;
        this.requesterEmail = requesterEmail;
        this.bloodGroup = bloodGroup;
        this.units = units;
        this.requestDate = requestDate;
        this.status = status;
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getRequesterName() { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }

    public String getRequesterEmail() { return requesterEmail; }
    public void setRequesterEmail(String requesterEmail) { this.requesterEmail = requesterEmail; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public int getUnits() { return units; }
    public void setUnits(int units) { this.units = units; }

    public LocalDate getRequestDate() { return requestDate; }
    public void setRequestDate(LocalDate requestDate) { this.requestDate = requestDate; }

    public Status getStatus() { return status; }
    public void setStatus(Status status) { this.status = status; }

    public String getUrgency() { return urgency; }
    public void setUrgency(String urgency) { this.urgency = urgency; }

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
        java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy");
        return requestDate.format(formatter);
    }
}
