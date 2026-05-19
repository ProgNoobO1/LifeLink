package backend.model;

import java.sql.Timestamp;

public class UsageHistory {
    private int id;
    private int hospitalId;
    private String bloodGroup;
    private int unitsUsed;
    private Integer requestId;
    private String reason;
    private Timestamp usedAt;
    // Joined:
    private String requesterName;

    public UsageHistory() {}

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getHospitalId() { return hospitalId; }
    public void setHospitalId(int hospitalId) { this.hospitalId = hospitalId; }

    public String getBloodGroup() { return bloodGroup; }
    public void setBloodGroup(String bloodGroup) { this.bloodGroup = bloodGroup; }

    public int getUnitsUsed() { return unitsUsed; }
    public void setUnitsUsed(int unitsUsed) { this.unitsUsed = unitsUsed; }

    public Integer getRequestId() { return requestId; }
    public void setRequestId(Integer requestId) { this.requestId = requestId; }

    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }

    public Timestamp getUsedAt() { return usedAt; }
    public void setUsedAt(Timestamp usedAt) { this.usedAt = usedAt; }

    public String getRequesterName() { return requesterName; }
    public void setRequesterName(String requesterName) { this.requesterName = requesterName; }
}
