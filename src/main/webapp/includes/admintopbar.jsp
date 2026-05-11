<%--
  Created by IntelliJ IDEA.
  User: ektarai
  Date: 02/05/2026
  Time: 23:58
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="com.lifelink.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User currentAdmin = (User) session.getAttribute("currentUser");
    String adminName = (currentAdmin != null) ? currentAdmin.getFullName() : "Admin User";
    String adminEmail = (currentAdmin != null) ? currentAdmin.getEmail() : "admin@lifelink.com";
%>
<style>


  /* TOP BAR */
  .topbar {
    background: var(--white);
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    padding: .9rem 2rem;
    gap: 1rem;
    position: sticky;
    top: 0;
    z-index: 50;
  }

  .topbar-title { flex: 1; }
  .topbar-title h1 { font-size: 1.2rem; font-weight: 700; color: var(--text-dark); }
  .topbar-title p  { font-size: .8rem; color: var(--text-mid); margin-top: .1rem; }

  .topbar-search {
    position: relative;
    display: flex;
    align-items: center;
  }

  .topbar-search svg {
    position: absolute;
    left: .8rem;
    width: 16px; height: 16px;
    fill: none;
    stroke: var(--text-light);
    stroke-width: 2;
  }

  .topbar-search input {
    padding: .5rem 1rem .5rem 2.3rem;
    border: 1.5px solid var(--border);
    border-radius: 10px;
    font-family: 'DM Sans', sans-serif;
    font-size: .85rem;
    background: #fafafa;
    color: var(--text-dark);
    outline: none;
    width: 200px;
    transition: border-color .2s, box-shadow .2s;
  }

  .topbar-search input:focus {
    border-color: var(--red);
    box-shadow: 0 0 0 3px var(--red-light);
  }

  .topbar-actions { display: flex; align-items: center; gap: .75rem; }

  .notif-btn {
    position: relative;
    width: 38px; height: 38px;
    background: #fafafa;
    border: 1.5px solid var(--border);
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer;
    transition: background .2s;
  }

  .notif-btn:hover { background: var(--red-light); }
  .notif-btn svg { width: 18px; height: 18px; fill: none; stroke: var(--text-mid); stroke-width: 2; }

  .notif-dot {
    position: absolute;
    top: -4px; right: -4px;
    background: var(--red);
    color: white;
    font-size: .6rem;
    font-weight: 700;
    width: 17px; height: 17px;
    border-radius: 999px;
    display: flex; align-items: center; justify-content: center;
    border: 2px solid white;
  }

  .topbar-user {
    display: flex;
    align-items: center;
    gap: .65rem;
    cursor: pointer;
  }

  .user-avatar {
    width: 38px; height: 38px;
    background: var(--red-light);
    border: 2px solid var(--border);
    border-radius: 10px;
  }

  .topbar-user .uname { font-size: .85rem; font-weight: 600; color: var(--text-dark); }
  .topbar-user .uemail { font-size: .75rem; color: var(--text-mid); }

  .topbar-user svg { width: 16px; height: 16px; fill: none; stroke: var(--text-mid); stroke-width: 2; }
</style>
<!-- TOP BAR -->
<header class="topbar">
  <%
      String topUri = request.getRequestURI();
      String topForwardUri = (String) request.getAttribute("jakarta.servlet.forward.request_uri");
      if (topForwardUri != null) topUri = topForwardUri;
      String pageTitle = "Admin Dashboard";
      String pageSubtitle = "Welcome back! Here's what's happening today.";
      if (topUri != null && topUri.contains("/admin/users")) {
          pageTitle = "Manage Users";
          pageSubtitle = "View, add, edit, and manage system users.";
      } else if (topUri != null && topUri.contains("/admin/requests")) {
          pageTitle = "Manage Requests";
          pageSubtitle = "Review and process blood requests.";
      }
  %>
  <div class="topbar-title">
    <h1><%= pageTitle %></h1>
    <p><%= pageSubtitle %></p>
  </div>

  <div class="topbar-search">
    <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
    <input type="text" placeholder="Search..."/>
  </div>

  <div class="topbar-actions">
    <div class="notif-btn">
      <svg viewBox="0 0 24 24"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
      <span class="notif-dot">3</span>
    </div>

    <a href="<%= request.getContextPath() %>/logout" style="text-decoration:none;">
      <div class="topbar-user">
        <div class="user-avatar"></div>
        <div>
          <div class="uname"><%= adminName %></div>
          <div class="uemail"><%= adminEmail %></div>
        </div>
        <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
      </div>
    </a>
  </div>
</header>
