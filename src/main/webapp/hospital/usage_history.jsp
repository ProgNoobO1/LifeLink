<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blood Usage History - LifeLink</title>
    <style>
        :root {
            --sidebar-bg: #1a0a0a;
            --sidebar-deep: #220909;
            --sidebar-active: #c0392b;
            --white: #ffffff;
            --page-bg: #f6f7fb;
            --text-primary: #253047;
            --text-muted: #98a2b3;
            --border: #e7ebf1;
            --red: #c0392b;
            --red-soft: #fdeceb;
            --purple: #a855f7;
            --purple-soft: #f5ebff;
            --amber: #f59e0b;
            --amber-soft: #fff7e0;
            --blue: #4f86f7;
            --blue-soft: #eaf1ff;
            --teal: #17b7b0;
            --teal-soft: #e8fbf8;
            --shadow: 0 1px 4px rgba(15, 23, 42, 0.08);
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: var(--page-bg);
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
            background: linear-gradient(180deg, var(--sidebar-bg) 0%, var(--sidebar-deep) 100%);
            color: #f8d7d3;
            padding: 24px 16px 18px;
            display: flex;
            flex-direction: column;
            position: fixed;
            inset: 0 auto 0 0;
        }

        .brand {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 0 12px;
            color: var(--white);
            font-size: 20px;
            font-weight: 700;
            margin-bottom: 26px;
        }

        .brand-icon,
        .nav-icon,
        .logout-icon,
        .profile-icon,
        .header-bell,
        .stat-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .brand-icon {
            width: 38px;
            height: 38px;
            border-radius: 12px;
            background: var(--red);
            color: var(--white);
            font-weight: 700;
        }

        .menu-label {
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 2px;
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
            color: #f7d8d5;
            padding: 14px 16px;
            border-radius: 14px;
            transition: background 0.2s ease;
        }

        .nav-link:hover {
            background: #2a1010;
        }

        .nav-link.active {
            background: var(--sidebar-active);
            color: var(--white);
            font-weight: 700;
            box-shadow: inset -4px 0 0 rgba(255, 255, 255, 0.8);
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
        .header-badge {
            min-width: 24px;
            height: 24px;
            padding: 0 8px;
            border-radius: 999px;
            background: var(--red);
            color: var(--white);
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
            border-top: 1px solid rgba(255, 255, 255, 0.12);
            padding: 18px 0 0;
        }

        .logout-link {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 10px 12px;
            border-radius: 12px;
            margin-bottom: 18px;
        }

        .logout-link:hover {
            background: rgba(255, 255, 255, 0.08);
        }

        .account-card {
            background: rgba(192, 57, 43, 0.2);
            border: 1px solid rgba(255, 255, 255, 0.08);
            border-radius: 14px;
            padding: 12px 14px;
            display: flex;
            align-items: center;
            gap: 12px;
            color: var(--white);
        }

        .account-card strong,
        .header-profile strong {
            display: block;
            font-size: 15px;
        }

        .account-card span,
        .header-profile span {
            display: block;
            color: #d0d5dd;
            font-size: 13px;
        }

        .content {
            margin-left: 220px;
            width: calc(100% - 220px);
        }

        .topbar {
            background: var(--white);
            border-bottom: 1px solid var(--border);
            padding: 16px 28px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 18px;
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
            color: var(--text-muted);
        }

        .topbar-right {
            display: flex;
            align-items: center;
            gap: 16px;
        }

        .header-bell {
            width: 42px;
            height: 42px;
            border-radius: 14px;
            border: 1px solid var(--border);
            background: #fafbfc;
            color: #687385;
            position: relative;
        }

        .header-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            min-width: 22px;
            height: 22px;
            font-size: 11px;
            margin-left: 0;
        }

        .header-profile {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .profile-icon {
            width: 42px;
            height: 42px;
            border-radius: 14px;
            background: var(--red);
            color: var(--white);
            font-weight: 700;
        }

        .dropdown-arrow {
            color: #98a2b3;
            font-size: 18px;
            padding-left: 4px;
        }

        .page-body {
            padding: 28px;
        }

        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 20px;
            margin-bottom: 24px;
        }

        .card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 18px;
            box-shadow: var(--shadow);
        }

        .stat-card {
            padding: 20px 18px;
            display: flex;
            align-items: center;
            gap: 14px;
        }

        .stat-icon {
            width: 48px;
            height: 48px;
            border-radius: 14px;
            font-weight: 700;
            font-size: 18px;
        }

        .icon-red {
            background: var(--red-soft);
            color: var(--red);
        }

        .icon-purple {
            background: var(--purple-soft);
            color: var(--purple);
        }

        .icon-amber {
            background: var(--amber-soft);
            color: var(--amber);
        }

        .icon-blue {
            background: var(--blue-soft);
            color: var(--blue);
        }

        .stat-number {
            margin: 0;
            font-size: 18px;
            font-weight: 800;
            color: #263248;
        }

        .stat-label {
            margin: 4px 0 0;
            color: var(--text-muted);
            font-size: 14px;
        }

        .filter-card {
            padding: 22px;
            margin-bottom: 24px;
        }

        .filter-bar {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
        }

        .filter-form {
            display: flex;
            align-items: center;
            gap: 12px;
            flex-wrap: wrap;
            flex: 1;
        }

        .search-wrap,
        .select-wrap {
            position: relative;
        }

        .search-wrap input,
        .select-wrap select {
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 14px 16px 14px 38px;
            font-size: 14px;
            outline: none;
            background: #fbfcfe;
            color: #475467;
        }

        .search-wrap input {
            min-width: 258px;
        }

        .select-wrap select {
            min-width: 162px;
            appearance: none;
            cursor: pointer;
            padding-right: 36px;
        }

        .search-wrap input:focus,
        .select-wrap select:focus {
            border-color: #cf2e2e;
            box-shadow: 0 0 0 3px rgba(207, 46, 46, 0.12);
        }

        .field-icon,
        .field-arrow {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            color: #98a2b3;
            pointer-events: none;
        }

        .field-icon {
            left: 14px;
        }

        .field-arrow {
            right: 14px;
        }

        .export-btn {
            margin-left: auto;
            background: #cf2e2e;
            color: var(--white);
            border: none;
            border-radius: 14px;
            padding: 14px 20px;
            font-size: 14px;
            font-weight: 700;
            cursor: pointer;
            box-shadow: 0 8px 18px rgba(207, 46, 46, 0.2);
        }

        .table-card {
            overflow: hidden;
        }

        .table-head {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 16px;
            padding: 18px 24px 14px;
        }

        .table-head h2 {
            margin: 0;
            font-size: 18px;
        }

        .table-head p {
            margin: 4px 0 0;
            color: var(--text-muted);
        }

        .sorted-note {
            color: var(--text-muted);
            font-size: 14px;
        }

        .table-wrap {
            overflow-x: auto;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            min-width: 1040px;
        }

        thead th {
            text-align: left;
            padding: 14px 24px;
            background: #fafbfc;
            color: #98a2b3;
            font-size: 13px;
            letter-spacing: 0.04em;
        }

        tbody tr {
            border-bottom: 1px solid var(--border);
        }

        tbody tr:hover {
            background: #fcfcfd;
        }

        tbody td {
            padding: 16px 24px;
            vertical-align: middle;
        }

        .date-main {
            display: block;
            font-size: 15px;
            font-weight: 700;
            color: #344054;
        }

        .date-sub {
            display: block;
            margin-top: 4px;
            color: var(--text-muted);
            font-size: 13px;
        }

        .blood-pill,
        .purpose-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border-radius: 999px;
            padding: 6px 12px;
            font-size: 13px;
            font-weight: 700;
            white-space: nowrap;
        }

        .blood-pill {
            color: var(--white);
            min-width: 44px;
            justify-content: center;
            border-radius: 10px;
        }

        .bg-a-pos { background: #c62828; }
        .bg-b-pos { background: #3f7ded; }
        .bg-o-pos { background: #9f1f1f; }
        .bg-ab-pos { background: #9750e6; }
        .bg-a-neg { background: #f08c2e; }
        .bg-b-neg { background: #16a6a1; }
        .bg-o-neg { background: #7b4b32; }
        .bg-ab-neg { background: #7d8596; }

        .purpose-surgery {
            background: var(--purple-soft);
            color: var(--purple);
        }

        .purpose-emergency {
            background: var(--amber-soft);
            color: #d97706;
        }

        .purpose-transfer {
            background: var(--blue-soft);
            color: var(--blue);
        }

        .units-cell strong {
            font-size: 15px;
            color: #344054;
        }

        .units-cell span {
            color: var(--text-muted);
            margin-left: 4px;
            font-size: 14px;
        }

        .recipient {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .avatar {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background: linear-gradient(135deg, #fbd3d3 0%, #f0f4ff 100%);
            color: #344054;
            font-weight: 700;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 12px;
            flex-shrink: 0;
        }

        .recipient-name {
            font-weight: 700;
            color: #344054;
        }

        .pending-text {
            color: var(--text-muted);
        }

        .empty-state {
            text-align: center;
            color: var(--text-muted);
            padding: 30px 24px;
        }

        .table-footer {
            padding: 16px 24px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 16px;
            color: var(--text-muted);
        }

        .pagination {
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .page-link,
        .page-current,
        .page-dots {
            min-width: 34px;
            height: 34px;
            border-radius: 12px;
            display: inline-flex;
            align-items: center;
            justify-content: center;
            font-size: 14px;
        }

        .page-link {
            border: 1px solid var(--border);
            background: var(--white);
            color: var(--text-muted);
        }

        .page-current {
            background: #cf2e2e;
            color: var(--white);
            font-weight: 700;
        }

        .page-dots {
            color: var(--text-muted);
        }

        @media (max-width: 900px) {
            .layout {
                flex-direction: column;
            }

            .sidebar {
                position: static;
                width: 100%;
                min-width: 0;
            }

            .content {
                margin-left: 0;
                width: 100%;
            }

            .topbar,
            .table-head,
            .table-footer {
                flex-direction: column;
                align-items: flex-start;
            }

            .stats-grid {
                grid-template-columns: repeat(2, 1fr);
            }

            .filter-form {
                width: 100%;
            }

            .export-btn {
                margin-left: 0;
            }
        }

        @media (max-width: 600px) {
            .stats-grid {
                grid-template-columns: 1fr;
            }

            .search-wrap input,
            .select-wrap select {
                width: 100%;
                min-width: 0;
            }

            .filter-form {
                flex-direction: column;
                align-items: stretch;
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

        <div class="menu-label">Main Menu</div>
        <nav class="nav-menu">
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/dashboard">
                <span class="nav-icon">&#9673;</span>
                <span>Dashboard</span>
            </a>
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/stock">
                <span class="nav-icon">&#128230;</span>
                <span>Manage Stock</span>
            </a>
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/requests">
                <span class="nav-icon">&#128196;</span>
                <span>Requests</span>
                <span class="nav-badge">${pendingCount}</span>
            </a>
            <a class="nav-link active" href="${pageContext.request.contextPath}/hospital/usage">
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

            <div class="account-card">
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
                <h1>Blood Usage History</h1>
                <p>Track all blood usage events and recipients.</p>
            </div>

            <div class="topbar-right">
                <jsp:include page="/includes/hospital_notifications.jsp" />
                <div class="header-profile">
                    <span class="profile-icon">&#127973;</span>
                    <div>
                        <strong>${hospitalName}</strong>
                        <span>${hospitalEmail}</span>
                    </div>
                    <span class="dropdown-arrow">&#9662;</span>
                </div>
            </div>
        </header>

        <div class="page-body">
            <section class="stats-grid">
                <article class="card stat-card">
                    <span class="stat-icon icon-red">&#128167;</span>
                    <div>
                        <p class="stat-number">${stats.totalUnits}</p>
                        <p class="stat-label">Total Units Used</p>
                    </div>
                </article>
                <article class="card stat-card">
                    <span class="stat-icon icon-purple">&#9675;</span>
                    <div>
                        <p class="stat-number">${stats.surgeryCount}</p>
                        <p class="stat-label">Surgery</p>
                    </div>
                </article>
                <article class="card stat-card">
                    <span class="stat-icon icon-amber">&#9889;</span>
                    <div>
                        <p class="stat-number">${stats.emergencyCount}</p>
                        <p class="stat-label">Emergency</p>
                    </div>
                </article>
                <article class="card stat-card">
                    <span class="stat-icon icon-blue">&#8646;</span>
                    <div>
                        <p class="stat-number">${stats.transferCount}</p>
                        <p class="stat-label">Transfer</p>
                    </div>
                </article>
            </section>

            <section class="card filter-card">
                <div class="filter-bar">
                    <form id="filterForm" class="filter-form" method="get" action="${pageContext.request.contextPath}/hospital/usage">
                        <input type="hidden" name="page" value="1">
                        <div class="search-wrap">
                            <span class="field-icon">&#8981;</span>
                            <input type="text" id="clientSearch" name="search" value="${param.search}" placeholder="Search recipient or blood group...">
                        </div>
                        <div class="select-wrap">
                            <span class="field-icon">&#9662;</span>
                            <select name="filter" onchange="document.getElementById('filterForm').submit()">
                                <option value="all" ${selectedFilter == 'all' ? 'selected' : ''}>All Purposes</option>
                                <option value="verified" ${selectedFilter == 'verified' ? 'selected' : ''}>Verified</option>
                                <option value="unverified" ${selectedFilter == 'unverified' ? 'selected' : ''}>Unverified</option>
                                <option value="with_request" ${selectedFilter == 'with_request' ? 'selected' : ''}>With Request</option>
                                <option value="without_request" ${selectedFilter == 'without_request' ? 'selected' : ''}>Without Request</option>
                            </select>
                            <span class="field-arrow">&#9662;</span>
                        </div>
                        <div class="select-wrap">
                            <span class="field-icon">&#128197;</span>
                            <select name="dateRange" onchange="document.getElementById('filterForm').submit()">
                                <option value="this_month" ${selectedDateRange == 'this_month' ? 'selected' : ''}>This Month</option>
                                <option value="last_month" ${selectedDateRange == 'last_month' ? 'selected' : ''}>Last Month</option>
                                <option value="last_3_months" ${selectedDateRange == 'last_3_months' ? 'selected' : ''}>Last 3 Months</option>
                                <option value="last_6_months" ${selectedDateRange == 'last_6_months' ? 'selected' : ''}>Last 6 Months</option>
                                <option value="this_year" ${selectedDateRange == 'this_year' ? 'selected' : ''}>This Year</option>
                                <option value="all_time" ${selectedDateRange == 'all_time' ? 'selected' : ''}>All Time</option>
                            </select>
                            <span class="field-arrow">&#9662;</span>
                        </div>
                    </form>

                    <button type="button" class="export-btn" id="exportCsvBtn">Export CSV</button>
                </div>
            </section>

            <section class="card table-card">
                <div class="table-head">
                    <div>
                        <h2>Usage Records</h2>
                        <p>Showing ${endRecord} of ${totalCount} records</p>
                    </div>
                    <div class="sorted-note">Sorted by latest date</div>
                </div>

                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>DATE</th>
                            <th>BLOOD GROUP</th>
                            <th>UNITS</th>
                            <th>PURPOSE</th>
                            <th>RECIPIENT NAME</th>
                            <th>PROCESSED BY</th>
                        </tr>
                        </thead>
                        <tbody id="usageTableBody">
                        <c:forEach var="record" items="${records}">
                            <tr class="usage-row" data-search="${record.searchText}">
                                <td>
                                    <span class="date-main">${record.donatedAt}</span>
                                    <span class="date-sub">${record.donatedAtSubtext}</span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${record.bloodGroup == 'A+'}"><span class="blood-pill bg-a-pos">${record.bloodGroup}</span></c:when>
                                        <c:when test="${record.bloodGroup == 'B+'}"><span class="blood-pill bg-b-pos">${record.bloodGroup}</span></c:when>
                                        <c:when test="${record.bloodGroup == 'O+'}"><span class="blood-pill bg-o-pos">${record.bloodGroup}</span></c:when>
                                        <c:when test="${record.bloodGroup == 'AB+'}"><span class="blood-pill bg-ab-pos">${record.bloodGroup}</span></c:when>
                                        <c:when test="${record.bloodGroup == 'A-'}"><span class="blood-pill bg-a-neg">${record.bloodGroup}</span></c:when>
                                        <c:when test="${record.bloodGroup == 'B-'}"><span class="blood-pill bg-b-neg">${record.bloodGroup}</span></c:when>
                                        <c:when test="${record.bloodGroup == 'O-'}"><span class="blood-pill bg-o-neg">${record.bloodGroup}</span></c:when>
                                        <c:otherwise><span class="blood-pill bg-ab-neg">${record.bloodGroup}</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="units-cell">
                                    <strong>${record.units}</strong>
                                    <span>${record.unitLabel}</span>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${record.purpose == 'Surgery'}"><span class="purpose-pill purpose-surgery">&#9675; Surgery</span></c:when>
                                        <c:when test="${record.purpose == 'Transfer'}"><span class="purpose-pill purpose-transfer">&#8646; Transfer</span></c:when>
                                        <c:otherwise><span class="purpose-pill purpose-emergency">&#9889; Emergency</span></c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <div class="recipient">
                                        <span class="avatar">${record.recipientInitials}</span>
                                        <span class="recipient-name">${record.recipientName}</span>
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${record.verified}">
                                            ${record.processedBy}
                                        </c:when>
                                        <c:otherwise>
                                            <span class="pending-text">${record.processedBy}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty records}">
                            <tr>
                                <td colspan="6" class="empty-state">No usage records match the current filters.</td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </div>

                <div class="table-footer">
                    <span>Showing ${startRecord}-${endRecord} of ${totalCount} records</span>
                    <div class="pagination">
                        <c:if test="${currentPage > 1}">
                            <a class="page-link" href="${pageContext.request.contextPath}/hospital/usage?page=${currentPage - 1}&filter=${selectedFilter}&dateRange=${selectedDateRange}&search=${param.search}">&lt;</a>
                        </c:if>
                        <c:if test="${currentPage <= 1}">
                            <span class="page-link">&lt;</span>
                        </c:if>

                        <c:forEach begin="1" end="${totalPages}" var="pageNo">
                            <c:if test="${pageNo <= 3 || pageNo == currentPage || pageNo == totalPages}">
                                <c:choose>
                                    <c:when test="${pageNo == currentPage}">
                                        <span class="page-current">${pageNo}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="page-link" href="${pageContext.request.contextPath}/hospital/usage?page=${pageNo}&filter=${selectedFilter}&dateRange=${selectedDateRange}&search=${param.search}">${pageNo}</a>
                                    </c:otherwise>
                                </c:choose>
                            </c:if>
                            <c:if test="${pageNo == 4 && totalPages > 5 && currentPage < totalPages - 1}">
                                <span class="page-dots">...</span>
                            </c:if>
                        </c:forEach>

                        <c:if test="${currentPage < totalPages}">
                            <a class="page-link" href="${pageContext.request.contextPath}/hospital/usage?page=${currentPage + 1}&filter=${selectedFilter}&dateRange=${selectedDateRange}&search=${param.search}">&gt;</a>
                        </c:if>
                        <c:if test="${currentPage >= totalPages}">
                            <span class="page-link">&gt;</span>
                        </c:if>
                    </div>
                </div>
            </section>
        </div>
    </main>
</div>

<script>
    (function () {
        var searchInput = document.getElementById('clientSearch');
        var rows = document.querySelectorAll('.usage-row');
        var exportButton = document.getElementById('exportCsvBtn');

        function filterRows() {
            var term = searchInput.value.toLowerCase().trim();
            rows.forEach(function (row) {
                var haystack = row.getAttribute('data-search') || '';
                row.style.display = haystack.indexOf(term) !== -1 ? '' : 'none';
            });
        }

        if (searchInput) {
            searchInput.addEventListener('keyup', filterRows);
            filterRows();
        }

        if (exportButton) {
            exportButton.addEventListener('click', function () {
                var params = new URLSearchParams(window.location.search);
                params.set('export', 'csv');
                params.set('filter', '${selectedFilter}');
                params.set('dateRange', '${selectedDateRange}');
                params.set('search', searchInput ? searchInput.value : '');
                window.location.href = '${pageContext.request.contextPath}/hospital/usage?' + params.toString();
            });
        }
    })();
</script>
</body>
</html>
