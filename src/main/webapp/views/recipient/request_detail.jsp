<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lifelink.dao.NotificationDAO" %>
<%@ page import="com.lifelink.dao.RequestDetailDAO" %>
<%@ page import="com.lifelink.model.User" %>
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Locale" %>
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

    private String reqId(long id) {
        return "#REQ-" + String.format("%03d", id);
    }

    private String displayStatus(String status) {
        if ("accepted".equals(status)) return "Accepted";
        if ("completed".equals(status)) return "Completed";
        if ("rejected".equals(status)) return "Rejected";
        if ("cancelled".equals(status)) return "Cancelled";
        return "Pending";
    }

    private String displayUrgency(String urgency) {
        if ("critical".equals(urgency)) return "Critical";
        if ("urgent".equals(urgency)) return "Urgent";
        return "Normal";
    }

    private String bloodClass(String bloodGroup) {
        if (bloodGroup == null) return "bg-unknown";
        String bg = bloodGroup.toUpperCase(Locale.ROOT);
        if ("A+".equals(bg)) return "bg-a-pos";
        if ("A-".equals(bg)) return "bg-a-neg";
        if ("B+".equals(bg)) return "bg-b-pos";
        if ("B-".equals(bg)) return "bg-b-neg";
        if ("AB+".equals(bg)) return "bg-ab-pos";
        if ("AB-".equals(bg)) return "bg-ab-neg";
        if ("O+".equals(bg)) return "bg-o-pos";
        if ("O-".equals(bg)) return "bg-o-neg";
        return "bg-unknown";
    }

    private String compatibleTypes(String bloodGroup) {
        if ("A+".equals(bloodGroup)) return "Compatible with A+, AB+";
        if ("A-".equals(bloodGroup)) return "Compatible with A+, A-, AB+, AB-";
        if ("B+".equals(bloodGroup)) return "Compatible with B+, AB+";
        if ("B-".equals(bloodGroup)) return "Compatible with B+, B-, AB+, AB-";
        if ("AB+".equals(bloodGroup)) return "Compatible with AB+";
        if ("AB-".equals(bloodGroup)) return "Compatible with AB+, AB-";
        if ("O+".equals(bloodGroup)) return "Compatible with O+, A+, B+, AB+";
        if ("O-".equals(bloodGroup)) return "Compatible with all blood groups";
        return "Compatibility unavailable";
    }
%>
<%
    User currentUser = (User) request.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    if (currentUser.getRole() != User.Role.RECIPIENT) {
        response.sendRedirect(request.getContextPath() + "/403");
        return;
    }

    RequestDetailDAO.RequestDetail detail = (RequestDetailDAO.RequestDetail) request.getAttribute("requestDetail");
    if (detail == null) {
        response.sendRedirect(request.getContextPath() + "/recipient/requests");
        return;
    }

    List<RequestDetailDAO.MatchedResponder> matchedResponders =
        (List<RequestDetailDAO.MatchedResponder>) request.getAttribute("matchedResponders");
    if (matchedResponders == null) matchedResponders = Collections.emptyList();

    List<NotificationDAO.NotificationItem> recentNotifications =
        (List<NotificationDAO.NotificationItem>) request.getAttribute("recentNotifications");
    if (recentNotifications == null) recentNotifications = Collections.emptyList();
    Integer unreadCount = (Integer) request.getAttribute("unreadNotificationCount");
    if (unreadCount == null) unreadCount = 0;

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
    String status = detail.getStatus();
    String statusDisplay = displayStatus(status);
    String urgencyDisplay = displayUrgency(detail.getUrgency());
    Timestamp requestedAt = detail.getRequestedAt();
    Timestamp completedAt = detail.getCompletedAt();
    SimpleDateFormat dateFmt = new SimpleDateFormat("MMMM d, yyyy");
    SimpleDateFormat dateTimeFmt = new SimpleDateFormat("MMM d, yyyy h:mm a");
    DateTimeFormatter notifFmt = DateTimeFormatter.ofPattern("MMM d, h:mm a");
    String requestedDate = requestedAt != null ? dateFmt.format(requestedAt) : "N/A";
    String requestedDateTime = requestedAt != null ? dateTimeFmt.format(requestedAt) : "N/A";
    String completedDateTime = completedAt != null ? dateTimeFmt.format(completedAt) : "";
    String flashSuccess = (String) session.getAttribute("requestSuccess");
    String flashError = (String) session.getAttribute("requestError");
    session.removeAttribute("requestSuccess");
    session.removeAttribute("requestError");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Request Details | LifeLink</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { min-height: 100vh; background: #f6f7f9; color: #1f2937; font-family: 'Inter', sans-serif; }
        button { font: inherit; }
        .main-content { min-height: 100vh; margin-left: 210px; }
        .topbar { position: sticky; top: 0; z-index: 60; display: flex; align-items: center; justify-content: space-between; gap: 1rem; min-height: 78px; padding: 1rem 2rem; background: #fff; border-bottom: 1px solid #eceff3; }
        .topbar-left { display: flex; align-items: center; gap: .85rem; }
        .title-icon { width: 38px; height: 38px; border-radius: 12px; background: #fee2e2; color: #c91c20; display: grid; place-items: center; }
        .title-icon svg { width: 18px; height: 18px; fill: currentColor; }
        .page-title h1 { font-size: 1.25rem; line-height: 1.2; font-weight: 800; color: #1f2937; }
        .page-title p { margin-top: .35rem; font-size: .78rem; color: #98a2b3; }
        .hamburger { display: none; border: 0; background: transparent; color: #4b5563; cursor: pointer; padding: .35rem; }
        .hamburger svg { width: 24px; height: 24px; fill: currentColor; }
        .topbar-right { display: flex; align-items: center; gap: .95rem; }
        .bell-wrap { position: relative; }
        .bell { position: relative; width: 40px; height: 40px; border: 1px solid #e5e7eb; border-radius: 12px; background: #fff; color: #6b7280; display: grid; place-items: center; cursor: pointer; }
        .bell svg { width: 19px; height: 19px; fill: currentColor; }
        .bell-count { position: absolute; top: -5px; right: -4px; min-width: 16px; height: 16px; border-radius: 999px; background: #c91c20; color: #fff; font-size: .62rem; font-weight: 800; line-height: 16px; text-align: center; }
        .notif-menu { position: absolute; top: calc(100% + .55rem); right: 0; width: 330px; display: none; background: #fff; border: 1px solid #edf0f4; border-radius: 14px; box-shadow: 0 18px 40px rgba(16,24,40,.14); overflow: hidden; z-index: 90; }
        .notif-menu.open { display: block; }
        .notif-head { display: flex; align-items: center; justify-content: space-between; gap: .75rem; padding: .9rem 1rem; border-bottom: 1px solid #edf0f4; }
        .notif-head strong { font-size: .88rem; }
        .mark-read { border: 0; background: transparent; color: #c91c20; font-size: .72rem; font-weight: 800; cursor: pointer; }
        .notif-item { padding: .85rem 1rem; border-bottom: 1px solid #f2f4f7; }
        .notif-item strong { display: block; color: #344054; font-size: .8rem; margin-bottom: .22rem; }
        .notif-item p { color: #667085; font-size: .74rem; line-height: 1.35; }
        .notif-item span { display: block; margin-top: .35rem; color: #98a2b3; font-size: .7rem; }
        .notif-empty { padding: 1.3rem; color: #98a2b3; font-size: .8rem; text-align: center; }
        .top-user { display: flex; align-items: center; gap: .7rem; min-width: 0; }
        .avatar { width: 38px; height: 38px; border-radius: 999px; background: linear-gradient(135deg, #b91c1c, #ef4444); color: #fff; display: grid; place-items: center; font-weight: 800; font-size: .78rem; border: 2px solid #f4d0d0; }
        .top-user strong { display: block; font-size: .84rem; color: #344054; }
        .top-user span { display: block; font-size: .74rem; color: #98a2b3; }
        .chevron { width: 18px; height: 18px; fill: #98a2b3; }
        .page-body { padding: 2rem 2rem 3rem; }
        .shell { max-width: 1120px; margin: 0 auto; display: grid; gap: 1.5rem; }
        .breadcrumb { display: flex; align-items: center; gap: .6rem; color: #98a2b3; font-size: .78rem; font-weight: 700; }
        .breadcrumb a { color: #98a2b3; text-decoration: none; }
        .breadcrumb strong { color: #c91c20; }
        .flash { padding: .85rem 1rem; border-radius: 12px; font-size: .84rem; font-weight: 700; border: 1px solid transparent; }
        .flash.success { background: #ecfdf3; color: #047857; border-color: #bbf7d0; }
        .flash.error { background: #fef2f2; color: #b42318; border-color: #fecaca; }
        .status-banner { display: flex; align-items: center; justify-content: space-between; gap: 1rem; padding: 1.15rem 1.45rem; border-radius: 15px; border: 1px solid #fde68a; background: #fffbeb; }
        .status-banner.accepted { background: #ecfdf3; border-color: #bbf7d0; }
        .status-banner.rejected { background: #fef2f2; border-color: #fecaca; }
        .status-banner.completed { background: #f0fdfa; border-color: #99f6e4; }
        .banner-left { display: flex; align-items: center; gap: 1rem; }
        .banner-icon { width: 36px; height: 36px; border-radius: 11px; display: grid; place-items: center; background: #fbbf24; color: #fff; flex-shrink: 0; }
        .accepted .banner-icon { background: #22c55e; }
        .rejected .banner-icon { background: #ef4444; }
        .completed .banner-icon { background: #14b8a6; }
        .banner-icon svg { width: 17px; height: 17px; fill: currentColor; }
        .banner-title { color: #b45309; font-weight: 800; font-size: .9rem; }
        .accepted .banner-title { color: #047857; }
        .rejected .banner-title { color: #b42318; }
        .completed .banner-title { color: #0f766e; }
        .banner-copy { margin-top: .25rem; color: #d97706; font-size: .78rem; }
        .accepted .banner-copy { color: #059669; }
        .rejected .banner-copy { color: #dc2626; }
        .completed .banner-copy { color: #0d9488; }
        .status-pill { display: inline-flex; align-items: center; gap: .45rem; padding: .45rem .85rem; border-radius: 999px; font-size: .78rem; font-weight: 800; border: 1px solid #fde68a; background: #fffbeb; color: #d97706; white-space: nowrap; }
        .status-pill::before { content: ""; width: 7px; height: 7px; border-radius: 999px; background: currentColor; }
        .accepted .status-pill { background: #ecfdf3; border-color: #bbf7d0; color: #059669; }
        .rejected .status-pill { background: #fef2f2; border-color: #fecaca; color: #dc2626; }
        .completed .status-pill { background: #f0fdfa; border-color: #99f6e4; color: #0d9488; }
        .detail-layout { display: grid; grid-template-columns: minmax(0, 1fr) 356px; gap: 1.5rem; align-items: start; }
        .left-stack, .right-stack { display: grid; gap: 1.5rem; }
        .card { background: #fff; border: 1px solid #edf0f4; border-radius: 16px; box-shadow: 0 1px 3px rgba(16,24,40,.04); overflow: hidden; }
        .card-head { display: flex; align-items: center; justify-content: space-between; gap: 1rem; padding: 1.35rem 1.45rem; border-bottom: 1px solid #edf0f4; }
        .card-title { display: flex; align-items: center; gap: .8rem; font-size: 1rem; font-weight: 800; color: #1f2937; }
        .small-icon { width: 32px; height: 32px; border-radius: 9px; display: grid; place-items: center; background: #fee2e2; color: #c91c20; }
        .small-icon.green { background: #ecfdf3; color: #22c55e; }
        .small-icon svg { width: 15px; height: 15px; fill: currentColor; }
        .id-badge { padding: .45rem .75rem; background: #fee2e2; color: #c91c20; border-radius: 9px; font-size: .78rem; font-weight: 800; }
        .info-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1.35rem; padding: 1.55rem 1.45rem; }
        .info-box { min-height: 96px; padding: 1rem; border: 1px solid #edf0f4; border-radius: 12px; background: #fafbfc; }
        .info-box.blood { background: #fee2e2; border-color: #fecaca; }
        .info-box.full { grid-column: 1 / -1; min-height: 100px; }
        .info-label { display: flex; align-items: center; gap: .45rem; color: #98a2b3; font-size: .72rem; letter-spacing: .06em; text-transform: uppercase; font-weight: 800; margin-bottom: .65rem; }
        .info-label svg { width: 14px; height: 14px; fill: currentColor; }
        .info-value { color: #1f2937; font-weight: 800; font-size: .95rem; }
        .info-sub { margin-top: .35rem; color: #98a2b3; font-size: .78rem; line-height: 1.45; }
        .blood-row { display: flex; align-items: center; gap: .8rem; }
        .blood-badge { display: inline-grid; place-items: center; min-width: 42px; height: 42px; border-radius: 12px; color: #fff; font-weight: 800; box-shadow: 0 8px 14px rgba(185,28,28,.18); }
        .bg-a-pos { background: #c91c20; }
        .bg-a-neg { background: #991b1b; }
        .bg-b-pos { background: #ea580c; }
        .bg-b-neg { background: #b91c1c; }
        .bg-ab-pos { background: #7c3aed; }
        .bg-ab-neg { background: #5b21b6; }
        .bg-o-pos { background: #be123c; }
        .bg-o-neg { background: #881337; }
        .bg-unknown { background: #e5e7eb; color: #667085; }
        .unit-row { display: flex; align-items: center; gap: .6rem; }
        .unit-blocks { display: inline-flex; gap: .28rem; }
        .unit-block { width: 20px; height: 29px; border-radius: 5px; background: #c94a50; }
        .urgency-badge { display: inline-flex; align-items: center; gap: .45rem; padding: .45rem .75rem; border-radius: 999px; font-size: .78rem; font-weight: 800; }
        .urgency-badge::before { content: "!"; display: grid; place-items: center; width: 14px; height: 14px; border-radius: 999px; background: currentColor; color: #fff; font-size: .62rem; }
        .urgency-critical { background: #fef2f2; color: #dc2626; border: 1px solid #fecaca; }
        .urgency-urgent { background: #fffbeb; color: #d97706; border: 1px solid #fde68a; }
        .urgency-normal { background: #ecfdf3; color: #059669; border: 1px solid #bbf7d0; }
        .side-card { padding: 1.35rem 1.25rem; background: #fff; border: 1px solid #edf0f4; border-radius: 16px; box-shadow: 0 1px 3px rgba(16,24,40,.04); }
        .side-card h2 { font-size: .92rem; font-weight: 800; color: #1f2937; margin-bottom: 1.05rem; }
        .actions-panel { display: grid; gap: .75rem; }
        .action-main, .action-secondary { width: 100%; height: 44px; border: 0; border-radius: 11px; display: inline-flex; align-items: center; justify-content: center; gap: .55rem; font-weight: 800; text-decoration: none; cursor: pointer; }
        .action-main { background: #c91c20; color: #fff; box-shadow: 0 8px 15px rgba(185,28,28,.2); }
        .action-secondary { background: #f2f4f7; color: #475467; border: 1px solid #dce2ea; }
        .action-main.teal { background: #0d9488; box-shadow: 0 8px 15px rgba(13,148,136,.2); }
        .action-main svg, .action-secondary svg { width: 16px; height: 16px; fill: currentColor; }
        .warning { display: flex; gap: .5rem; margin-top: 1rem; padding-top: 1rem; border-top: 1px solid #edf0f4; color: #98a2b3; font-size: .78rem; line-height: 1.45; }
        .timeline { display: grid; gap: 0; }
        .timeline-item { display: grid; grid-template-columns: 32px 1fr; gap: .8rem; position: relative; min-height: 68px; }
        .timeline-item:not(:last-child)::before { content: ""; position: absolute; left: 15px; top: 32px; bottom: 0; width: 2px; background: #f1c7c7; }
        .timeline-dot { width: 32px; height: 32px; border-radius: 999px; display: grid; place-items: center; background: #c91c20; color: #fff; z-index: 1; }
        .timeline-dot.pending { background: #fbbf24; }
        .timeline-dot.future { background: #eef1f5; color: #c0c7d1; border: 2px solid #dce2ea; }
        .timeline-dot svg { width: 15px; height: 15px; fill: currentColor; }
        .timeline-title { color: #344054; font-size: .82rem; font-weight: 800; }
        .timeline-time { margin-top: .25rem; color: #98a2b3; font-size: .76rem; }
        .donor-head-sub { color: #98a2b3; font-size: .78rem; font-weight: 500; margin-top: .25rem; }
        .matched-pill { display: inline-flex; align-items: center; gap: .45rem; padding: .42rem .8rem; border-radius: 999px; background: #ecfdf3; color: #22c55e; font-size: .78rem; font-weight: 800; }
        .matched-pill::before { content: ""; width: 7px; height: 7px; border-radius: 999px; background: currentColor; }
        .donor-list { display: grid; gap: .75rem; padding: 1.45rem; }
        .donor-row { display: flex; align-items: center; justify-content: space-between; gap: 1rem; padding: 1rem; border: 1px solid #edf0f4; border-radius: 12px; background: #fafbfc; }
        .donor-left { display: flex; align-items: center; gap: .9rem; min-width: 0; }
        .donor-avatar { width: 40px; height: 40px; border-radius: 11px; display: grid; place-items: center; color: #fff; font-size: .82rem; font-weight: 800; background: linear-gradient(135deg, #c91c20, #f97316); flex-shrink: 0; }
        .donor-name { display: flex; align-items: center; gap: .55rem; color: #1f2937; font-size: .9rem; font-weight: 800; }
        .avail { padding: .2rem .55rem; border-radius: 999px; background: #ecfdf3; color: #16a34a; font-size: .7rem; font-weight: 800; }
        .avail.busy { background: #fffbeb; color: #d97706; }
        .donor-meta { display: flex; flex-wrap: wrap; gap: .75rem; margin-top: .35rem; color: #98a2b3; font-size: .74rem; }
        .donor-actions { display: flex; gap: .55rem; }
        .icon-btn { width: 34px; height: 34px; border: 0; border-radius: 9px; display: grid; place-items: center; background: #fee2e2; color: #c91c20; cursor: pointer; }
        .icon-btn.disabled { background: #f1f3f6; color: #c0c7d1; cursor: not-allowed; }
        .icon-btn svg { width: 15px; height: 15px; fill: currentColor; }
        .empty { padding: 2rem 1rem; text-align: center; color: #98a2b3; font-size: .85rem; }
        .summary-list { display: grid; gap: .85rem; }
        .summary-row { display: flex; align-items: center; justify-content: space-between; gap: .75rem; color: #98a2b3; font-size: .8rem; }
        .summary-row strong { color: #344054; text-align: right; }
        .summary-row .red { color: #c91c20; }
        .summary-row .green { color: #16a34a; }
        @media (max-width: 1024px) {
            .main-content { margin-left: 0; }
            .hamburger { display: inline-grid; place-items: center; }
            .detail-layout { grid-template-columns: 1fr; }
        }
        @media (max-width: 760px) {
            .topbar { align-items: flex-start; padding: 1rem; }
            .top-user div:not(.avatar), .chevron { display: none; }
            .page-body { padding: 1rem; }
            .status-banner, .requests-header { align-items: flex-start; flex-direction: column; }
            .info-grid { grid-template-columns: 1fr; padding: 1.1rem; }
            .info-box.full { grid-column: auto; }
            .donor-row { align-items: flex-start; flex-direction: column; }
            .donor-actions { align-self: flex-end; }
            .notif-menu { right: -4.5rem; width: min(330px, calc(100vw - 2rem)); }
        }
        @media (max-width: 600px) {
            .card-head { align-items: flex-start; flex-direction: column; }
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
            <div class="title-icon"><svg viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8l-6-6Zm0 12h3v2h-3v3h-2v-3H9v-2h3v-3h2v3Z"/></svg></div>
            <div class="page-title">
                <h1>Request Details</h1>
                <p>Viewing request <%= reqId(detail.getId()) %></p>
            </div>
        </div>
        <div class="topbar-right">
            <div class="bell-wrap">
                <button class="bell" type="button" id="bellButton" title="Notifications">
                    <svg viewBox="0 0 24 24"><path d="M12 22a2.5 2.5 0 0 0 2.45-2h-4.9A2.5 2.5 0 0 0 12 22Zm7-6v-5a7 7 0 0 0-5-6.71V3a2 2 0 1 0-4 0v1.29A7 7 0 0 0 5 11v5l-2 2v1h18v-1l-2-2Z"/></svg>
                    <% if (unreadCount > 0) { %><span class="bell-count"><%= unreadCount > 99 ? "99+" : unreadCount %></span><% } %>
                </button>
                <div class="notif-menu" id="notifMenu">
                    <div class="notif-head">
                        <strong>Notifications</strong>
                        <form method="post" action="${pageContext.request.contextPath}/recipient/request-detail">
                            <input type="hidden" name="csrfToken" value="<%= esc(csrfToken) %>">
                            <input type="hidden" name="action" value="markNotificationsRead">
                            <input type="hidden" name="requestId" value="<%= detail.getId() %>">
                            <button class="mark-read" type="submit">Mark all as read</button>
                        </form>
                    </div>
                    <% if (recentNotifications.isEmpty()) { %>
                        <div class="notif-empty">No notifications yet</div>
                    <% } else { %>
                        <% for (NotificationDAO.NotificationItem item : recentNotifications) {
                            long notifMillis = item.getCreatedAt() != null
                                ? item.getCreatedAt().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
                                : 0L;
                            String notifTime = item.getCreatedAt() != null ? notifFmt.format(item.getCreatedAt()) : "";
                        %>
                        <div class="notif-item" data-time="<%= notifMillis %>">
                            <strong><%= esc(item.getSubject()) %></strong>
                            <p><%= esc(item.getBody()) %></p>
                            <span class="js-relative" title="<%= esc(notifTime) %>">Just now</span>
                        </div>
                        <% } %>
                    <% } %>
                </div>
            </div>
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
        <div class="shell">
            <nav class="breadcrumb">
                <a href="${pageContext.request.contextPath}/recipient/dashboard">Dashboard</a>
                <span>&gt;</span>
                <a href="${pageContext.request.contextPath}/recipient/requests">My Requests</a>
                <span>&gt;</span>
                <strong><%= reqId(detail.getId()) %></strong>
            </nav>

            <% if (flashSuccess != null) { %><div class="flash success"><%= esc(flashSuccess) %></div><% } %>
            <% if (flashError != null) { %><div class="flash error"><%= esc(flashError) %></div><% } %>

            <section class="status-banner <%= esc(status) %>">
                <div class="banner-left">
                    <div class="banner-icon"><svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm1 11h4v2h-6V7h2v6Z"/></svg></div>
                    <div>
                        <div class="banner-title">Request is <%= esc(statusDisplay) %></div>
                        <div class="banner-copy">This request was submitted <span class="js-relative" data-time="<%= requestedAt != null ? requestedAt.getTime() : 0 %>">recently</span>.</div>
                    </div>
                </div>
                <span class="status-pill"><%= esc(statusDisplay) %></span>
            </section>

            <div class="detail-layout">
                <div class="left-stack">
                    <section class="card">
                        <div class="card-head">
                            <h2 class="card-title"><span class="small-icon"><svg viewBox="0 0 24 24"><path d="M11 17h2v-6h-2v6Zm1-14a9 9 0 1 0 0 18 9 9 0 0 0 0-18Z"/></svg></span>Request Information</h2>
                            <span class="id-badge"><%= reqId(detail.getId()) %></span>
                        </div>
                        <div class="info-grid">
                            <div class="info-box">
                                <div class="info-label"><svg viewBox="0 0 24 24"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm0 2c-4.42 0-8 2.24-8 5v1h16v-1c0-2.76-3.58-5-8-5Z"/></svg>Patient Name</div>
                                <div class="info-value"><%= esc(detail.getPatientName()) %></div>
                                <div class="info-sub">Primary recipient</div>
                            </div>
                            <div class="info-box blood">
                                <div class="info-label" style="color:#c91c20;"><svg viewBox="0 0 24 24"><path d="M12 2S5 9.67 5 15a7 7 0 0 0 14 0C19 9.67 12 2 12 2Z"/></svg>Blood Group</div>
                                <div class="blood-row">
                                    <span class="blood-badge <%= bloodClass(detail.getBloodGroup()) %>"><%= esc(detail.getBloodGroup()) %></span>
                                    <div>
                                        <div class="info-value"><%= esc(detail.getBloodGroup()) %></div>
                                        <div class="info-sub" style="color:#ef4444;"><%= esc(compatibleTypes(detail.getBloodGroup())) %></div>
                                    </div>
                                </div>
                            </div>
                            <div class="info-box">
                                <div class="info-label"><svg viewBox="0 0 24 24"><path d="M7 20h10v-2H7v2Zm12-14h-4.18C14.4 4.84 13.3 4 12 4s-2.4.84-2.82 2H5v12h14V6Z"/></svg>Units Required</div>
                                <div class="unit-row">
                                    <span class="unit-blocks">
                                        <% for (int i = 0; i < Math.min(detail.getUnitsNeeded(), 6); i++) { %><span class="unit-block"></span><% } %>
                                    </span>
                                    <div><div class="info-value"><%= detail.getUnitsNeeded() %> <%= detail.getUnitsNeeded() == 1 ? "Unit" : "Units" %></div><div class="info-sub">~450ml each</div></div>
                                </div>
                            </div>
                            <div class="info-box">
                                <div class="info-label"><svg viewBox="0 0 24 24"><path d="M19 3H5v18h14V3Zm-8 16H7v-4h4v4Zm6 0h-4v-4h4v4ZM9 5h6v2H9V5Z"/></svg>Hospital</div>
                                <div class="info-value"><%= esc(detail.getHospitalName()) %></div>
                                <div class="info-sub">Ward/location not provided</div>
                            </div>
                            <div class="info-box">
                                <div class="info-label"><svg viewBox="0 0 24 24"><path d="M1 21h22L12 2 1 21Zm12-3h-2v-2h2v2Zm0-4h-2v-4h2v4Z"/></svg>Urgency Level</div>
                                <span class="urgency-badge urgency-<%= esc(detail.getUrgency()) %>"><%= esc(urgencyDisplay) %></span>
                            </div>
                            <div class="info-box">
                                <div class="info-label"><svg viewBox="0 0 24 24"><path d="M7 2v2H5a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6a2 2 0 0 0-2-2h-2V2h-2v2H9V2H7Z"/></svg>Submitted On</div>
                                <div class="info-value"><%= esc(requestedDate) %></div>
                                <div class="info-sub"><span class="js-relative" data-time="<%= requestedAt != null ? requestedAt.getTime() : 0 %>">recently</span> &middot; <%= esc(requestedDateTime) %></div>
                            </div>
                            <div class="info-box full">
                                <div class="info-label"><svg viewBox="0 0 24 24"><path d="M4 4h16v12H5.17L4 17.17V4Zm0-2a2 2 0 0 0-2 2v18l4-4h14a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2H4Z"/></svg>Additional Notes</div>
                                <div class="info-sub" style="font-size:.9rem;color:#475467;"><%= esc(detail.getAdditionalNotes()) %></div>
                            </div>
                        </div>
                    </section>

                    <section class="card">
                        <div class="card-head">
                            <div>
                                <h2 class="card-title"><span class="small-icon green"><svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5s-3 1.34-3 3 1.34 3 3 3ZM8 11c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5 5 6.34 5 8s1.34 3 3 3Zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5C15 14.17 10.33 13 8 13Zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5Z"/></svg></span>Matched Donors</h2>
                                <div class="donor-head-sub"><%= matchedResponders.size() %> responders matched for this request</div>
                            </div>
                            <span class="matched-pill"><%= matchedResponders.size() %> Matched</span>
                        </div>
                        <div class="donor-list">
                            <% if (matchedResponders.isEmpty()) { %>
                                <div class="empty">No accepted donor or hospital responses yet.</div>
                            <% } else { %>
                                <% for (RequestDetailDAO.MatchedResponder responder : matchedResponders) {
                                    String responderName = responder.getFullName() != null && !responder.getFullName().trim().isEmpty() ? responder.getFullName() : "Responder";
                                    String[] parts = responderName.trim().split("\\s+");
                                    String responderInitials = parts.length > 1
                                        ? (parts[0].substring(0,1) + parts[parts.length - 1].substring(0,1)).toUpperCase(Locale.ROOT)
                                        : responderName.substring(0, Math.min(2, responderName.length())).toUpperCase(Locale.ROOT);
                                %>
                                <div class="donor-row">
                                    <div class="donor-left">
                                        <div class="donor-avatar"><%= esc(responderInitials) %></div>
                                        <div>
                                            <div class="donor-name"><%= esc(responderName) %><span class="avail <%= responder.isAvailable() ? "" : "busy" %>"><%= responder.isAvailable() ? "Available" : "Busy" %></span></div>
                                            <div class="donor-meta">
                                                <span><%= esc(responder.getBloodGroup() != null ? responder.getBloodGroup() : detail.getBloodGroup()) %></span>
                                                <span><%= esc(responder.getResponderType()) %></span>
                                                <span><%= responder.getUnitsProvided() %> unit<%= responder.getUnitsProvided() == 1 ? "" : "s" %> offered</span>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="donor-actions">
                                        <button class="icon-btn <%= responder.getPhone() == null || responder.getPhone().trim().isEmpty() ? "disabled" : "" %>" type="button" title="<%= esc(responder.getPhone() != null ? responder.getPhone() : "Phone unavailable") %>"><svg viewBox="0 0 24 24"><path d="M6.62 10.79a15.1 15.1 0 0 0 6.59 6.59l2.2-2.2a1 1 0 0 1 1.01-.24 11.36 11.36 0 0 0 3.58.57 1 1 0 0 1 1 1V20a1 1 0 0 1-1 1A17 17 0 0 1 3 4a1 1 0 0 1 1-1h3.5a1 1 0 0 1 1 1 11.36 11.36 0 0 0 .57 3.58 1 1 0 0 1-.24 1.01l-2.21 2.2Z"/></svg></button>
                                        <button class="icon-btn" type="button" title="Message"><svg viewBox="0 0 24 24"><path d="M4 4h16v12H5.17L4 17.17V4Zm0-2a2 2 0 0 0-2 2v18l4-4h14a2 2 0 0 0 2-2V4a2 2 0 0 0-2-2H4Z"/></svg></button>
                                    </div>
                                </div>
                                <% } %>
                            <% } %>
                        </div>
                    </section>
                </div>

                <aside class="right-stack">
                    <section class="side-card">
                        <h2>Actions</h2>
                        <div class="actions-panel">
                            <% if ("pending".equals(status)) { %>
                            <form method="post" action="${pageContext.request.contextPath}/recipient/request-detail">
                                <input type="hidden" name="csrfToken" value="<%= esc(csrfToken) %>">
                                <input type="hidden" name="action" value="cancel">
                                <input type="hidden" name="returnTo" value="detail">
                                <input type="hidden" name="requestId" value="<%= detail.getId() %>">
                                <button class="action-main" type="submit">
                                    <svg viewBox="0 0 24 24"><path d="m18.3 5.71-1.41-1.42L12 9.17 7.11 4.29 5.7 5.71 10.59 10.6 5.7 15.49l1.41 1.41L12 12.01l4.89 4.89 1.41-1.41-4.89-4.89 4.89-4.89Z"/></svg>
                                    Cancel Request
                                </button>
                            </form>
                            <% } else if ("accepted".equals(status)) { %>
                            <form method="post" action="${pageContext.request.contextPath}/recipient/request-detail">
                                <input type="hidden" name="csrfToken" value="<%= esc(csrfToken) %>">
                                <input type="hidden" name="action" value="complete">
                                <input type="hidden" name="requestId" value="<%= detail.getId() %>">
                                <button class="action-main teal" type="submit">Mark as Completed</button>
                            </form>
                            <% } %>
                            <a class="action-secondary" href="${pageContext.request.contextPath}/recipient/requests">
                                <svg viewBox="0 0 24 24"><path d="m20 11H7.83l5.59-5.59L12 4l-8 8 8 8 1.42-1.41L7.83 13H20v-2Z"/></svg>
                                Back to List
                            </a>
                        </div>
                        <div class="warning">Cancelling will remove this request and notify matched donors.</div>
                    </section>

                    <section class="side-card">
                        <h2>Request Timeline</h2>
                        <div class="timeline">
                            <div class="timeline-item">
                                <div class="timeline-dot"><svg viewBox="0 0 24 24"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2Z"/></svg></div>
                                <div><div class="timeline-title">Request Submitted</div><div class="timeline-time"><%= esc(requestedDateTime) %></div></div>
                            </div>
                            <div class="timeline-item">
                                <div class="timeline-dot <%= matchedResponders.isEmpty() ? "future" : "" %>"><svg viewBox="0 0 24 24"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2Z"/></svg></div>
                                <div><div class="timeline-title">Donors Matched</div><div class="timeline-time"><%= matchedResponders.isEmpty() ? "Pending..." : matchedResponders.size() + " accepted response(s)" %></div></div>
                            </div>
                            <div class="timeline-item">
                                <div class="timeline-dot <%= ("pending".equals(status) || "accepted".equals(status)) ? "pending" : "" %>"><svg viewBox="0 0 24 24"><path d="M12 2a10 10 0 1 0 0 20 10 10 0 0 0 0-20Zm1 11h4v2h-6V7h2v6Z"/></svg></div>
                                <div><div class="timeline-title">Awaiting Confirmation</div><div class="timeline-time"><%= "completed".equals(status) ? "Confirmed" : "In progress..." %></div></div>
                            </div>
                            <div class="timeline-item">
                                <div class="timeline-dot <%= "completed".equals(status) ? "" : "future" %>"><svg viewBox="0 0 24 24"><path d="M9 16.2 4.8 12l-1.4 1.4L9 19 21 7l-1.4-1.4L9 16.2Z"/></svg></div>
                                <div><div class="timeline-title">Request Fulfilled</div><div class="timeline-time"><%= "completed".equals(status) ? esc(completedDateTime) : "Pending..." %></div></div>
                            </div>
                        </div>
                    </section>

                    <section class="side-card">
                        <h2>Quick Summary</h2>
                        <div class="summary-list">
                            <div class="summary-row"><span>Request ID</span><strong class="red"><%= reqId(detail.getId()) %></strong></div>
                            <div class="summary-row"><span>Blood Group</span><strong><%= esc(detail.getBloodGroup()) %></strong></div>
                            <div class="summary-row"><span>Units</span><strong><%= detail.getUnitsNeeded() %> <%= detail.getUnitsNeeded() == 1 ? "Unit" : "Units" %></strong></div>
                            <div class="summary-row"><span>Urgency</span><strong class="red"><%= esc(urgencyDisplay) %></strong></div>
                            <div class="summary-row"><span>Donors Found</span><strong class="green"><%= matchedResponders.size() %> Matched</strong></div>
                            <div class="summary-row"><span>Status</span><strong><span class="status-pill"><%= esc(statusDisplay) %></span></strong></div>
                        </div>
                    </section>
                </aside>
            </div>
        </div>
    </section>
</main>

<script>
function relativeTime(time) {
    if (!time) return 'recently';
    const seconds = Math.max(1, Math.floor((Date.now() - time) / 1000));
    const units = [['year',31536000], ['month',2592000], ['day',86400], ['hour',3600], ['minute',60]];
    for (const [label, value] of units) {
        const amount = Math.floor(seconds / value);
        if (amount >= 1) return amount + ' ' + label + (amount === 1 ? '' : 's') + ' ago';
    }
    return 'just now';
}

document.querySelectorAll('.js-relative').forEach(el => {
    const source = el.dataset.time || (el.closest('[data-time]') ? el.closest('[data-time]').dataset.time : '0');
    el.textContent = relativeTime(Number(source));
});

const bellButton = document.getElementById('bellButton');
const notifMenu = document.getElementById('notifMenu');
bellButton.addEventListener('click', event => {
    event.stopPropagation();
    notifMenu.classList.toggle('open');
});
document.addEventListener('click', event => {
    if (!notifMenu.contains(event.target) && !bellButton.contains(event.target)) {
        notifMenu.classList.remove('open');
    }
});
</script>
</body>
</html>
