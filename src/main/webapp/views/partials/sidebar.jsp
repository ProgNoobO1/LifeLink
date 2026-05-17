<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<div class="sidebar">
    <div class="sidebar-logo">
        <i class="fas fa-heartbeat"></i> LifeLink
    </div>
    
    <c:choose>
        <c:when test="${sessionScope.user.role == 'Recipient'}">
            <div class="menu-label">Recipient Menu</div>
            <ul class="sidebar-menu">
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/recipient/dashboard" class="menu-link ${pageContext.request.requestURI.contains('/recipient/dashboard') ? 'active' : ''}">
                        <i class="fas fa-th-large"></i> Dashboard
                    </a>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/recipient/search" class="menu-link ${pageContext.request.requestURI.contains('/recipient/search') ? 'active' : ''}">
                        <i class="fas fa-search"></i> Search Donors
                    </a>
                </li>
            </ul>
        </c:when>
        <c:otherwise>
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
        </c:otherwise>
    </c:choose>

    <div class="sidebar-footer">
        <a href="${pageContext.request.contextPath}/logout" class="menu-link" style="margin-bottom: 1rem;">
            <i class="fas fa-sign-out-alt"></i> Logout
        </a>
        <div class="user-mini-profile">
            <div class="stat-icon icon-red" style="width: 32px; height: 32px; font-size: 0.8rem;"><i class="fas fa-user"></i></div>
            <div class="user-info-text">
                <c:choose>
                    <c:when test="${sessionScope.user.role == 'Recipient'}">
                        <span class="name">Jane Recipient</span>
                        <span class="role">Recipient Account</span>
                    </c:when>
                    <c:otherwise>
                        <span class="name">${donor.name}</span>
                        <span class="role">Blood Type: ${donor.bloodGroup}</span>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>
