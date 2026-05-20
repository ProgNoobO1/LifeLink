<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Blood Stock - LifeLink</title>
    <style>
        :root {
            --red: #c0392b;
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

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: var(--bg-page);
            color: var(--text-primary);
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        .layout {
            display: flex;
            min-height: 100vh;
        }

        .sidebar {
            width: 220px;
            min-width: 220px;
            background: linear-gradient(180deg, #220909 0%, var(--dark-sidebar) 100%);
            color: #f8d7d3;
            padding: 24px 16px;
            display: flex;
            flex-direction: column;
            position: fixed;
            inset: 0 auto 0 0;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            color: #ffffff;
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 28px;
        }

        .brand-icon,
        .nav-icon,
        .logout-icon,
        .profile-icon,
        .topbar-bell,
        .summary-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .brand-icon {
            width: 38px;
            height: 38px;
            background: var(--red);
            border-radius: 12px;
            color: #ffffff;
            font-weight: 700;
        }

        .sidebar-label {
            font-size: 12px;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: #c97b74;
            margin: 0 8px 12px;
        }

        .nav-menu {
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .nav-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 14px 16px;
            border-radius: 14px;
            color: #f7d8d5;
            transition: background 0.2s ease;
        }

        .nav-link:hover {
            background: var(--sidebar-hover);
        }

        .nav-link.active {
            background: var(--red);
            color: #ffffff;
            font-weight: 700;
            box-shadow: inset -4px 0 0 rgba(255, 255, 255, 0.7);
        }

        .nav-icon,
        .logout-icon {
            width: 32px;
            height: 32px;
            border-radius: 10px;
            background: rgba(255, 255, 255, 0.08);
            flex-shrink: 0;
        }

        .nav-badge,
        .bell-badge {
            min-width: 24px;
            height: 24px;
            padding: 0 8px;
            border-radius: 999px;
            background: var(--red);
            color: #ffffff;
            font-size: 12px;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            margin-left: auto;
        }

        .sidebar-spacer {
            flex: 1;
        }

        .sidebar-footer {
            border-top: 1px solid rgba(255, 255, 255, 0.08);
            padding-top: 18px;
        }

        .logout-link {
            display: flex;
            align-items: center;
            gap: 12px;
            color: #ffd8d2;
            margin-bottom: 18px;
            padding: 10px 12px;
            border-radius: 12px;
        }

        .logout-link:hover {
            background: var(--sidebar-hover);
        }

        .hospital-account {
            background: rgba(192, 57, 43, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 14px;
            padding: 12px 14px;
            display: flex;
            align-items: center;
            gap: 12px;
            color: #ffffff;
        }

        .hospital-account strong,
        .topbar-profile strong {
            display: block;
            font-size: 15px;
        }

        .hospital-account span,
        .topbar-profile span {
            display: block;
            color: #d0d5dd;
            font-size: 13px;
        }

        .content {
            margin-left: 220px;
            width: calc(100% - 220px);
        }

        .topbar {
            background: #ffffff;
            padding: 16px 28px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 20px;
            position: sticky;
            top: 0;
            z-index: 5;
        }

        .topbar h1 {
            margin: 0;
            font-size: 24px;
        }

        .topbar p {
            margin: 4px 0 0;
            color: #98a2b3;
        }

        .topbar-right {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .topbar-bell {
            width: 42px;
            height: 42px;
            border-radius: 14px;
            border: 1px solid var(--border);
            background: #f8fafc;
            position: relative;
            color: #6b7280;
        }

        .bell-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            min-width: 22px;
            height: 22px;
            font-size: 11px;
            margin-left: 0;
        }

        .topbar-profile {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .profile-icon {
            width: 42px;
            height: 42px;
            border-radius: 14px;
            background: var(--red);
            color: #ffffff;
            font-weight: 700;
        }

        .page-body {
            padding: 28px;
        }

        .success-banner {
            background: #d1fae5;
            border-left: 4px solid var(--success-green);
            padding: 12px 16px;
            border-radius: 8px;
            color: #166534;
            margin-bottom: 20px;
        }

        .error-banner {
            background: #fef2f2;
            border-left: 4px solid #ef4444;
            padding: 12px 16px;
            border-radius: 8px;
            color: #b91c1c;
            margin-bottom: 20px;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 24px;
        }

        .card {
            background: var(--card-bg);
            border-radius: 12px;
            box-shadow: 0 1px 4px rgba(0, 0, 0, 0.08);
            padding: 24px;
        }

        .summary-card {
            display: flex;
            align-items: center;
            gap: 16px;
            min-height: 88px;
        }

        .summary-icon {
            width: 44px;
            height: 44px;
            border-radius: 12px;
            font-weight: 700;
        }

        .summary-icon.red {
            background: #fbe9e7;
            color: var(--red);
        }

        .summary-icon.green {
            background: #ecfdf4;
            color: var(--success-green);
        }

        .summary-icon.amber {
            background: #fff7e0;
            color: var(--low-amber);
        }

        .summary-icon.soft-red {
            background: #fdebec;
            color: var(--red);
        }

        .summary-value {
            margin: 0;
            font-size: 18px;
            font-weight: 800;
            color: #273449;
        }

        .summary-label {
            margin: 4px 0 0;
            color: #98a2b3;
            font-size: 14px;
        }

        .section-card {
            padding: 0;
            overflow: hidden;
        }

        .section-header {
            padding: 20px 28px;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
        }

        .section-header h2 {
            margin: 0;
            font-size: 18px;
        }

        .section-header p {
            margin: 4px 0 0;
            color: #98a2b3;
        }

        .header-tools {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .search-box {
            min-width: 220px;
            padding: 11px 14px;
            border: 1px solid var(--border);
            border-radius: 12px;
            outline: none;
            font-size: 14px;
        }

        .search-box:focus {
            border-color: var(--red);
            box-shadow: 0 0 0 3px rgba(192, 57, 43, 0.12);
        }

        .add-btn {
            background: var(--red);
            color: #ffffff;
            padding: 12px 18px;
            border-radius: 12px;
            font-weight: 700;
            box-shadow: 0 6px 16px rgba(192, 57, 43, 0.18);
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead th {
            text-align: left;
            padding: 14px 28px;
            font-size: 13px;
            color: #98a2b3;
            letter-spacing: 0.04em;
            background: #f8fafc;
        }

        tbody tr {
            border-bottom: 1px solid var(--border);
        }

        tbody tr:hover {
            background: #fafafa;
        }

        tbody td {
            padding: 16px 28px;
            vertical-align: middle;
        }

        .group-cell {
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .blood-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 40px;
            padding: 4px 10px;
            border-radius: 6px;
            color: #ffffff;
            font-weight: 700;
        }

        .blood-red {
            background: #c0392b;
        }

        .blood-blue {
            background: #3f7ded;
        }

        .blood-teal {
            background: #1fb7aa;
        }

        .blood-purple {
            background: #a154f2;
        }

        .full-name {
            font-weight: 600;
            color: #344054;
        }

        .units-cell {
            min-width: 210px;
        }

        .units-row {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .units-row strong {
            color: #273449;
        }

        .units-row span {
            color: #98a2b3;
            font-size: 14px;
        }

        .progress-track {
            width: 84px;
            height: 6px;
            border-radius: 3px;
            background: #e5e7eb;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            border-radius: 3px;
        }

        .status-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border-radius: 999px;
            padding: 5px 12px;
            font-size: 13px;
            font-weight: 700;
        }

        .status-badge.normal {
            background: #ecfdf4;
            color: var(--success-green);
        }

        .status-badge.low {
            background: #fff8e7;
            color: var(--low-amber);
        }

        .status-dot {
            width: 7px;
            height: 7px;
            border-radius: 50%;
            background: currentColor;
        }

        .date-cell {
            color: #667085;
        }

        .expiry-warning {
            color: #d97706;
            font-weight: 700;
        }

        .actions {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .icon-btn {
            width: 32px;
            height: 32px;
            border-radius: 6px;
            border: none;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            cursor: pointer;
            font-weight: 700;
        }

        .icon-btn.edit {
            background: #e8f0fe;
            color: var(--info-blue);
        }

        .icon-btn.delete {
            background: #fdecec;
            color: var(--red);
        }

        .table-footer {
            padding: 16px 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            color: #98a2b3;
        }

        .pagination {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .page-chip,
        .page-arrow {
            width: 32px;
            height: 32px;
            border-radius: 8px;
            border: 1px solid var(--border);
            display: inline-flex;
            align-items: center;
            justify-content: center;
            background: #ffffff;
            color: #98a2b3;
        }

        .page-chip.active {
            background: var(--red);
            color: #ffffff;
            border-color: var(--red);
            font-weight: 700;
        }

        .empty-row {
            text-align: center;
            color: #98a2b3;
        }

        @media (max-width: 900px) {
            .sidebar {
                position: static;
                width: 100%;
                min-width: 0;
            }

            .layout {
                flex-direction: column;
            }

            .content {
                margin-left: 0;
                width: 100%;
            }

            .summary-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .topbar,
            .section-header,
            .table-footer {
                flex-direction: column;
                align-items: flex-start;
            }

            .header-tools {
                width: 100%;
                flex-direction: column;
                align-items: stretch;
            }
        }

        @media (max-width: 600px) {
            .summary-grid {
                grid-template-columns: 1fr;
            }

            thead {
                display: none;
            }

            tbody td {
                display: block;
                padding: 10px 20px;
            }

            tbody tr {
                display: block;
                padding: 8px 0;
            }
        }
    </style>
</head>
<body>
<div class="layout">
    <aside class="sidebar">
        <div class="brand">
            <span class="brand-icon">&#128167;</span>
            <span>LifeLink</span>
        </div>

        <div class="sidebar-label">Main Menu</div>
        <nav class="nav-menu">
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/dashboard">
                <span class="nav-icon">&#9673;</span>
                <span>Dashboard</span>
            </a>
            <a class="nav-link active" href="${pageContext.request.contextPath}/hospital/stock">
                <span class="nav-icon">&#128230;</span>
                <span>Manage Stock</span>
            </a>
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/requests">
                <span class="nav-icon">&#128196;</span>
                <span>Requests</span>
                <span class="nav-badge">${pendingCount}</span>
            </a>
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/usage">
                <span class="nav-icon">&#8635;</span>
                <span>Usage History</span>
            </a>
        </nav>

        <div class="sidebar-spacer"></div>

        <div class="sidebar-footer">
            <a class="logout-link" href="${pageContext.request.contextPath}/logout">
                <span class="logout-icon">&#8617;</span>
                <span>Logout</span>
            </a>

            <div class="hospital-account">
                <span class="profile-icon">&#127973;</span>
                <div>
                    <strong>${hospitalName}</strong>
                    <span>Hospital Account</span>
                </div>
            </div>
        </div>
    </aside>

    <main class="content">
        <header class="topbar">
            <div>
                <h1>Manage Blood Stock</h1>
                <p>Add, update or remove blood units from your inventory.</p>
            </div>
            <div class="topbar-right">
                <jsp:include page="/includes/hospital_notifications.jsp" />
                <div class="topbar-profile">
                    <span class="profile-icon">&#127973;</span>
                    <div>
                        <strong>${hospitalName}</strong>
                        <span>${not empty sessionScope.email ? sessionScope.email : hospitalEmail}</span>
                    </div>
                </div>
            </div>
        </header>

        <div class="page-body">
            <c:if test="${param.success != null}">
                <div class="success-banner" id="successBanner">
                    <c:choose>
                        <c:when test="${param.success == 'added'}">Stock added successfully.</c:when>
                        <c:when test="${param.success == 'updated'}">Stock updated successfully.</c:when>
                        <c:when test="${param.success == 'deleted'}">Stock deleted successfully.</c:when>
                        <c:otherwise>Stock action completed successfully.</c:otherwise>
                    </c:choose>
                </div>
            </c:if>
            <c:if test="${param.error != null}">
                <div class="error-banner">
                    <c:choose>
                        <c:when test="${param.error == 'delete'}">Unable to delete that stock entry.</c:when>
                        <c:otherwise>Unable to complete the stock action.</c:otherwise>
                    </c:choose>
                </div>
            </c:if>

            <section class="summary-grid">
                <article class="card summary-card">
                    <span class="summary-icon red">&#128167;</span>
                    <div>
                        <p class="summary-value">${stats.totalUnits}</p>
                        <p class="summary-label">Total Units</p>
                    </div>
                </article>
                <article class="card summary-card">
                    <span class="summary-icon green">&#10003;</span>
                    <div>
                        <p class="summary-value">${stats.normalGroups}</p>
                        <p class="summary-label">Normal Groups</p>
                    </div>
                </article>
                <article class="card summary-card">
                    <span class="summary-icon amber">&#9888;</span>
                    <div>
                        <p class="summary-value">${stats.lowStockCount}</p>
                        <p class="summary-label">Low Stock</p>
                    </div>
                </article>
                <article class="card summary-card">
                    <span class="summary-icon soft-red">&#128197;</span>
                    <div>
                        <p class="summary-value">${stats.expiringSoon}</p>
                        <p class="summary-label">Expiring Soon</p>
                    </div>
                </article>
            </section>

            <section class="card section-card">
                <div class="section-header">
                    <div>
                        <h2>Blood Stock Inventory</h2>
                        <p>All blood groups currently tracked in your inventory.</p>
                    </div>
                    <div class="header-tools">
                        <input type="text" id="stockSearch" class="search-box" placeholder="Search stock...">
                        <a class="add-btn" href="${pageContext.request.contextPath}/hospital/stock?action=add">+ Add New Stock</a>
                    </div>
                </div>

                <table>
                    <thead>
                    <tr>
                        <th>BLOOD GROUP</th>
                        <th>UNITS AVAILABLE</th>
                        <th>STATUS</th>
                        <th>LAST UPDATED</th>
                        <th>AVG. EXPIRY DATE</th>
                        <th>ACTIONS</th>
                    </tr>
                    </thead>
                    <tbody id="stockTableBody">
                    <c:forEach var="stock" items="${stockList}">
                        <tr class="stock-row" data-search="${stock.bloodGroupName} ${stock.fullName}">
                            <td>
                                <div class="group-cell">
                                    <c:choose>
                                        <c:when test="${stock.bloodGroupName == 'A+' || stock.bloodGroupName == 'A-'}">
                                            <span class="blood-pill blood-red">${stock.bloodGroupName}</span>
                                        </c:when>
                                        <c:when test="${stock.bloodGroupName == 'B+' || stock.bloodGroupName == 'B-'}">
                                            <span class="blood-pill blood-blue">${stock.bloodGroupName}</span>
                                        </c:when>
                                        <c:when test="${stock.bloodGroupName == 'O+' || stock.bloodGroupName == 'O-'}">
                                            <span class="blood-pill blood-teal">${stock.bloodGroupName}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="blood-pill blood-purple">${stock.bloodGroupName}</span>
                                        </c:otherwise>
                                    </c:choose>
                                    <span class="full-name">${stock.fullName}</span>
                                </div>
                            </td>
                            <td class="units-cell">
                                <div class="units-row">
                                    <strong>${stock.units}</strong>
                                    <span>units</span>
                                    <div class="progress-track">
                                        <c:choose>
                                            <c:when test="${stock.bloodGroupName == 'A+' || stock.bloodGroupName == 'A-'}">
                                                <div class="progress-fill blood-red" style="width: ${stock.units * 2 > 100 ? 100 : stock.units * 2}%;"></div>
                                            </c:when>
                                            <c:when test="${stock.bloodGroupName == 'B+' || stock.bloodGroupName == 'B-'}">
                                                <div class="progress-fill blood-blue" style="width: ${stock.units * 2 > 100 ? 100 : stock.units * 2}%;"></div>
                                            </c:when>
                                            <c:when test="${stock.bloodGroupName == 'O+' || stock.bloodGroupName == 'O-'}">
                                                <div class="progress-fill blood-teal" style="width: ${stock.units * 2 > 100 ? 100 : stock.units * 2}%;"></div>
                                            </c:when>
                                            <c:otherwise>
                                                <div class="progress-fill blood-purple" style="width: ${stock.units * 2 > 100 ? 100 : stock.units * 2}%;"></div>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${stock.status == 'Low'}">
                                        <span class="status-badge low"><span class="status-dot"></span>Low</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge normal"><span class="status-dot"></span>Normal</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td class="date-cell">${stock.lastUpdated}</td>
                            <td class="${stock.expiryWarning ? 'expiry-warning' : 'date-cell'}">${stock.expiryDate}</td>
                            <td>
                                <div class="actions">
                                    <a class="icon-btn edit" href="${pageContext.request.contextPath}/hospital/stock?action=edit&id=${stock.id}">&#9998;</a>
                                    <form method="post" action="${pageContext.request.contextPath}/hospital/stock" style="margin: 0;">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="id" value="${stock.id}">
                                        <button type="submit" class="icon-btn delete" onclick="return confirm('Delete this stock entry?');">&#128465;</button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                    <c:if test="${empty stockList}">
                        <tr>
                            <td colspan="6" class="empty-row">No blood stock entries found for this hospital yet.</td>
                        </tr>
                    </c:if>
                    </tbody>
                </table>

                <div class="table-footer">
                    <span>Showing ${stockCount} of ${stockCount} blood groups</span>
                    <div class="pagination">
                        <span class="page-arrow">&lt;</span>
                        <span class="page-chip active">1</span>
                        <span class="page-arrow">&gt;</span>
                    </div>
                </div>
            </section>
        </div>
    </main>
</div>

<script>
    (function () {
        var banner = document.getElementById('successBanner');
        if (banner) {
            setTimeout(function () {
                banner.style.display = 'none';
            }, 3000);
        }

        var searchInput = document.getElementById('stockSearch');
        if (!searchInput) {
            return;
        }

        searchInput.addEventListener('keyup', function () {
            var filter = searchInput.value.toLowerCase();
            var rows = document.querySelectorAll('.stock-row');

            rows.forEach(function (row) {
                var haystack = row.getAttribute('data-search').toLowerCase();
                row.style.display = haystack.indexOf(filter) !== -1 ? '' : 'none';
            });
        });
    })();
</script>
</body>
</html>
