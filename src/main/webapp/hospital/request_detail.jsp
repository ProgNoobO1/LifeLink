<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Request Details - LifeLink</title>
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
        .brand, .nav-link, .logout-link, .hospital-account, .topbar-right, .topbar-profile, .hero-head, .stat-card, .summary-row, .timeline-item, .stock-row, .other-row, .action-bar { display: flex; align-items: center; }
        .brand { gap: 12px; color: #fff; font-size: 20px; font-weight: 700; margin-bottom: 28px; }
        .brand-icon, .nav-icon, .logout-icon, .profile-icon, .topbar-bell, .hero-icon, .avatar, .timeline-dot { display: inline-flex; align-items: center; justify-content: center; }
        .brand-icon { width: 38px; height: 38px; background: var(--red); border-radius: 12px; color: #fff; font-weight: 700; }
        .sidebar-label { font-size: 12px; letter-spacing: 2px; text-transform: uppercase; color: #c97b74; margin: 0 8px 12px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; }
        .nav-link { gap: 12px; padding: 14px 16px; border-radius: 14px; color: #f7d8d5; transition: background .2s ease; }
        .nav-link.active { background: var(--red); color: #fff; font-weight: 700; box-shadow: inset -4px 0 0 rgba(255,255,255,.7); }
        .nav-icon, .logout-icon { width: 32px; height: 32px; border-radius: 10px; background: rgba(255,255,255,.08); flex-shrink: 0; }
        .nav-badge, .bell-badge { min-width: 24px; height: 24px; padding: 0 8px; border-radius: 999px; background: var(--red); color: #fff; font-size: 12px; font-weight: 700; display: inline-flex; align-items: center; justify-content: center; }
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
        .profile-icon { width: 42px; height: 42px; border-radius: 14px; background: var(--red); color: #fff; font-weight: 700; }
        .topbar-profile { gap: 12px; }
        .page-body { padding: 28px; }
        .breadcrumb { color: #98a2b3; font-size: 14px; margin-bottom: 18px; }
        .breadcrumb strong { color: var(--red); }
        .main-grid { display: grid; grid-template-columns: 1fr 320px; gap: 24px; }
        .card { background: var(--card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
        .hero-card { border-radius: 12px; padding: 28px 32px; background: var(--dark-red-hero); color: white; margin-bottom: 18px; }
        .hero-head { justify-content: space-between; gap: 18px; }
        .hero-left { display: flex; align-items: center; gap: 16px; }
        .hero-icon { width: 52px; height: 52px; border-radius: 14px; background: rgba(255,255,255,.12); font-weight: 700; }
        .hero-title { font-size: 36px; font-weight: 800; margin: 0; }
        .hero-sub { margin: 6px 0 0; color: rgba(255,255,255,.82); }
        .status-badge { border-radius: 20px; padding: 4px 12px; font-size: 12px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
        .status-badge.pending { background: rgba(245,158,11,.18); color: #ffd27b; border: 1px solid rgba(245,158,11,.36); }
        .status-badge.accepted { background: rgba(16,185,129,.14); color: #b9f5da; border: 1px solid rgba(16,185,129,.3); }
        .status-badge.rejected { background: rgba(239,68,68,.14); color: #fecaca; border: 1px solid rgba(239,68,68,.3); }
        .info-grid { display: grid; grid-template-columns: repeat(3, 1fr); grid-template-rows: repeat(2, auto); gap: 16px; margin-bottom: 18px; }
        .stat-card { gap: 14px; padding: 16px; border: 1px solid var(--border); }
        .stat-icon { width: 34px; height: 34px; border-radius: 10px; display: inline-flex; align-items: center; justify-content: center; }
        .stat-icon.red { background: #fdebec; color: var(--red); }
        .stat-icon.amber { background: #fff7e0; color: var(--low-amber); }
        .stat-icon.blue { background: #e8f0fe; color: var(--info-blue); }
        .stat-label { font-size: 13px; color: #98a2b3; font-weight: 700; letter-spacing: .04em; }
        .stat-value { margin-top: 8px; font-size: 16px; font-weight: 800; color: #273449; }
        .avatar { width: 34px; height: 34px; border-radius: 50%; background: #e8f0fe; color: var(--info-blue); font-weight: 700; }
        .blood-pill { display: inline-flex; align-items: center; justify-content: center; min-width: 62px; padding: 10px 16px; border-radius: 12px; color: #fff; font-weight: 800; font-size: 20px; }
        .blood-red { background: #c0392b; }
        .blood-blue { background: #3f7ded; }
        .blood-teal { background: #1fb7aa; }
        .blood-purple { background: #a154f2; }
        .note-card { padding: 18px; border: 1px solid #f6df9e; background: #fffaf0; color: #b45309; margin-bottom: 18px; }
        .action-card { padding: 20px; }
        .action-title { font-size: 18px; font-weight: 800; margin-bottom: 16px; }
        .action-bar { gap: 12px; }
        .action-btn { padding: 12px 18px; border-radius: 10px; font-weight: 700; border: none; cursor: pointer; }
        .action-btn.approve { background: #22c55e; color: #fff; }
        .action-btn.reject { background: #fff1f2; color: #dc2626; border: 1px solid #fecdd3; }
        .action-btn.back { background: #f3f4f6; color: #6b7280; }
        .action-btn.disabled { opacity: .4; cursor: not-allowed; pointer-events: none; }
        .action-note { margin-top: 12px; color: #98a2b3; font-style: italic; }
        .side-stack { display: grid; gap: 20px; }
        .side-card { padding: 20px; }
        .side-card h3 { margin: 0; font-size: 18px; }
        .side-card p { margin: 4px 0 0; color: #98a2b3; }
        .stock-box { margin-top: 18px; padding: 14px; border-radius: 12px; }
        .stock-box.good { background: #ecfdf4; color: #166534; }
        .stock-box.bad { background: #fef2f2; color: #b91c1c; }
        .stock-row, .other-row { justify-content: space-between; gap: 12px; margin-top: 16px; }
        .stock-left { display: flex; align-items: center; gap: 12px; }
        .progress-track { width: 100%; height: 8px; border-radius: 4px; background: #e5e7eb; overflow: hidden; margin-top: 12px; }
        .progress-fill { height: 100%; }
        .timeline { margin-top: 16px; display: grid; gap: 18px; }
        .timeline-item { align-items: flex-start; gap: 12px; }
        .timeline-dot { width: 12px; height: 12px; border-radius: 50%; margin-top: 6px; flex-shrink: 0; }
        .timeline-dot.done { background: var(--success-green); }
        .timeline-dot.pending { border: 2px solid #d1d5db; background: transparent; }
        .timeline-dot.active { background: var(--low-amber); animation: pulse 1.3s infinite; }
        @keyframes pulse { 0% { box-shadow: 0 0 0 0 rgba(245,158,11,.45); } 70% { box-shadow: 0 0 0 8px rgba(245,158,11,0); } 100% { box-shadow: 0 0 0 0 rgba(245,158,11,0); } }
        .timeline-stage { font-weight: 800; color: #344054; }
        .timeline-time { color: #98a2b3; font-size: 13px; margin: 2px 0 4px; }
        .timeline-desc { color: #667085; }
        .summary-list { margin-top: 16px; display: grid; gap: 12px; }
        .summary-row { justify-content: space-between; gap: 12px; border-bottom: 1px solid var(--border); padding-bottom: 10px; }
        .summary-row:last-child { border-bottom: none; padding-bottom: 0; }
        .priority-high { color: #ef4444; }
        .priority-medium { color: #d97706; }
        .priority-low { color: #6b7280; }
        @media (max-width: 900px) {
            .sidebar { position: static; width: 100%; min-width: 0; }
            .layout { flex-direction: column; }
            .content { margin-left: 0; width: 100%; }
            .main-grid, .info-grid { grid-template-columns: 1fr; }
            .topbar, .hero-head, .action-bar { flex-direction: column; align-items: flex-start; }
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
                <h1>Request Details</h1>
                <p>Full information for request ${requestDetail.formattedId}.</p>
            </div>
            <div class="topbar-right">
                <jsp:include page="/includes/hospital_notifications.jsp" />
                <div class="topbar-profile"><span class="profile-icon">&#127973;</span><div><strong>${hospitalName}</strong><span>${not empty sessionScope.email ? sessionScope.email : hospitalEmail}</span></div></div>
            </div>
        </header>

        <div class="page-body">
            <div class="breadcrumb">Requests &gt; <strong>Request Details</strong></div>

            <div class="main-grid">
                <section>
                    <div class="hero-card">
                        <div class="hero-head">
                            <div class="hero-left">
                                <span class="hero-icon">&#128196;</span>
                                <div>
                                    <p class="hero-title">${requestDetail.formattedId}</p>
                                    <p class="hero-sub">Submitted on ${requestDetail.requestedAt}</p>
                                </div>
                            </div>
                            <span class="status-badge ${requestDetail.status}">
                                <c:choose>
                                    <c:when test="${requestDetail.status == 'pending'}">Pending Review</c:when>
                                    <c:when test="${requestDetail.status == 'accepted'}">Approved</c:when>
                                    <c:otherwise>Rejected</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </div>

                    <div class="info-grid">
                        <div class="card stat-card">
                            <span class="stat-icon red">&#128100;</span>
                            <div>
                                <div class="stat-label">REQUESTER</div>
                                <div class="summary-row" style="justify-content:flex-start;margin-top:10px;border-bottom:none;padding-bottom:0;">
                                    <span class="avatar">${requestDetail.requesterInitial}</span>
                                    <div><div class="stat-value">${requestDetail.requesterName}</div><div class="requester-role">${requestDetail.requesterRole}</div></div>
                                </div>
                            </div>
                        </div>
                        <div class="card stat-card">
                            <span class="stat-icon red">&#128167;</span>
                            <div>
                                <div class="stat-label">BLOOD GROUP</div>
                                <div class="summary-row" style="justify-content:flex-start;margin-top:10px;border-bottom:none;padding-bottom:0;">
                                    <c:choose>
                                        <c:when test="${requestDetail.bloodGroup == 'A+' || requestDetail.bloodGroup == 'A-'}"><span class="blood-pill blood-red">${requestDetail.bloodGroup}</span></c:when>
                                        <c:when test="${requestDetail.bloodGroup == 'B+' || requestDetail.bloodGroup == 'B-'}"><span class="blood-pill blood-blue">${requestDetail.bloodGroup}</span></c:when>
                                        <c:when test="${requestDetail.bloodGroup == 'O+' || requestDetail.bloodGroup == 'O-'}"><span class="blood-pill blood-teal">${requestDetail.bloodGroup}</span></c:when>
                                        <c:otherwise><span class="blood-pill blood-purple">${requestDetail.bloodGroup}</span></c:otherwise>
                                    </c:choose>
                                    <div><div class="stat-value">${requestDetail.bloodGroupFullName}</div><div class="requester-role"><c:if test="${requestDetail.bloodGroup == 'A+' || requestDetail.bloodGroup == 'O+'}">Most common</c:if></div></div>
                                </div>
                            </div>
                        </div>
                        <div class="card stat-card">
                            <span class="stat-icon red">&#128202;</span>
                            <div><div class="stat-label">UNITS REQUESTED</div><div class="stat-value">${requestDetail.units} units</div><div class="requester-role">&asymp; ${requestDetail.milliliters} mL total</div></div>
                        </div>
                        <div class="card stat-card">
                            <span class="stat-icon amber">&#9889;</span>
                            <div>
                                <div class="stat-label">URGENCY</div>
                                <div class="stat-value">
                                    <span class="status-badge <c:choose><c:when test='${requestDetail.urgency == "critical"}'>rejected</c:when><c:when test='${requestDetail.urgency == "urgent"}'>pending</c:when><c:otherwise>completed</c:otherwise></c:choose>">
                                        <c:choose><c:when test="${requestDetail.urgency == 'critical'}">Critical</c:when><c:when test="${requestDetail.urgency == 'urgent'}">Urgent</c:when><c:otherwise>Normal</c:otherwise></c:choose>
                                    </span>
                                </div>
                                <div class="requester-role"><c:choose><c:when test="${requestDetail.urgency == 'critical'}">Required within 2 hrs</c:when><c:when test="${requestDetail.urgency == 'urgent'}">Required within 24 hrs</c:when><c:otherwise>Standard timeline</c:otherwise></c:choose></div>
                            </div>
                        </div>
                        <div class="card stat-card">
                            <span class="stat-icon amber">&#9679;</span>
                            <div><div class="stat-label">STATUS</div><div class="stat-value"><span class="status-badge ${requestDetail.status}">${requestDetail.status}</span></div><div class="requester-role"><c:choose><c:when test="${requestDetail.status == 'pending'}">Awaiting approval</c:when><c:when test="${requestDetail.status == 'accepted'}">Approved by hospital</c:when><c:otherwise>Request closed</c:otherwise></c:choose></div></div>
                        </div>
                        <div class="card stat-card">
                            <span class="stat-icon blue">&#8646;</span>
                            <div><div class="stat-label">REQUEST TYPE</div><div class="stat-value"><span class="status-badge completed">Incoming</span></div><div class="requester-role">From external entity</div></div>
                        </div>
                    </div>

                    <c:if test="${not empty requestDetail.notes}">
                        <div class="card note-card">
                            <div class="stat-label" style="color:#d97706;">REQUESTER NOTES</div>
                            <div class="stat-value" style="font-size:15px;margin-top:8px;color:#b45309;">"${requestDetail.notes}"</div>
                        </div>
                    </c:if>

                    <div class="card action-card">
                        <div class="action-title">Take Action</div>
                        <div class="action-bar">
                            <c:choose>
                                <c:when test="${requestDetail.status == 'pending'}">
                                    <form method="post" action="${pageContext.request.contextPath}/hospital/requests" style="margin:0;">
                                        <input type="hidden" name="action" value="approve">
                                        <input type="hidden" name="id" value="${requestDetail.id}">
                                        <button type="submit" class="action-btn approve">Approve &amp; Dispatch</button>
                                    </form>
                                    <form method="post" action="${pageContext.request.contextPath}/hospital/requests" style="margin:0;">
                                        <input type="hidden" name="action" value="reject">
                                        <input type="hidden" name="id" value="${requestDetail.id}">
                                        <button type="submit" class="action-btn reject">Reject Request</button>
                                    </form>
                                    <a class="action-btn back" href="${pageContext.request.contextPath}/hospital/requests">Back to List</a>
                                </c:when>
                                <c:otherwise>
                                    <button type="button" class="action-btn approve disabled" title="Already actioned">Approve &amp; Dispatch</button>
                                    <button type="button" class="action-btn reject disabled" title="Already actioned">Reject Request</button>
                                    <span class="action-btn back disabled" title="Already actioned">Back to List</span>
                                </c:otherwise>
                            </c:choose>
                        </div>
                        <div class="action-note">Approving will immediately notify ${requestDetail.requesterName} and log dispatch details.</div>
                    </div>
                </section>

                <aside class="side-stack">
                    <section class="card side-card">
                        <h3>Available Stock</h3>
                        <p>${hospitalName} Inventory</p>
                        <div class="stock-box ${availableStock.canFulfill ? 'good' : 'bad'}">
                            <strong><c:choose><c:when test="${availableStock.canFulfill}">Sufficient Stock</c:when><c:otherwise>Insufficient Stock</c:otherwise></c:choose></strong>
                            <div><c:choose><c:when test="${availableStock.canFulfill}">Can fulfil this request</c:when><c:otherwise>Cannot fulfil this request</c:otherwise></c:choose></div>
                        </div>
                        <div class="stock-row">
                            <div class="stock-left">
                                <c:choose>
                                    <c:when test="${requestDetail.bloodGroup == 'A+' || requestDetail.bloodGroup == 'A-'}"><span class="blood-pill blood-red">${requestDetail.bloodGroup}</span></c:when>
                                    <c:when test="${requestDetail.bloodGroup == 'B+' || requestDetail.bloodGroup == 'B-'}"><span class="blood-pill blood-blue">${requestDetail.bloodGroup}</span></c:when>
                                    <c:when test="${requestDetail.bloodGroup == 'O+' || requestDetail.bloodGroup == 'O-'}"><span class="blood-pill blood-teal">${requestDetail.bloodGroup}</span></c:when>
                                    <c:otherwise><span class="blood-pill blood-purple">${requestDetail.bloodGroup}</span></c:otherwise>
                                </c:choose>
                                <div><div class="stat-value" style="font-size:16px;">Available</div><div class="requester-role">${availableStock.units} units</div></div>
                            </div>
                        </div>
                        <div class="progress-track"><div class="progress-fill blood-red" style="width: ${availableStock.units * 2 > 100 ? 100 : availableStock.units * 2}%;"></div></div>
                        <div class="summary-row" style="margin-top:10px;">
                            <span class="requester-role">Requested: ${requestDetail.units} units</span>
                            <span class="${availableStock.remaining >= 0 ? 'priority-high' : 'priority-high'}">
                                <c:choose>
                                    <c:when test="${availableStock.remaining >= 0}">+${availableStock.remaining} remaining</c:when>
                                    <c:otherwise>${availableStock.remaining} short</c:otherwise>
                                </c:choose>
                            </span>
                        </div>
                    </section>

                    <section class="card side-card">
                        <h3>OTHER BLOOD GROUPS</h3>
                        <div style="margin-top:16px;">
                            <c:forEach var="stock" items="${otherStock}">
                                <div class="other-row">
                                    <div class="stock-left">
                                        <c:choose>
                                            <c:when test="${stock.bloodGroup == 'A+' || stock.bloodGroup == 'A-'}"><span class="blood-pill blood-red">${stock.bloodGroup}</span></c:when>
                                            <c:when test="${stock.bloodGroup == 'B+' || stock.bloodGroup == 'B-'}"><span class="blood-pill blood-blue">${stock.bloodGroup}</span></c:when>
                                            <c:when test="${stock.bloodGroup == 'O+' || stock.bloodGroup == 'O-'}"><span class="blood-pill blood-teal">${stock.bloodGroup}</span></c:when>
                                            <c:otherwise><span class="blood-pill blood-purple">${stock.bloodGroup}</span></c:otherwise>
                                        </c:choose>
                                        <div class="progress-track" style="width:120px;margin-top:0;"><div class="progress-fill blood-blue" style="width: ${stock.units * 2 > 100 ? 100 : stock.units * 2}%;"></div></div>
                                    </div>
                                    <strong>${stock.units} units</strong>
                                </div>
                            </c:forEach>
                        </div>
                    </section>

                    <section class="card side-card">
                        <h3>Activity Timeline</h3>
                        <p>Request history</p>
                        <div class="timeline">
                            <c:forEach var="item" items="${activityTimeline}">
                                <div class="timeline-item">
                                    <span class="timeline-dot ${item.active ? 'active' : (item.done ? 'done' : 'pending')}"></span>
                                    <div>
                                        <div class="timeline-stage">${item.stage}</div>
                                        <div class="timeline-time">${item.time}</div>
                                        <div class="timeline-desc">${item.desc}</div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </section>

                    <section class="card side-card">
                        <h3>Request Summary</h3>
                        <div class="summary-list">
                            <div class="summary-row"><span>Request ID</span><strong>${requestSummary.requestId}</strong></div>
                            <div class="summary-row"><span>Contact</span><strong>${requestSummary.contact}</strong></div>
                            <div class="summary-row"><span>Phone</span><strong>${requestSummary.phone}</strong></div>
                            <div class="summary-row"><span>Entity Type</span><strong>${requestSummary.entityType}</strong></div>
                            <div class="summary-row"><span>Priority</span><strong class="${requestSummary.priority == 'High' ? 'priority-high' : (requestSummary.priority == 'Medium' ? 'priority-medium' : 'priority-low')}">${requestSummary.priority}</strong></div>
                        </div>
                    </section>
                </aside>
            </div>
        </div>
    </main>
</div>
</body>
</html>
