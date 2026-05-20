package com.lifelink.model;

import java.time.LocalDateTime;

public class Notification {
    private Long id;
    private String type;
    private String title;
    private String message;
    private String link;
    private boolean read;
    private LocalDateTime createdAt;
    
    // HEAD specific fields
    private String icon;
    private String time;

    public Notification() {}

    public static Notification createDonorNotification(String type, String message, String icon, String time) {
        Notification n = new Notification();
        n.type = type;
        n.message = message;
        n.icon = icon;
        n.time = time;
        n.createdAt = LocalDateTime.now();
        return n;
    }

    public Notification(String type, String title, String message, String link) {
        this.type = type;
        this.title = title;
        this.message = message;
        this.link = link;
        this.read = false;
        this.createdAt = LocalDateTime.now();
    }

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }

    public String getLink() { return link; }
    public void setLink(String link) { this.link = link; }

    public boolean isRead() { return read; }
    public void setRead(boolean read) { this.read = read; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public String getIcon() { return icon; }
    public void setIcon(String icon) { this.icon = icon; }

    public String getTime() { return time; }
    public void setTime(String time) { this.time = time; }
}
