<%--
  Admin Reports – LifeLink
  Updated: 15/05/2026
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>System Reports – LifeLink</title>
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

        /* DATE BAR */
        .date-bar {
            display: flex;
            align-items: center;
            gap: 1rem;
            flex-wrap: wrap;
        }

        .date-picker {
            display: flex;
            align-items: center;
            gap: .6rem;
            padding: .5rem .9rem;
            background: var(--white);
            border: 1.5px solid var(--border);
            border-radius: 10px;
            font-size: .85rem;
            font-weight: 500;
            color: var(--text-mid);
            cursor: pointer;
        }

        .date-picker svg { width: 16px; height: 16px; fill: var(--red); }

        .date-pills { display: flex; align-items: center; gap: .4rem; }

        .dpill {
            padding: .5rem .9rem;
            border-radius: 10px;
            font-size: .82rem;
            font-weight: 600;
            cursor: pointer;
            border: 1.5px solid var(--border);
            background: white;
            color: var(--text-mid);
            transition: all .2s;
            font-family: 'DM Sans', sans-serif;
            text-decoration: none;
        }

        .dpill:hover { border-color: var(--red); color: var(--red); }
        .dpill.active { background: var(--red); color: white; border-color: var(--red); }

        .date-actions { display: flex; align-items: center; gap: .6rem; margin-left: auto; }

        .btn-icon {
            display: flex; align-items: center; gap: .4rem;
            padding: .5rem .9rem;
            border-radius: 10px;
            border: 1.5px solid var(--border);
            background: white;
            font-family: 'DM Sans', sans-serif;
            font-size: .82rem;
            font-weight: 600;
            color: var(--text-mid);
            cursor: pointer;
            transition: all .2s;
            text-decoration: none;
        }

        .btn-icon:hover { border-color: var(--red); color: var(--red); }
        .btn-icon svg { width: 16px; height: 16px; fill: currentColor; }

        .btn-refresh {
            display: flex; align-items: center; gap: .4rem;
            padding: .5rem .9rem;
            border-radius: 10px;
            border: none;
            background: var(--red);
            font-family: 'DM Sans', sans-serif;
            font-size: .82rem;
            font-weight: 600;
            color: white;
            cursor: pointer;
            transition: opacity .2s;
        }
        .btn-refresh:hover { opacity: .9; }
        .btn-refresh svg { width: 16px; height: 16px; fill: currentColor; }

        /* CHARTS ROW */
        .charts-row { display: grid; grid-template-columns: 1.4fr 1fr; gap: 1.25rem; }

        .card {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow);
            overflow: hidden;
        }

        .card-head {
            padding: 1.2rem 1.5rem;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
        }

        .card-head h3 { font-size: 1rem; font-weight: 700; color: var(--text-dark); }
        .card-head p  { font-size: .78rem; color: var(--text-mid); margin-top: .15rem; }

        .trend-up {
            display: inline-flex;
            align-items: center;
            gap: .2rem;
            font-size: .78rem;
            font-weight: 700;
            color: #059669;
            background: #d1fae5;
            padding: .25rem .55rem;
            border-radius: 6px;
        }

        .trend-up svg { width: 12px; height: 12px; fill: currentColor; }

        .card-icon-btn {
            width: 32px; height: 32px;
            border-radius: 8px;
            border: 1.5px solid var(--border);
            background: white;
            display: flex; align-items: center; justify-content: center;
            cursor: pointer;
            color: var(--text-mid);
        }
        .card-icon-btn svg { width: 14px; height: 14px; fill: currentColor; }

        /* Line Chart */
        .chart-area { padding: 0 1.5rem 1.5rem; }

        .line-chart-wrapper { position: relative; height: 220px; }

        .line-chart-svg { width: 100%; height: 100%; }

        /* Donut Chart */
        .donut-wrap {
            display: flex;
            align-items: center;
            gap: 1.5rem;
            padding: 0 1.5rem 1.5rem;
        }

        .donut-chart {
            width: 180px; height: 180px;
            flex-shrink: 0;
        }

        .donut-legend { flex: 1; display: flex; flex-direction: column; gap: .55rem; }

        .legend-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: .82rem;
        }

        .legend-left { display: flex; align-items: center; gap: .5rem; }
        .legend-dot { width: 10px; height: 10px; border-radius: 50%; }
        .legend-name { font-weight: 500; color: var(--text-dark); }
        .legend-pct { font-weight: 700; color: var(--text-dark); }

        /* BOTTOM ROW */
        .bottom-row { display: grid; grid-template-columns: 1fr 1fr; gap: 1.25rem; }

        /* Fulfillment */
        .fulfill-body {
            padding: 0 1.5rem 1.5rem;
            display: flex;
            gap: 1.5rem;
            align-items: center;
        }

        .donut-progress {
            width: 140px; height: 140px;
            position: relative;
            flex-shrink: 0;
        }

        .donut-progress svg { transform: rotate(-90deg); }

        .donut-progress-text {
            position: absolute;
            inset: 0;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
        }

        .donut-progress-text .pct {
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--text-dark);
            line-height: 1;
        }

        .donut-progress-text .lbl {
            font-size: .7rem;
            color: var(--text-light);
            margin-top: .2rem;
        }

        .fulfill-bars { flex: 1; display: flex; flex-direction: column; gap: .9rem; }

        .fbar { display: flex; flex-direction: column; gap: .35rem; }
        .fbar-head { display: flex; justify-content: space-between; font-size: .78rem; }
        .fbar-name { color: var(--text-mid); font-weight: 500; }
        .fbar-val { color: var(--text-dark); font-weight: 700; }
        .fbar-track { height: 8px; background: #f3f4f6; border-radius: 999px; overflow: hidden; }
        .fbar-fill { height: 100%; border-radius: 999px; }

        .fbar-fill.green { background: #059669; }
        .fbar-fill.amber { background: #f59e0b; }
        .fbar-fill.red   { background: var(--red); }

        .fulfill-summary {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: .75rem;
            padding: 0 1.5rem 1.5rem;
        }

        .fsum-card {
            border-radius: 12px;
            padding: 1rem;
            text-align: center;
            border: 1.5px solid transparent;
        }

        .fsum-card.green { background: #f0fdf4; border-color: #bbf7d0; }
        .fsum-card.amber { background: #fffbeb; border-color: #fde68a; }
        .fsum-card.red   { background: var(--red-light); border-color: #fecaca; }

        .fsum-num { font-size: 1.3rem; font-weight: 700; line-height: 1; }
        .fsum-card.green .fsum-num { color: #059669; }
        .fsum-card.amber .fsum-num { color: #d97706; }
        .fsum-card.red   .fsum-num { color: var(--red); }

        .fsum-label { font-size: .75rem; color: var(--text-mid); margin-top: .3rem; font-weight: 500; }

        /* Top Donors */
        .donors-list {
            padding: 0 1.5rem 1.5rem;
            display: flex;
            flex-direction: column;
            gap: .6rem;
        }

        .donor-row {
            display: flex;
            align-items: center;
            gap: .75rem;
            padding: .7rem .8rem;
            border-radius: 12px;
            transition: background .2s;
        }

        .donor-row:hover { background: #fafafa; }
        .donor-row.gold { background: #fffbeb; border: 1.5px solid #fde68a; }

        .donor-rank {
            width: 28px; height: 28px;
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: .75rem;
            font-weight: 700;
            flex-shrink: 0;
        }

        .donor-rank.gold { background: #fef3c7; color: #d97706; }
        .donor-rank.silver { background: #f3f4f6; color: var(--text-mid); }
        .donor-rank.bronze { background: #fef3c7; color: #d97706; }
        .donor-rank.plain { background: #f3f4f6; color: var(--text-light); }

        .donor-avatar {
            width: 38px; height: 38px;
            border-radius: 50%;
            background: var(--red-light);
            display: flex; align-items: center; justify-content: center;
            font-size: .8rem;
            font-weight: 700;
            color: var(--red);
            flex-shrink: 0;
        }

        .donor-info { flex: 1; min-width: 0; }
        .donor-name { font-weight: 600; font-size: .85rem; color: var(--text-dark); }
        .donor-bg { font-size: .75rem; color: var(--text-light); }

        .donor-count {
            display: flex;
            align-items: center;
            gap: .3rem;
            font-size: .85rem;
            font-weight: 700;
            color: var(--text-dark);
        }

        .donor-count svg { width: 14px; height: 14px; }

        .medal-gold { fill: #f59e0b; }
        .medal-silver { fill: #9ca3af; }
        .medal-bronze { fill: #ea580c; }

        .empty-state {
            text-align: center;
            padding: 2rem;
            color: var(--text-light);
            font-size: .85rem;
        }

        /* Animations */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .date-bar { animation: fadeUp .4s ease .05s both; }
        .charts-row { animation: fadeUp .4s ease .15s both; }
        .bottom-row { animation: fadeUp .4s ease .3s both; }
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

        <!-- DATE BAR -->
        <div class="date-bar">
            <div class="date-picker">
                <svg viewBox="0 0 24 24"><path d="M19 3h-1V1h-2v2H8V1H6v2H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V8h14v11z"/></svg>
                ${fromDate} &nbsp;—&nbsp; ${toDate} &nbsp;<span style="color:var(--text-light);">▼</span>
            </div>
            <div class="date-pills">
                <a href="${pageContext.request.contextPath}/admin/reports?period=month" class="dpill ${empty period || period eq 'month' ? 'active' : ''}">This Month</a>
                <a href="${pageContext.request.contextPath}/admin/reports?period=3months" class="dpill ${period eq '3months' ? 'active' : ''}">Last 3 Months</a>
                <a href="${pageContext.request.contextPath}/admin/reports?period=year" class="dpill ${period eq 'year' ? 'active' : ''}">This Year</a>
            </div>
            <div class="date-actions">
                <a href="${pageContext.request.contextPath}/admin/reports/export?type=pdf&fromDate=${fromDate}&toDate=${toDate}" class="btn-icon">
                    <svg viewBox="0 0 24 24"><path d="M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z"/></svg>
                    Export PDF
                </a>
                <a href="${pageContext.request.contextPath}/admin/reports/export?type=csv&fromDate=${fromDate}&toDate=${toDate}" class="btn-icon">
                    <svg viewBox="0 0 24 24"><path d="M19 9h-4V3H9v6H5l7 7 7-7zM5 18v2h14v-2H5z"/></svg>
                    Export Excel
                </a>
                <button class="btn-refresh" onclick="location.reload()">
                    <svg viewBox="0 0 24 24"><path d="M17.65 6.35A7.95 7.95 0 0012 4a8 8 0 108 8h-2a6 6 0 11-6-6c1.66 0 3.14.69 4.22 1.76L13 11h7V4l-2.35 2.35z"/></svg>
                    Refresh
                </button>
            </div>
        </div><!-- /date-bar -->

        <!-- CHARTS ROW -->
        <div class="charts-row">

            <!-- Donation Trends -->
            <div class="card">
                <div class="card-head">
                    <div>
                        <h3>Donation Trends</h3>
                        <p>Monthly donations over the selected period</p>
                    </div>
                    <div style="display:flex; align-items:center; gap:.6rem;">
                        <span class="trend-up">
                            <svg viewBox="0 0 24 24"><path d="M7 14l5-5 5 5M12 9v10"/></svg>
                            ${totalDonated} units
                        </span>
                        <button class="card-icon-btn">
                            <svg viewBox="0 0 24 24"><path d="M3 3v18h18"/><path d="M18 9l-5 5-4-4-3 3"/></svg>
                        </button>
                    </div>
                </div>
                <div class="chart-area">
                    <div class="line-chart-wrapper" id="trendsChart">
                        <svg class="line-chart-svg" viewBox="0 0 600 220" preserveAspectRatio="none">
                            <!-- Will be populated by JS -->
                        </svg>
                    </div>
                </div>
            </div><!-- /card -->

            <!-- Blood Group Distribution -->
            <div class="card">
                <div class="card-head">
                    <div>
                        <h3>Blood Group Distribution</h3>
                        <p>Donor share by blood type</p>
                    </div>
                    <button class="card-icon-btn">
                        <svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"/><line x1="12" y1="16" x2="12" y2="12"/><line x1="12" y1="8" x2="12.01" y2="8"/></svg>
                    </button>
                </div>
                <div class="donut-wrap" id="bgChart">
                    <!-- Populated by JS -->
                </div>
            </div><!-- /card -->

        </div><!-- /charts-row -->

        <!-- BOTTOM ROW -->
        <div class="bottom-row">

            <!-- Request Fulfillment Rate -->
            <div class="card">
                <div class="card-head">
                    <div>
                        <h3>Request Fulfillment Rate</h3>
                        <p>How well requests are being met</p>
                    </div>
                    <div style="width:28px;height:28px;border-radius:8px;background:#d1fae5;display:flex;align-items:center;justify-content:center;">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="#059669"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                    </div>
                </div>
                <div class="fulfill-body">
                    <div class="donut-progress">
                        <svg viewBox="0 0 140 140">
                            <circle cx="70" cy="70" r="58" fill="none" stroke="#f3f4f6" stroke-width="10"/>
                            <circle id="fulfillRing" cx="70" cy="70" r="58" fill="none" stroke="#b91c1c" stroke-width="10"
                                    stroke-dasharray="0 363.8" stroke-linecap="round"
                                    stroke-dashoffset="0"/>
                        </svg>
                        <div class="donut-progress-text">
                            <div class="pct" id="fulfillPct">0%</div>
                            <div class="lbl">Fulfilled</div>
                        </div>
                    </div>
                    <div class="fulfill-bars">
                        <div class="fbar">
                            <div class="fbar-head"><span class="fbar-name">Fulfilled</span><span class="fbar-val" id="fbarF">0</span></div>
                            <div class="fbar-track"><div class="fbar-fill green" id="fbarFW" style="width:0%;"></div></div>
                        </div>
                        <div class="fbar">
                            <div class="fbar-head"><span class="fbar-name">Pending</span><span class="fbar-val" id="fbarP">0</span></div>
                            <div class="fbar-track"><div class="fbar-fill amber" id="fbarPW" style="width:0%;"></div></div>
                        </div>
                        <div class="fbar">
                            <div class="fbar-head"><span class="fbar-name">Rejected</span><span class="fbar-val" id="fbarR">0</span></div>
                            <div class="fbar-track"><div class="fbar-fill red" id="fbarRW" style="width:0%;"></div></div>
                        </div>
                    </div>
                </div>
                <div class="fulfill-summary">
                    <div class="fsum-card green">
                        <div class="fsum-num" id="fsumF">0</div>
                        <div class="fsum-label">Fulfilled</div>
                    </div>
                    <div class="fsum-card amber">
                        <div class="fsum-num" id="fsumP">0</div>
                        <div class="fsum-label">Pending</div>
                    </div>
                    <div class="fsum-card red">
                        <div class="fsum-num" id="fsumR">0</div>
                        <div class="fsum-label">Rejected</div>
                    </div>
                </div>
            </div><!-- /card -->

            <!-- Top Donors -->
            <div class="card">
                <div class="card-head">
                    <div>
                        <h3>Top Donors</h3>
                        <p>Most active donors this period</p>
                    </div>
                    <div style="display:flex;align-items:center;gap:.5rem;">
                        <div style="width:28px;height:28px;border-radius:8px;background:var(--red-light);display:flex;align-items:center;justify-content:center;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="#b91c1c"><path d="M19 5h-2V3H7v2H5c-1.1 0-2 .9-2 2v1c0 2.55 1.28 4.8 3.23 6.14.65.45 1.35.8 2.1 1.03V21h7.89v-4.83c.75-.23 1.45-.58 2.1-1.03C20.72 13.8 22 11.55 22 9V7c0-1.1-.9-2-2-2zM7 10.82C5.84 9.88 5.07 8.55 5 7h2v3.82zm0 0C7 10.82 7 10.82 7 10.82zM17 10.82V7h2c-.07 1.55-.84 2.88-2 3.82z"/></svg>
                        </div>
                    </div>
                </div>
                <div class="donors-list" id="topDonorsList">
                    <!-- Populated by JS -->
                </div>
            </div><!-- /card -->

        </div><!-- /bottom-row -->

    </div><!-- /content -->
</div><!-- /main -->

<script>
// --- Donation Trends Line Chart ---
const monthlyData = ${monthlyDonationsJson};
(function drawTrends() {
    const svg = document.querySelector('#trendsChart svg');
    if (!monthlyData || monthlyData.length === 0) {
        svg.innerHTML = '<text x="300" y="110" text-anchor="middle" fill="#9ca3af" font-size="14">No donation data for this period</text>';
        return;
    }

    const vbW = 600, vbH = 220;
    const padL = 40, padR = 10, padT = 10, padB = 30;
    const chartW = vbW - padL - padR;
    const chartH = vbH - padT - padB;

    const maxVal = Math.max(...monthlyData.map(d => d.units || d.count || 0), 1);
    const niceMax = Math.ceil(maxVal / 10) * 10 || 10;

    let gridLines = '', yLabels = '';
    const steps = 4;
    for (let i = 0; i <= steps; i++) {
        const y = padT + (chartH * i / steps);
        const val = Math.round(niceMax * (steps - i) / steps);
        gridLines += '<line x1="' + padL + '" y1="' + y + '" x2="' + (vbW - padR) + '" y2="' + y + '" stroke="#f3f4f6" stroke-width="1"/>';
        yLabels += '<text x="' + (padL - 6) + '" y="' + (y + 4) + '" font-size="10" fill="#9ca3af" text-anchor="end">' + val + '</text>';
    }

    let points = '';
    let areaPath = 'M' + padL + ',' + (padT + chartH) + ' ';
    let circles = '';
    let xLabels = '';

    monthlyData.forEach((d, i) => {
        const x = padL + (chartW * i / Math.max(monthlyData.length - 1, 1));
        const val = d.units || d.count || 0;
        const y = padT + chartH - (val / niceMax * chartH);
        points += x + ',' + y + ' ';
        areaPath += 'L' + x + ',' + y + ' ';
        circles += '<circle cx="' + x + '" cy="' + y + '" r="3" fill="#b91c1c"/>';

        const label = d.month ? d.month.substring(5) : '';
        xLabels += '<text x="' + x + '" y="' + (vbH - 8) + '" font-size="10" fill="#9ca3af" text-anchor="middle">' + label + '</text>';
    });
    areaPath += 'L' + (padL + chartW) + ',' + (padT + chartH) + ' Z';

    // Strip M, L, Z for polygon points attribute
    const polyPoints = areaPath.replace(/M|L|Z/g, '').trim().replace(/\s+/g, ' ');

    svg.innerHTML = gridLines +
        '<polygon points="' + polyPoints + '" fill="rgba(185,28,28,0.06)"/>' +
        '<polyline points="' + points.trim() + '" fill="none" stroke="#b91c1c" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>' +
        circles + yLabels + xLabels;
})();

// --- Blood Group Distribution Donut Chart ---
const bgData = ${bloodGroupDistJson};
(function drawDonut() {
    const container = document.getElementById('bgChart');
    if (!bgData || bgData.length === 0) {
        container.innerHTML = '<div class="empty-state">No blood group data available</div>';
        return;
    }

    const total = bgData.reduce((s, d) => s + d.count, 0);
    const colors = ['#dc2626','#ef4444','#fca5a5','#f59e0b','#fbbf24','#fde047','#e879f9','#d1d5db','#9ca3af','#6b7280'];
    const circ = 2 * Math.PI * 80; // r=80

    let circles = '';
    let legend = '';
    let offset = 0;

    bgData.forEach((d, i) => {
        const pct = d.count / total;
        const dash = pct * circ;
        const gap = circ - dash;
        circles += '<circle cx="100" cy="100" r="80" fill="none" stroke="' + colors[i % colors.length] + '" stroke-width="40"' +
                    ' stroke-dasharray="' + dash.toFixed(2) + ' ' + gap.toFixed(2) + '" stroke-dashoffset="' + (-offset).toFixed(2) + '"/>';
        offset += dash;

        legend += '<div class="legend-item">' +
                '<div class="legend-left"><span class="legend-dot" style="background:' + colors[i % colors.length] + ';"></span><span class="legend-name">' + d.bloodGroup + '</span></div>' +
                '<span class="legend-pct">' + (pct * 100).toFixed(1) + '%</span>' +
            '</div>';
    });

    container.innerHTML = '<svg class="donut-chart" viewBox="0 0 200 200" style="transform: rotate(-90deg);">' + circles + '</svg>' +
        '<div class="donut-legend">' + legend + '</div>';
})();

// --- Request Fulfillment Rate ---
const fulfillData = ${fulfillmentStatsJson};
(function drawFulfillment() {
    const f = fulfillData.FULFILLED || 0;
    const p = fulfillData.PENDING || 0;
    const r = fulfillData.REJECTED || 0;
    const total = f + p + r;
    const pct = total > 0 ? Math.round((f / total) * 100) : 0;

    const circ = 2 * Math.PI * 58;
    const dash = (pct / 100) * circ;
    const gap = circ - dash;

    document.getElementById('fulfillRing').setAttribute('stroke-dasharray', dash.toFixed(2) + ' ' + gap.toFixed(2));
    document.getElementById('fulfillPct').textContent = pct + '%';

    document.getElementById('fbarF').textContent = f;
    document.getElementById('fbarP').textContent = p;
    document.getElementById('fbarR').textContent = r;

    document.getElementById('fbarFW').style.width = total > 0 ? ((f / total) * 100) + '%' : '0%';
    document.getElementById('fbarPW').style.width = total > 0 ? ((p / total) * 100) + '%' : '0%';
    document.getElementById('fbarRW').style.width = total > 0 ? ((r / total) * 100) + '%' : '0%';

    document.getElementById('fsumF').textContent = f;
    document.getElementById('fsumP').textContent = p;
    document.getElementById('fsumR').textContent = r;
})();

// --- Top Donors ---
const donorsData = ${topDonorsJson};
(function drawDonors() {
    const container = document.getElementById('topDonorsList');
    if (!donorsData || donorsData.length === 0) {
        container.innerHTML = '<div class="empty-state">No donors in this period</div>';
        return;
    }

    const medals = [
        { cls: 'medal-gold', fill: '#f59e0b' },
        { cls: 'medal-silver', fill: '#9ca3af' },
        { cls: 'medal-bronze', fill: '#ea580c' },
        { cls: 'medal-silver', fill: '#9ca3af' },
        { cls: 'medal-silver', fill: '#9ca3af' }
    ];

    const rankCls = ['gold','silver','bronze','plain','plain'];

    let html = '';
    donorsData.forEach((d, i) => {
        const initials = d.name.split(' ').map(n => n[0]).join('').substring(0,2).toUpperCase();
        const m = medals[i] || medals[3];
        const rc = rankCls[i] || 'plain';
        const goldCls = i === 0 ? ' gold' : '';
        html += '<div class="donor-row' + goldCls + '">' +
                '<div class="donor-rank ' + rc + '">' + (i + 1) + '</div>' +
                '<div class="donor-avatar">' + initials + '</div>' +
                '<div class="donor-info">' +
                    '<div class="donor-name">' + d.name + '</div>' +
                    '<div class="donor-bg">Blood Group: ' + (d.bloodGroup || 'N/A') + '</div>' +
                '</div>' +
                '<div class="donor-count">' +
                    d.totalUnits +
                    '<svg class="' + m.cls + '" viewBox="0 0 24 24"><path d="M19 5h-2V3H7v2H5c-1.1 0-2 .9-2 2v1c0 2.55 1.28 4.8 3.23 6.14.65.45 1.35.8 2.1 1.03V21h7.89v-4.83c.75-.23 1.45-.58 2.1-1.03C20.72 13.8 22 11.55 22 9V7c0-1.1-.9-2-2-2z"/></svg>' +
                '</div>' +
                '<div style="font-size:.7rem;color:var(--text-light);">units</div>' +
            '</div>';
    });
    container.innerHTML = html;
})();
</script>

</body>
</html>
