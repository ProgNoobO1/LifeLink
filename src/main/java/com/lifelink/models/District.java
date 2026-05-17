package com.lifelink.models;

public class District {
    private int id;
    private String name;
    private String province;

    public District() {}

    public District(int id, String name, String province) {
        this.id = id;
        this.name = name;
        this.province = province;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }
}
