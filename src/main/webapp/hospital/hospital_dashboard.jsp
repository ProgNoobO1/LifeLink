<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hospital Dashboard - LifeLink</title>
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
        }

        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
            background: #f4f5f7;
            color: var(--text-primary);
        }

        a {
            color: inherit;
            text-decoration: none;
        }

        .dashboard-shell {
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
        .summary-icon,
        .action-icon,
        .alert-icon,
        .topbar-bell,
        .profile-icon {
            display: inline-flex;
            align-items: center;
            justify-content: center;
        }

        .brand-icon {
            width: 38px;
            height: 38px;
            background: var(--red);
            border-radius: 12px;
            font-size: 18px;
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
            display: inline-flex;
            align-items: center;
            justify-content: center;
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

        .pending-badge {
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
            margin-left: 0;
            flex-shrink: 0;
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
            font-size: 18px;
        }

        .notif-wrap {
            position: relative;
        }

        .notif-btn {
            width: 42px;
            height: 42px;
            border-radius: 14px;
            border: 1px solid var(--border);
            background: #f8fafc;
            position: relative;
            color: #6b7280;
            font-size: 18px;
            cursor: pointer;
        }

        .notif-menu {
            position: absolute;
            top: calc(100% + 10px);
            right: 0;
            width: 340px;
            background: #ffffff;
            border: 1px solid var(--border);
            border-radius: 14px;
            box-shadow: 0 18px 40px rgba(16, 24, 40, 0.14);
            overflow: hidden;
            display: none;
            z-index: 20;
        }

        .notif-menu.open {
            display: block;
        }

        .notif-head {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 14px 16px;
            border-bottom: 1px solid #edf0f4;
        }

        .notif-head strong {
            font-size: 14px;
            color: #1f2937;
        }

        .mark-read-btn {
            border: none;
            background: transparent;
            color: var(--red);
            font-size: 12px;
            font-weight: 700;
            cursor: pointer;
        }

        .notif-list {
            max-height: 340px;
            overflow-y: auto;
        }

        .notif-item {
            padding: 14px 16px;
            border-bottom: 1px solid #f2f4f7;
        }

        .notif-item strong {
            display: block;
            font-size: 13px;
            color: #344054;
            margin-bottom: 4px;
        }

        .notif-item p {
            margin: 0;
            color: #667085;
            font-size: 12px;
            line-height: 1.45;
        }

        .notif-item span {
            display: block;
            margin-top: 6px;
            color: #98a2b3;
            font-size: 11px;
        }

        .notif-empty {
            padding: 20px 16px;
            color: #98a2b3;
            font-size: 13px;
            text-align: center;
        }

        .bell-badge {
            position: absolute;
            top: -8px;
            right: -8px;
            min-width: 22px;
            height: 22px;
            font-size: 11px;
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
            font-size: 18px;
        }

        .topbar-profile span {
            color: #98a2b3;
        }

        .page-body {
            padding: 28px;
        }

        .error-banner {
            background: #fef2f2;
            border: 1px solid #fecaca;
            color: #b91c1c;
            padding: 14px 16px;
            border-radius: 12px;
            margin-bottom: 20px;
        }

        .summary-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
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
            position: relative;
            overflow: hidden;
            min-height: 210px;
        }

        .summary-card::after {
            content: "";
            position: absolute;
            top: -30px;
            right: -30px;
            width: 120px;
            height: 120px;
            border-radius: 50%;
            opacity: 0.12;
        }

        .summary-card.red::after {
            background: var(--red);
        }

        .summary-card.amber::after {
            background: var(--low-amber);
        }

        .summary-card.blue::after {
            background: var(--info-blue);
        }

        .summary-head {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            margin-bottom: 18px;
        }

        .summary-icon {
            width: 48px;
            height: 48px;
            border-radius: 12px;
            font-size: 22px;
        }

        .summary-card.red .summary-icon {
            background: #fbe9e7;
            color: var(--red);
        }

        .summary-card.amber .summary-icon {
            background: #fff7e0;
            color: var(--low-amber);
        }

        .summary-card.blue .summary-icon {
            background: #e8f0fe;
            color: var(--info-blue);
        }

        .status-chip {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            border-radius: 999px;
            padding: 4px 10px;
            font-size: 12px;
            font-weight: 700;
            background: #f9fafb;
        }

        .dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            display: inline-block;
        }

        .status-chip.green {
            color: var(--success-green);
            background: #edfdf4;
        }

        .status-chip.amber {
            color: var(--low-amber);
            background: #fff8e7;
        }

        .status-chip.blue {
            color: var(--info-blue);
            background: #eff6ff;
        }

        .summary-value {
            font-size: 54px;
            line-height: 1;
            font-weight: 800;
            margin: 0 0 8px;
            color: #273449;
        }

        .summary-label {
            margin: 0;
            font-size: 14px;
            color: #94a3b8;
            font-weight: 700;
        }

        .summary-subtitle {
            margin: 6px 0 18px;
            color: #c0c6d2;
        }

        .progress-track {
            width: 100%;
            height: 6px;
            border-radius: 3px;
            background: #e5e7eb;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            border-radius: 3px;
        }

        .fill-red {
            background: var(--red);
        }

        .fill-amber {
            background: #fbbf24;
        }

        .fill-blue {
            background: #69a1f4;
        }

        .fill-teal {
            background: #2cc4b8;
        }

        .fill-purple {
            background: #b07af5;
        }

        .main-grid {
            display: grid;
            grid-template-columns: 1fr 320px;
            gap: 24px;
        }

        .section-head {
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            gap: 16px;
            margin-bottom: 18px;
        }

        .section-head h2 {
            margin: 0;
            font-size: 18px;
        }

        .section-head p {
            margin: 4px 0 0;
            color: #98a2b3;
        }

        .section-link {
            background: #fdeceb;
            color: var(--red);
            padding: 10px 14px;
            border-radius: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        .ghost-link {
            background: #ffffff;
            color: #475467;
            border: 1px solid var(--border);
            padding: 10px 14px;
            border-radius: 12px;
            font-weight: 700;
            white-space: nowrap;
        }

        table {
            width: 100%;
            border-collapse: collapse;
        }

        thead th {
            text-align: left;
            padding: 14px 16px;
            font-size: 13px;
            color: #98a2b3;
            letter-spacing: 0.04em;
            background: #f8fafc;
        }

        tbody td {
            padding: 12px 16px;
            border-top: 1px solid #f1f5f9;
            vertical-align: middle;
        }

        tbody tr:nth-child(even) {
            background: #fafafa;
        }

        .blood-pill {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            min-width: 42px;
            padding: 4px 10px;
            border-radius: 6px;
            color: #ffffff;
            font-weight: 700;
        }

        .blood-red {
            background: #c0392b;
        }

        .blood-blue {
            background: #2980b9;
        }

        .blood-teal {
            background: #16a085;
        }

        .blood-purple {
            background: #8e44ad;
        }

        .units-text {
            font-weight: 700;
            color: #475467;
        }

        .stock-progress {
            max-width: 128px;
        }

        .action-list {
            display: grid;
            gap: 14px;
        }

        .action-btn {
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 14px;
            width: 100%;
            padding: 14px 16px;
            border-radius: 14px;
            font-weight: 700;
            box-shadow: 0 6px 16px rgba(0, 0, 0, 0.08);
        }

        .action-btn.red {
            background: var(--red);
            color: #ffffff;
        }

        .action-btn.dark {
            background: #1f2937;
            color: #ffffff;
        }

        .action-btn.soft {
            background: #fdecec;
            color: var(--red);
            box-shadow: none;
        }

        .action-icon {
            width: 32px;
            height: 32px;
            border-radius: 10px;
            background: rgba(255, 255, 255, 0.16);
            flex-shrink: 0;
        }

        .action-btn.soft .action-icon {
            background: rgba(192, 57, 43, 0.12);
        }

        .action-copy {
            display: flex;
            align-items: center;
            gap: 12px;
            flex: 1;
        }

        .side-stack {
            display: grid;
            gap: 24px;
        }

        .alerts-head {
            display: flex;
            align-items: flex-start;
            gap: 12px;
            margin-bottom: 18px;
        }

        .alert-icon {
            width: 32px;
            height: 32px;
            border-radius: 10px;
            background: #fff7e0;
            color: var(--low-amber);
            flex-shrink: 0;
        }

        .alerts-head h3,
        .quick-head h3 {
            margin: 0;
            font-size: 16px;
        }

        .alerts-head p,
        .quick-head p,
        .muted {
            margin: 4px 0 0;
            color: #98a2b3;
        }

        .alert-list {
            display: grid;
            gap: 12px;
        }

        .alert-item {
            border: 1px solid #f6df9e;
            background: #fffdf5;
            border-radius: 14px;
            padding: 14px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            gap: 12px;
        }

        .alert-copy {
            display: flex;
            align-items: center;
            gap: 12px;
            min-width: 0;
        }

        .alert-copy p {
            margin: 0 0 8px;
            font-weight: 600;
            color: #344054;
        }

        .alert-mini-bar {
            width: 180px;
            max-width: 100%;
            height: 6px;
            border-radius: 3px;
            background: #f3f4f6;
            overflow: hidden;
        }

        .alert-foot {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-top: 24px;
            color: #98a2b3;
            font-size: 14px;
        }

        .caret {
            color: #98a2b3;
            font-size: 18px;
            margin-left: 4px;
        }

        @media (max-width: 900px) {
            .sidebar {
                position: static;
                width: 100%;
                min-width: 0;
            }

            .dashboard-shell {
                flex-direction: column;
            }

            .content {
                margin-left: 0;
                width: 100%;
            }

            .summary-grid {
                grid-template-columns: 1fr;
            }

            .main-grid {
                grid-template-columns: 1fr;
            }

            .topbar {
                flex-direction: column;
                align-items: flex-start;
            }
        }
    </style>
</head>
<body>
<div class="dashboard-shell">
    <aside class="sidebar">
        <div class="brand">
            <span class="brand-icon">&#128167;</span>
            <span>LifeLink</span>
        </div>

        <div class="sidebar-label">Main Menu</div>
        <nav class="nav-menu">
            <a class="nav-link active" href="${pageContext.request.contextPath}/hospital/dashboard">
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
                <h1>Hospital Dashboard</h1>
                <p>Monitor your blood stock and requests.</p>
            </div>
            <div class="topbar-right">
                <a class="ghost-link" href="${pageContext.request.contextPath}/hospital/edit-details">Edit Details</a>
                <jsp:include page="/includes/hospital_notifications.jsp" />
                <div class="topbar-profile">
                    <span class="profile-icon">&#127973;</span>
                    <div>
                        <strong>${hospitalName}</strong>
                        <span>${not empty sessionScope.email ? sessionScope.email : hospitalEmail}</span>
                    </div>
                    <span class="caret">&#9662;</span>
                </div>
            </div>
        </header>

        <div class="page-body">
            <c:if test="${not empty dashboardError}">
                <div class="error-banner">${dashboardError}</div>
            </c:if>

            <section class="summary-grid">
                <article class="card summary-card red">
                    <div class="summary-head">
                        <span class="summary-icon">&#128167;</span>
                        <span class="status-chip green"><span class="dot" style="background: var(--success-green);"></span>Stable</span>
                    </div>
                    <p class="summary-value">${totalStock}</p>
                    <p class="summary-label">Total Stock</p>
                    <p class="summary-subtitle">units available across all blood groups</p>
                    <div class="progress-track">
                        <div class="progress-fill fill-red" style="width: 64%;"></div>
                    </div>
                </article>

                <article class="card summary-card amber">
                    <div class="summary-head">
                        <span class="summary-icon">&#9888;</span>
                        <span class="status-chip amber"><span class="dot" style="background: var(--low-amber);"></span>Watch</span>
                    </div>
                    <p class="summary-value">${lowStockCount}</p>
                    <p class="summary-label">Low Stock Alerts</p>
                    <p class="summary-subtitle">blood groups need restocking soon</p>
                    <div class="progress-track">
                        <div class="progress-fill fill-amber" style="width: 20%;"></div>
                    </div>
                </article>

                <article class="card summary-card blue">
                    <div class="summary-head">
                        <span class="summary-icon">&#128339;</span>
                        <span class="status-chip blue"><span class="dot" style="background: var(--info-blue);"></span>Active</span>
                    </div>
                    <p class="summary-value">${pendingCount}</p>
                    <p class="summary-label">Pending Requests</p>
                    <p class="summary-subtitle">requests awaiting approval</p>
                    <div class="progress-track">
                        <div class="progress-fill fill-blue" style="width: 36%;"></div>
                    </div>
                </article>
            </section>

            <section class="main-grid">
                <article class="card">
                    <div class="section-head">
                        <div>
                            <h2>Stock Overview</h2>
                            <p>Current blood units by group</p>
                        </div>
                        <a class="section-link" href="${pageContext.request.contextPath}/hospital/stock">View All</a>
                    </div>

                    <table>
                        <thead>
                        <tr>
                            <th>BLOOD GROUP</th>
                            <th>UNITS AVAILABLE</th>
                            <th>STOCK LEVEL</th>
                            <th>STATUS</th>
                        </tr>
                        </thead>
                        <tbody>
                        <c:forEach var="stock" items="${stockList}">
                            <tr>
                                <td>
                                    <c:choose>
                                        <c:when test="${stock.bloodGroup == 'A+' || stock.bloodGroup == 'A-'}">
                                            <span class="blood-pill blood-red">${stock.bloodGroup}</span>
                                        </c:when>
                                        <c:when test="${stock.bloodGroup == 'B+' || stock.bloodGroup == 'B-'}">
                                            <span class="blood-pill blood-blue">${stock.bloodGroup}</span>
                                        </c:when>
                                        <c:when test="${stock.bloodGroup == 'O+' || stock.bloodGroup == 'O-'}">
                                            <span class="blood-pill blood-teal">${stock.bloodGroup}</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="blood-pill blood-purple">${stock.bloodGroup}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td class="units-text">${stock.units} units</td>
                                <td>
                                    <div class="stock-progress">
                                        <div class="progress-track">
                                            <c:choose>
                                                <c:when test="${stock.bloodGroup == 'A+' || stock.bloodGroup == 'A-'}">
                                                    <div class="progress-fill fill-red" style="width: ${stock.units * 2 > 100 ? 100 : stock.units * 2}%;"></div>
                                                </c:when>
                                                <c:when test="${stock.bloodGroup == 'B+' || stock.bloodGroup == 'B-'}">
                                                    <div class="progress-fill fill-blue" style="width: ${stock.units * 2 > 100 ? 100 : stock.units * 2}%;"></div>
                                                </c:when>
                                                <c:when test="${stock.bloodGroup == 'O+' || stock.bloodGroup == 'O-'}">
                                                    <div class="progress-fill fill-teal" style="width: ${stock.units * 2 > 100 ? 100 : stock.units * 2}%;"></div>
                                                </c:when>
                                                <c:otherwise>
                                                    <div class="progress-fill fill-purple" style="width: ${stock.units * 2 > 100 ? 100 : stock.units * 2}%;"></div>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${stock.status == 'Low'}">
                                            <span class="status-chip amber"><span class="dot" style="background: var(--low-amber);"></span>Low</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="status-chip green"><span class="dot" style="background: var(--success-green);"></span>Normal</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                            </tr>
                        </c:forEach>
                        <c:if test="${empty stockList}">
                            <tr>
                                <td colspan="4" class="muted">No stock data is available for this hospital yet.</td>
                            </tr>
                        </c:if>
                        </tbody>
                    </table>
                </article>

                <div class="side-stack">
                    <article class="card">
                        <div class="quick-head">
                            <h3>Quick Actions</h3>
                            <p>Manage your hospital stock</p>
                        </div>

                        <div class="action-list" style="margin-top: 20px;">
                            <a class="action-btn red" href="${pageContext.request.contextPath}/hospital/stock?action=add">
                                <span class="action-copy">
                                    <span class="action-icon">&#43;</span>
                                    <span>Add Stock</span>
                                </span>
                                <span>&rarr;</span>
                            </a>
                            <a class="action-btn dark" href="${pageContext.request.contextPath}/hospital/requests?action=create">
                                <span class="action-copy">
                                    <span class="action-icon">&#9998;</span>
                                    <span>Create Request</span>
                                </span>
                                <span>&rarr;</span>
                            </a>
                            <a class="action-btn soft" href="${pageContext.request.contextPath}/hospital/requests">
                                <span class="action-copy">
                                    <span class="action-icon">&#128339;</span>
                                    <span>View Pending</span>
                                </span>
                                <span class="pending-badge">${pendingCount}</span>
                            </a>
                        </div>
                    </article>

                    <article class="card">
                        <div class="alerts-head">
                            <span class="alert-icon">&#9888;</span>
                            <div>
                                <h3>Low Stock Alerts</h3>
                                <p>Requires immediate attention</p>
                            </div>
                        </div>

                        <c:choose>
                            <c:when test="${not empty alertList}">
                                <div class="alert-list">
                                    <c:forEach var="alert" items="${alertList}">
                                        <div class="alert-item">
                                            <div class="alert-copy">
                                                <c:choose>
                                                    <c:when test="${alert.bloodGroup == 'A+' || alert.bloodGroup == 'A-'}">
                                                        <span class="blood-pill blood-red">${alert.bloodGroup}</span>
                                                    </c:when>
                                                    <c:when test="${alert.bloodGroup == 'B+' || alert.bloodGroup == 'B-'}">
                                                        <span class="blood-pill blood-blue">${alert.bloodGroup}</span>
                                                    </c:when>
                                                    <c:when test="${alert.bloodGroup == 'O+' || alert.bloodGroup == 'O-'}">
                                                        <span class="blood-pill blood-teal">${alert.bloodGroup}</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="blood-pill blood-purple">${alert.bloodGroup}</span>
                                                    </c:otherwise>
                                                </c:choose>
                                                <div>
                                                    <p>Only ${alert.unitsAtAlert} units left</p>
                                                    <div class="alert-mini-bar">
                                                        <div class="progress-fill fill-amber" style="width: ${alert.unitsAtAlert * 5 > 100 ? 100 : alert.unitsAtAlert * 5}%;"></div>
                                                    </div>
                                                </div>
                                            </div>
                                            <span class="status-chip amber"><span class="dot" style="background: var(--low-amber);"></span>Low</span>
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <p class="muted">All stock levels normal</p>
                            </c:otherwise>
                        </c:choose>

                        <div class="alert-foot">
                            <span>Last updated</span>
                            <span><%= new java.util.Date() %></span>
                        </div>
                    </article>
                </div>
            </section>
        </div>
    </main>
</div>
<script>
    (function () {
        var toggle = document.getElementById('notifToggle');
        var menu = document.getElementById('notifMenu');
        if (!toggle || !menu) {
            return;
        }

        toggle.addEventListener('click', function (event) {
            event.stopPropagation();
            menu.classList.toggle('open');
        });

        document.addEventListener('click', function (event) {
            if (!menu.contains(event.target) && event.target !== toggle) {
                menu.classList.remove('open');
            }
        });
    })();
</script>
</body>
</html>
