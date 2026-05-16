<%--
  Admin Requests – LifeLink
  Created: 15/05/2026
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Manage Requests – LifeLink</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>

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

        /* STAT CARDS */
        .stats-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.1rem; }

        .stat-card {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid var(--border);
            padding: 1.4rem 1.5rem 1.2rem;
            box-shadow: var(--shadow);
            position: relative;
            overflow: hidden;
            display: flex;
            align-items: center;
            gap: 1rem;
        }

        .stat-icon-wrap {
            width: 48px; height: 48px;
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }

        .stat-icon-wrap svg { width: 22px; height: 22px; }

        .stat-icon-wrap.red    { background: var(--red-light); }
        .stat-icon-wrap.red svg { fill: var(--red); }
        .stat-icon-wrap.amber  { background: #fef3c7; }
        .stat-icon-wrap.amber svg { fill: #d97706; }
        .stat-icon-wrap.green  { background: #d1fae5; }
        .stat-icon-wrap.green svg { fill: #059669; }

        .stat-info { flex: 1; }

        .stat-num {
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--text-dark);
            line-height: 1;
            margin-bottom: .35rem;
        }

        .stat-label { font-size: .82rem; color: var(--text-mid); }

        /* FILTERS */
        .filters-row {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow);
            padding: 1rem 1.5rem;
            display: flex;
            align-items: center;
            gap: 1.5rem;
            flex-wrap: wrap;
        }

        .filter-group { display: flex; align-items: center; gap: .6rem; }

        .filter-label {
            font-size: .72rem;
            font-weight: 700;
            letter-spacing: .05em;
            text-transform: uppercase;
            color: var(--text-light);
        }

        .filter-label svg {
            width: 14px; height: 14px;
            fill: var(--text-light);
            vertical-align: middle;
            margin-right: .2rem;
        }

        .filter-pills { display: flex; align-items: center; gap: .4rem; flex-wrap: wrap; }

        .pill {
            padding: .35rem .75rem;
            border-radius: 999px;
            font-size: .78rem;
            font-weight: 600;
            cursor: pointer;
            border: 1.5px solid transparent;
            background: transparent;
            color: var(--text-mid);
            transition: all .2s;
            font-family: 'DM Sans', sans-serif;
            text-decoration: none;
            display: inline-block;
        }

        .pill:hover { background: #f3f4f6; }

        .pill.active {
            background: var(--red-light);
            color: var(--red);
            border-color: var(--red);
        }

        .pill.approved-pill.active {
            background: #d1fae5;
            color: #059669;
            border-color: #059669;
        }

        .pill.rejected-pill.active {
            background: var(--red-light);
            color: var(--red);
            border-color: var(--red);
        }

        .pill.pending-pill.active {
            background: #fef3c7;
            color: #d97706;
            border-color: #d97706;
        }

        .filter-divider {
            width: 1px;
            height: 24px;
            background: var(--border);
            margin: 0 .3rem;
        }

        .btn-export {
            display: flex; align-items: center; gap: .4rem;
            padding: .55rem 1rem;
            border: none;
            border-radius: 10px;
            background: #1f2937;
            font-family: 'DM Sans', sans-serif;
            font-size: .82rem;
            font-weight: 600;
            color: white;
            cursor: pointer;
            transition: opacity .2s;
            margin-left: auto;
        }

        .btn-export:hover { opacity: .9; }
        .btn-export svg { width: 16px; height: 16px; fill: currentColor; }

        /* TABLE CARD */
        .card {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .card-head {
            padding: 1.2rem 1.5rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
        }

        .card-head h3 { font-size: 1rem; font-weight: 700; color: var(--text-dark); }
        .card-head p  { font-size: .78rem; color: var(--text-mid); margin-top: .15rem; }

        .sort-dropdown {
            display: flex;
            align-items: center;
            gap: .3rem;
            font-size: .8rem;
            color: var(--text-mid);
            cursor: pointer;
        }

        .sort-dropdown svg { width: 14px; height: 14px; fill: none; stroke: var(--text-light); stroke-width: 2; }

        table { width: 100%; border-collapse: collapse; }

        thead tr { border-bottom: 1px solid var(--border); }

        th {
            font-size: .72rem;
            font-weight: 700;
            letter-spacing: .05em;
            text-transform: uppercase;
            color: var(--text-light);
            padding: .8rem 1.5rem;
            text-align: left;
            white-space: nowrap;
        }

        td {
            padding: .85rem 1.5rem;
            font-size: .875rem;
            color: var(--text-dark);
            border-bottom: 1px solid #f3f4f6;
            vertical-align: middle;
        }

        tbody tr:last-child td { border-bottom: none; }
        tbody tr:hover { background: #fafafa; }

        .req-id {
            color: var(--red);
            font-weight: 700;
            font-size: .85rem;
        }

        .requester {
            display: flex;
            align-items: center;
            gap: .75rem;
        }

        .requester-avatar {
            width: 36px; height: 36px;
            border-radius: 50%;
            background: var(--red-light);
            display: flex; align-items: center; justify-content: center;
            font-size: .75rem;
            font-weight: 700;
            color: var(--red);
            flex-shrink: 0;
        }

        .requester-info { display: flex; flex-direction: column; }
        .requester-name { font-weight: 600; font-size: .85rem; }
        .requester-email { font-size: .75rem; color: var(--text-light); }

        .blood-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: .25rem .6rem;
            border-radius: 6px;
            font-size: .78rem;
            font-weight: 700;
            min-width: 40px;
            color: white;
        }

        .bg-red    { background: #dc2626; }
        .bg-blue   { background: #2563eb; }
        .bg-purple { background: #7c3aed; }
        .bg-green  { background: #059669; }
        .bg-teal   { background: #0d9488; }
        .bg-orange { background: #ea580c; }

        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: .35rem;
            padding: .28rem .7rem;
            border-radius: 999px;
            font-size: .78rem;
            font-weight: 600;
        }

        .status-pill::before {
            content: '';
            width: 6px; height: 6px;
            border-radius: 50%;
            background: currentColor;
            opacity: .8;
        }

        .status-pill.pending  { background: #fef3c7; color: #d97706; }
        .status-pill.approved { background: #d1fae5; color: #059669; }
        .status-pill.rejected { background: var(--red-light); color: var(--red); }

        .actions { display: flex; align-items: center; gap: .4rem; }

        .action-btn {
            display: inline-flex;
            align-items: center;
            gap: .3rem;
            padding: .35rem .6rem;
            border-radius: 6px;
            font-size: .78rem;
            font-weight: 600;
            cursor: pointer;
            border: 1px solid transparent;
            font-family: 'DM Sans', sans-serif;
            transition: all .2s;
            text-decoration: none;
            background: none;
        }

        .action-btn.approve-btn {
            background: #d1fae5;
            color: #059669;
            border-color: #059669;
        }
        .action-btn.approve-btn:hover { background: #059669; color: white; }

        .action-btn.reject-btn {
            background: var(--red-light);
            color: var(--red);
            border-color: var(--red);
        }
        .action-btn.reject-btn:hover { background: var(--red); color: white; }

        .action-btn.view-btn {
            background: #f3f4f6;
            color: var(--text-mid);
            border-color: var(--border);
        }
        .action-btn.view-btn:hover { background: var(--text-mid); color: white; }

        .action-btn.disabled {
            opacity: .5;
            cursor: not-allowed;
        }

        .action-btn svg { width: 12px; height: 12px; fill: currentColor; }

        /* Alert messages */
        .alert {
            padding: .9rem 1.2rem;
            border-radius: 10px;
            font-size: .85rem;
            font-weight: 600;
            margin-bottom: 1rem;
        }
        .alert-success { background: #d1fae5; color: #065f46; border: 1.5px solid #a7f3d0; }
        .alert-error   { background: var(--red-light); color: var(--red-dark); border: 1.5px solid #fecaca; }

        /* PAGINATION */
        .card-footer {
            padding: 1rem 1.5rem;
            border-top: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .showing-text { font-size: .78rem; color: var(--text-light); }

        .pagination { display: flex; align-items: center; gap: .35rem; }

        .page-btn {
            width: 32px; height: 32px;
            display: flex; align-items: center; justify-content: center;
            border-radius: 8px;
            border: 1px solid var(--border);
            background: white;
            font-family: 'DM Sans', sans-serif;
            font-size: .8rem;
            font-weight: 600;
            color: var(--text-mid);
            cursor: pointer;
            transition: all .2s;
            text-decoration: none;
        }

        .page-btn:hover { border-color: var(--red); color: var(--red); }
        .page-btn.active { background: var(--red); color: white; border-color: var(--red); }
        .page-btn:disabled { opacity: .4; cursor: not-allowed; }

        .page-btn svg { width: 14px; height: 14px; fill: none; stroke: currentColor; stroke-width: 2; }

        .page-dots {
            width: 32px; height: 32px;
            display: flex; align-items: center; justify-content: center;
            font-size: .8rem;
            color: var(--text-light);
        }

        /* Animations */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .stats-row .stat-card:nth-child(1) { animation: fadeUp .4s ease .05s both; }
        .stats-row .stat-card:nth-child(2) { animation: fadeUp .4s ease .12s both; }
        .stats-row .stat-card:nth-child(3) { animation: fadeUp .4s ease .19s both; }
        .stats-row .stat-card:nth-child(4) { animation: fadeUp .4s ease .26s both; }
        .filters-row { animation: fadeUp .4s ease .3s both; }
        .requests-card { animation: fadeUp .4s ease .4s both; }

        /* RESPONSIVE */
        @media (max-width: 1024px) {
            .main { margin-left: 0; }
            .content { padding: 1.25rem 1rem; }
            .stats-row { grid-template-columns: repeat(2, 1fr); }
            .filters-row { gap: 1rem; }
            .btn-export { margin-left: 0; width: 100%; justify-content: center; }
        }
        @media (max-width: 768px) {
            .stats-row { grid-template-columns: 1fr; }
            table { display: block; overflow-x: auto; white-space: nowrap; }
            .card-head { flex-direction: column; align-items: flex-start; gap: .5rem; }
            .actions { flex-wrap: nowrap; }
            .card-footer { flex-direction: column; gap: 1rem; align-items: flex-start; }
        }
    </style>
</head>
<body>

<!-- Sidebar -->
<jsp:include page="/includes/sidebar.jsp" />

<!-- MAIN -->
<div class="main">

    <jsp:include page="/includes/admintopbar.jsp" />

    <!-- CONTENT -->
    <div class="content">

        <c:if test="${not empty param.success}">
            <div class="alert alert-success">${param.success}</div>
        </c:if>
        <c:if test="${not empty param.error}">
            <div class="alert alert-error">${param.error}</div>
        </c:if>

        <!-- STAT CARDS -->
        <div class="stats-row">
            <div class="stat-card">
                <div class="stat-icon-wrap red">
                    <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                </div>
                <div class="stat-info">
                    <div class="stat-num">${totalRequests}</div>
                    <div class="stat-label">Total Requests</div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon-wrap amber">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                </div>
                <div class="stat-info">
                    <div class="stat-num">${pendingCount}</div>
                    <div class="stat-label">Pending</div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon-wrap green">
                    <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                </div>
                <div class="stat-info">
                    <div class="stat-num">${approvedCount}</div>
                    <div class="stat-label">Approved</div>
                </div>
            </div>

            <div class="stat-card">
                <div class="stat-icon-wrap red">
                    <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                </div>
                <div class="stat-info">
                    <div class="stat-num">${rejectedCount}</div>
                    <div class="stat-label">Rejected</div>
                </div>
            </div>
        </div><!-- /stats-row -->

        <!-- FILTERS -->
        <div class="filters-row">
            <div class="filter-group">
                <span class="filter-label">
                    <svg viewBox="0 0 24 24"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
                    Filters:
                </span>
            </div>

            <div class="filter-group">
                <span class="filter-label">Status</span>
                <div class="filter-pills">
                    <a href="${pageContext.request.contextPath}/admin/requests" class="pill ${activeFilter == 'all' ? 'active' : ''}">All</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?status=pending" class="pill pending-pill ${activeFilter == 'pending' ? 'active' : ''}">Pending</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?status=approved" class="pill approved-pill ${activeFilter == 'approved' ? 'active' : ''}">Approved</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?status=rejected" class="pill rejected-pill ${activeFilter == 'rejected' ? 'active' : ''}">Rejected</a>
                </div>
            </div>

            <div class="filter-divider"></div>

            <div class="filter-group">
                <span class="filter-label">Blood Group</span>
                <div class="filter-pills">
                    <a href="${pageContext.request.contextPath}/admin/requests" class="pill ${activeBloodGroup == 'all' ? 'active' : ''}">All</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?bg=A%2B" class="pill ${activeBloodGroup == 'A+' ? 'active' : ''}">A+</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?bg=A-" class="pill ${activeBloodGroup == 'A-' ? 'active' : ''}">A-</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?bg=B%2B" class="pill ${activeBloodGroup == 'B+' ? 'active' : ''}">B+</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?bg=B-" class="pill ${activeBloodGroup == 'B-' ? 'active' : ''}">B-</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?bg=O%2B" class="pill ${activeBloodGroup == 'O+' ? 'active' : ''}">O+</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?bg=O-" class="pill ${activeBloodGroup == 'O-' ? 'active' : ''}">O-</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?bg=AB%2B" class="pill ${activeBloodGroup == 'AB+' ? 'active' : ''}">AB+</a>
                    <a href="${pageContext.request.contextPath}/admin/requests?bg=AB-" class="pill ${activeBloodGroup == 'AB-' ? 'active' : ''}">AB-</a>
                </div>
            </div>

            <a href="${pageContext.request.contextPath}/admin/requests/export" class="btn-export" style="text-decoration:none;">
                <svg viewBox="0 0 24 24"><path d="M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z"/></svg>
                Export CSV
            </a>
        </div><!-- /filters-row -->

        <!-- REQUESTS TABLE -->
        <div class="card requests-card">
            <div class="card-head">
                <div>
                    <h3>All Requests</h3>
                    <p>Showing ${totalRequests} total requests</p>
                </div>
                <div class="sort-dropdown">
                    <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
                    <span style="margin-right:.3rem;">Sort by:</span>
                    <c:choose>
                        <c:when test="${activeSort == 'oldest'}">
                            <a href="${pageContext.request.contextPath}/admin/requests?sort=newest" style="color:var(--text-dark); font-weight:700; text-decoration:none;">Oldest First</a>
                        </c:when>
                        <c:otherwise>
                            <a href="${pageContext.request.contextPath}/admin/requests?sort=oldest" style="color:var(--text-dark); font-weight:700; text-decoration:none;">Newest First</a>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>

            <table>
                <thead>
                <tr>
                    <th>Request ID</th>
                    <th>Requester</th>
                    <th>Blood Group</th>
                    <th>Units</th>
                    <th>Date</th>
                    <th>Status</th>
                    <th>Actions</th>
                </tr>
                </thead>
                <tbody>
                <c:forEach items="${requests}" var="req">
                <tr>
                    <td><span class="req-id">${req.formattedRequestId}</span></td>
                    <td>
                        <div class="requester">
                            <div class="requester-avatar">${req.initials}</div>
                            <div class="requester-info">
                                <span class="requester-name">${req.requesterName}</span>
                                <span class="requester-email">${req.requesterEmail}</span>
                            </div>
                        </div>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${req.bloodGroup == 'A+'}"><span class="blood-badge bg-red">A+</span></c:when>
                            <c:when test="${req.bloodGroup == 'A-'}"><span class="blood-badge bg-blue">A-</span></c:when>
                            <c:when test="${req.bloodGroup == 'B+'}"><span class="blood-badge bg-purple">B+</span></c:when>
                            <c:when test="${req.bloodGroup == 'B-'}"><span class="blood-badge bg-orange">B-</span></c:when>
                            <c:when test="${req.bloodGroup == 'O+'}"><span class="blood-badge bg-green">O+</span></c:when>
                            <c:when test="${req.bloodGroup == 'O-'}"><span class="blood-badge bg-blue">O-</span></c:when>
                            <c:when test="${req.bloodGroup == 'AB+'}"><span class="blood-badge bg-red">AB+</span></c:when>
                            <c:when test="${req.bloodGroup == 'AB-'}"><span class="blood-badge bg-teal">AB-</span></c:when>
                            <c:otherwise><span class="blood-badge bg-red">${req.bloodGroup}</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>${req.units} unit${req.units > 1 ? 's' : ''}</td>
                    <td>${req.formattedDate}</td>
                    <td>
                        <c:choose>
                            <c:when test="${req.status == 'PENDING'}">
                                <span class="status-pill pending">Pending</span>
                            </c:when>
                            <c:when test="${req.status == 'APPROVED'}">
                                <span class="status-pill approved">Approved</span>
                            </c:when>
                            <c:when test="${req.status == 'REJECTED'}">
                                <span class="status-pill rejected">Rejected</span>
                            </c:when>
                        </c:choose>
                    </td>
                    <td>
                        <div class="actions">
                            <c:choose>
                                <c:when test="${req.status == 'PENDING'}">
                                    <form method="post" action="${pageContext.request.contextPath}/admin/requests/action" style="display:inline;">
                                        <input type="hidden" name="id" value="${req.id}"/>
                                        <input type="hidden" name="action" value="approve"/>
                                        <button type="submit" class="action-btn approve-btn">
                                            <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                            Approve
                                        </button>
                                    </form>
                                    <form method="post" action="${pageContext.request.contextPath}/admin/requests/action" style="display:inline;">
                                        <input type="hidden" name="id" value="${req.id}"/>
                                        <input type="hidden" name="action" value="reject"/>
                                        <button type="submit" class="action-btn reject-btn">
                                            <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                                            Reject
                                        </button>
                                    </form>
                                </c:when>
                                <c:otherwise>
                                    <button class="action-btn approve-btn disabled" disabled>
                                        <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                        Approve
                                    </button>
                                    <button class="action-btn reject-btn disabled" disabled>
                                        <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                                        Reject
                                    </button>
                                </c:otherwise>
                            </c:choose>
                            <a href="${pageContext.request.contextPath}/admin/requests/action?id=${req.id}" class="action-btn view-btn">
                                <svg viewBox="0 0 24 24"><path d="M12 4.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5zM12 17c-2.76 0-5-2.24-5-5s2.24-5 5-5 5 2.24 5 5-2.24 5-5 5zm0-8c-1.66 0-3 1.34-3 3s1.34 3 3 3 3-1.34 3-3-1.34-3-3-3z"/></svg>
                                View
                            </a>
                        </div>
                    </td>
                </tr>
                </c:forEach>
                <c:if test="${empty requests}">
                <tr>
                    <td colspan="7" style="text-align:center; color:var(--text-light); padding:2rem;">No requests found</td>
                </tr>
                </c:if>
                </tbody>
            </table>

            <div class="card-footer">
                <span class="showing-text">Showing ${showingStart}–${showingEnd} of ${filteredTotal} requests</span>
                <div class="pagination">
                    <c:choose>
                        <c:when test="${currentPage > 1}">
                            <a href="${pageContext.request.contextPath}/admin/requests?page=${currentPage - 1}" class="page-btn">
                                <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                            </a>
                        </c:when>
                        <c:otherwise>
                            <button class="page-btn" disabled>
                                <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                            </button>
                        </c:otherwise>
                    </c:choose>

                    <c:forEach begin="1" end="${totalPages}" var="p">
                        <a href="${pageContext.request.contextPath}/admin/requests?page=${p}" class="page-btn ${p == currentPage ? 'active' : ''}">${p}</a>
                    </c:forEach>

                    <c:choose>
                        <c:when test="${currentPage < totalPages}">
                            <a href="${pageContext.request.contextPath}/admin/requests?page=${currentPage + 1}" class="page-btn">
                                <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
                            </a>
                        </c:when>
                        <c:otherwise>
                            <button class="page-btn" disabled>
                                <svg viewBox="0 0 24 24"><polyline points="9 18 15 12 9 6"/></svg>
                            </button>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div><!-- /requests-card -->

    </div><!-- /content -->
</div><!-- /main -->

</body>
</html>
