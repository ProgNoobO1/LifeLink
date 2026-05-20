<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<style>
.logout-btn {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    padding: 0.65rem 1rem;
    border-radius: 12px;
    cursor: pointer;
    font-size: 0.87rem;
    font-weight: 500;
    color: #D1D5DB;
    text-decoration: none;
    transition: all 0.2s ease;
    margin-bottom: 0.75rem;
}
.logout-btn svg {
    width: 18px;
    height: 18px;
    fill: currentColor;
}
.logout-btn:hover {
    background-color: var(--sidebar-hover);
    color: var(--white);
}
</style>
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
            <a href="${pageContext.request.contextPath}/donor/requests" class="menu-link ${requestScope['jakarta.servlet.forward.path_info'] == '/requests' ? 'active' : ''}">
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
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
            <svg viewBox="0 0 24 24"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5-5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg>
            Logout
        </a>
        <div class="user-mini-profile">
            <div class="stat-icon icon-red" style="width: 32px; height: 32px; font-size: 0.8rem;"><i class="fas fa-user"></i></div>
            <div class="user-info-text">
                <span class="name">${donor.name}</span>
                <span class="role">Blood Type: ${donor.bloodGroup}</span>
            </div>
        </div>
    </div>
</div>
