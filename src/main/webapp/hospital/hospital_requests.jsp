<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Requests - LifeLink</title>
    <style>
        :root {
            --red: #c0392b;
            --dark-red-hero: #8b1a1a;
            --dark-sidebar: #1a0a0a;
            --sidebar-hover: #2a1010;
            --card-bg: #ffffff;
            --text-primary: #1a1a1a;
            --text-muted: #888888;
            --border: #e5e7eb;
            --low-amber: #f59e0b;
            --info-blue: #3b82f6;
            --success-green: #10b981;
            --bg-page: #f5f5f5;
        }
        * { box-sizing: border-box; }
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: var(--bg-page); color: var(--text-primary); }
        a { color: inherit; text-decoration: none; }
        .layout { display: flex; min-height: 100vh; }
        .sidebar { width: 220px; min-width: 220px; background: linear-gradient(180deg, #220909 0%, var(--dark-sidebar) 100%); color: #f8d7d3; padding: 24px 16px; display: flex; flex-direction: column; position: fixed; inset: 0 auto 0 0; }
        .brand, .topbar-profile, .topbar-right, .tab-btn, .requester-cell, .actions, .filters, .header-tools, .summary-card, .nav-link, .logout-link, .hospital-account { display: flex; align-items: center; }
        .brand { gap: 12px; color: #fff; font-size: 20px; font-weight: 700; margin-bottom: 28px; }
        .brand-icon, .nav-icon, .logout-icon, .profile-icon, .topbar-bell, .summary-icon, .avatar, .action-btn.icon-only { display: inline-flex; align-items: center; justify-content: center; }
        .brand-icon { width: 38px; height: 38px; background: var(--red); border-radius: 12px; color: #fff; font-weight: 700; }
        .sidebar-label { font-size: 12px; letter-spacing: 2px; text-transform: uppercase; color: #c97b74; margin: 0 8px 12px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; }
        .nav-link { gap: 12px; padding: 14px 16px; border-radius: 14px; color: #f7d8d5; transition: background .2s ease; }
        .nav-link:hover { background: var(--sidebar-hover); }
        .nav-link.active { background: var(--red); color: #fff; font-weight: 700; box-shadow: inset -4px 0 0 rgba(255,255,255,.7); }
        .nav-icon, .logout-icon { width: 32px; height: 32px; border-radius: 10px; background: rgba(255,255,255,.08); flex-shrink: 0; }
        .nav-badge, .bell-badge, .tab-badge { min-width: 24px; height: 24px; padding: 0 8px; border-radius: 999px; background: var(--red); color: #fff; font-size: 12px; font-weight: 700; display: inline-flex; align-items: center; justify-content: center; }
        .nav-badge { margin-left: auto; }
        .sidebar-spacer { flex: 1; }
        .sidebar-footer { border-top: 1px solid rgba(255,255,255,.08); padding-top: 18px; }
        .logout-link { gap: 12px; color: #ffd8d2; margin-bottom: 18px; padding: 10px 12px; border-radius: 12px; }
        .hospital-account { background: rgba(192,57,43,.2); border: 1px solid rgba(255,255,255,.08); border-radius: 14px; padding: 12px 14px; gap: 12px; color: #fff; }
        .hospital-account strong, .topbar-profile strong { display: block; font-size: 15px; line-height: 1.2; }
        .hospital-account span, .topbar-profile span { display: block; color: #d0d5dd; font-size: 13px; line-height: 1.3; }
        .content { margin-left: 220px; width: calc(100% - 220px); }
        .topbar { background: #fff; padding: 16px 28px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; gap: 20px; }
        .topbar h1 { margin: 0; font-size: 24px; }
        .topbar p { margin: 4px 0 0; color: #98a2b3; }
        .topbar-right { gap: 16px; }
        .topbar-bell { width: 42px; height: 42px; border-radius: 14px; border: 1px solid var(--border); background: #f8fafc; position: relative; color: #6b7280; }
        .bell-badge { position: absolute; top: -8px; right: -8px; min-width: 22px; height: 22px; font-size: 11px; }
        .new-request-btn { background: var(--red); color: #fff; padding: 12px 18px; border-radius: 14px; font-weight: 700; box-shadow: 0 6px 16px rgba(192,57,43,.18); white-space: nowrap; }
        .profile-icon { width: 42px; height: 42px; border-radius: 14px; background: var(--red); color: #fff; font-weight: 700; }
        .topbar-profile { gap: 12px; }
        .page-body { padding: 28px; }
        .banner { padding: 12px 16px; border-radius: 8px; margin-bottom: 18px; }
        .banner.success { background: #d1fae5; border-left: 4px solid var(--success-green); color: #166534; }
        .banner.error { background: #fef2f2; border-left: 4px solid #ef4444; color: #b91c1c; }
        .summary-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 20px; margin-bottom: 24px; }
        .card { background: var(--card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
        .summary-card { gap: 16px; padding: 24px; min-height: 88px; }
        .summary-icon { width: 44px; height: 44px; border-radius: 12px; font-weight: 700; }
        .summary-icon.red { background: #fdebec; color: var(--red); }
        .summary-icon.amber { background: #fff7e0; color: var(--low-amber); }
        .summary-icon.green { background: #ecfdf4; color: var(--success-green); }
        .summary-value { margin: 0; font-size: 18px; font-weight: 800; color: #273449; }
        .summary-label { margin: 4px 0 0; color: #98a2b3; font-size: 14px; }
        .section-card { overflow: hidden; }
        .tabs-bar { padding: 18px 24px 0; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; gap: 16px; }
        .tabs { display: flex; align-items: center; gap: 12px; }
        .tab-btn { gap: 10px; padding: 14px 16px; border: none; background: transparent; color: #98a2b3; font-weight: 700; cursor: pointer; border-bottom: 2px solid transparent; }
        .tab-btn.active { color: var(--red); border-bottom-color: var(--red); }
        .tab-badge { background: #eef2f7; color: #6b7280; }
        .tab-btn.active .tab-badge { background: var(--red); color: #fff; }
        .filters { position: relative; gap: 12px; }
        .search-box, .filter-select { border: 1px solid var(--border); border-radius: 12px; padding: 10px 14px; outline: none; font-size: 14px; background: #fff; }
        .search-box:focus, .filter-select:focus { border-color: var(--red); box-shadow: 0 0 0 3px rgba(192,57,43,.12); }
        .filter-toggle { border: 1px solid var(--border); border-radius: 12px; padding: 10px 14px; background: #fff; color: #6b7280; cursor: pointer; }
        .filter-panel { position: absolute; top: 52px; right: 0; width: 220px; background: #fff; border: 1px solid var(--border); border-radius: 12px; padding: 14px; box-shadow: 0 10px 24px rgba(0,0,0,.08); display: none; z-index: 4; }
        .filter-panel.show { display: block; }
        .table-wrap { overflow-x: auto; }
        table { width: 100%; border-collapse: collapse; }
        thead th { text-align: left; padding: 16px 24px; font-size: 13px; color: #98a2b3; letter-spacing: .04em; background: #f8fafc; }
        tbody tr { border-bottom: 1px solid var(--border); }
        tbody tr:hover { background: #fafafa; }
        tbody td { padding: 16px 24px; vertical-align: middle; }
        .id-pill { display: inline-flex; align-items: center; justify-content: center; padding: 8px 10px; border-radius: 10px; background: #f3f4f6; color: #667085; font-weight: 700; }
        .requester-cell { gap: 12px; }
        .avatar { width: 34px; height: 34px; border-radius: 50%; background: #e8f0fe; color: var(--info-blue); font-weight: 700; flex-shrink: 0; }
        .requester-name { font-weight: 700; color: #344054; }
        .requester-role { color: #98a2b3; font-size: 13px; margin-top: 2px; }
        .blood-pill { display: inline-flex; align-items: center; justify-content: center; min-width: 46px; padding: 6px 12px; border-radius: 10px; color: #fff; font-weight: 700; }
        .blood-red { background: #c0392b; }
        .blood-blue { background: #3f7ded; }
        .blood-teal { background: #1fb7aa; }
        .blood-purple { background: #a154f2; }
        .units-strong { font-weight: 800; color: #273449; }
        .status-badge { border-radius: 20px; padding: 4px 12px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
        .status-badge.pending { background: #fff8e7; color: #d97706; }
        .status-badge.accepted { background: #ecfdf4; color: var(--success-green); }
        .status-badge.rejected { background: #fdecec; color: #ef4444; }
        .status-badge.completed { background: #e8fcf8; color: #0f9f90; }
        .status-dot { width: 6px; height: 6px; border-radius: 50%; background: currentColor; }
        .actions { gap: 8px; }
        .action-btn { padding: 6px 14px; border-radius: 6px; font-size: 13px; border: none; font-weight: 700; cursor: pointer; }
        .action-btn.approve { background: #22c55e; color: #fff; }
        .action-btn.reject { background: #fff1f2; color: #dc2626; }
        .action-btn.icon-only { width: 38px; height: 32px; padding: 0 10px; background: #f3f4f6; color: #6b7280; font-size: 12px; }
        .action-btn.view { background: #eef2f7; color: #667085; }
        .action-btn.disabled { opacity: .4; cursor: not-allowed; pointer-events: none; }
        .table-footer { padding: 16px 24px; display: flex; align-items: center; justify-content: space-between; color: #98a2b3; }
        .pagination { display: flex; align-items: center; gap: 8px; }
        .page-link { width: 32px; height: 32px; border-radius: 8px; border: 1px solid var(--border); display: inline-flex; align-items: center; justify-content: center; background: #fff; color: #98a2b3; }
        .page-link.active { background: var(--red); border-color: var(--red); color: #fff; font-weight: 700; }
        .tab-pane { display: none; }
        .tab-pane.active { display: block; }
        @media (max-width: 900px) {
            .sidebar { position: static; width: 100%; min-width: 0; }
            .layout { flex-direction: column; }
            .content { margin-left: 0; width: 100%; }
            .summary-grid { grid-template-columns: repeat(2, 1fr); }
            .topbar, .tabs-bar, .table-footer { flex-direction: column; align-items: flex-start; }
        }
        @media (max-width: 600px) {
            .summary-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="brand"><span class="brand-icon">&#128167;</span><span>LifeLink</span></div>
        <div class="sidebar-label">Main Menu</div>
        <nav class="nav-menu">
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/dashboard"><span class="nav-icon">&#9673;</span><span>Dashboard</span></a>
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/stock"><span class="nav-icon">&#128230;</span><span>Manage Stock</span></a>
            <a class="nav-link active" href="${pageContext.request.contextPath}/hospital/requests"><span class="nav-icon">&#128196;</span><span>Requests</span><span class="nav-badge">${pendingCount}</span></a>
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/usage"><span class="nav-icon">&#8635;</span><span>Usage History</span></a>
        </nav>
        <div class="sidebar-spacer"></div>
        <div class="sidebar-footer">
            <a class="logout-link" href="${pageContext.request.contextPath}/logout"><span class="logout-icon">&#8617;</span><span>Logout</span></a>
            <div class="hospital-account"><span class="profile-icon">&#127973;</span><div><strong>${hospitalName}</strong><span>Hospital Account</span></div></div>
        </div>
    </aside>

    <main class="content">
        <header class="topbar">
            <div>
                <h1>Manage Requests</h1>
                <p>Review and act on blood requests.</p>
            </div>
            <div class="topbar-right">
                <jsp:include page="/includes/hospital_notifications.jsp" />
                <a class="new-request-btn" href="${pageContext.request.contextPath}/hospital/requests?action=create">+ New Request</a>
                <div class="topbar-profile"><span class="profile-icon">&#127973;</span><div><strong>${hospitalName}</strong><span>${not empty sessionScope.email ? sessionScope.email : hospitalEmail}</span></div></div>
            </div>
        </header>

        <div class="page-body">
            <c:choose>
                <c:when test="${param.success == 'created'}"><div class="banner success" id="flashBanner">Request created successfully.</div></c:when>
                <c:when test="${param.success == 'approved'}"><div class="banner success" id="flashBanner">Request approved successfully.</div></c:when>
                <c:when test="${param.success == 'rejected'}"><div class="banner success" id="flashBanner">Request rejected successfully.</div></c:when>
                <c:when test="${param.error == 'already_actioned'}"><div class="banner error" id="flashBanner">This request has already been actioned.</div></c:when>
                <c:when test="${param.error == 'insufficient_stock'}"><div class="banner error" id="flashBanner">Insufficient stock to approve this request.</div></c:when>
                <c:when test="${param.error == 'transaction_failed'}"><div class="banner error" id="flashBanner">Unable to complete the request action right now.</div></c:when>
            </c:choose>

            <section class="summary-grid">
                <article class="card summary-card"><span class="summary-icon red">&#128196;</span><div><p class="summary-value">${summaryStats.totalRequests}</p><p class="summary-label">Total Requests</p></div></article>
                <article class="card summary-card"><span class="summary-icon amber">&#128339;</span><div><p class="summary-value">${summaryStats.pendingCount}</p><p class="summary-label">Pending</p></div></article>
                <article class="card summary-card"><span class="summary-icon green">&#10003;</span><div><p class="summary-value">${summaryStats.approvedCount}</p><p class="summary-label">Approved</p></div></article>
                <article class="card summary-card"><span class="summary-icon red">&#10005;</span><div><p class="summary-value">${summaryStats.rejectedCount}</p><p class="summary-label">Rejected</p></div></article>
            </section>

            <section class="card section-card">
                <div class="tabs-bar">
                    <div class="tabs">
                        <button class="tab-btn active" type="button" data-tab="incomingTab">Incoming Requests <span class="tab-badge">${incomingCount}</span></button>
                        <button class="tab-btn" type="button" data-tab="myTab">My Requests <span class="tab-badge">${myRequests.size()}</span></button>
                    </div>
                    <div class="filters">
                        <input type="text" id="requestSearch" class="search-box" placeholder="Search requests...">
                        <button type="button" id="filterToggle" class="filter-toggle">Filter</button>
                        <div id="filterPanel" class="filter-panel">
                            <form method="get" action="${pageContext.request.contextPath}/hospital/requests">
                                <label for="bloodGroup" style="display:block;font-size:13px;font-weight:700;margin-bottom:8px;color:#344054;">Blood Group</label>
                                <select id="bloodGroup" name="bloodGroup" class="filter-select" onchange="this.form.submit()">
                                    <option value="">All groups</option>
                                    <c:forEach var="group" items="${filterGroups}">
                                        <option value="${group.id}" <c:if test="${group.id == bloodGroupFilter}">selected</c:if>>${group.name}</option>
                                    </c:forEach>
                                </select>
                            </form>
                        </div>
                    </div>
                </div>

                <div id="incomingTab" class="tab-pane active">
                    <div class="table-wrap">
                        <table>
                            <thead>
                            <tr>
                                <th>REQUEST ID</th><th>REQUESTER</th><th>BLOOD GROUP</th><th>UNITS</th><th>DATE</th><th>STATUS</th><th>ACTIONS</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="req" items="${incomingRequests}">
                                <tr class="request-row" data-search="${req.formattedId} ${req.requesterName}">
                                    <td><span class="id-pill">${req.formattedId}</span></td>
                                    <td>
                                        <div class="requester-cell">
                                            <span class="avatar">${req.avatarInitial}</span>
                                            <div><div class="requester-name">${req.requesterName}</div><div class="requester-role">${req.requesterRole}</div></div>
                                        </div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${req.bloodGroup == 'A+' || req.bloodGroup == 'A-'}"><span class="blood-pill blood-red">${req.bloodGroup}</span></c:when>
                                            <c:when test="${req.bloodGroup == 'B+' || req.bloodGroup == 'B-'}"><span class="blood-pill blood-blue">${req.bloodGroup}</span></c:when>
                                            <c:when test="${req.bloodGroup == 'O+' || req.bloodGroup == 'O-'}"><span class="blood-pill blood-teal">${req.bloodGroup}</span></c:when>
                                            <c:otherwise><span class="blood-pill blood-purple">${req.bloodGroup}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><span class="units-strong">${req.units}</span> units</td>
                                    <td>${req.requestedAt}</td>
                                    <td>
                                        <span class="status-badge ${req.status}">
                                            <span class="status-dot"></span>
                                            <c:choose>
                                                <c:when test="${req.status == 'accepted'}">Approved</c:when>
                                                <c:otherwise>${req.status}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>
                                    <td>
                                        <div class="actions">
                                            <c:choose>
                                                <c:when test="${req.status == 'pending'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/hospital/requests" style="margin:0;">
                                                        <input type="hidden" name="action" value="approve">
                                                        <input type="hidden" name="id" value="${req.id}">
                                                        <button class="action-btn approve" type="submit">Approve</button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/hospital/requests" style="margin:0;">
                                                        <input type="hidden" name="action" value="reject">
                                                        <input type="hidden" name="id" value="${req.id}">
                                                        <button class="action-btn reject" type="submit">Reject</button>
                                                    </form>
                                                    <a class="action-btn icon-only view" href="${pageContext.request.contextPath}/hospital/requests?action=detail&id=${req.id}" title="View Request">View</a>
                                                </c:when>
                                                <c:otherwise>
                                                    <button class="action-btn approve disabled" type="button">Approve</button>
                                                    <button class="action-btn reject disabled" type="button">Reject</button>
                                                    <a class="action-btn icon-only view" href="${pageContext.request.contextPath}/hospital/requests?action=detail&id=${req.id}" title="View Request">View</a>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                    <div class="table-footer">
                        <span>Showing ${incomingRequests.size()} of ${incomingCount} requests</span>
                        <div class="pagination">
                            <a class="page-link ${currentPage == 1 ? 'disabled' : ''}" href="${pageContext.request.contextPath}/hospital/requests?page=${currentPage > 1 ? currentPage - 1 : 1}${bloodGroupFilter != null ? '&bloodGroup=' : ''}${bloodGroupFilter != null ? bloodGroupFilter : ''}">&lt;</a>
                            <c:forEach begin="1" end="${totalPages}" var="pageNum">
                                <a class="page-link ${pageNum == currentPage ? 'active' : ''}" href="${pageContext.request.contextPath}/hospital/requests?page=${pageNum}${bloodGroupFilter != null ? '&bloodGroup=' : ''}${bloodGroupFilter != null ? bloodGroupFilter : ''}">${pageNum}</a>
                            </c:forEach>
                            <a class="page-link ${currentPage == totalPages ? 'disabled' : ''}" href="${pageContext.request.contextPath}/hospital/requests?page=${currentPage < totalPages ? currentPage + 1 : totalPages}${bloodGroupFilter != null ? '&bloodGroup=' : ''}${bloodGroupFilter != null ? bloodGroupFilter : ''}">&gt;</a>
                        </div>
                    </div>
                </div>

                <div id="myTab" class="tab-pane">
                    <div class="table-wrap">
                        <table>
                            <thead>
                            <tr>
                                <th>REQUEST ID</th><th>REQUESTER</th><th>BLOOD GROUP</th><th>UNITS</th><th>DATE</th><th>STATUS</th><th>ACTIONS</th>
                            </tr>
                            </thead>
                            <tbody>
                            <c:forEach var="req" items="${myRequests}">
                                <tr class="request-row" data-search="${req.formattedId} ${req.requesterName}">
                                    <td><span class="id-pill">${req.formattedId}</span></td>
                                    <td><div class="requester-cell"><span class="avatar">${req.avatarInitial}</span><div><div class="requester-name">${req.requesterName}</div><div class="requester-role">${req.requesterRole}</div></div></div></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${req.bloodGroup == 'A+' || req.bloodGroup == 'A-'}"><span class="blood-pill blood-red">${req.bloodGroup}</span></c:when>
                                            <c:when test="${req.bloodGroup == 'B+' || req.bloodGroup == 'B-'}"><span class="blood-pill blood-blue">${req.bloodGroup}</span></c:when>
                                            <c:when test="${req.bloodGroup == 'O+' || req.bloodGroup == 'O-'}"><span class="blood-pill blood-teal">${req.bloodGroup}</span></c:when>
                                            <c:otherwise><span class="blood-pill blood-purple">${req.bloodGroup}</span></c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><span class="units-strong">${req.units}</span> units</td>
                                    <td>${req.requestedAt}</td>
                                    <td>
                                        <span class="status-badge ${req.status}">
                                            <span class="status-dot"></span>
                                            <c:choose>
                                                <c:when test="${req.status == 'accepted'}">Approved</c:when>
                                                <c:otherwise>${req.status}</c:otherwise>
                                            </c:choose>
                                        </span>
                                    </td>
                                    <td><a class="action-btn icon-only view" href="${pageContext.request.contextPath}/hospital/requests?action=detail&id=${req.id}" title="View Request">View</a></td>
                                </tr>
                            </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </div>
    </main>
</div>

<script>
    (function () {
        var flash = document.getElementById('flashBanner');
        if (flash) {
            setTimeout(function () { flash.style.display = 'none'; }, 4000);
        }

        document.querySelectorAll('.tab-btn').forEach(function (button) {
            button.addEventListener('click', function () {
                document.querySelectorAll('.tab-btn').forEach(function (btn) { btn.classList.remove('active'); });
                document.querySelectorAll('.tab-pane').forEach(function (pane) { pane.classList.remove('active'); });
                button.classList.add('active');
                document.getElementById(button.getAttribute('data-tab')).classList.add('active');
            });
        });

        var searchInput = document.getElementById('requestSearch');
        searchInput.addEventListener('keyup', function () {
            var filter = searchInput.value.toLowerCase();
            document.querySelectorAll('.tab-pane.active .request-row').forEach(function (row) {
                row.style.display = row.getAttribute('data-search').toLowerCase().indexOf(filter) !== -1 ? '' : 'none';
            });
        });

        var filterToggle = document.getElementById('filterToggle');
        var filterPanel = document.getElementById('filterPanel');
        filterToggle.addEventListener('click', function () {
            filterPanel.classList.toggle('show');
        });
        document.addEventListener('click', function (event) {
            if (!filterPanel.contains(event.target) && event.target !== filterToggle) {
                filterPanel.classList.remove('show');
            }
        });
    })();
</script>
</body>
</html>
