<%--
  Admin Dashboard – LifeLink
  Created: 02/05/2026
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Admin Dashboard – LifeLink</title>
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


        /* ═══════════════════════════════════════
           MAIN CONTENT
        ═══════════════════════════════════════ */
        .main {
            margin-left: var(--sidebar-w);
            flex: 1;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        /* CONTENT */
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
        }

        .stat-card-blob {
            position: absolute;
            top: -20px; right: -20px;
            width: 90px; height: 90px;
            border-radius: 50%;
            opacity: .13;
        }

        .stat-icon {
            width: 44px; height: 44px;
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            margin-bottom: 1rem;
        }

        .stat-icon svg { width: 22px; height: 22px; }

        .stat-icon.red   { background: var(--red-light); }
        .stat-icon.red svg { fill: var(--red); }
        .stat-icon.blue  { background: #dbeafe; }
        .stat-icon.blue svg { fill: #2563eb; }
        .stat-icon.amber { background: #fef3c7; }
        .stat-icon.amber svg { fill: #d97706; }

        .stat-num {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text-dark);
            line-height: 1;
            margin-bottom: .35rem;
        }

        .stat-label { font-size: .82rem; color: var(--text-mid); }

        .stat-bar {
            height: 3px;
            border-radius: 999px;
            margin-top: 1rem;
        }

        /* MIDDLE SECTION */
        .middle-row { display: grid; grid-template-columns: 1fr 320px; gap: 1.25rem; }

        /* REQUESTS TABLE */
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

        .card-actions { display: flex; gap: .6rem; }

        .btn-outline {
            display: flex; align-items: center; gap: .4rem;
            padding: .4rem .85rem;
            border: 1.5px solid var(--border);
            border-radius: 8px;
            background: white;
            font-family: 'DM Sans', sans-serif;
            font-size: .8rem;
            font-weight: 600;
            color: var(--text-mid);
            cursor: pointer;
            transition: border-color .2s, color .2s;
        }

        .btn-outline:hover { border-color: var(--red); color: var(--red); }

        .btn-red-outline {
            display: flex; align-items: center; gap: .4rem;
            padding: .4rem .85rem;
            border: 1.5px solid var(--red);
            border-radius: 8px;
            background: var(--red-light);
            font-family: 'DM Sans', sans-serif;
            font-size: .8rem;
            font-weight: 600;
            color: var(--red);
            cursor: pointer;
        }

        .btn-outline svg, .btn-red-outline svg { width: 14px; height: 14px; fill: currentColor; }

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
        .status-pill.rejected { background: #fee2e2; color: var(--red); }

        .review-link {
            font-size: .82rem;
            color: var(--text-mid);
            font-weight: 500;
            cursor: pointer;
            text-decoration: none;
            transition: color .2s;
        }

        .review-link:hover { color: var(--red); }

        /* SIDEBAR RIGHT */
        .right-col { display: flex; flex-direction: column; gap: 1.1rem; }

        /* QUICK ACTIONS */
        .quick-actions { padding: 1.2rem 1.5rem; }

        .qa-btn {
            width: 100%;
            display: flex;
            align-items: center;
            gap: .8rem;
            padding: .85rem 1rem;
            border-radius: 12px;
            border: none;
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
            font-size: .88rem;
            font-weight: 600;
            margin-bottom: .7rem;
            transition: opacity .2s, transform .15s;
        }

        .qa-btn:hover { opacity: .9; transform: translateY(-1px); }
        .qa-btn:last-child { margin-bottom: 0; }

        .qa-btn svg { width: 20px; height: 20px; fill: currentColor; flex-shrink: 0; }

        .qa-btn .qa-arrow {
            margin-left: auto;
            width: 18px; height: 18px;
            fill: none;
            stroke: currentColor;
            stroke-width: 2.5;
        }

        .qa-red   { background: var(--red); color: white; }
        .qa-dark  { background: #1f2937; color: white; }
        .qa-light { background: var(--red-light); color: var(--red); }

        .qa-light .qa-arrow { stroke: var(--red); }

        .qa-badge {
            margin-left: auto;
            background: var(--red);
            color: white;
            font-size: .7rem;
            font-weight: 700;
            padding: .15rem .5rem;
            border-radius: 999px;
        }

        /* BLOOD DISTRIBUTION */
        .chart-area { padding: 0 1.5rem 1.5rem; }

        .bar-chart {
            display: flex;
            align-items: flex-end;
            gap: .35rem;
            height: 120px;
            margin-top: .5rem;
        }

        .bar-col {
            display: flex;
            flex-direction: column;
            align-items: center;
            flex: 1;
            gap: .3rem;
        }

        .bar {
            width: 100%;
            border-radius: 4px 4px 0 0;
            transition: opacity .2s;
        }

        .bar:hover { opacity: .8; }
        .bar.full { background: var(--red); }
        .bar.light-bar { background: #fca5a5; }

        .bar-label {
            font-size: .65rem;
            color: var(--text-light);
            font-weight: 600;
            text-align: center;
        }

        /* Y-axis lines (decorative) */
        .chart-wrapper { position: relative; }

        .y-lines {
            position: absolute;
            top: 0; left: 0; right: 0; bottom: 20px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            pointer-events: none;
        }

        .y-line {
            border-top: 1px dashed #f0f0f0;
            position: relative;
        }

        .y-line span {
            position: absolute;
            left: -22px;
            top: -8px;
            font-size: .62rem;
            color: var(--text-light);
        }

        /* RECENT ACTIVITY */
        .activity-row {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 1rem;
        }

        .activity-card {
            background: var(--white);
            border-radius: 14px;
            border: 1px solid var(--border);
            padding: 1.1rem 1.2rem;
            box-shadow: var(--shadow);
            display: flex;
            flex-direction: column;
            gap: .6rem;
        }

        .activity-icon {
            width: 36px; height: 36px;
            border-radius: 9px;
            display: flex; align-items: center; justify-content: center;
        }

        .activity-icon svg { width: 18px; height: 18px; }

        .activity-title {
            font-size: .85rem;
            font-weight: 700;
            color: var(--text-dark);
            line-height: 1.3;
        }

        .activity-desc {
            font-size: .78rem;
            color: var(--text-mid);
            line-height: 1.5;
        }

        .activity-time {
            font-size: .72rem;
            color: var(--text-light);
            font-weight: 500;
        }

        .activity-section .card-head { padding: 1.1rem 1.5rem; }

        /* Animations */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .stats-row .stat-card:nth-child(1) { animation: fadeUp .4s ease .05s both; }
        .stats-row .stat-card:nth-child(2) { animation: fadeUp .4s ease .12s both; }
        .stats-row .stat-card:nth-child(3) { animation: fadeUp .4s ease .19s both; }
        .stats-row .stat-card:nth-child(4) { animation: fadeUp .4s ease .26s both; }

        .middle-row { animation: fadeUp .4s ease .3s both; }
        .activity-section { animation: fadeUp .4s ease .4s both; }

    </style>
</head>
<body>

<!--Side Bar-->
<jsp:include page="/includes/sidebar.jsp" />

<!-- MAIN -->
<div class="main">

    <jsp:include page="/includes/admintopbar.jsp" />

    <!-- CONTENT -->
    <div class="content">

        <!-- STAT CARDS -->
        <div class="stats-row">

            <div class="stat-card">
                <div class="stat-card-blob" style="background:var(--red);"></div>
                <div class="stat-icon red">
                    <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                </div>
                <div class="stat-num">${totalDonors}</div>
                <div class="stat-label">Total Donors</div>
                <div class="stat-bar" style="background: linear-gradient(90deg, var(--red) ${totalUsers > 0 ? (totalDonors * 100 / totalUsers) : 0}%, var(--red-light) ${totalUsers > 0 ? (totalDonors * 100 / totalUsers) : 0}%);"></div>
            </div>

            <div class="stat-card">
                <div class="stat-card-blob" style="background:#3b82f6;"></div>
                <div class="stat-icon blue">
                    <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
                </div>
                <div class="stat-num">${totalRecipients}</div>
                <div class="stat-label">Total Recipients</div>
                <div class="stat-bar" style="background: linear-gradient(90deg, #3b82f6 ${totalUsers > 0 ? (totalRecipients * 100 / totalUsers) : 0}%, #dbeafe ${totalUsers > 0 ? (totalRecipients * 100 / totalUsers) : 0}%);"></div>
            </div>

            <div class="stat-card">
                <div class="stat-card-blob" style="background:#f59e0b;"></div>
                <div class="stat-icon amber">
                    <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                </div>
                <div class="stat-num">${totalHospitals}</div>
                <div class="stat-label">Total Hospitals</div>
                <div class="stat-bar" style="background: linear-gradient(90deg, #f59e0b ${totalUsers > 0 ? (totalHospitals * 100 / totalUsers) : 0}%, #fef3c7 ${totalUsers > 0 ? (totalHospitals * 100 / totalUsers) : 0}%);"></div>
            </div>

            <div class="stat-card">
                <div class="stat-card-blob" style="background:var(--red);"></div>
                <div class="stat-icon red">
                    <svg viewBox="0 0 24 24"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
                </div>
                <div class="stat-num">${totalUsers}</div>
                <div class="stat-label">Total Users</div>
                <div class="stat-bar" style="background: linear-gradient(90deg, var(--red) 100%, var(--red-light) 100%);"></div>
            </div>

        </div><!-- /stats-row -->

        <!-- MIDDLE ROW -->
        <div class="middle-row">

            <!-- REQUESTS TABLE -->
            <div class="card">
                <div class="card-head">
                    <div>
                        <h3>Recent Requests</h3>
                        <p>Latest blood request activity</p>
                    </div>
                    <div class="card-actions">
                        <a href="${pageContext.request.contextPath}/admin/users" class="btn-red-outline" style="text-decoration:none;">View All</a>
                        <button class="btn-outline">
                            <svg viewBox="0 0 24 24"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/></svg>
                            Filter
                        </button>
                    </div>
                </div>

                <table>
                    <thead>
                    <tr>
                        <th>User ID</th>
                        <th>Name</th>
                        <th>Blood Group</th>
                        <th>Role</th>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                    </thead>
                    <tbody>
                    <c:forEach items="${recentUsers}" var="u">
                    <tr>
                        <td><span class="req-id">#USR-${u.id}</span></td>
                        <td>${u.firstName} ${u.lastName}</td>
                        <td>
                            <c:choose>
                                <c:when test="${not empty u.bloodGroup}">
                                    <span class="blood-badge bg-red">${u.bloodGroup}</span>
                                </c:when>
                                <c:otherwise>—</c:otherwise>
                            </c:choose>
                        </td>
                        <td>${u.role}</td>
                        <td>
                            <c:choose>
                                <c:when test="${u.status == 'ACTIVE'}">
                                    <span class="status-pill approved">Active</span>
                                </c:when>
                                <c:when test="${u.status == 'INACTIVE'}">
                                    <span class="status-pill pending">Inactive</span>
                                </c:when>
                                <c:otherwise>
                                    <span class="status-pill rejected">Suspended</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                        <td><a href="${pageContext.request.contextPath}/admin/users" class="review-link">View</a></td>
                    </tr>
                    </c:forEach>
                    <c:if test="${empty recentUsers}">
                    <tr>
                        <td colspan="6" style="text-align:center; color:var(--text-light); padding:2rem;">No users found</td>
                    </tr>
                    </c:if>
                    </tbody>
                </table>
            </div><!-- /card -->

            <!-- RIGHT COLUMN -->
            <div class="right-col">

                <!-- QUICK ACTIONS -->
                <div class="card">
                    <div class="card-head" style="border-bottom:none; padding-bottom:.5rem;">
                        <div>
                            <h3>Quick Actions</h3>
                            <p>Manage the platform efficiently</p>
                        </div>
                    </div>
                    <div class="quick-actions" style="padding-top:.3rem;">
                        <a href="${pageContext.request.contextPath}/admin/users?action=add" class="qa-btn qa-red" style="text-decoration:none;">
                            <svg viewBox="0 0 24 24"><path d="M15 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm-9-2V7H4v3H1v2h3v3h2v-3h3v-2H6zm9 4c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
                            Add User
                            <svg class="qa-arrow" viewBox="0 0 24 24"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/reports" class="qa-btn qa-dark" style="text-decoration:none;">
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/></svg>
                            Generate Report
                            <svg class="qa-arrow" viewBox="0 0 24 24" style="stroke:white;"><line x1="5" y1="12" x2="19" y2="12"/><polyline points="12 5 19 12 12 19"/></svg>
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/users" class="qa-btn qa-light" style="text-decoration:none;">
                            <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                            Manage Users
                            <span class="qa-badge">${totalUsers}</span>
                        </a>
                    </div>
                </div>

                <!-- BLOOD GROUP DISTRIBUTION -->
                <div class="card">
                    <div class="card-head" style="border-bottom:none; padding-bottom:.4rem;">
                        <div>
                            <h3>Blood Group Distribution</h3>
                            <p>Available units by blood type</p>
                        </div>
                    </div>
                    <div class="chart-area">
                        <div class="chart-wrapper" style="padding-left: 26px;">
                            <div class="y-lines">
                                <div class="y-line"><span>${maxBloodGroup}</span></div>
                                <div class="y-line"><span>${maxBloodGroup > 0 ? (maxBloodGroup * 0.75) : 0}</span></div>
                                <div class="y-line"><span>${maxBloodGroup > 0 ? (maxBloodGroup * 0.5) : 0}</span></div>
                                <div class="y-line"><span>${maxBloodGroup > 0 ? (maxBloodGroup * 0.25) : 0}</span></div>
                                <div class="y-line"><span>0</span></div>
                            </div>
                            <div class="bar-chart">
                                <c:forEach items="${bloodGroupCounts}" var="entry">
                                <div class="bar-col">
                                    <div class="bar ${entry.value > 0 ? 'full' : 'light-bar'}" style="height:${maxBloodGroup > 0 ? (entry.value * 100 / maxBloodGroup) : 0}px;"></div>
                                    <div class="bar-label">${entry.key}</div>
                                </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>

            </div><!-- /right-col -->
        </div><!-- /middle-row -->

        <!-- RECENT ACTIVITY -->
        <div class="card activity-section">
            <div class="card-head">
                <div>
                    <h3>Recent Activity</h3>
                    <p>Latest system events</p>
                </div>
                <a href="${pageContext.request.contextPath}/admin/users" class="btn-red-outline" style="text-decoration:none;">See All</a>
            </div>

            <div style="padding: 1.1rem 1.5rem;">
                <div class="activity-row">
                    <c:forEach items="${recentActivities}" var="act">
                    <div class="activity-card">
                        <div class="activity-icon" style="background:${act.iconBg};">
                            <svg viewBox="0 0 24 24" fill="${act.iconColor}"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                        </div>
                        <div class="activity-title">${act.title}</div>
                        <div class="activity-desc">${act.desc}</div>
                        <div class="activity-time">${act.time}</div>
                    </div>
                    </c:forEach>
                    <c:if test="${empty recentActivities}">
                    <div style="text-align:center; color:var(--text-light); padding:2rem; width:100%;">No recent activity</div>
                    </c:if>
                </div>
            </div>
        </div><!-- /activity -->

    </div><!-- /content -->
</div><!-- /main -->

</body>
</html>
