<%--
  Created by IntelliJ IDEA.
  User: ektarai
  Date: 02/05/2026
  Time: 18:43
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  Manage Users – LifeLink Admin
  Created: 02/05/2026
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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


    /* ═══════════════════════════════════════
       MAIN
    ═══════════════════════════════════════ */
    .main {
      margin-left: var(--sidebar-w);
      flex: 1;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }


    /* ═══════════════════════════════════════
       CONTENT
    ═══════════════════════════════════════ */
    .content { padding: 1.75rem 2rem; display: flex; flex-direction: column; gap: 1.5rem; }

    /* STAT STRIP */
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

    /* USER LIST CARD */
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

    /* Search in card */
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

    /* Filter button */
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

    /* Add New User button */
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

    /* TABLE */
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

    tbody tr {
      transition: background .15s;
    }

    tbody tr:hover { background: #fdf2f2; }

    /* Checkbox */
    input[type="checkbox"] {
      width: 16px; height: 16px;
      border: 1.5px solid var(--border);
      border-radius: 4px;
      cursor: pointer;
      accent-color: var(--red);
    }

    /* User cell */
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

    /* Email */
    .email-cell { font-size: .85rem; color: var(--text-mid); }

    /* Role badge */
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

    /* Blood badge */
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

    /* Status */
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

    /* Action buttons */
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

    /* PAGINATION */
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
    }

    .page-btn:hover { border-color: var(--red); color: var(--red); }

    .page-btn.active {
      background: var(--red);
      border-color: var(--red);
      color: white;
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

    /* Animations */
    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(14px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    .stat-strip { animation: fadeUp .35s ease .05s both; }
    .card       { animation: fadeUp .35s ease .15s both; }
  </style>
</head>
<body>

<!-- ═══════════════════════════════════════
     SIDEBAR
═══════════════════════════════════════ -->
<!--Side Bar-->
<jsp:include page="/includes/sidebar.jsp" />

<!-- ═══════════════════════════════════════
     MAIN
═══════════════════════════════════════ -->
<div class="main">

  <!-- TOP BAR -->
  <jsp:include page="/includes/admintopbar.jsp" />

  <!-- CONTENT -->
  <div class="content">

    <!-- STAT STRIP -->
    <div class="stat-strip">

      <div class="stat-strip-card">
        <div class="strip-icon red">
          <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
        </div>
        <div class="strip-info">
          <div class="snum">2,340</div>
          <div class="slabel">Total Users</div>
        </div>
      </div>

      <div class="stat-strip-card">
        <div class="strip-icon pinkish">
          <svg viewBox="0 0 24 24"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
        </div>
        <div class="strip-info">
          <div class="snum">1,240</div>
          <div class="slabel">Donors</div>
        </div>
      </div>

      <div class="stat-strip-card">
        <div class="strip-icon blue">
          <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
        </div>
        <div class="strip-info">
          <div class="snum">850</div>
          <div class="slabel">Recipients</div>
        </div>
      </div>

      <div class="stat-strip-card">
        <div class="strip-icon purple">
          <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
        </div>
        <div class="strip-info">
          <div class="snum">250</div>
          <div class="slabel">Hospitals</div>
        </div>
      </div>

    </div><!-- /stat-strip -->

    <!-- USER LIST CARD -->
    <div class="card">

      <div class="card-head">
        <div class="card-head-left">
          <h3>User List</h3>
          <p>All registered platform users</p>
        </div>

        <!-- Search users -->
        <div class="table-search">
          <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
          <input type="text" id="userSearch" placeholder="Search users..." oninput="filterTable()"/>
        </div>

        <!-- Filter -->
        <button class="btn-filter">
          <svg viewBox="0 0 24 24"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
          Filter
          <svg viewBox="0 0 24 24" style="width:12px;height:12px;"><polyline points="6 9 12 15 18 9"/></svg>
        </button>

        <!-- Add New User -->
        <button class="btn-add">
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

        <tr>
          <td><input type="checkbox" class="row-cb"/></td>
          <td>
            <div class="user-cell">
              <div class="user-thumb" style="background:#fce7f3;color:#db2777;">SJ</div>
              <div class="user-cell-info">
                <div class="uname">Sarah Johnson</div>
                <div class="uid">ID: #USR-001</div>
              </div>
            </div>
          </td>
          <td class="email-cell">sarah.j@email.com</td>
          <td>
              <span class="role-badge role-donor">
                <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                Donor
              </span>
          </td>
          <td><span class="blood-badge blood-red">A+</span></td>
          <td><span class="status-pill status-active">Active</span></td>
          <td>
            <div class="action-btns">
              <button class="act-btn act-view" title="View"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
              <button class="act-btn act-edit" title="Edit"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>
              <button class="act-btn act-delete" title="Delete"><svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg></button>
            </div>
          </td>
        </tr>

        <tr>
          <td><input type="checkbox" class="row-cb"/></td>
          <td>
            <div class="user-cell">
              <div class="user-thumb" style="background:#dbeafe;color:#2563eb;">MC</div>
              <div class="user-cell-info">
                <div class="uname">Michael Chen</div>
                <div class="uid">ID: #USR-002</div>
              </div>
            </div>
          </td>
          <td class="email-cell">m.chen@email.com</td>
          <td>
              <span class="role-badge role-recipient">
                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                Recipient
              </span>
          </td>
          <td><span class="blood-badge blood-blue">O-</span></td>
          <td><span class="status-pill status-active">Active</span></td>
          <td>
            <div class="action-btns">
              <button class="act-btn act-view" title="View"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
              <button class="act-btn act-edit" title="Edit"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>
              <button class="act-btn act-delete" title="Delete"><svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg></button>
            </div>
          </td>
        </tr>

        <tr>
          <td><input type="checkbox" class="row-cb"/></td>
          <td>
            <div class="user-cell">
              <div class="user-thumb" style="background:#ede9fe;color:#7c3aed;">AP</div>
              <div class="user-cell-info">
                <div class="uname">Aisha Patel</div>
                <div class="uid">ID: #USR-003</div>
              </div>
            </div>
          </td>
          <td class="email-cell">aisha.p@email.com</td>
          <td>
              <span class="role-badge role-hospital">
                <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                Hospital
              </span>
          </td>
          <td><span class="blood-none">—</span></td>
          <td><span class="status-pill status-inactive">Inactive</span></td>
          <td>
            <div class="action-btns">
              <button class="act-btn act-view" title="View"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
              <button class="act-btn act-edit" title="Edit"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>
              <button class="act-btn act-delete" title="Delete"><svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg></button>
            </div>
          </td>
        </tr>

        <tr>
          <td><input type="checkbox" class="row-cb"/></td>
          <td>
            <div class="user-cell">
              <div class="user-thumb" style="background:#d1fae5;color:#059669;">JO</div>
              <div class="user-cell-info">
                <div class="uname">James Osei</div>
                <div class="uid">ID: #USR-004</div>
              </div>
            </div>
          </td>
          <td class="email-cell">james.o@email.com</td>
          <td>
              <span class="role-badge role-donor">
                <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                Donor
              </span>
          </td>
          <td><span class="blood-badge blood-red">AB+</span></td>
          <td><span class="status-pill status-active">Active</span></td>
          <td>
            <div class="action-btns">
              <button class="act-btn act-view" title="View"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
              <button class="act-btn act-edit" title="Edit"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>
              <button class="act-btn act-delete" title="Delete"><svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg></button>
            </div>
          </td>
        </tr>

        <tr>
          <td><input type="checkbox" class="row-cb"/></td>
          <td>
            <div class="user-cell">
              <div class="user-thumb" style="background:#ccfbf1;color:#0d9488;">PN</div>
              <div class="user-cell-info">
                <div class="uname">Priya Nair</div>
                <div class="uid">ID: #USR-005</div>
              </div>
            </div>
          </td>
          <td class="email-cell">priya.n@email.com</td>
          <td>
              <span class="role-badge role-recipient">
                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                Recipient
              </span>
          </td>
          <td><span class="blood-badge blood-teal">O+</span></td>
          <td><span class="status-pill status-active">Active</span></td>
          <td>
            <div class="action-btns">
              <button class="act-btn act-view" title="View"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
              <button class="act-btn act-edit" title="Edit"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>
              <button class="act-btn act-delete" title="Delete"><svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg></button>
            </div>
          </td>
        </tr>

        <tr>
          <td><input type="checkbox" class="row-cb"/></td>
          <td>
            <div class="user-cell">
              <div class="user-thumb" style="background:#ede9fe;color:#7c3aed;">DM</div>
              <div class="user-cell-info">
                <div class="uname">David Mensah</div>
                <div class="uid">ID: #USR-006</div>
              </div>
            </div>
          </td>
          <td class="email-cell">d.mensah@hospital.org</td>
          <td>
              <span class="role-badge role-hospital">
                <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                Hospital
              </span>
          </td>
          <td><span class="blood-none">—</span></td>
          <td><span class="status-pill status-active">Active</span></td>
          <td>
            <div class="action-btns">
              <button class="act-btn act-view" title="View"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
              <button class="act-btn act-edit" title="Edit"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>
              <button class="act-btn act-delete" title="Delete"><svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg></button>
            </div>
          </td>
        </tr>

        <tr>
          <td><input type="checkbox" class="row-cb"/></td>
          <td>
            <div class="user-cell">
              <div class="user-thumb" style="background:#fce7f3;color:#db2777;">LT</div>
              <div class="user-cell-info">
                <div class="uname">Linda Torres</div>
                <div class="uid">ID: #USR-007</div>
              </div>
            </div>
          </td>
          <td class="email-cell">l.torres@email.com</td>
          <td>
              <span class="role-badge role-donor">
                <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                Donor
              </span>
          </td>
          <td><span class="blood-badge blood-pink">B+</span></td>
          <td><span class="status-pill status-inactive">Inactive</span></td>
          <td>
            <div class="action-btns">
              <button class="act-btn act-view" title="View"><svg viewBox="0 0 24 24"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg></button>
              <button class="act-btn act-edit" title="Edit"><svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg></button>
              <button class="act-btn act-delete" title="Delete"><svg viewBox="0 0 24 24"><polyline points="3 6 5 6 21 6"/><path d="M19 6l-1 14a2 2 0 01-2 2H8a2 2 0 01-2-2L5 6"/><path d="M10 11v6"/><path d="M14 11v6"/><path d="M9 6V4h6v2"/></svg></button>
            </div>
          </td>
        </tr>

        </tbody>
      </table>

      <!-- PAGINATION -->
      <div class="pagination-row">
        <div class="page-info">
          Showing <strong>1–7</strong> of <strong>2,340</strong> users
        </div>

        <div class="page-btns">
          <button class="page-btn" title="Previous">
            <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
          </button>
          <button class="page-btn active">1</button>
          <button class="page-btn">2</button>
          <button class="page-btn">3</button>
          <span class="page-ellipsis">...</span>
          <button class="page-btn">335</button>
          <button class="page-btn" title="Next">
            <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
          </button>
        </div>

        <div class="rows-select">
          Rows per page:
          <select>
            <option>7</option>
            <option>10</option>
            <option>25</option>
            <option>50</option>
          </select>
        </div>
      </div>

    </div><!-- /card -->

  </div><!-- /content -->
</div><!-- /main -->

<script>
  /* Select-all checkbox */
  function toggleAll(master) {
    document.querySelectorAll('.row-cb').forEach(cb => cb.checked = master.checked);
  }

  /* Live search filter */
  function filterTable() {
    const q = document.getElementById('userSearch').value.toLowerCase();
    document.querySelectorAll('#userTable tbody tr').forEach(tr => {
      tr.style.display = tr.textContent.toLowerCase().includes(q) ? '' : 'none';
    });
  }
</script>

</body>
</html>

