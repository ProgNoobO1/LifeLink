package com.lifelink.model;

import java.time.LocalDateTime;

public class RequestResponse {
    private Integer id;
    private Integer requestId;
    private Integer responderId;
    private String responderType;
    private String response;
    private Integer unitsProvided;
    private LocalDateTime respondedAt;
    private String notes;

    public RequestResponse() {}

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public Integer getRequestId() { return requestId; }
    public void setRequestId(Integer requestId) { this.requestId = requestId; }

    public Integer getResponderId() { return responderId; }
    public void setResponderId(Integer responderId) { this.responderId = responderId; }

    public String getResponderType() { return responderType; }
    public void setResponderType(String responderType) { this.responderType = responderType; }

    public String getResponse() { return response; }
    public void setResponse(String response) { this.response = response; }

    public Integer getUnitsProvided() { return unitsProvided; }
    public void setUnitsProvided(Integer unitsProvided) { this.unitsProvided = unitsProvided; }

    public LocalDateTime getRespondedAt() { return respondedAt; }
    public void setRespondedAt(LocalDateTime respondedAt) { this.respondedAt = respondedAt; }

    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
}
