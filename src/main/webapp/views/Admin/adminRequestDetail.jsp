<%--
  User Detail – LifeLink Admin
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate"/>
    <meta http-equiv="Pragma" content="no-cache"/>
    <meta http-equiv="Expires" content="0"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>User Details – LifeLink</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>

    <style>
        :root {
            --red:         #b91c1c;
            --red-dark:    #991b1b;
            --red-light:   #fee2e2;
            --red-mid:     #dc2626;
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

        /* Page Header */
        .page-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 1rem;
        }

        .page-header-left { display: flex; align-items: center; gap: 1rem; }

        .back-btn {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            padding: .5rem 1rem;
            border: 1.5px solid var(--border);
            border-radius: 10px;
            background: white;
            font-family: 'DM Sans', sans-serif;
            font-size: .85rem;
            font-weight: 600;
            color: var(--text-mid);
            text-decoration: none;
            transition: all .2s;
            cursor: pointer;
        }
        .back-btn:hover { border-color: var(--red); color: var(--red); }
        .back-btn svg { width: 16px; height: 16px; fill: none; stroke: currentColor; stroke-width: 2; }

        .page-title h2 {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--text-dark);
        }
        .page-title p {
            font-size: .78rem;
            color: var(--text-mid);
            margin-top: .15rem;
        }

        .page-actions { display: flex; align-items: center; gap: .6rem; }

        .btn {
            display: inline-flex; align-items: center; gap: .4rem;
            padding: .55rem 1rem;
            border-radius: 9px;
            font-family: 'DM Sans', sans-serif;
            font-size: .85rem;
            font-weight: 600;
            cursor: pointer;
            border: 1.5px solid transparent;
            text-decoration: none;
            transition: all .2s;
        }

        .btn-edit {
            background: var(--white);
            color: var(--text-mid);
            border-color: var(--border);
        }
        .btn-edit:hover { border-color: var(--red); color: var(--red); }
        .btn-edit svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; }

        .btn-deactivate {
            background: var(--red);
            color: white;
            border-color: var(--red);
        }
        .btn-deactivate:hover { background: var(--red-dark); }
        .btn-deactivate svg { width: 14px; height: 14px; fill: none; stroke: white; stroke-width: 2; }

        /* Modal */
        .modal-overlay {
            position: fixed; inset: 0;
            background: rgba(0,0,0,.45);
            display: none; align-items: center; justify-content: center;
            z-index: 1000;
            opacity: 0; transition: opacity .25s ease;
        }
        .modal-overlay.show { display: flex; opacity: 1; }
        .modal-box {
            background: var(--white);
            border-radius: 18px;
            width: 420px; max-width: 92vw;
            box-shadow: 0 24px 64px rgba(0,0,0,.25);
            transform: translateY(18px) scale(.96);
            transition: transform .25s ease;
        }
        .modal-overlay.show .modal-box {
            transform: translateY(0) scale(1);
        }
        .modal-header {
            padding: 1.5rem 1.5rem .75rem; text-align: center;
        }
        .modal-icon {
            width: 56px; height: 56px; border-radius: 50%;
            display: inline-flex; align-items: center; justify-content: center;
            margin-bottom: .75rem;
        }
        .modal-icon.deactivate { background: var(--red-light); }
        .modal-icon.deactivate svg { stroke: var(--red); }
        .modal-icon.activate { background: #d1fae5; }
        .modal-icon.activate svg { stroke: #059669; }
        .modal-header h3 {
            font-size: 1.1rem; font-weight: 700; color: var(--text-dark);
            margin-bottom: .3rem;
        }
        .modal-header p {
            font-size: .85rem; color: var(--text-mid); line-height: 1.45;
        }
        .modal-actions {
            display: flex; gap: .75rem; padding: 1rem 1.5rem 1.5rem;
        }
        .modal-actions .btn { flex: 1; justify-content: center; }
        .btn-secondary {
            background: var(--white); color: var(--text-mid);
            border-color: var(--border);
        }
        .btn-secondary:hover { background: #f9fafb; }

        /* Grid Layout */
        .detail-grid {
            display: grid;
            grid-template-columns: 320px 1fr;
            gap: 1.5rem;
            align-items: start;
        }

        @media (max-width: 1024px) {
            .detail-grid { grid-template-columns: 1fr; }
            .main { margin-left: 0; }
        }

        /* Cards */
        .card {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .card-pad { padding: 1.5rem; }

        /* Profile Card */
        .profile-top {
            height: 90px;
            background: linear-gradient(135deg, var(--red) 0%, var(--red-dark) 100%);
            position: relative;
        }

        .profile-body {
            padding: 3.2rem 1.5rem 1.5rem;
            text-align: center;
            position: relative;
        }

        .profile-avatar {
            width: 80px; height: 80px;
            border-radius: 50%;
            background: var(--white);
            border: 4px solid var(--white);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--red);
            position: absolute;
            top: -40px;
            left: 50%;
            transform: translateX(-50%);
            box-shadow: var(--shadow-md);
        }

        .profile-name {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: .4rem;
        }

        .profile-role {
            display: inline-flex;
            align-items: center;
            gap: .3rem;
            padding: .25rem .7rem;
            border-radius: 8px;
            font-size: .78rem;
            font-weight: 600;
            margin-bottom: .8rem;
        }
        .profile-role.donor     { background: var(--red-light); color: var(--red); }
        .profile-role.recipient { background: #dbeafe; color: #2563eb; }
        .profile-role.hospital  { background: #ede9fe; color: #7c3aed; }
        .profile-role.admin     { background: #fef3c7; color: #d97706; }

        .profile-badges {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: .5rem;
        }

        .badge-status {
            display: inline-flex;
            align-items: center;
            gap: .3rem;
            padding: .25rem .7rem;
            border-radius: 999px;
            font-size: .75rem;
            font-weight: 600;
        }
        .badge-status::before {
            content: '';
            width: 6px; height: 6px;
            border-radius: 50%;
            background: currentColor;
        }
        .badge-active   { background: #d1fae5; color: #059669; }
        .badge-inactive { background: #f3f4f6; color: var(--text-light); }
        .badge-suspended{ background: var(--red-light); color: var(--red); }

        .badge-blood {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: .25rem .6rem;
            border-radius: 6px;
            font-size: .78rem;
            font-weight: 700;
            color: white;
            background: var(--red-mid);
        }

        /* Section Titles */
        .section-title {
            font-size: .9rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 1rem;
            display: flex;
            align-items: center;
            gap: .5rem;
        }
        .section-title svg { width: 16px; height: 16px; }

        /* Info List */
        .info-list { display: flex; flex-direction: column; gap: .9rem; }
        .info-row { display: flex; align-items: center; gap: .75rem; }
        .info-icon {
            width: 36px; height: 36px;
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .info-icon svg { width: 16px; height: 16px; }
        .info-icon.red    { background: var(--red-light); }
        .info-icon.red svg { fill: var(--red); }
        .info-icon.blue   { background: #dbeafe; }
        .info-icon.blue svg { fill: #2563eb; }
        .info-icon.green  { background: #d1fae5; }
        .info-icon.green svg { fill: #059669; }
        .info-icon.purple { background: #ede9fe; }
        .info-icon.purple svg { fill: #7c3aed; }
        .info-icon.amber  { background: #fef3c7; }
        .info-icon.amber svg { fill: #d97706; }

        .info-label { font-size: .75rem; color: var(--text-light); font-weight: 500; }
        .info-value { font-size: .9rem; font-weight: 600; color: var(--text-dark); }

        /* Stats Grid */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: .75rem;
        }
        .stat-box {
            background: #fafafa;
            border-radius: 12px;
            padding: 1rem;
            text-align: center;
        }
        .stat-box .num {
            font-size: 1.5rem;
            font-weight: 700;
            display: block;
            line-height: 1;
        }
        .stat-box .num.red    { color: var(--red); }
        .stat-box .num.blue   { color: #2563eb; }
        .stat-box .num.green  { color: #059669; }
        .stat-box .num.purple { color: #7c3aed; }
        .stat-box .label {
            font-size: .75rem;
            color: var(--text-mid);
            margin-top: .3rem;
            font-weight: 500;
        }

        /* Account Details */
        .detail-table { width: 100%; }
        .detail-table tr { border-bottom: 1px solid #f3f4f6; }
        .detail-table tr:last-child { border-bottom: none; }
        .detail-table td {
            padding: .7rem 0;
            font-size: .85rem;
        }
        .detail-table td:first-child {
            color: var(--text-light);
            font-weight: 500;
            width: 40%;
        }
        .detail-table td:last-child {
            color: var(--text-dark);
            font-weight: 600;
            text-align: right;
        }

        .id-badge {
            display: inline-block;
            background: #f3f4f6;
            padding: .2rem .55rem;
            border-radius: 6px;
            font-size: .8rem;
            font-weight: 700;
            color: var(--text-dark);
        }

        /* Right column layout */
        .right-stack { display: flex; flex-direction: column; gap: 1.5rem; }

        /* RESPONSIVE */
        @media (max-width: 768px) {
            .content { padding: 1.25rem 1rem; }
            .page-header { flex-direction: column; align-items: flex-start; }
            .stats-grid { grid-template-columns: 1fr 1fr; }
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(14px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .card { animation: fadeUp .35s ease both; }
        .card:nth-child(1) { animation-delay: .05s; }
        .card:nth-child(2) { animation-delay: .1s; }
    </style>
</head>
<body>

<jsp:include page="/includes/sidebar.jsp" />

<div class="main">
    <jsp:include page="/includes/admintopbar.jsp" />

    <div class="content">

        <div class="page-header">
            <div class="page-header-left">
                <a href="${pageContext.request.contextPath}/admin/requests" class="back-btn">
                    <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                    Back to List
                </a>
                <div class="page-title">
                    <h2>User Details: ${userDetail.fullName}</h2>
                    <p>ID: #USR-${userDetail.id} · Member since ${userDetail.memberSince}</p>
                </div>
            </div>
            <div class="page-actions">
                <a href="${pageContext.request.contextPath}/admin/users?action=edit&id=${userDetail.id}" class="btn btn-edit">
                    <svg viewBox="0 0 24 24"><path d="M11 4H4a2 2 0 00-2 2v14a2 2 0 002 2h14a2 2 0 002-2v-7"/><path d="M18.5 2.5a2.121 2.121 0 013 3L12 15l-4 1 1-4 9.5-9.5z"/></svg>
                    Edit User
                </a>
                <c:choose>
                    <c:when test="${userDetail.status == 'ACTIVE'}">
                        <button type="button" class="btn btn-deactivate" onclick="openDeactivateModal()">
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                            Deactivate Account
                        </button>
                    </c:when>
                    <c:otherwise>
                        <button type="button" class="btn btn-edit" onclick="openActivateModal()">
                            <svg viewBox="0 0 24 24"><polyline points="20 6 9 17 4 12"/></svg>
                            Activate Account
                        </button>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <div class="detail-grid">
            <!-- LEFT COLUMN -->
            <div class="left-col">
                <!-- Profile Card -->
                <div class="card">
                    <div class="profile-top"></div>
                    <div class="profile-body">
                        <div class="profile-avatar">${userDetail.initials}</div>
                        <div class="profile-name">${userDetail.fullName}</div>
                        <c:choose>
                            <c:when test="${userDetail.role == 'DONOR'}">
                                <span class="profile-role donor">
                                    <svg viewBox="0 0 24 24" width="12" height="12"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/></svg>
                                    Donor
                                </span>
                            </c:when>
                            <c:when test="${userDetail.role == 'RECIPIENT'}">
                                <span class="profile-role recipient">
                                    <svg viewBox="0 0 24 24" width="12" height="12"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                                    Recipient
                                </span>
                            </c:when>
                            <c:when test="${userDetail.role == 'HOSPITAL'}">
                                <span class="profile-role hospital">
                                    <svg viewBox="0 0 24 24" width="12" height="12"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                                    Hospital
                                </span>
                            </c:when>
                            <c:otherwise>
                                <span class="profile-role admin">
                                    <svg viewBox="0 0 24 24" width="12" height="12"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z"/></svg>
                                    Admin
                                </span>
                            </c:otherwise>
                        </c:choose>
                        <div class="profile-badges">
                            <c:choose>
                                <c:when test="${userDetail.status == 'ACTIVE'}">
                                    <span class="badge-status badge-active">Active</span>
                                </c:when>
                                <c:when test="${userDetail.status == 'INACTIVE'}">
                                    <span class="badge-status badge-inactive">Inactive</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="badge-status badge-suspended">Rejected</span>
                                </c:otherwise>
                            </c:choose>
                            <c:if test="${not empty userDetail.bloodGroup}">
                                <span class="badge-blood">${userDetail.bloodGroup}</span>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Profile Information -->
                <div class="card card-pad" style="margin-top:1.5rem;">
                    <div class="section-title">
                        <svg viewBox="0 0 24 24" fill="var(--red)"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                        Profile Information
                    </div>
                    <div class="info-list">
                        <div class="info-row">
                            <div class="info-icon red">
                                <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                            </div>
                            <div>
                                <div class="info-label">Full Name</div>
                                <div class="info-value">${userDetail.fullName}</div>
                            </div>
                        </div>
                        <div class="info-row">
                            <div class="info-icon blue">
                                <svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
                            </div>
                            <div>
                                <div class="info-label">Email</div>
                                <div class="info-value">${userDetail.email}</div>
                            </div>
                        </div>
                        <div class="info-row">
                            <div class="info-icon green">
                                <svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07A19.5 19.5 0 014.69 12 19.79 19.79 0 011.63 3.42 2 2 0 013.6 1.24h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L7.91 8.96a16 16 0 006.13 6.13l.96-.96a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/></svg>
                            </div>
                            <div>
                                <div class="info-label">Phone</div>
                                <div class="info-value">${not empty userDetail.phone ? userDetail.phone : '—'}</div>
                            </div>
                        </div>
                        <div class="info-row">
                            <div class="info-icon purple">
                                <svg viewBox="0 0 24 24"><path d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4z"/></svg>
                            </div>
                            <div>
                                <div class="info-label">Role</div>
                                <div class="info-value">${userDetail.role}</div>
                            </div>
                        </div>
                        <div class="info-row">
                            <div class="info-icon red">
                                <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 00-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 00-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 000-7.78z"/></svg>
                            </div>
                            <div>
                                <div class="info-label">Blood Group</div>
                                <div class="info-value">${not empty userDetail.bloodGroup ? userDetail.bloodGroup : '—'}</div>
                            </div>
                        </div>
                    </div>
                </div>


            </div>

            <!-- RIGHT COLUMN -->
            <div class="right-col right-stack">
                <!-- Account Details -->
                <div class="card card-pad">
                    <div class="section-title">
                        <svg viewBox="0 0 24 24" fill="var(--red)"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                        Account Details
                    </div>
                    <table class="detail-table">
                        <tr>
                            <td>User ID</td>
                            <td><span class="id-badge">#USR-${userDetail.id}</span></td>
                        </tr>
                        <tr>
                            <td>Joined</td>
                            <td>${userDetail.formattedDate}</td>
                        </tr>
                        <tr>
                            <td>Account Status</td>
                            <td>
                                <c:choose>
                                    <c:when test="${userDetail.status == 'ACTIVE'}">
                                        <span style="color:#059669;font-weight:600;">● Active</span>
                                    </c:when>
                                    <c:when test="${userDetail.status == 'INACTIVE'}">
                                        <span style="color:var(--text-light);font-weight:600;">● Inactive</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:var(--red);font-weight:600;">● Rejected</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                        <tr>
                            <td>Verified</td>
                            <td>
                                <c:choose>
                                    <c:when test="${userDetail.approved}">
                                        <span style="color:#059669;font-weight:600;">✓ Yes</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color:var(--text-light);font-weight:600;">○ No</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </table>
                </div>

                <!-- Blood Request Actions (when accessed from notification) -->
                <c:if test="${not empty requestDetail}">
                <div class="card card-pad">
                    <div class="section-title">
                        <svg viewBox="0 0 24 24" fill="var(--red)"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
                        Blood Request Actions
                    </div>
                    <div style="display:flex;gap:.75rem;flex-wrap:wrap;">
                        <c:choose>
                            <c:when test="${requestDetail.status == 'PENDING'}">
                                <form method="post" action="${pageContext.request.contextPath}/admin/requests/action" style="display:inline;">
                                    <input type="hidden" name="id" value="${requestDetail.id}"/>
                                    <input type="hidden" name="action" value="approve"/>
                                    <button type="submit" class="btn btn-edit" style="background:#d1fae5;color:#059669;border-color:#059669;">
                                        <svg viewBox="0 0 24 24" width="14" height="14"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                        Approve Request
                                    </button>
                                </form>
                                <form method="post" action="${pageContext.request.contextPath}/admin/requests/action" style="display:inline;">
                                    <input type="hidden" name="id" value="${requestDetail.id}"/>
                                    <input type="hidden" name="action" value="reject"/>
                                    <button type="submit" class="btn btn-deactivate">
                                        <svg viewBox="0 0 24 24" width="14" height="14"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                                        Reject Request
                                    </button>
                                </form>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-edit" style="opacity:.5;cursor:not-allowed;" disabled>
                                    <svg viewBox="0 0 24 24" width="14" height="14"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                    Approve Request
                                </button>
                                <button class="btn btn-deactivate" style="opacity:.5;cursor:not-allowed;" disabled>
                                    <svg viewBox="0 0 24 24" width="14" height="14"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                                    Reject Request
                                </button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                    <div style="margin-top:1rem;padding-top:1rem;border-top:1px solid var(--border);">
                        <div class="detail-table" style="display:grid;grid-template-columns:1fr 1fr;gap:.5rem 1rem;">
                            <div style="font-size:.8rem;color:var(--text-light);">Request ID</div>
                            <div style="font-size:.85rem;font-weight:600;text-align:right;">${requestDetail.formattedRequestId}</div>
                            <div style="font-size:.8rem;color:var(--text-light);">Blood Group</div>
                            <div style="font-size:.85rem;font-weight:600;text-align:right;">${requestDetail.bloodGroup}</div>
                            <div style="font-size:.8rem;color:var(--text-light);">Units</div>
                            <div style="font-size:.85rem;font-weight:600;text-align:right;">${requestDetail.units}</div>
                            <div style="font-size:.8rem;color:var(--text-light);">Request Date</div>
                            <div style="font-size:.85rem;font-weight:600;text-align:right;">${requestDetail.formattedDate}</div>
                            <div style="font-size:.8rem;color:var(--text-light);">Status</div>
                            <div style="font-size:.85rem;font-weight:600;text-align:right;">
                                <c:choose>
                                    <c:when test="${requestDetail.status == 'PENDING'}"><span style="color:#d97706;">● Pending</span></c:when>
                                    <c:when test="${requestDetail.status == 'APPROVED'}"><span style="color:#059669;">● Approved</span></c:when>
                                    <c:otherwise><span style="color:var(--red);">● Rejected</span></c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </div>
                </div>
                </c:if>


            </div>
        </div>

    </div>
</div>

<!-- Deactivate Modal -->
<div class="modal-overlay" id="deactivateModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-icon deactivate">
                <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke-width="2"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
            </div>
            <h3>Deactivate Account</h3>
            <p>Are you sure you want to deactivate <strong>${userDetail.fullName}</strong>?<br>This user will no longer be able to log in.</p>
        </div>
        <div class="modal-actions">
            <button class="btn btn-secondary" onclick="closeModal('deactivateModal')">Cancel</button>
            <form method="post" action="${pageContext.request.contextPath}/admin/users/approve" style="flex:1;display:flex;">
                <input type="hidden" name="id" value="${userDetail.id}"/>
                <button type="submit" class="btn btn-deactivate" style="flex:1;justify-content:center;">Deactivate</button>
            </form>
        </div>
    </div>
</div>

<!-- Activate Modal -->
<div class="modal-overlay" id="activateModal">
    <div class="modal-box">
        <div class="modal-header">
            <div class="modal-icon activate">
                <svg viewBox="0 0 24 24" width="28" height="28" fill="none" stroke-width="2"><polyline points="20 6 9 17 4 12"/></svg>
            </div>
            <h3>Activate Account</h3>
            <p>Are you sure you want to activate <strong>${userDetail.fullName}</strong>?<br>The user will be able to log in again.</p>
        </div>
        <div class="modal-actions">
            <button class="btn btn-secondary" onclick="closeModal('activateModal')">Cancel</button>
            <form method="post" action="${pageContext.request.contextPath}/admin/users/approve" style="flex:1;display:flex;">
                <input type="hidden" name="id" value="${userDetail.id}"/>
                <button type="submit" class="btn btn-edit" style="flex:1;justify-content:center;background:#059669;color:#fff;border-color:#059669;">Activate</button>
            </form>
        </div>
    </div>
</div>

<script>
    function openDeactivateModal() { document.getElementById('deactivateModal').classList.add('show'); }
    function openActivateModal()   { document.getElementById('activateModal').classList.add('show'); }
    function closeModal(id)        { document.getElementById(id).classList.remove('show'); }

    // Close on overlay click
    document.querySelectorAll('.modal-overlay').forEach(overlay => {
        overlay.addEventListener('click', e => { if (e.target === overlay) overlay.classList.remove('show'); });
    });
    // Close on Escape
    document.addEventListener('keydown', e => {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-overlay').forEach(m => m.classList.remove('show'));
        }
    });

    // Force reload when page is restored from bfcache
    window.addEventListener('pageshow', function(event) {
        if (event.persisted) {
            window.location.reload();
        }
    });
</script>

</body>
</html>
