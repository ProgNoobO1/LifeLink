<%--
  Manage Users – LifeLink Admin
  Created: 02/05/2026
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Manage Users – LifeLink</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>

  <style>
    :root {
      --red:        #b91c1c;
      --red-dark:   #991b1b;
      --red-light:  #fee2e2;
      --sidebar-bg: #1a0a0a;
      --sidebar-w:  210px;
      --text-dark:  #111827;
      --text-mid:   #4b5563;
      --text-light: #9ca3af;
      --border:     #e5e7eb;
      --bg:         #f3f4f6;
      --white:      #ffffff;
      --shadow:     0 2px 12px rgba(0,0,0,.07);
    }

    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: 'DM Sans', sans-serif;
      background: var(--bg);
      color: var(--text-dark);
      min-height: 100vh;
      display: flex;
    }

    .main {
      margin-left: var(--sidebar-w);
      flex: 1;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }

    .content { padding: 1.75rem 2rem; display: flex; flex-direction: column; gap: 1.5rem; }

    .stat-strip {
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 1rem;
    }

    .stat-strip-card {
      background: var(--white);
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 1.2rem 1.4rem;
      display: flex;
      align-items: center;
      gap: 1rem;
      box-shadow: var(--shadow);
      transition: box-shadow .2s, transform .2s;
    }

    .stat-strip-card:hover {
      box-shadow: 0 6px 24px rgba(0,0,0,.1);
      transform: translateY(-2px);
    }

    .strip-icon {
      width: 48px; height: 48px;
      border-radius: 12px;
      display: flex; align-items: center; justify-content: center;
      flex-shrink: 0;
    }

    .strip-icon svg { width: 24px; height: 24px; }
    .strip-icon.red    { background: var(--red-light); }
    .strip-icon.red svg { fill: var(--red); }
    .strip-icon.pinkish { background: #fce7f3; }
    .strip-icon.pinkish svg { fill: #db2777; }
    .strip-icon.blue   { background: #dbeafe; }
    .strip-icon.blue svg { fill: #2563eb; }
    .strip-icon.purple { background: #ede9fe; }
    .strip-icon.purple svg { fill: #7c3aed; }

    .strip-info .snum  { font-size: 1.6rem; font-weight: 700; color: var(--text-dark); line-height: 1; }
    .strip-info .slabel { font-size: .8rem; color: var(--text-mid); margin-top: .2rem; }

    .card {
      background: var(--white);
      border-radius: 16px;
      border: 1px solid var(--border);
      box-shadow: var(--shadow);
      overflow: hidden;
    }

    .card-head {
      padding: 1.1rem 1.5rem;
      border-bottom: 1px solid var(--border);
      display: flex;
      align-items: center;
      gap: 1rem;
    }

    .card-head-left { flex: 1; }
    .card-head-left h3 { font-size: 1rem; font-weight: 700; color: var(--text-dark); }
    .card-head-left p  { font-size: .78rem; color: var(--text-mid); margin-top: .1rem; }

    .table-search {
      position: relative;
      display: flex;
      align-items: center;
    }

    .table-search svg {
      position: absolute; left: .75rem;
      width: 15px; height: 15px;
      fill: none; stroke: var(--text-light); stroke-width: 2;
    }

    .table-search input {
      padding: .48rem 1rem .48rem 2.2rem;
      border: 1.5px solid var(--border);
      border-radius: 9px;
      font-family: 'DM Sans', sans-serif;
      font-size: .83rem;
      background: #fafafa;
      color: var(--text-dark);
      outline: none;
      width: 180px;
      transition: border-color .2s, box-shadow .2s;
    }

    .table-search input:focus {
      border-color: var(--red);
      box-shadow: 0 0 0 3px var(--red-light);
    }

    .btn-filter {
      display: flex; align-items: center; gap: .4rem;
      padding: .48rem .9rem;
      border: 1.5px solid var(--border);
      border-radius: 9px;
      background: white;
      font-family: 'DM Sans', sans-serif;
      font-size: .82rem;
      font-weight: 600;
      color: var(--text-mid);
      cursor: pointer;
      transition: border-color .2s, color .2s;
    }

    .btn-filter:hover { border-color: var(--red); color: var(--red); }
    .btn-filter svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; }

    .btn-add {
      display: flex; align-items: center; gap: .5rem;
      padding: .52rem 1.1rem;
      background: var(--red);
      color: white;
      border: none;
      border-radius: 9px;
      font-family: 'DM Sans', sans-serif;
      font-size: .85rem;
      font-weight: 600;
      cursor: pointer;
      transition: background .2s, transform .15s, box-shadow .2s;
      box-shadow: 0 3px 12px rgba(185,28,28,.3);
    }

    .btn-add:hover {
      background: var(--red-dark);
      transform: translateY(-1px);
      box-shadow: 0 5px 18px rgba(185,28,28,.35);
    }

    .btn-add svg { width: 17px; height: 17px; fill: white; }

    table { width: 100%; border-collapse: collapse; }

    thead tr { background: #fafafa; border-bottom: 1px solid var(--border); }

    th {
      font-size: .7rem;
      font-weight: 700;
      letter-spacing: .06em;
      text-transform: uppercase;
      color: var(--text-light);
      padding: .75rem 1.2rem;
      text-align: left;
      white-space: nowrap;
    }

    th:first-child { width: 40px; padding-left: 1.5rem; }

    td {
      padding: .85rem 1.2rem;
      font-size: .875rem;
      color: var(--text-dark);
      border-bottom: 1px solid #f3f4f6;
      vertical-align: middle;
    }

    td:first-child { padding-left: 1.5rem; }

    tbody tr:last-child td { border-bottom: none; }

    tbody tr { transition: background .15s; }
    tbody tr:hover { background: #fdf2f2; }

    input[type="checkbox"] {
      width: 16px; height: 16px;
      border: 1.5px solid var(--border);
      border-radius: 4px;
      cursor: pointer;
      accent-color: var(--red);
    }

    .user-cell {
      display: flex;
      align-items: center;
      gap: .85rem;
    }

    .user-thumb {
      width: 36px; height: 36px;
      border-radius: 50%;
      background: var(--red-light);
      overflow: hidden;
      flex-shrink: 0;
      display: flex; align-items: center; justify-content: center;
      font-size: .8rem;
      font-weight: 700;
      color: var(--red);
    }

    .user-thumb img { width: 100%; height: 100%; object-fit: cover; }

    .user-cell-info .uname  { font-size: .875rem; font-weight: 600; color: var(--text-dark); }
    .user-cell-info .uid    { font-size: .75rem; color: var(--text-light); }

    .email-cell { font-size: .85rem; color: var(--text-mid); }

    .role-badge {
      display: inline-flex;
      align-items: center;
      gap: .35rem;
      padding: .28rem .75rem;
      border-radius: 8px;
      font-size: .78rem;
      font-weight: 600;
    }

    .role-badge svg { width: 14px; height: 14px; fill: currentColor; }

    .role-donor     { background: #fee2e2; color: var(--red); }
    .role-recipient { background: #dbeafe; color: #2563eb; }
    .role-hospital  { background: #ede9fe; color: #7c3aed; }
    .role-admin     { background: #fef3c7; color: #d97706; }

    .blood-badge {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: .3rem .65rem;
      border-radius: 7px;
      font-size: .8rem;
      font-weight: 700;
      color: white;
      min-width: 38px;
    }

    .blood-red    { background: #dc2626; }
    .blood-blue   { background: #2563eb; }
    .blood-purple { background: #7c3aed; }
    .blood-teal   { background: #0d9488; }
    .blood-green  { background: #059669; }
    .blood-pink   { background: #db2777; }
    .blood-none   { color: var(--text-light); font-size: 1.1rem; letter-spacing: .05em; }

    .status-pill {
      display: inline-flex;
      align-items: center;
      gap: .35rem;
      padding: .28rem .75rem;
      border-radius: 999px;
      font-size: .78rem;
      font-weight: 600;
    }

    .status-pill::before {
      content: '';
      width: 6px; height: 6px;
      border-radius: 50%;
      background: currentColor;
    }

    .status-active   { background: #d1fae5; color: #059669; }
    .status-inactive { background: #f3f4f6; color: var(--text-light); }
    .status-suspended{ background: #fee2e2; color: var(--red); }

    .action-btns {
      display: flex;
      align-items: center;
      gap: .4rem;
    }

    .act-btn {
      width: 30px; height: 30px;
      border-radius: 7px;
      border: none;
      cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      transition: opacity .2s, transform .15s;
    }

    .act-btn:hover { opacity: .8; transform: scale(1.1); }
    .act-btn svg { width: 15px; height: 15px; }

    .act-view   { background: #dbeafe; }
    .act-view svg { fill: #2563eb; }
    .act-edit   { background: #fef3c7; }
    .act-edit svg { fill: #d97706; }
    .act-delete { background: #fee2e2; }
    .act-delete svg { fill: var(--red); }
    .act-approve { background: #d1fae5; }
    .act-approve svg { fill: #059669; }

    .pagination-row {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 1rem 1.5rem;
      border-top: 1px solid var(--border);
      font-size: .82rem;
      color: var(--text-mid);
    }

    .page-info strong { color: var(--text-dark); font-weight: 600; }

    .page-btns { display: flex; align-items: center; gap: .35rem; }

    .page-btn {
      width: 32px; height: 32px;
      border-radius: 8px;
      border: 1.5px solid var(--border);
      background: white;
      font-family: 'DM Sans', sans-serif;
      font-size: .82rem;
      font-weight: 600;
      color: var(--text-mid);
      cursor: pointer;
      display: flex; align-items: center; justify-content: center;
      transition: background .15s, border-color .15s, color .15s;
      text-decoration: none;
    }

    .page-btn:hover { border-color: var(--red); color: var(--red); }

    .page-btn.active {
      background: var(--red);
      border-color: var(--red);
      color: white;
    }

    .page-btn.disabled {
      opacity: .5;
      cursor: not-allowed;
    }

    .page-btn svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2.5; }

    .page-ellipsis {
      font-size: .85rem;
      color: var(--text-light);
      padding: 0 .2rem;
    }

    .rows-select {
      display: flex; align-items: center; gap: .5rem;
    }

    .rows-select select {
      padding: .3rem .6rem;
      border: 1.5px solid var(--border);
      border-radius: 7px;
      font-family: 'DM Sans', sans-serif;
      font-size: .82rem;
      background: white;
      color: var(--text-dark);
      outline: none;
      cursor: pointer;
    }

    .empty-state {
      text-align: center;
      padding: 3rem 1.5rem;
      color: var(--text-light);
      font-size: .9rem;
    }

    .alert {
      padding: .85rem 1.2rem; border-radius: 12px; font-size: .9rem; font-weight: 600;
    }
    .alert-success { background: #d1fae5; color: #065f46; border: 1px solid #a7f3d0; }
    .alert-error   { background: #fee2e2; color: #991b1b; border: 1px solid #fecaca; }

    .modal {
      position: fixed; inset: 0; z-index: 200;
      background: rgba(0,0,0,.45);
      display: none; align-items: center; justify-content: center;
    }
    .modal-content {
      background: var(--white); border-radius: 16px;
      width: 100%; max-width: 480px; max-height: 90vh; overflow-y: auto;
      padding: 1.5rem; box-shadow: 0 20px 60px rgba(0,0,0,.2);
    }
    .modal-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:1.2rem; }
    .modal-header h3 { font-size:1.1rem; font-weight:700; }
    .modal-header button { background:none; border:none; font-size:1.4rem; cursor:pointer; color:var(--text-light); }
    .form-group { display:flex; flex-direction:column; gap:.35rem; margin-bottom:1rem; }
    .form-group label { font-size:.82rem; font-weight:600; }
    .form-group input, .form-group select {
      padding:.55rem .8rem; border:1.5px solid var(--border); border-radius:9px;
      font-family:inherit; font-size:.88rem; outline:none;
    }
    .form-group input:focus, .form-group select:focus { border-color:var(--red); }
    .password-row { display:flex; gap:.5rem; }
    .password-row button {
      padding:.55rem .9rem; border:none; border-radius:9px; background:var(--red-light);
      color:var(--red); font-weight:600; cursor:pointer; white-space:nowrap;
    }
    .form-group small { font-size:.75rem; color:var(--text-light); }
    .modal-actions { display:flex; justify-content:flex-end; gap:.6rem; margin-top:1.2rem; }
    .btn-cancel { padding:.55rem 1rem; border:1.5px solid var(--border); background:white; border-radius:9px; cursor:pointer; font-family:inherit; font-size:.85rem; }
    .btn-save { padding:.55rem 1.2rem; border:none; background:var(--red); color:white; border-radius:9px; font-weight:600; cursor:pointer; font-family:inherit; font-size:.85rem; }

    .user-detail-body { display: flex; flex-direction: column; gap: 1rem; }
    .detail-row { display: flex; justify-content: space-between; align-items: center; padding: .6rem 0; border-bottom: 1px solid #f3f4f6; }
    .detail-row:last-child { border-bottom: none; }
    .detail-label { font-size: .82rem; color: var(--text-light); font-weight: 500; }
    .detail-value { font-size: .9rem; color: var(--text-dark); font-weight: 600; }
    .badge-role-donor     { color: var(--red); background: var(--red-light); padding: .2rem .6rem; border-radius: 6px; font-size: .78rem; }
    .badge-role-recipient { color: #2563eb; background: #dbeafe; padding: .2rem .6rem; border-radius: 6px; font-size: .78rem; }
    .badge-role-hospital  { color: #7c3aed; background: #ede9fe; padding: .2rem .6rem; border-radius: 6px; font-size: .78rem; }
    .badge-role-admin     { color: #d97706; background: #fef3c7; padding: .2rem .6rem; border-radius: 6px; font-size: .78rem; }
    .badge-status-active    { color: #059669; background: #d1fae5; padding: .2rem .6rem; border-radius: 999px; font-size: .78rem; }
    .badge-status-inactive  { color: var(--text-light); background: #f3f4f6; padding: .2rem .6rem; border-radius: 999px; font-size: .78rem; }
    .badge-status-suspended { color: var(--red); background: #fee2e2; padding: .2rem .6rem; border-radius: 999px; font-size: .78rem; }

    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(14px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    .stat-strip { animation: fadeUp .35s ease .05s both; }
    .card       { animation: fadeUp .35s ease .15s both; }

    /* RESPONSIVE */
    @media (max-width: 1024px) {
      .main { margin-left: 0; }
      .content { padding: 1.25rem 1rem; }
      .stat-strip { grid-template-columns: repeat(2, 1fr); }
      .card-head { flex-wrap: wrap; gap: .75rem; }
      .table-search { width: 100%; }
      .table-search input { width: 100%; }
    }
    @media (max-width: 768px) {
      .stat-strip { grid-template-columns: 1fr; }
      table { display: block; overflow-x: auto; white-space: nowrap; }
      .modal-content { margin: 1rem; max-height: 80vh; }
      .password-row { flex-direction: column; }
    }
  </style>
</head>
<body>

<jsp:include page="/includes/sidebar.jsp" />

<div class="main">

  <jsp:include page="/includes/admintopbar.jsp" />

  <div class="content">

    <c:if test="${not empty sessionScope.successMessage}">
      <div class="alert alert-success">${sessionScope.successMessage}</div>
      <% session.removeAttribute("successMessage"); %>
    </c:if>
    <c:if test="${not empty success}">
      <div class="alert alert-success">${success}</div>
    </c:if>
    <c:if test="${not empty error}">
      <div class="alert alert-error">${error}</div>
    </c:if>

    <!-- STAT STRIP -->
    <div class="stat-strip">

      <div class="stat-strip-card">
        <div class="strip-icon red">
          <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
        </div>
        <div class="strip-info">
          <div class="snum">${totalUsers}</div>
          <div class="slabel">Total Users</div>
        </div>
      </div>

      <div class="stat-strip-card">
        <div class="strip-icon pinkish">
          <svg viewBox="0 0 24 24"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
        </div>
        <div class="strip-info">
          <div class="snum">${totalDonors}</div>
          <div class="slabel">Donors</div>
        </div>
      </div>

      <div class="stat-strip-card">
        <div class="strip-icon blue">
          <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        </div>
        <div class="strip-info">
          <div class="snum">${totalRecipients}</div>
          <div class="slabel">Recipients</div>
        </div>
      </div>

      <div class="stat-strip-card">
        <div class="strip-icon purple">
          <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
        </div>
        <div class="strip-info">
          <div class="snum">${totalHospitals}</div>
          <div class="slabel">Hospitals</div>
        </div>
      </div>

    </div>

    <!-- USER LIST CARD -->
    <div class="card">

      <div class="card-head">
        <div class="card-head-left">
          <h3>User List</h3>
          <p>All registered platform users</p>
        </div>

        <div class="table-search">
          <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input type="text" id="userSearch" placeholder="Search users..." oninput="filterTable()"/>
        </div>

        <button class="btn-filter">
          <svg viewBox="0 0 24 24"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
          Filter
          <svg viewBox="0 0 24 24" style="width:12px;height:12px;"><polyline points="6 9 12 15 18 9"/></svg>
        </button>

        <button class="btn-add" type="button" onclick="openAddUserModal()">
          <svg viewBox="0 0 24 24"><path d="M15 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm-9-2V7H4v3H1v2h3v3h2v-3h3v-2H6zm9 4c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
          Add New User
        </button>
      </div>

      <!-- TABLE -->
      <table id="userTable">
        <thead>
        <tr>
          <th><input type="checkbox" id="selectAll" onchange="toggleAll(this)"/></th>
          <th>Name</th>
          <th>Email</th>
          <th>Role</th>
          <th>Blood Group</th>
          <th>Status</th>
          <th>Actions</th>
        </tr>
        </thead>
        <tbody>

        <c:choose>
          <c:when test="${empty users}">
            <tr>
              <td colspan="7" class="empty-state">No users found.</td>
            </tr>
          </c:when>
          <c:otherwise>
            <c:forEach items="${users}" var="user" varStatus="loop">
              <tr>
                <td><input type="checkbox" class="row-cb"/></td>
                <td>
                  <div class="user-cell">
                    <div class="user-thumb" style="background:
                      <c:choose>
                        <c:when test="${user.role == 'DONOR'}">#fee2e2;color:#b91c1c;</c:when>
                        <c:when test="${user.role == 'RECIPIENT'}">#dbeafe;color:#2563eb;</c:when>
                        <c:when test="${user.role == 'HOSPITAL'}">#ede9fe;color:#7c3aed;</c:when>
                        <c:otherwise>#fef3c7;color:#d97706;</c:otherwise>
                      </c:choose>">
                      ${user.initials}
                    </div>
                    <div class="user-cell-info">
                      <div class="uname">${user.fullName}</div>
                      <div class="uid">ID: #USR-${user.id}</div>
                    </div>
                  </div>
                </td>
                <td class="email-cell">${user.email}</td>
                <td>
                  <c:choose>
                    <c:when test="${user.role == 'DONOR'}">
                      <span class="role-badge role-donor">
                        <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                        Donor
                      </span>
                    </c:when>
                    <c:when test="${user.role == 'RECIPIENT'}">
                      <span class="role-badge role-recipient">
                        <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        Recipient
                      </span>
                    </c:when>
                    <c:when test="${user.role == 'HOSPITAL'}">
                      <span class="role-badge role-hospital">
                        <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                        Hospital
                      </span>
                    </c:when>
                    <c:otherwise>
                      <span class="role-badge role-admin">
                        <svg viewBox="0 0 24 24"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z"/></svg>
                        Admin
                      </span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${not empty user.bloodGroup}">
                      <span class="blood-badge blood-red">${user.bloodGroup}</span>
                    </c:when>
                    <c:otherwise>
                      <span class="blood-none">—</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <c:choose>
                    <c:when test="${user.status == 'ACTIVE'}">
                      <span class="status-pill status-active">Active</span>
                    </c:when>
                    <c:when test="${user.status == 'INACTIVE'}">
                      <span class="status-pill status-inactive">Inactive</span>
                    </c:when>
                    <c:otherwise>
                      <span class="status-pill status-suspended">Suspended</span>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td>
                  <div class="action-btns">
                    <button class="act-btn act-view" title="View" onclick="openViewUserModal(${user.id})"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
                    <button class="act-btn act-edit" title="Edit" onclick="openEditUserModal(${user.id})"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>
                    <c:if test="${user.status == 'INACTIVE'}">
                      <form action="${pageContext.request.contextPath}/admin/users/approve" method="post" style="display:inline;" onsubmit="return confirm('Approve this user?');">
                        <input type="hidden" name="id" value="${user.id}" />
                        <button type="submit" class="act-btn act-approve" title="Approve"><svg viewBox="0 0 24 24"><path d="M20 6L9 17l-5-5"/></svg></button>
                      </form>
                    </c:if>
                    <button class="act-btn act-delete" title="Delete" onclick="openDeleteConfirmModal(${user.id})"><svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg></button>
                  </div>
                </td>
              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>

        </tbody>
      </table>

      <!-- PAGINATION -->
      <div class="pagination-row">
        <div class="page-info">
          Showing <strong>${(currentPage - 1) * pageSize + 1}–${(currentPage - 1) * pageSize + fn:length(users)}</strong> of <strong>${totalUsers}</strong> users
        </div>

        <div class="page-btns">
          <c:choose>
            <c:when test="${currentPage > 1}">
              <a href="${pageContext.request.contextPath}/admin/users?page=${currentPage - 1}" class="page-btn" title="Previous">
                <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
              </a>
            </c:when>
            <c:otherwise>
              <span class="page-btn disabled" title="Previous">
                <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
              </span>
            </c:otherwise>
          </c:choose>

          <c:forEach items="${pages}" var="p">
            <c:choose>
              <c:when test="${p == currentPage}">
                <span class="page-btn active">${p}</span>
              </c:when>
              <c:otherwise>
                <a href="${pageContext.request.contextPath}/admin/users?page=${p}" class="page-btn">${p}</a>
              </c:otherwise>
            </c:choose>
          </c:forEach>

          <c:choose>
            <c:when test="${currentPage < totalPages}">
              <a href="${pageContext.request.contextPath}/admin/users?page=${currentPage + 1}" class="page-btn" title="Next">
                <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
              </a>
            </c:when>
            <c:otherwise>
              <span class="page-btn disabled" title="Next">
                <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
              </span>
            </c:otherwise>
          </c:choose>
        </div>

        <div class="rows-select">
          Rows per page:
          <select disabled>
            <option>${pageSize}</option>
          </select>
        </div>
      </div>

    </div>

  </div>
</div>

<!-- ADD USER MODAL -->
<div id="addUserModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">
      <h3>Add New User</h3>
      <button type="button" onclick="closeAddUserModal()">&times;</button>
    </div>
    <form id="addUserForm" action="${pageContext.request.contextPath}/admin/users/add" method="post">
      <div class="form-group">
        <label>Full Name</label>
        <input type="text" name="fullName" required maxlength="150" value="${fullName != null ? fullName : ''}"/>
      </div>
      <div class="form-group">
        <label>Email</label>
        <input type="email" name="email" required maxlength="100" value="${email != null ? email : ''}"/>
      </div>
      <div class="form-group">
        <label>Phone</label>
        <input type="tel" name="phone" maxlength="20" value="${phone != null ? phone : ''}"/>
      </div>
      <div class="form-group">
        <label>Blood Group</label>
        <select name="bloodGroup">
          <option value="" ${empty bloodGroup ? 'selected' : ''}>None</option>
          <option value="A+" ${bloodGroup == 'A+' ? 'selected' : ''}>A+</option>
          <option value="A-" ${bloodGroup == 'A-' ? 'selected' : ''}>A-</option>
          <option value="B+" ${bloodGroup == 'B+' ? 'selected' : ''}>B+</option>
          <option value="B-" ${bloodGroup == 'B-' ? 'selected' : ''}>B-</option>
          <option value="AB+" ${bloodGroup == 'AB+' ? 'selected' : ''}>AB+</option>
          <option value="AB-" ${bloodGroup == 'AB-' ? 'selected' : ''}>AB-</option>
          <option value="O+" ${bloodGroup == 'O+' ? 'selected' : ''}>O+</option>
          <option value="O-" ${bloodGroup == 'O-' ? 'selected' : ''}>O-</option>
        </select>
      </div>
      <div class="form-group">
        <label>Role</label>
        <select name="role" required>
          <option value="DONOR" ${role == 'DONOR' ? 'selected' : ''}>Donor</option>
          <option value="RECIPIENT" ${role == 'RECIPIENT' ? 'selected' : ''}>Recipient</option>
          <option value="HOSPITAL" ${role == 'HOSPITAL' ? 'selected' : ''}>Hospital</option>
          <option value="ADMIN" ${role == 'ADMIN' ? 'selected' : ''}>Admin</option>
        </select>
      </div>
      <div class="form-group">
        <label>Status</label>
        <select name="status" required>
          <option value="ACTIVE" ${status == 'ACTIVE' || empty status ? 'selected' : ''}>Active</option>
          <option value="INACTIVE" ${status == 'INACTIVE' ? 'selected' : ''}>Inactive</option>
          <option value="SUSPENDED" ${status == 'SUSPENDED' ? 'selected' : ''}>Suspended</option>
        </select>
      </div>
      <div class="form-group">
        <label>Password</label>
        <div class="password-row">
          <input type="text" name="password" id="passwordField" required minlength="8"/>
          <button type="button" onclick="generatePassword()">Generate</button>
        </div>
        <small>Minimum 8 characters. User should change this on first login.</small>
      </div>
      <div class="modal-actions">
        <button type="button" class="btn-cancel" onclick="closeAddUserModal()">Cancel</button>
        <button type="submit" class="btn-save">Create User</button>
      </div>
    </form>
  </div>
</div>

<!-- VIEW USER MODAL -->
<div id="viewUserModal" class="modal">
  <div class="modal-content" style="max-width:420px;">
    <div class="modal-header">
      <h3>User Details</h3>
      <button type="button" onclick="closeViewUserModal()">&times;</button>
    </div>
    <div class="user-detail-body" id="viewUserBody">
      <!-- Content loaded dynamically -->
    </div>
  </div>
</div>

<!-- DELETE CONFIRMATION MODAL -->
<div id="deleteConfirmModal" class="modal">
  <div class="modal-content" style="max-width:400px;">
    <div class="modal-header">
      <h3>Confirm Delete</h3>
      <button type="button" onclick="closeDeleteConfirmModal()">&times;</button>
    </div>
    <div style="padding: 20px;">
      <p>Are you sure you want to delete user <strong id="deleteUserName"></strong>?</p>
      <p style="color: var(--red); font-size: 13px; margin-top: 10px;">This action cannot be undone.</p>
    </div>
    <form id="deleteUserForm" action="${pageContext.request.contextPath}/admin/users/delete" method="post" style="padding: 0 20px 20px;">
      <input type="hidden" name="id" id="deleteUserId" />
      <div class="modal-actions">
        <button type="button" class="btn-cancel" onclick="closeDeleteConfirmModal()">Cancel</button>
        <button type="submit" class="btn-save" style="background: var(--red);">Delete</button>
      </div>
    </form>
  </div>
</div>

<!-- EDIT USER MODAL -->
<div id="editUserModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">
      <h3 id="editModalTitle">Edit User</h3>
      <button type="button" onclick="closeEditUserModal()">&times;</button>
    </div>
    <form id="editUserForm" action="${pageContext.request.contextPath}/admin/users/edit" method="post">
      <input type="hidden" name="editId" />
      <div class="form-group">
        <label>Full Name</label>
        <input type="text" name="editFullName" required maxlength="150"/>
      </div>
      <div class="form-group">
        <label>Email</label>
        <input type="email" name="editEmail" required maxlength="100"/>
      </div>
      <div class="form-group">
        <label>Phone</label>
        <input type="tel" name="editPhone" maxlength="20"/>
      </div>
      <div class="form-group">
        <label>Blood Group</label>
        <select name="editBloodGroup">
          <option value="">None</option>
          <option value="A+">A+</option>
          <option value="A-">A-</option>
          <option value="B+">B+</option>
          <option value="B-">B-</option>
          <option value="AB+">AB+</option>
          <option value="AB-">AB-</option>
          <option value="O+">O+</option>
          <option value="O-">O-</option>
        </select>
      </div>
      <div class="form-group">
        <label>Role</label>
        <select name="editRole" required>
          <option value="DONOR">Donor</option>
          <option value="RECIPIENT">Recipient</option>
          <option value="HOSPITAL">Hospital</option>
          <option value="ADMIN">Admin</option>
        </select>
      </div>
      <div class="form-group">
        <label>Status</label>
        <select name="editStatus" required>
          <option value="ACTIVE">Active</option>
          <option value="INACTIVE">Inactive</option>
          <option value="SUSPENDED">Suspended</option>
        </select>
      </div>
      <div class="form-group">
        <label>New Password (leave blank to keep current)</label>
        <div class="password-row">
          <input type="text" name="editPassword" id="editPasswordField" minlength="8" placeholder="Leave blank to keep current"/>
          <button type="button" onclick="generateEditPassword()">Generate</button>
        </div>
      </div>
      <div class="modal-actions">
        <button type="button" class="btn-cancel" onclick="closeEditUserModal()">Cancel</button>
        <button type="submit" class="btn-save" id="editSubmitBtn">Update User</button>
      </div>
    </form>
  </div>
</div>

<script>
  function toggleAll(master) {
    document.querySelectorAll('.row-cb').forEach(cb => cb.checked = master.checked);
  }

  function filterTable() {
    const q = document.getElementById('userSearch').value.toLowerCase();
    document.querySelectorAll('#userTable tbody tr').forEach(tr => {
      if (tr.querySelector('.empty-state')) return;
      tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
  }

  function openAddUserModal() {
    document.getElementById('addUserModal').style.display = 'flex';
  }

  function closeAddUserModal() {
    document.getElementById('addUserModal').style.display = 'none';
    document.getElementById('addUserForm').reset();
  }

  function generatePassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%';
    let pw = '';
    for (let i = 0; i < 12; i++) pw += chars.charAt(Math.floor(Math.random() * chars.length));
    document.getElementById('passwordField').value = pw;
  }

  // Auto-open modal if there was a validation error
  <c:if test="${not empty error}">
    openAddUserModal();
  </c:if>

  // Auto-open add modal if navigated from dashboard "Add User" button
  if (window.location.search.includes('action=add')) {
    openAddUserModal();
  }

  // Close on backdrop click
  document.getElementById('addUserModal').addEventListener('click', function(e) {
    if (e.target === this) closeAddUserModal();
  });

  function openViewUserModal(userId) {
    fetch('${pageContext.request.contextPath}/admin/users/view?id=' + userId)
      .then(r => {
        if (!r.ok) throw new Error('Failed to load user');
        return r.json();
      })
      .then(user => {
        const roleClass = 'badge-role-' + user.role.toLowerCase();
        const statusClass = 'badge-status-' + user.status.toLowerCase();
        const html = `
          <div class="detail-row">
            <span class="detail-label">User ID</span>
            <span class="detail-value">#USR-\${user.id}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Full Name</span>
            <span class="detail-value">\${user.fullName}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Email</span>
            <span class="detail-value">\${user.email}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Phone</span>
            <span class="detail-value">\${user.phone || '—'}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Blood Group</span>
            <span class="detail-value">\${user.bloodGroup || '—'}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Role</span>
            <span class="detail-value \${roleClass}">\${user.role}</span>
          </div>
          <div class="detail-row">
            <span class="detail-label">Status</span>
            <span class="detail-value \${statusClass}">\${user.status}</span>
          </div>
        `;
        document.getElementById('viewUserBody').innerHTML = html;
        document.getElementById('viewUserModal').style.display = 'flex';
      })
      .catch(err => {
        alert(err.message);
      });
  }

  function closeViewUserModal() {
    document.getElementById('viewUserModal').style.display = 'none';
  }

  // Close view modal on backdrop click
  document.getElementById('viewUserModal').addEventListener('click', function(e) {
    if (e.target === this) closeViewUserModal();
  });

  function openEditUserModal(userId) {
    fetch('${pageContext.request.contextPath}/admin/users/view?id=' + userId)
      .then(r => {
        if (!r.ok) throw new Error('Failed to load user');
        return r.json();
      })
      .then(user => {
        document.querySelector('#editUserForm [name="editId"]').value = user.id;
        document.querySelector('#editUserForm [name="editFullName"]').value = user.fullName;
        document.querySelector('#editUserForm [name="editEmail"]').value = user.email;
        document.querySelector('#editUserForm [name="editPhone"]').value = user.phone || '';
        document.querySelector('#editUserForm [name="editBloodGroup"]').value = user.bloodGroup || '';
        document.querySelector('#editUserForm [name="editRole"]').value = user.role;
        document.querySelector('#editUserForm [name="editStatus"]').value = user.status;
        document.getElementById('editPasswordField').value = '';

        document.getElementById('editModalTitle').textContent = 'Edit User';
        document.getElementById('editSubmitBtn').textContent = 'Update User';

        document.getElementById('editUserModal').style.display = 'flex';
      })
      .catch(err => {
        alert(err.message);
      });
  }

  function closeEditUserModal() {
    document.getElementById('editUserModal').style.display = 'none';
  }

  function generateEditPassword() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%';
    let pw = '';
    for (let i = 0; i < 12; i++) pw += chars.charAt(Math.floor(Math.random() * chars.length));
    document.getElementById('editPasswordField').value = pw;
  }

  // Close edit modal on backdrop click
  document.getElementById('editUserModal').addEventListener('click', function(e) {
    if (e.target === this) closeEditUserModal();
  });

  function openDeleteConfirmModal(userId) {
    document.getElementById('deleteUserId').value = userId;
    document.getElementById('deleteUserName').textContent = '#USR-' + userId;
    document.getElementById('deleteConfirmModal').style.display = 'flex';
  }

  function closeDeleteConfirmModal() {
    document.getElementById('deleteConfirmModal').style.display = 'none';
  }

  // Close delete modal on backdrop click
  document.getElementById('deleteConfirmModal').addEventListener('click', function(e) {
    if (e.target === this) closeDeleteConfirmModal();
  });
</script>

</body>
</html>
