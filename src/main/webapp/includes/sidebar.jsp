<%--
  Created by IntelliJ IDEA.
  User: ektarai
  Date: 02/05/2026
  Time: 18:21
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
        .nav-item.active::after {
            content: '';
            margin-left: auto;
            width: 4px;
            height: 26px;
            background: rgba(255,255,255,.5);
            border-radius: 999px;
            flex-shrink: 0;
        }
    </style>
    <style>
        :root {
            --red:         #b91c1c;
            --red-dark:    #991b1b;
            --red-light:   #fee2e2;
            --sidebar-bg:  #1a0a0a;
            --sidebar-w:   210px;
            --text-dark:   #111827;
            --text-mid:    #4b5563;
            --text-light:  #9ca3af;
            --border:      #e5e7eb;
            --bg:          #f3f4f6;
            --white:       #ffffff;
            --shadow:      0 2px 12px rgba(0,0,0,.07);
            --shadow-md:   0 4px 24px rgba(0,0,0,.10);
        }

        .sidebar {
            width: var(--sidebar-w);
            background: var(--sidebar-bg);
            display: flex;
            flex-direction: column;
            position: fixed;
            top: 0; left: 0; bottom: 0;
            z-index: 100;
        }

        .sidebar-logo {
            display: flex;
            align-items: center;
            gap: .75rem;
            padding: 1.4rem 1.25rem;
            border-bottom: 1px solid rgba(255,255,255,.07);
        }

        .logo-icon {
            width: 38px; height: 38px;
            background: var(--red);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
        }

        .logo-icon svg { width: 20px; height: 20px; fill: white; }

        .logo-name {
            font-family: 'Playfair Display', serif;
            font-size: 1.2rem;
            color: white;
            letter-spacing: -.01em;
        }

        .sidebar-section {
            padding: 1.4rem 1rem .5rem;
        }

        .sidebar-section-label {
            font-size: .65rem;
            font-weight: 700;
            letter-spacing: .1em;
            text-transform: uppercase;
            color: rgba(255,255,255,.3);
            padding: 0 .4rem;
            margin-bottom: .6rem;
        }

        .nav-item {
            display: flex;
            align-items: center;
            gap: .75rem;
            padding: .68rem .85rem;
            border-radius: 10px;
            cursor: pointer;
            font-size: .88rem;
            font-weight: 500;
            color: rgba(255,255,255,.55);
            text-decoration: none;
            transition: background .2s, color .2s;
            position: relative;
            margin-bottom: .15rem;
        }

        .nav-item svg { width: 18px; height: 18px; fill: currentColor; flex-shrink: 0; }

        .nav-item:hover {
            background: rgba(255,255,255,.07);
            color: rgba(255,255,255,.85);
        }

        .nav-item.active {
            background: var(--red);
            color: white;
        }

        .nav-item .badge {
            margin-left: auto;
            background: rgba(255,255,255,.25);
            color: white;
            font-size: .68rem;
            font-weight: 700;
            padding: .15rem .45rem;
            border-radius: 999px;
            line-height: 1.4;
        }

        .nav-item.active .badge { background: rgba(255,255,255,.3); }

        .sidebar-spacer { flex: 1; }

        .sidebar-bottom {
            border-top: 1px solid rgba(255,255,255,.07);
            padding: 1rem;
        }

        .logout-btn {
            display: flex;
            align-items: center;
            gap: .75rem;
            padding: .65rem .85rem;
            border-radius: 10px;
            cursor: pointer;
            font-size: .87rem;
            font-weight: 500;
            color: rgba(255,255,255,.5);
            text-decoration: none;
            transition: background .2s, color .2s;
            margin-bottom: .9rem;
        }

        .logout-btn svg { width: 18px; height: 18px; fill: currentColor; }
        .logout-btn:hover { background: rgba(255,255,255,.07); color: rgba(255,255,255,.8); }

        .sidebar-user {
            display: flex;
            align-items: center;
            gap: .7rem;
            padding: .7rem .85rem;
            background: rgba(255,255,255,.06);
            border-radius: 10px;
        }

        .user-avatar-sm {
            width: 34px; height: 34px;
            background: var(--red);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: .75rem;
            font-weight: 700;
            color: white;
            flex-shrink: 0;
        }

        .user-info-sm { flex: 1; min-width: 0; }

        .user-info-sm .uname {
            font-size: .82rem;
            font-weight: 600;
            color: white;
            white-space: nowrap;
            overflow: hidden;
            text-overflow: ellipsis;
        }

        .user-info-sm .urole {
            font-size: .72rem;
            color: var(--red);
            font-weight: 600;
        }

        .user-more {
            background: none;
            border: none;
            cursor: pointer;
            color: rgba(255,255,255,.4);
            display: flex;
        }

        .user-more svg { width: 16px; height: 16px; fill: currentColor; }

</style>
<!-- ═════════════════ SIDEBAR ═════════════════ -->
<aside class="sidebar">

    <div class="sidebar-logo">
        <div class="logo-icon">
            <svg viewBox="0 0 24 24"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
        </div>
        <span class="logo-name">LifeLink</span>
    </div>

    <%
        String currentUri = request.getRequestURI();
        String forwardUri = (String) request.getAttribute("jakarta.servlet.forward.request_uri");
        if (forwardUri != null) {
            currentUri = forwardUri;
        }
    %>

    <div class="sidebar-section">
        <div class="sidebar-section-label">Main Menu</div>

        <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item <%= (currentUri != null && currentUri.contains("/admin/dashboard")) ? "active" : "" %>">
            <svg viewBox="0 0 24 24"><path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/></svg>
            Dashboard
        </a>

        <a href="${pageContext.request.contextPath}/admin/users" class="nav-item <%= currentUri.contains("/admin/users") ? "active" : "" %>">
            <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
            Manage Users
        </a>

        <a href="${pageContext.request.contextPath}/admin/requests" class="nav-item <%= (currentUri != null && currentUri.contains("/admin/requests")) ? "active" : "" %>">
            <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
            Requests
            <span class="badge">45</span>
        </a>

        <a href="#" class="nav-item">
            <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 14l-5-5 1.41-1.41L12 14.17l7.59-7.59L21 8l-9 9z"/></svg>
            Reports
        </a>

    </div>

    <div class="sidebar-spacer"></div>

    <div class="sidebar-bottom">

        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
            <svg viewBox="0 0 24 24"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5-5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg>
            Logout
        </a>

        <div class="sidebar-user">
            <div class="user-avatar-sm">AU</div>
            <div class="user-info-sm">
                <div class="uname">Admin User</div>
                <div class="urole">Super Admin</div>
            </div>
        </div>

    </div>

</aside>
