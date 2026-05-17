<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lifelink.model.User" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.sql.Timestamp" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    User user = (User) request.getAttribute("currentUser");
    String fullName = (user != null) ? user.getFullName() : "Recipient";
    String firstName = fullName.contains(" ") ? fullName.substring(0, fullName.indexOf(' ')) : fullName;
    String email = (user != null) ? user.getEmail() : "";
    String initials = (user != null) ? user.getInitials() : "R";

    long totalReq = (Long) request.getAttribute("totalRequests");
    long pendingReq = (Long) request.getAttribute("pendingRequests");
    long fulfilledReq = (Long) request.getAttribute("fulfilledRequests");

    List<Map<String,Object>> recentReqs = (List<Map<String,Object>>) request.getAttribute("recentRequests");
    List<Map<String,Object>> activity = (List<Map<String,Object>>) request.getAttribute("recentActivity");

    SimpleDateFormat dateFmt = new SimpleDateFormat("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Recipient Dashboard | LifeLink</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: #f3f4f6; color: #111827; min-height: 100vh; }

        .main-content { margin-left: 210px; padding: 0; min-height: 100vh; }

        /* ── TOP BAR ── */
        .topbar { display: flex; align-items: center; justify-content: space-between; padding: 1.3rem 2rem; background: #fff; border-bottom: 1px solid #e5e7eb; position: sticky; top: 0; z-index: 50; }
        .topbar-left h1 { font-size: 1.25rem; font-weight: 700; color: #111827; }
        .topbar-left p { font-size: .82rem; color: #6b7280; margin-top: .15rem; }
        .topbar-right { display: flex; align-items: center; gap: 1rem; }
        .notif-btn { position: relative; background: none; border: none; cursor: pointer; padding: .45rem; border-radius: 8px; color: #6b7280; transition: background .15s; }
        .notif-btn:hover { background: #f3f4f6; }
        .notif-btn svg { width: 22px; height: 22px; fill: currentColor; }
        .notif-dot { position: absolute; top: 6px; right: 6px; width: 8px; height: 8px; background: #16a34a; border-radius: 50%; border: 2px solid #fff; }
        .topbar-user { display: flex; align-items: center; gap: .6rem; cursor: pointer; }
        .topbar-avatar { width: 36px; height: 36px; background: linear-gradient(135deg, #b91c1c, #dc2626); border-radius: 50%; display: flex; align-items: center; justify-content: center; color: #fff; font-size: .78rem; font-weight: 700; }
        .topbar-uname { font-size: .85rem; font-weight: 600; color: #111827; }
        .topbar-uemail { font-size: .72rem; color: #9ca3af; }

        /* mobile hamburger */
        .hamburger { display: none; background: none; border: none; cursor: pointer; padding: .4rem; color: #374151; }
        .hamburger svg { width: 24px; height: 24px; fill: currentColor; }

        /* ── PAGE BODY ── */
        .page-body { padding: 1.6rem 2rem 2.5rem; }

        /* ── STAT CARDS ── */
        .stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.2rem; margin-bottom: 1.8rem; }
        .stat-card { background: #fff; border-radius: 14px; padding: 1.2rem 1.3rem 1rem; position: relative; overflow: hidden; box-shadow: 0 1px 4px rgba(0,0,0,.04); border: 1px solid #f0f0f0; }
        .stat-card::after { content: ''; position: absolute; bottom: 0; left: 0; right: 0; height: 4px; }
        .stat-card.total::after { background: linear-gradient(90deg, #b91c1c, #ef4444); }
        .stat-card.pending::after { background: linear-gradient(90deg, #d97706, #f59e0b); }
        .stat-card.fulfilled::after { background: linear-gradient(90deg, #059669, #10b981); }
        .stat-icon { width: 40px; height: 40px; border-radius: 10px; display: flex; align-items: center; justify-content: center; margin-bottom: .7rem; }
        .stat-icon svg { width: 20px; height: 20px; fill: white; }
        .stat-icon.red { background: #fee2e2; }
        .stat-icon.red svg { fill: #b91c1c; }
        .stat-icon.amber { background: #fef3c7; }
        .stat-icon.amber svg { fill: #d97706; }
        .stat-icon.green { background: #d1fae5; }
        .stat-icon.green svg { fill: #059669; }
        .stat-number { font-size: 1.9rem; font-weight: 800; color: #111827; line-height: 1; }
        .stat-label { font-size: .82rem; color: #6b7280; margin-top: .3rem; font-weight: 500; }
        .stat-corner { position: absolute; top: 8px; right: 12px; font-size: .7rem; font-weight: 700; border-radius: 6px; padding: .15rem .45rem; }

        /* ── MIDDLE ROW: requests + quick action ── */
        .mid-row { display: grid; grid-template-columns: 1fr 340px; gap: 1.4rem; margin-bottom: 1.8rem; }

        /* Recent Requests card */
        .card { background: #fff; border-radius: 14px; padding: 1.3rem; box-shadow: 0 1px 4px rgba(0,0,0,.04); border: 1px solid #f0f0f0; }
        .card-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: .2rem; }
        .card-title { font-size: 1rem; font-weight: 700; color: #111827; }
        .card-subtitle { font-size: .78rem; color: #9ca3af; margin-bottom: .9rem; }
        .view-all-btn { font-size: .76rem; font-weight: 600; color: #b91c1c; background: #fee2e2; border: none; padding: .35rem .85rem; border-radius: 8px; cursor: pointer; text-decoration: none; transition: background .15s; }
        .view-all-btn:hover { background: #fecaca; }

        /* Request table */
        .req-table { width: 100%; border-collapse: collapse; }
        .req-table th { text-align: left; font-size: .7rem; font-weight: 600; color: #9ca3af; text-transform: uppercase; letter-spacing: .04em; padding: .55rem .4rem; border-bottom: 1px solid #f3f4f6; }
        .req-table td { padding: .7rem .4rem; font-size: .84rem; color: #374151; border-bottom: 1px solid #f9fafb; vertical-align: middle; }
        .req-table tr:last-child td { border-bottom: none; }
        .req-id { font-weight: 700; color: #b91c1c; font-size: .82rem; }

        /* Blood group badge */
        .bg-badge { display: inline-flex; align-items: center; justify-content: center; padding: .2rem .55rem; border-radius: 6px; font-size: .72rem; font-weight: 700; color: #fff; min-width: 36px; }
        .bg-a-pos { background: #dc2626; }
        .bg-a-neg { background: #991b1b; }
        .bg-b-pos { background: #ea580c; }
        .bg-b-neg { background: #9a3412; }
        .bg-ab-pos { background: #7c3aed; }
        .bg-ab-neg { background: #5b21b6; }
        .bg-o-pos { background: #be123c; }
        .bg-o-neg { background: #881337; }

        /* Status badges */
        .status-badge { display: inline-flex; align-items: center; gap: .3rem; font-size: .76rem; font-weight: 600; }
        .status-dot { width: 7px; height: 7px; border-radius: 50%; }
        .status-pending .status-dot { background: #f59e0b; }
        .status-pending { color: #d97706; }
        .status-accepted .status-dot, .status-completed .status-dot { background: #10b981; }
        .status-accepted, .status-completed { color: #059669; }
        .status-rejected .status-dot { background: #ef4444; }
        .status-rejected { color: #dc2626; }
        .status-cancelled .status-dot { background: #9ca3af; }
        .status-cancelled { color: #6b7280; }

        /* ── QUICK ACTION + TIPS ── */
        .right-col { display: flex; flex-direction: column; gap: 1.2rem; }
        .quick-action { background: #fffbeb; border-radius: 14px; padding: 1.5rem; text-align: center; border: 1px solid #fef3c7; }
        .quick-action-title { font-size: 1rem; font-weight: 700; color: #111827; margin-bottom: .15rem; }
        .quick-action-sub { font-size: .78rem; color: #9ca3af; margin-bottom: 1.1rem; }
        .qa-icon { width: 56px; height: 56px; background: linear-gradient(135deg, #fecaca, #fee2e2); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto .8rem; }
        .qa-icon svg { width: 28px; height: 28px; fill: #b91c1c; }
        .qa-heading { font-size: .95rem; font-weight: 700; color: #111827; margin-bottom: .1rem; }
        .qa-sub { font-size: .76rem; color: #9ca3af; margin-bottom: 1rem; }
        .create-req-btn { display: inline-flex; align-items: center; gap: .4rem; background: linear-gradient(135deg, #b91c1c, #dc2626); color: #fff; font-size: .86rem; font-weight: 600; padding: .7rem 1.6rem; border-radius: 10px; border: none; cursor: pointer; text-decoration: none; transition: opacity .15s; width: 100%; justify-content: center; }
        .create-req-btn:hover { opacity: .9; }

        .tips-card { background: #fff; border-radius: 14px; padding: 1.2rem; box-shadow: 0 1px 4px rgba(0,0,0,.04); border: 1px solid #f0f0f0; }
        .tips-title { font-size: .92rem; font-weight: 700; color: #111827; margin-bottom: .7rem; display: flex; align-items: center; gap: .4rem; }
        .tips-title span { font-size: .9rem; }
        .tip-item { display: flex; align-items: flex-start; gap: .55rem; margin-bottom: .55rem; }
        .tip-item:last-child { margin-bottom: 0; }
        .tip-check { width: 20px; height: 20px; background: #d1fae5; border-radius: 50%; display: flex; align-items: center; justify-content: center; flex-shrink: 0; margin-top: .1rem; }
        .tip-check svg { width: 12px; height: 12px; fill: #059669; }
        .tip-text { font-size: .78rem; color: #6b7280; line-height: 1.45; }

        /* ── ACTIVITY TIMELINE ── */
        .activity-section { margin-top: .2rem; }
        .activity-title { font-size: 1rem; font-weight: 700; color: #111827; }
        .activity-sub { font-size: .78rem; color: #9ca3af; margin-bottom: 1rem; }
        .activity-scroll { display: flex; gap: 1rem; overflow-x: auto; padding-bottom: .6rem; scrollbar-width: thin; }
        .activity-card { flex: 0 0 200px; background: #fff; border-radius: 12px; padding: 1rem; border: 1px solid #f0f0f0; box-shadow: 0 1px 3px rgba(0,0,0,.03); }
        .activity-card-header { display: flex; align-items: center; gap: .5rem; margin-bottom: .5rem; }
        .act-dot { width: 10px; height: 10px; border-radius: 50%; flex-shrink: 0; }
        .act-dot.submitted { background: #ef4444; }
        .act-dot.fulfilled { background: #10b981; }
        .act-dot.matched { background: #3b82f6; }
        .act-dot.rejected { background: #f59e0b; }
        .act-dot.account { background: #8b5cf6; }
        .act-label { font-size: .82rem; font-weight: 700; color: #111827; line-height: 1.2; }
        .act-detail { font-size: .74rem; color: #6b7280; line-height: 1.4; margin-bottom: .4rem; }
        .act-date { font-size: .68rem; color: #9ca3af; }

        /* ── EMPTY STATE ── */
        .empty-state { text-align: center; padding: 2rem 1rem; color: #9ca3af; }
        .empty-state svg { width: 48px; height: 48px; fill: #d1d5db; margin-bottom: .6rem; }
        .empty-state p { font-size: .85rem; }

        /* ── RESPONSIVE ── */
        @media (max-width: 1024px) {
            .main-content { margin-left: 0; }
            .hamburger { display: block; }
            .mid-row { grid-template-columns: 1fr; }
        }
        @media (max-width: 768px) {
            .stats-grid { grid-template-columns: 1fr; }
            .page-body { padding: 1rem; }
            .topbar { padding: 1rem; }
        }
        @media (max-width: 600px) {
            .activity-card { flex: 0 0 170px; }
        }
    </style>
</head>
<body>

<jsp:include page="/includes/recipient_sidebar.jsp" />

<div class="main-content">

    <!-- TOP BAR -->
    <div class="topbar">
        <div style="display:flex;align-items:center;gap:.8rem;">
            <button class="hamburger" onclick="toggleSidebar()">
                <svg viewBox="0 0 24 24"><path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"/></svg>
            </button>
            <div class="topbar-left">
                <h1>Recipient Dashboard</h1>
                <p>Welcome back, <%= firstName %>! Here's your request overview.</p>
            </div>
        </div>
        <div class="topbar-right">
            <button class="notif-btn" title="Notifications">
                <svg viewBox="0 0 24 24"><path d="M12 22c1.1 0 2-.9 2-2h-4c0 1.1.89 2 2 2zm6-6v-5c0-3.07-1.63-5.64-4.5-6.32V4c0-.83-.67-1.5-1.5-1.5s-1.5.67-1.5 1.5v.68C7.64 5.36 6 7.92 6 11v5l-2 2v1h16v-1l-2-2zm-2 1H8v-6c0-2.48 1.51-4.5 4-4.5s4 2.02 4 4.5v6z"/></svg>
                <span class="notif-dot"></span>
            </button>
            <div class="topbar-user">
                <div class="topbar-avatar"><%= initials %></div>
                <div>
                    <div class="topbar-uname"><%= fullName %></div>
                    <div class="topbar-uemail"><%= email %></div>
                </div>
            </div>
        </div>
    </div>

    <div class="page-body">

        <!-- STAT CARDS -->
        <div class="stats-grid">
            <div class="stat-card total">
                <div class="stat-icon red">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zm-1 7V3.5L18.5 9H13zM6 20V4h5v7h7v9H6z"/></svg>
                </div>
                <div class="stat-number"><%= totalReq %></div>
                <div class="stat-label">Total Requests</div>
            </div>
            <div class="stat-card pending">
                <div class="stat-icon amber">
                    <svg viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/></svg>
                </div>
                <div class="stat-number"><%= pendingReq %></div>
                <div class="stat-label">Pending</div>
            </div>
            <div class="stat-card fulfilled">
                <div class="stat-icon green">
                    <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"/></svg>
                </div>
                <div class="stat-number"><%= fulfilledReq %></div>
                <div class="stat-label">Fulfilled</div>
            </div>
        </div>

        <!-- MID ROW -->
        <div class="mid-row">

            <!-- Recent Requests Table -->
            <div class="card">
                <div class="card-header">
                    <div>
                        <div class="card-title">Recent Requests</div>
                        <div class="card-subtitle">Your blood request history</div>
                    </div>
                    <a href="${pageContext.request.contextPath}/recipient/requests" class="view-all-btn">View All</a>
                </div>

                <% if (recentReqs != null && !recentReqs.isEmpty()) { %>
                <table class="req-table">
                    <thead>
                        <tr>
                            <th>Request ID</th>
                            <th>Blood Group</th>
                            <th>Date</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% for (Map<String,Object> r : recentReqs) {
                        long rid = (Long) r.get("id");
                        String bg = (String) r.get("blood_group");
                        Timestamp ts = (Timestamp) r.get("requested_at");
                        String st = (String) r.get("status");
                        String dateStr = (ts != null) ? dateFmt.format(ts) : "";
                        String bgClass = "bg-a-pos";
                        if (bg != null) {
                            String norm = bg.replace("+","pos").replace("-","neg").toLowerCase();
                            if (norm.startsWith("a") && !norm.startsWith("ab")) bgClass = norm.contains("neg") ? "bg-a-neg" : "bg-a-pos";
                            else if (norm.startsWith("b")) bgClass = norm.contains("neg") ? "bg-b-neg" : "bg-b-pos";
                            else if (norm.startsWith("ab")) bgClass = norm.contains("neg") ? "bg-ab-neg" : "bg-ab-pos";
                            else if (norm.startsWith("o")) bgClass = norm.contains("neg") ? "bg-o-neg" : "bg-o-pos";
                        }
                        String statusDisplay = "Pending";
                        String statusClass = "status-pending";
                        if ("accepted".equals(st) || "completed".equals(st)) { statusDisplay = "Fulfilled"; statusClass = "status-accepted"; }
                        else if ("rejected".equals(st)) { statusDisplay = "Rejected"; statusClass = "status-rejected"; }
                        else if ("cancelled".equals(st)) { statusDisplay = "Cancelled"; statusClass = "status-cancelled"; }
                    %>
                    <tr>
                        <td><span class="req-id">#REQ-<%= String.format("%03d", rid) %></span></td>
                        <td><span class="bg-badge <%= bgClass %>"><%= bg %></span></td>
                        <td><%= dateStr %></td>
                        <td><span class="status-badge <%= statusClass %>"><span class="status-dot"></span> <%= statusDisplay %></span></td>
                    </tr>
                    <% } %>
                    </tbody>
                </table>
                <% } else { %>
                <div class="empty-state">
                    <svg viewBox="0 0 24 24"><path d="M14 2H6c-1.1 0-2 .9-2 2v16c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V8l-6-6zM6 20V4h7v5h5v11H6z"/></svg>
                    <p>No requests yet. Create your first blood request!</p>
                </div>
                <% } %>
            </div>

            <!-- Right Column -->
            <div class="right-col">

                <!-- Quick Action -->
                <div class="quick-action">
                    <div class="quick-action-title">Quick Action</div>
                    <div class="quick-action-sub">Submit a new blood request quickly</div>
                    <div class="qa-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
                    </div>
                    <div class="qa-heading">Need Blood?</div>
                    <div class="qa-heading" style="font-size:.88rem;margin-bottom:.05rem;">Create a Request</div>
                    <div class="qa-sub">Fast. Simple. Life-saving.</div>
                    <a href="${pageContext.request.contextPath}/recipient/requests?action=new" class="create-req-btn">+ Create Request</a>
                </div>

                <!-- Request Tips -->
                <div class="tips-card">
                    <div class="tips-title"><span>&#x2757;</span> Request Tips</div>
                    <div class="tip-item">
                        <div class="tip-check"><svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"/></svg></div>
                        <div class="tip-text">Specify your blood group clearly when submitting a request.</div>
                    </div>
                    <div class="tip-item">
                        <div class="tip-check"><svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"/></svg></div>
                        <div class="tip-text">Keep your contact details updated for faster donor matching.</div>
                    </div>
                    <div class="tip-item">
                        <div class="tip-check"><svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41L9 16.17z"/></svg></div>
                        <div class="tip-text">Use Search Donors to find nearby donors directly.</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- RECENT ACTIVITY TIMELINE -->
        <div class="activity-section">
            <div class="activity-title">Recent Activity</div>
            <div class="activity-sub">Latest updates on your requests</div>

            <% if (activity != null && !activity.isEmpty()) { %>
            <div class="activity-scroll">
                <% for (Map<String,Object> ev : activity) {
                    String evType = (String) ev.get("event_type");
                    String evLabel = (String) ev.get("label");
                    String evDetail = (String) ev.get("detail");
                    Timestamp evTs = (Timestamp) ev.get("occurred_at");
                    String evDate = (evTs != null) ? dateFmt.format(evTs) : "";
                    String dotClass = "submitted";
                    if ("request_fulfilled".equals(evType)) dotClass = "fulfilled";
                    else if ("donor_matched".equals(evType)) dotClass = "matched";
                    else if ("request_rejected".equals(evType)) dotClass = "rejected";
                    else if ("account_created".equals(evType)) dotClass = "account";
                %>
                <div class="activity-card">
                    <div class="activity-card-header">
                        <div class="act-dot <%= dotClass %>"></div>
                        <div class="act-label"><%= evLabel %></div>
                    </div>
                    <div class="act-detail"><%= evDetail %></div>
                    <div class="act-date" title="<%= evDate %>"><%= evDate %></div>
                </div>
                <% } %>
            </div>
            <% } else { %>
            <div class="empty-state">
                <p>No activity yet.</p>
            </div>
            <% } %>
        </div>

    </div>
</div>

<script>
// Relative time helper for activity dates (future enhancement)
document.querySelectorAll('.act-date').forEach(el => {
    const full = el.getAttribute('title');
    if (full) el.title = full;
});
</script>
</body>
</html>
