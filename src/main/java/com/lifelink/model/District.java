package com.lifelink.model;

import java.math.BigDecimal;

public class District {
    private Integer id;
    private String name;
    private String province;
    private BigDecimal latitude;
    private BigDecimal longitude;

    public District() {}

    public District(int id, String name, String province) {
        this.id = id;
        this.name = name;
        this.province = province;
    }

    public District(String name, String province, BigDecimal latitude, BigDecimal longitude) {
        this.name = name;
        this.province = province;
        this.latitude = latitude;
        this.longitude = longitude;
    }

    public Integer getId() { return id; }
    public void setId(Integer id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getProvince() { return province; }
    public void setProvince(String province) { this.province = province; }

    public BigDecimal getLatitude() { return latitude; }
    public void setLatitude(BigDecimal latitude) { this.latitude = latitude; }

    public BigDecimal getLongitude() { return longitude; }
    public void setLongitude(BigDecimal longitude) { this.longitude = longitude; }
}
