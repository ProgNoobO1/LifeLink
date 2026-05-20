<%@ page language="java" contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String role     = (String)  session.getAttribute("role");
    String fullName = (String)  session.getAttribute("fullName");
    String uri      = request.getRequestURI();
    String ctx      = request.getContextPath();
    if (fullName == null) fullName = "User";
    String initials = fullName.length() >= 2
        ? String.valueOf(fullName.charAt(0)).toUpperCase()
        : "U";

    // Safely query live pending requests count and live name for currently logged in hospital
    int pendingCount = 0;
    try {
        Object uidObj = session.getAttribute("userId");
        Integer sessionUserId = null;
        if (uidObj instanceof Integer) {
            sessionUserId = (Integer) uidObj;
        } else if (uidObj instanceof String) {
            sessionUserId = Integer.parseInt((String) uidObj);
        }
        if ("hospital".equals(role) && sessionUserId != null) {
            lifelink.dao.BloodRequestDAO requestDAO = new lifelink.dao.BloodRequestDAO();
            pendingCount = requestDAO.getPendingCount(sessionUserId);
            
            // Fetch live hospital name directly from database to prevent session sync delay
            lifelink.dao.HospitalDAO sidebarDAO = new lifelink.dao.HospitalDAO();
            lifelink.model.Hospital sidebarHosp = sidebarDAO.getHospitalByUserId(sessionUserId);
            if (sidebarHosp != null && sidebarHosp.getHospitalName() != null && !sidebarHosp.getHospitalName().trim().isEmpty()) {
                fullName = sidebarHosp.getHospitalName();
            }
        }
    } catch (Exception e) {
        // Fallback safely if database connection or schema is loaded lazily
    }
%>
<nav class="sidebar" id="sidebar">
    <div class="sidebar-brand">
        <div class="logo-icon" style="border-radius:50% !important;">🩸</div>
        <div class="brand-text" style="font-size: 20px; font-weight: 700; color: #FFFFFF; margin-left: 2px;">LifeLink</div>
    </div>

    <div class="sidebar-nav">

        <%-- HOSPITAL NAV --%>
        <% if ("hospital".equals(role)) { %>
        <div class="nav-section-label">MAIN MENU</div>
        <a href="<%= ctx %>/hospital/dashboard" class="nav-link <%= uri.contains("/dashboard") ? "active" : "" %>">
            <span class="nav-icon">🎛️</span> Dashboard
        </a>
        <a href="<%= ctx %>/hospital/stock" class="nav-link <%= uri.contains("/stock") ? "active" : "" %>">
            <span class="nav-icon">🩸</span> Manage Stock
        </a>
        <a href="<%= ctx %>/hospital/requests" class="nav-link <%= uri.contains("/requests") ? "active" : "" %>">
            <span class="nav-icon">📋</span> Requests
            <% if (pendingCount > 0) { %>
                <span class="nav-badge"><%= pendingCount %></span>
            <% } %>
        </a>
        <a href="<%= ctx %>/hospital/history" class="nav-link <%= uri.contains("/history") ? "active" : "" %>">
            <span class="nav-icon">🔄</span> Usage History
        </a>
        <a href="<%= ctx %>/hospital/profile" class="nav-link <%= uri.contains("/profile") ? "active" : "" %>">
            <span class="nav-icon">👤</span> Profile Manager
        </a>

        <%-- ADMIN NAV --%>
        <% } else if ("admin".equals(role)) { %>
        <div class="nav-section-label">Admin</div>
        <a href="<%= ctx %>/admin/dashboard" class="nav-link <%= uri.contains("/dashboard") ? "active" : "" %>">
            <span class="nav-icon">📊</span> Dashboard
        </a>
        <a href="<%= ctx %>/admin/users" class="nav-link <%= uri.contains("/users") ? "active" : "" %>">
            <span class="nav-icon">👥</span> Manage Users
        </a>
        <a href="<%= ctx %>/admin/requests" class="nav-link <%= uri.contains("/admin/requests") ? "active" : "" %>">
            <span class="nav-icon">📋</span> All Requests
        </a>

        <%-- DONOR NAV --%>
        <% } else if ("donor".equals(role)) { %>
        <div class="nav-section-label">Donor</div>
        <a href="<%= ctx %>/donor/dashboard" class="nav-link <%= uri.contains("/dashboard") ? "active" : "" %>">
            <span class="nav-icon">🏠</span> Dashboard
        </a>
        <a href="<%= ctx %>/donor/profile" class="nav-link <%= uri.contains("/profile") ? "active" : "" %>">
            <span class="nav-icon">👤</span> My Profile
        </a>
        <a href="<%= ctx %>/donor/requests" class="nav-link <%= uri.contains("/donor/requests") ? "active" : "" %>">
            <span class="nav-icon">📋</span> Hospital Requests
        </a>
        <a href="<%= ctx %>/donor/history" class="nav-link <%= uri.contains("/donor/history") ? "active" : "" %>">
            <span class="nav-icon">📊</span> Donation History
        </a>

        <%-- RECIPIENT NAV --%>
        <% } else if ("recipient".equals(role)) { %>
        <div class="nav-section-label">Recipient</div>
        <a href="<%= ctx %>/recipient/dashboard" class="nav-link <%= uri.contains("/dashboard") ? "active" : "" %>">
            <span class="nav-icon">🏠</span> Dashboard
        </a>
        <a href="<%= ctx %>/recipient/request/new" class="nav-link <%= uri.contains("/request/new") ? "active" : "" %>">
            <span class="nav-icon">🆘</span> Request Blood
        </a>
        <a href="<%= ctx %>/recipient/requests" class="nav-link <%= uri.contains("/recipient/requests") ? "active" : "" %>">
            <span class="nav-icon">📋</span> My Requests
        </a>
        <% } %>

        <%-- COMMON --%>
        <div class="nav-section-label" style="margin-top:12px">General</div>
        <% if ("hospital".equals(role)) { %>
        <a href="<%= ctx %>/hospital/request/new" class="nav-link <%= uri.contains("/request/new") ? "active" : "" %>">
            <span class="nav-icon">🔍</span> Search Blood
        </a>
        <% } else { %>
        <a href="<%= ctx %>/search" class="nav-link <%= uri.contains("/search") ? "active" : "" %>">
            <span class="nav-icon">🔍</span> Search Blood
        </a>
        <% } %>

    </div>

    <div class="sidebar-footer">
        <a href="<%= ctx %>/logout" class="nav-link logout-link">
            <span class="nav-icon">🚪</span> Logout
        </a>
        <a href="<%= ctx %>/<%= "hospital".equals(role) ? "hospital/profile" : "donor".equals(role) ? "donor/profile" : "#" %>" class="sidebar-user-card" style="text-decoration: none; color: inherit; display: flex;">
            <div class="sidebar-user-avatar">
                <% if ("hospital".equals(role)) { %>🏥
                <% } else if ("admin".equals(role)) { %>👑
                <% } else if ("donor".equals(role)) { %>🩸
                <% } else { %>👤<% } %>
            </div>
            <div class="sidebar-user-info">
                <div class="sidebar-user-name"><%= fullName %></div>
                <div class="sidebar-user-role">
                    <%= role != null ? role.substring(0, 1).toUpperCase() + role.substring(1) : "User" %>
                </div>
            </div>
            <div class="sidebar-user-dots">⋮</div>
        </a>
    </div>
</nav>
