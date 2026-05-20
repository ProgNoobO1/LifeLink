package com.lifelink.models;

public class Notification {
    private String type; // 'Request' or 'Renewal'
    private String message;
    private String icon;
    private String time;

    public Notification(String type, String message, String icon, String time) {
        this.type = type;
        this.message = message;
        this.icon = icon;
        this.time = time;
    }

    public String getType() { return type; }
    public String getMessage() { return message; }
    public String getIcon() { return icon; }
    public String getTime() { return time; }
}
