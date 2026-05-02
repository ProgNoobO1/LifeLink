<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="sidebar">
    <div class="sidebar-logo">
        <i class="fas fa-heartbeat"></i> LifeLink
    </div>
    
    <div class="menu-label">Donor Menu</div>
    <ul class="sidebar-menu">
        <li class="menu-item">
            <a href="${pageContext.request.contextPath}/donor/dashboard" class="menu-link ${requestScope['jakarta.servlet.forward.path_info'] == '/dashboard' ? 'active' : ''}">
                <i class="fas fa-th-large"></i> Dashboard
            </a>
        </li>
        <li class="menu-item">
            <a href="${pageContext.request.contextPath}/donor/profile" class="menu-link ${requestScope['jakarta.servlet.forward.path_info'] == '/profile' ? 'active' : ''}">
                <i class="fas fa-user"></i> Profile
            </a>
        </li>
        <li class="menu-item">
            <a href="${pageContext.request.contextPath}/donor/dashboard" class="menu-link">
                <i class="fas fa-hand-holding-medical"></i> Incoming Requests
                <span class="menu-badge">${requests != null ? requests.size() : 0}</span>
            </a>
        </li>
        <li class="menu-item">
            <a href="${pageContext.request.contextPath}/donor/history" class="menu-link ${requestScope['jakarta.servlet.forward.path_info'] == '/history' ? 'active' : ''}">
                <i class="fas fa-history"></i> Donation History
            </a>
        </li>
    </ul>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/logout" class="menu-link" style="margin-bottom: 1rem;">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
        <div class="user-mini-profile">
            <img src="https://i.pravatar.cc/150?u=${donor.email}" class="user-avatar" alt="Avatar">
            <div class="user-info-text">
                <span class="name">${donor.name}</span>
                <span class="role">Blood Type: ${donor.bloodGroup}</span>
            </div>
        </div>
    </div>
</div>
