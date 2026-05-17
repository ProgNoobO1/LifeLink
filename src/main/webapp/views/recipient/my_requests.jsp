<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lifelink.dao.RequestDAO" %>
<%@ page import="com.lifelink.model.User" %>
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.util.Map" %>
<%!
    private String esc(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }

    private int count(Map<String, Integer> counts, String key) {
        return counts != null && counts.get(key) != null ? counts.get(key) : 0;
    }

    private String bloodClass(String bloodGroup) {
        if (bloodGroup == null) return "bg-unknown";
        String normalized = bloodGroup.toUpperCase(Locale.ROOT);
        if ("A+".equals(normalized)) return "bg-a-pos";
        if ("A-".equals(normalized)) return "bg-a-neg";
        if ("B+".equals(normalized)) return "bg-b-pos";
        if ("B-".equals(normalized)) return "bg-b-neg";
        if ("AB+".equals(normalized)) return "bg-ab-pos";
        if ("AB-".equals(normalized)) return "bg-ab-neg";
        if ("O+".equals(normalized)) return "bg-o-pos";
        if ("O-".equals(normalized)) return "bg-o-neg";
        return "bg-unknown";
    }

    private String statusClass(String status) {
        if ("pending".equals(status)) return "status-pending";
        if ("fulfilled".equals(status)) return "status-fulfilled";
        if ("cancelled".equals(status)) return "status-cancelled";
        return "status-cancelled";
    }

    private String displayStatus(String status) {
        if ("pending".equals(status)) return "Pending";
        if ("fulfilled".equals(status)) return "Fulfilled";
        if ("cancelled".equals(status)) return "Cancelled";
        return status == null || status.isEmpty() ? "Unknown" : status.substring(0, 1).toUpperCase(Locale.ROOT) + status.substring(1);
    }
%>
<%
    User currentUser = (User) request.getAttribute("currentUser");
    if (currentUser == null) {
        currentUser = (User) session.getAttribute("currentUser");
    }
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    if (currentUser.getRole() != User.Role.RECIPIENT) {
        response.sendRedirect(request.getContextPath() + "/403");
        return;
    }

    List<RequestDAO.RequestListItem> requests =
        (List<RequestDAO.RequestListItem>) request.getAttribute("requests");
    if (requests == null) {
        requests = Collections.emptyList();
    }
    Map<String, Integer> requestCounts = (Map<String, Integer>) request.getAttribute("requestCounts");

    String csrfToken = (String) session.getAttribute("csrfToken");
    if (csrfToken == null) {
        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        csrfToken = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute("csrfToken", csrfToken);
    }

    String fullName = currentUser.getFullName() != null ? currentUser.getFullName() : "Recipient";
    String email = currentUser.getEmail() != null ? currentUser.getEmail() : "";
    String initials = currentUser.getInitials();
    String flashSuccess = (String) session.getAttribute("requestSuccess");
    String flashError = (String) session.getAttribute("requestError");
    session.removeAttribute("requestSuccess");
    session.removeAttribute("requestError");
    SimpleDateFormat dateFmt = new SimpleDateFormat("MMM dd, yyyy");
    SimpleDateFormat titleFmt = new SimpleDateFormat("MMM dd, yyyy h:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Blood Requests | LifeLink</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { min-height: 100vh; background: #f6f7f9; color: #1f2937; font-family: 'Inter', sans-serif; }
        button { font: inherit; }
        .main-content { min-height: 100vh; margin-left: 210px; }
        .topbar { position: sticky; top: 0; z-index: 50; display: flex; align-items: center; justify-content: space-between; gap: 1rem; min-height: 78px; padding: 1.05rem 2rem; background: #fff; border-bottom: 1px solid #eceff3; }
        .topbar-left { display: flex; align-items: center; gap: .85rem; }
        .hamburger { display: none; border: 0; background: transparent; color: #4b5563; cursor: pointer; padding: .35rem; }
        .hamburger svg { width: 24px; height: 24px; fill: currentColor; }
        .page-title h1 { font-size: 1.25rem; line-height: 1.2; font-weight: 800; color: #1f2937; }
        .page-title p { margin-top: .35rem; font-size: .78rem; color: #98a2b3; }
        .topbar-right { display: flex; align-items: center; gap: .95rem; }
        .bell { position: relative; width: 40px; height: 40px; border: 1px solid #e5e7eb; border-radius: 12px; background: #fff; color: #6b7280; display: grid; place-items: center; }
        .bell svg { width: 19px; height: 19px; fill: currentColor; }
        .bell-count { position: absolute; top: -5px; right: -4px; min-width: 16px; height: 16px; border-radius: 999px; background: #c91c20; color: #fff; font-size: .62rem; font-weight: 800; line-height: 16px; text-align: center; }
        .top-user { display: flex; align-items: center; gap: .7rem; min-width: 0; }
        .avatar { width: 38px; height: 38px; border-radius: 999px; background: linear-gradient(135deg, #b91c1c, #ef4444); color: #fff; display: grid; place-items: center; font-weight: 800; font-size: .78rem; border: 2px solid #f4d0d0; }
        .top-user strong { display: block; font-size: .84rem; color: #344054; }
        .top-user span { display: block; font-size: .74rem; color: #98a2b3; }
        .chevron { width: 18px; height: 18px; fill: #98a2b3; }
        .page-body { padding: 2.1rem 2.1rem 3rem; }
        .content-shell { max-width: 1120px; margin: 0 auto; display: grid; gap: 1.5rem; }
        .flash { padding: .85rem 1rem; border-radius: 12px; font-size: .84rem; font-weight: 700; border: 1px solid transparent; }
        .flash.success { background: #ecfdf3; color: #047857; border-color: #bbf7d0; }
        .flash.error { background: #fef2f2; color: #b42318; border-color: #fecaca; }
        .stats-grid { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 1.3rem; }
        .stat-card { display: flex; align-items: center; gap: 1rem; min-height: 92px; padding: 1.25rem 1.35rem; background: #fff; border: 1px solid #edf0f4; border-radius: 16px; box-shadow: 0 1px 3px rgba(16,24,40,.04); }
        .stat-icon { width: 48px; height: 48px; border-radius: 12px; display: grid; place-items: center; flex-shrink: 0; }
        .stat-icon svg { width: 20px; height: 20px; fill: currentColor; }
        .stat-icon.total { background: #fee2e2; color: #c91c20; }
        .stat-icon.pending { background: #fffbeb; color: #f59e0b; }
        .stat-icon.fulfilled { background: #ecfdf3; color: #22c55e; }
        .stat-icon.cancelled { background: #f0f2f5; color: #98a2b3; }
        .stat-value { font-size: 1.55rem; line-height: 1; font-weight: 800; color: #1f2937; }
        .stat-label { margin-top: .45rem; color: #8b95a5; font-size: .8rem; }
        .requests-card { overflow: hidden; background: #fff; border: 1px solid #edf0f4; border-radius: 16px; box-shadow: 0 1px 3px rgba(16,24,40,.04); }
        .requests-header { display: flex; align-items: center; justify-content: space-between; gap: 1rem; padding: 1.85rem 1.45rem 1.2rem; }
        .requests-header h2 { font-size: 1rem; font-weight: 800; color: #1f2937; }
        .requests-header p { margin-top: .35rem; color: #98a2b3; font-size: .78rem; }
        .header-actions { display: flex; align-items: center; gap: .75rem; }
        .tabs { display: inline-flex; align-items: center; gap: .15rem; padding: .25rem; border-radius: 11px; background: #f1f3f6; }
        .tab { border: 0; border-radius: 9px; padding: .52rem .8rem; background: transparent; color: #667085; font-size: .74rem; font-weight: 800; cursor: pointer; }
        .tab.active { background: #c91c20; color: #fff; box-shadow: 0 4px 10px rgba(185,28,28,.16); }
        .new-btn { display: inline-flex; align-items: center; justify-content: center; gap: .45rem; height: 36px; padding: 0 1rem; border-radius: 11px; background: #c91c20; color: #fff; text-decoration: none; font-size: .78rem; font-weight: 800; box-shadow: 0 8px 14px rgba(185,28,28,.2); white-space: nowrap; }
        .new-btn svg { width: 15px; height: 15px; fill: currentColor; }
        .table-wrap { overflow-x: auto; border-top: 1px solid #eef1f5; }
        table { width: 100%; min-width: 900px; border-collapse: collapse; }
        th { text-align: left; padding: 1.05rem 1.45rem; background: #f7f8fa; color: #98a2b3; font-size: .72rem; font-weight: 800; letter-spacing: .04em; text-transform: uppercase; }
        td { padding: 1rem 1.45rem; border-top: 1px solid #f0f2f5; color: #344054; font-size: .88rem; vertical-align: middle; }
        tr.is-hidden { display: none; }
        .request-id { color: #c91c20; font-weight: 800; letter-spacing: .01em; }
        .blood-badge { display: inline-grid; place-items: center; min-width: 41px; min-height: 41px; padding: .45rem .58rem; border-radius: 12px; color: #fff; font-size: .88rem; font-weight: 800; }
        .bg-a-pos { background: #c91c20; }
        .bg-a-neg { background: #991b1b; }
        .bg-b-pos { background: #ea580c; }
        .bg-b-neg { background: #b91c1c; }
        .bg-ab-pos { background: #7c3aed; }
        .bg-ab-neg { background: #5b21b6; }
        .bg-o-pos { background: #be123c; }
        .bg-o-neg { background: #881337; }
        .bg-unknown { background: #e5e7eb; color: #667085; }
        .units { display: inline-flex; align-items: center; gap: .55rem; font-weight: 800; }
        .unit-icon { width: 24px; height: 24px; border-radius: 8px; display: grid; place-items: center; background: #fee2e2; color: #c91c20; }
        .unit-icon.muted { background: #eef1f5; color: #98a2b3; }
        .unit-icon svg { width: 13px; height: 13px; fill: currentColor; }
        .date-main { color: #475467; font-weight: 600; }
        .date-sub { margin-top: .25rem; color: #98a2b3; font-size: .78rem; }
        .status-badge { display: inline-flex; align-items: center; gap: .42rem; padding: .42rem .76rem; border-radius: 999px; font-size: .76rem; font-weight: 800; border: 1px solid transparent; }
        .status-badge::before { content: ""; width: 7px; height: 7px; border-radius: 999px; }
        .status-pending { color: #d97706; background: #fffbeb; border-color: #fde68a; }
        .status-pending::before { background: #f59e0b; }
        .status-fulfilled { color: #22c55e; background: #ecfdf3; border-color: #bbf7d0; }
        .status-fulfilled::before { background: #22c55e; }
        .status-cancelled { color: #667085; background: #f5f6f8; border-color: #e5e7eb; }
        .status-cancelled::before { background: #98a2b3; }
        .actions { display: flex; align-items: center; gap: .5rem; }
        .action-btn { display: inline-flex; align-items: center; justify-content: center; gap: .38rem; height: 30px; border: 0; border-radius: 8px; padding: 0 .75rem; font-size: .76rem; font-weight: 800; cursor: pointer; }
        .view-btn { color: #c91c20; background: #fee2e2; }
        .cancel-btn { color: #667085; background: #f1f3f6; border: 1px solid #e5e7eb; }
        .cancel-btn:disabled { opacity: .42; cursor: not-allowed; }
        .action-btn svg { width: 14px; height: 14px; fill: currentColor; }
        .empty-state { padding: 3rem 1rem; text-align: center; color: #98a2b3; }
        .empty-state svg { width: 54px; height: 54px; fill: #d7dce3; margin-bottom: .75rem; }
        .empty-state strong { display: block; margin-bottom: .25rem; color: #475467; }
        .table-footer { display: flex; align-items: center; justify-content: space-between; gap: 1rem; padding: 1rem 1.45rem; background: #fafbfc; border-top: 1px solid #eef1f5; }
        .showing { color: #8b95a5; font-size: .78rem; }
        .pager { display: flex; align-items: center; gap: .55rem; }
        .pager button { width: 32px; height: 32px; border-radius: 8px; border: 1px solid #dce2ea; background: #fff; color: #98a2b3; cursor: pointer; display: grid; place-items: center; }
        .pager button:disabled { opacity: .45; cursor: not-allowed; }
        .pager svg { width: 17px; height: 17px; fill: currentColor; }
        .page-number { width: 32px; height: 32px; border-radius: 9px; display: grid; place-items: center; background: #c91c20; color: #fff; font-size: .82rem; font-weight: 800; }
        .help-card { display: flex; align-items: center; justify-content: space-between; gap: 1rem; padding: 1.15rem 1.25rem; background: #fff; border: 1px solid #edf0f4; border-radius: 16px; box-shadow: 0 1px 3px rgba(16,24,40,.04); }
        .help-copy { display: flex; align-items: center; gap: 1rem; min-width: 0; }
        .help-icon { width: 41px; height: 41px; border-radius: 12px; background: #fee2e2; color: #c91c20; display: grid; place-items: center; flex-shrink: 0; }
        .help-icon svg { width: 16px; height: 16px; fill: currentColor; }
        .help-copy strong { display: block; color: #344054; font-size: .88rem; margin-bottom: .28rem; }
        .help-copy p { color: #98a2b3; font-size: .78rem; }
        .help-copy b { color: #d97706; }
        @media (max-width: 1024px) {
            .main-content { margin-left: 0; }
            .hamburger { display: inline-grid; place-items: center; }
            .stats-grid { grid-template-columns: repeat(2, minmax(0, 1fr)); }
        }
        @media (max-width: 760px) {
            .topbar { align-items: flex-start; padding: 1rem; }
            .top-user div:not(.avatar) { display: none; }
            .chevron { display: none; }
            .page-body { padding: 1rem; }
            .requests-header { align-items: flex-start; flex-direction: column; padding: 1.2rem; }
            .header-actions { width: 100%; align-items: stretch; flex-direction: column; }
            .tabs { justify-content: space-between; }
            .tab { flex: 1; padding-left: .35rem; padding-right: .35rem; }
            .new-btn { width: 100%; }
            .help-card { align-items: stretch; flex-direction: column; }
            .help-card .new-btn { width: 100%; }
        }
        @media (max-width: 600px) {
            .stats-grid { grid-template-columns: 1fr; }
            .table-footer { align-items: flex-start; flex-direction: column; }
            .pager { align-self: flex-end; }
        }
    </style>
</head>
<body>
<jsp:include page="/includes/recipient_sidebar.jsp" />

<main class="main-content">
    <header class="topbar">
        <div class="topbar-left">
            <button class="hamburger" type="button" onclick="toggleSidebar()" aria-label="Open menu">
                <svg viewBox="0 0 24 24"><path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"/></svg>
            </button>
            <div class="page-title">
                <h1>My Blood Requests</h1>
                <p>Manage and track all your blood requests</p>
            </div>
        </div>
        <div class="topbar-right">
            <button class="bell" type="button" title="Notifications">
                <svg viewBox="0 0 24 24"><path d="M12 22a2.5 2.5 0 0 0 2.45-2h-4.9A2.5 2.5 0 0 0 12 22Zm7-6v-5a7 7 0 0 0-5-6.71V3a2 2 0 1 0-4 0v1.29A7 7 0 0 0 5 11v5l-2 2v1h18v-1l-2-2Z"/></svg>
                <span class="bell-count">1</span>
            </button>
            <div class="top-user">
                <div class="avatar"><%= esc(initials) %></div>
                <div>
                    <strong><%= esc(fullName) %></strong>
                    <span><%= esc(email) %></span>
                </div>
                <svg class="chevron" viewBox="0 0 24 24"><path d="M7.41 8.59 12 13.17l4.59-4.58L18 10l-6 6-6-6z"/></svg>
            </div>
        </div>
    </header>

    <section class="page-body">
        <div class="content-shell">
            <% if (flashSuccess != null) { %>
                <div class="flash success"><%= esc(flashSuccess) %></div>
            <% } %>
            <% if (flashError != null) { %>
                <div class="flash error"><%= esc(flashError) %></div>
            <% } %>
            <% if (request.getAttribute("requestListError") != null) { %>
                <div class="flash error"><%= esc(request.getAttribute("requestListError")) %></div>
            <% } %>

            <section class="stats-grid" aria-label="Request summary">
                <article class="stat-card">
                    <div class="stat-icon total"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6Zm-1 7V3.5L18.5 9H13Zm1 5h3v2h-3v3h-2v-3H9v-2h3v-3h2v3Z"/></svg></div>
                    <div><div class="stat-value"><%= count(requestCounts, "total") %></div><div class="stat-label">Total Requests</div></div>
                </article>
                <article class="stat-card">
                    <div class="stat-icon pending"><svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm1 11h4v2h-6V7h2v6Z"/></svg></div>
                    <div><div class="stat-value"><%= count(requestCounts, "pending") %></div><div class="stat-label">Pending</div></div>
                </article>
                <article class="stat-card">
                    <div class="stat-icon fulfilled"><svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm-1.2 14.2-4-4L8.2 10.8l2.6 2.6 5-5 1.4 1.4-6.4 6.4Z"/></svg></div>
                    <div><div class="stat-value"><%= count(requestCounts, "fulfilled") %></div><div class="stat-label">Fulfilled</div></div>
                </article>
                <article class="stat-card">
                    <div class="stat-icon cancelled"><svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 .01 0H12Zm3.54 12.12-1.42 1.42L12 13.41l-2.12 2.13-1.42-1.42L10.59 12 8.46 9.88l1.42-1.42L12 10.59l2.12-2.13 1.42 1.42L13.41 12l2.13 2.12Z"/></svg></div>
                    <div><div class="stat-value"><%= count(requestCounts, "cancelled") %></div><div class="stat-label">Cancelled</div></div>
                </article>
            </section>

            <section class="requests-card">
                <div class="requests-header">
                    <div>
                        <h2>All Requests</h2>
                        <p>Your complete blood request history</p>
                    </div>
                    <div class="header-actions">
                        <div class="tabs" role="tablist" aria-label="Filter requests">
                            <button class="tab active" type="button" data-filter="all">All</button>
                            <button class="tab" type="button" data-filter="pending">Pending</button>
                            <button class="tab" type="button" data-filter="fulfilled">Fulfilled</button>
                            <button class="tab" type="button" data-filter="cancelled">Cancelled</button>
                        </div>
                        <a class="new-btn" href="${pageContext.request.contextPath}/views/recipient/create_request.jsp">
                            <svg viewBox="0 0 24 24"><path d="M19 11h-6V5h-2v6H5v2h6v6h2v-6h6z"/></svg>
                            New Request
                        </a>
                    </div>
                </div>

                <div class="table-wrap">
                    <table>
                        <thead>
                        <tr>
                            <th>Request ID</th>
                            <th>Blood Group</th>
                            <th>Units</th>
                            <th>Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                        </thead>
                        <tbody id="requestRows">
                        <% for (RequestDAO.RequestListItem item : requests) {
                            String displayStatus = item.getDisplayStatus();
                            Timestamp requestedAt = item.getRequestedAt();
                            String dateText = requestedAt != null ? dateFmt.format(requestedAt) : "N/A";
                            String titleText = requestedAt != null ? titleFmt.format(requestedAt) : "";
                            long millis = requestedAt != null ? requestedAt.getTime() : 0L;
                            boolean canCancel = "pending".equals(item.getStatus());
                        %>
                        <tr data-status="<%= esc(displayStatus) %>" data-time="<%= millis %>">
                            <td><span class="request-id">#REQ-<%= String.format("%03d", item.getId()) %></span></td>
                            <td><span class="blood-badge <%= bloodClass(item.getBloodGroup()) %>"><%= esc(item.getBloodGroup()) %></span></td>
                            <td>
                                <span class="units">
                                    <span class="unit-icon <%= "cancelled".equals(displayStatus) ? "muted" : "" %>"><svg viewBox="0 0 24 24"><path d="M12 2S5 9.67 5 15a7 7 0 0 0 14 0C19 9.67 12 2 12 2Z"/></svg></span>
                                    <%= item.getUnitsNeeded() %> <%= item.getUnitsNeeded() == 1 ? "unit" : "units" %>
                                </span>
                            </td>
                            <td>
                                <div class="date-main" title="<%= esc(titleText) %>"><%= esc(dateText) %></div>
                                <div class="date-sub js-relative">Calculating...</div>
                            </td>
                            <td><span class="status-badge <%= statusClass(displayStatus) %>"><%= displayStatus(displayStatus) %></span></td>
                            <td>
                                <div class="actions">
                                    <button class="action-btn view-btn" type="button" data-request-id="#REQ-<%= String.format("%03d", item.getId()) %>">
                                        <svg viewBox="0 0 24 24"><path d="M12 5c5 0 9 4.5 10 7-1 2.5-5 7-10 7S3 14.5 2 12c1-2.5 5-7 10-7Zm0 2C8.7 7 5.9 9.4 4.4 12 5.9 14.6 8.7 17 12 17s6.1-2.4 7.6-5C18.1 9.4 15.3 7 12 7Zm0 2.2A2.8 2.8 0 1 1 12 14.8a2.8 2.8 0 0 1 0-5.6Z"/></svg>
                                        View
                                    </button>
                                    <form method="post" action="${pageContext.request.contextPath}/recipient/requests">
                                        <input type="hidden" name="csrfToken" value="<%= esc(csrfToken) %>">
                                        <input type="hidden" name="action" value="cancel">
                                        <input type="hidden" name="requestId" value="<%= item.getId() %>">
                                        <button class="action-btn cancel-btn" type="submit" <%= canCancel ? "" : "disabled" %>>
                                            <svg viewBox="0 0 24 24"><path d="m18.3 5.71-1.41-1.42L12 9.17 7.11 4.29 5.7 5.71 10.59 10.6 5.7 15.49l1.41 1.41L12 12.01l4.89 4.89 1.41-1.41-4.89-4.89 4.89-4.89Z"/></svg>
                                            Cancel
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                    <div class="empty-state" id="emptyState" hidden>
                        <svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6Zm-1 7V3.5L18.5 9H13Z"/></svg>
                        <strong>No requests found</strong>
                        <span>Try another filter or create a new blood request.</span>
                    </div>
                </div>

                <div class="table-footer">
                    <div class="showing" id="showingText">Showing 0 of 0 requests</div>
                    <div class="pager" aria-label="Pagination">
                        <button type="button" id="prevPage" aria-label="Previous page"><svg viewBox="0 0 24 24"><path d="m15.41 7.41-1.41-1.41L8 12l6 6 1.41-1.41L10.83 12z"/></svg></button>
                        <span class="page-number" id="pageNumber">1</span>
                        <button type="button" id="nextPage" aria-label="Next page"><svg viewBox="0 0 24 24"><path d="m8.59 16.59 1.41 1.41 6-6-6-6-1.41 1.41L13.17 12z"/></svg></button>
                    </div>
                </div>
            </section>

            <section class="help-card">
                <div class="help-copy">
                    <div class="help-icon"><svg viewBox="0 0 24 24"><path d="M11 17h2v-6h-2v6Zm1-14a9 9 0 1 0 0 18 9 9 0 0 0 0-18Zm0 16a7 7 0 1 1 0-14 7 7 0 0 1 0 14Zm-1-10h2V7h-2v2Z"/></svg></div>
                    <div>
                        <strong>Need help with a request?</strong>
                        <p>Only <b>Pending</b> requests can be cancelled. Fulfilled or cancelled requests are read-only.</p>
                    </div>
                </div>
                <a class="new-btn" href="${pageContext.request.contextPath}/views/recipient/create_request.jsp">
                    <svg viewBox="0 0 24 24"><path d="M19 11h-6V5h-2v6H5v2h6v6h2v-6h6z"/></svg>
                    New Request
                </a>
            </section>
        </div>
    </section>
</main>

<script>
const pageSize = 5;
let currentFilter = 'all';
let currentPage = 1;
const rows = Array.from(document.querySelectorAll('#requestRows tr'));
const tabs = Array.from(document.querySelectorAll('.tab'));
const emptyState = document.getElementById('emptyState');
const showingText = document.getElementById('showingText');
const pageNumber = document.getElementById('pageNumber');
const prevPage = document.getElementById('prevPage');
const nextPage = document.getElementById('nextPage');

function relativeTime(time) {
    if (!time) return '';
    const seconds = Math.max(1, Math.floor((Date.now() - time) / 1000));
    const units = [
        ['year', 31536000],
        ['month', 2592000],
        ['day', 86400],
        ['hour', 3600],
        ['minute', 60]
    ];
    for (const [label, value] of units) {
        const amount = Math.floor(seconds / value);
        if (amount >= 1) return amount + ' ' + label + (amount === 1 ? '' : 's') + ' ago';
    }
    return 'just now';
}

function matchingRows() {
    return rows.filter(row => currentFilter === 'all' || row.dataset.status === currentFilter);
}

function render() {
    const matches = matchingRows();
    const totalPages = Math.max(1, Math.ceil(matches.length / pageSize));
    currentPage = Math.min(currentPage, totalPages);
    const start = (currentPage - 1) * pageSize;
    const visible = matches.slice(start, start + pageSize);

    rows.forEach(row => row.classList.add('is-hidden'));
    visible.forEach(row => row.classList.remove('is-hidden'));

    emptyState.hidden = matches.length !== 0;
    pageNumber.textContent = String(currentPage);
    prevPage.disabled = currentPage <= 1;
    nextPage.disabled = currentPage >= totalPages;
    const shown = matches.length === 0 ? 0 : visible.length;
    showingText.textContent = 'Showing ' + shown + ' of ' + matches.length + ' requests';
}

document.querySelectorAll('.js-relative').forEach(el => {
    const row = el.closest('tr');
    el.textContent = relativeTime(Number(row.dataset.time));
});

tabs.forEach(tab => {
    tab.addEventListener('click', () => {
        tabs.forEach(item => item.classList.remove('active'));
        tab.classList.add('active');
        currentFilter = tab.dataset.filter;
        currentPage = 1;
        render();
    });
});

prevPage.addEventListener('click', () => {
    currentPage -= 1;
    render();
});

nextPage.addEventListener('click', () => {
    currentPage += 1;
    render();
});

document.querySelectorAll('.view-btn').forEach(button => {
    button.addEventListener('click', () => {
        alert(button.dataset.requestId + ' detail page will be available in the request-detail branch.');
    });
});

document.querySelectorAll('.cancel-btn:not(:disabled)').forEach(button => {
    button.addEventListener('click', event => {
        if (!confirm('Cancel this pending blood request?')) {
            event.preventDefault();
        }
    });
});

render();
</script>
</body>
</html>
