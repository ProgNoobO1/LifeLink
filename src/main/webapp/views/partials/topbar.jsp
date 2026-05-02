<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<div class="top-bar">
    <div class="page-info">
        <h2>${pageTitle}</h2>
        <p>${pageSubtitle}</p>
    </div>
    
    <div class="top-bar-right">
        <div class="notification-bell">
            <i class="far fa-bell"></i>
            <span class="bell-badge">2</span>
        </div>
        <div style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
            <img src="https://i.pravatar.cc/150?u=${donor.email}" class="user-avatar" style="width: 32px; height: 32px;">
            <span style="font-size: 0.9rem; font-weight: 500;">${donor.name}</span>
            <i class="fas fa-chevron-down" style="font-size: 0.7rem; color: var(--text-muted);"></i>
        </div>
    </div>
</div>
