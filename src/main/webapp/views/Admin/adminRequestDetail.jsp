<%--
  Request Detail – LifeLink
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Request Detail – LifeLink</title>
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

        /* Back link */
        .back-link {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            font-size: .85rem;
            font-weight: 600;
            color: var(--text-mid);
            text-decoration: none;
            transition: color .2s;
        }
        .back-link:hover { color: var(--red); }
        .back-link svg { width: 16px; height: 16px; fill: none; stroke: currentColor; stroke-width: 2; }

        /* Detail Card */
        .detail-card {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow);
            overflow: hidden;
            max-width: 720px;
        }

        .detail-header {
            padding: 1.5rem 2rem;
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .detail-header-left { display: flex; align-items: center; gap: 1rem; }

        .detail-avatar {
            width: 56px; height: 56px;
            border-radius: 50%;
            background: var(--red-light);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--red);
        }

        .detail-title h2 { font-size: 1.1rem; font-weight: 700; color: var(--text-dark); }
        .detail-title p { font-size: .8rem; color: var(--text-mid); margin-top: .15rem; }

        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: .35rem;
            padding: .35rem .8rem;
            border-radius: 999px;
            font-size: .8rem;
            font-weight: 600;
        }
        .status-pill::before {
            content: '';
            width: 7px; height: 7px;
            border-radius: 50%;
            background: currentColor;
            opacity: .8;
        }
        .status-pill.pending  { background: #fef3c7; color: #d97706; }
        .status-pill.approved { background: #d1fae5; color: #059669; }
        .status-pill.rejected { background: var(--red-light); color: var(--red); }

        .detail-body {
            padding: 1.5rem 2rem;
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 1.25rem;
        }

        .field { display: flex; flex-direction: column; gap: .35rem; }
        .field-label { font-size: .72rem; font-weight: 700; letter-spacing: .05em; text-transform: uppercase; color: var(--text-light); }
        .field-value { font-size: .95rem; font-weight: 600; color: var(--text-dark); }

        .blood-badge {
            display: inline-flex;
            align-items: center;
            justify-content: center;
            padding: .3rem .7rem;
            border-radius: 6px;
            font-size: .85rem;
            font-weight: 700;
            color: white;
            width: fit-content;
        }
        .bg-red    { background: #dc2626; }
        .bg-blue   { background: #2563eb; }
        .bg-purple { background: #7c3aed; }
        .bg-green  { background: #059669; }
        .bg-teal   { background: #0d9488; }
        .bg-orange { background: #ea580c; }

        .detail-footer {
            padding: 1.25rem 2rem;
            border-top: 1px solid var(--border);
            display: flex;
            align-items: center;
            gap: .75rem;
        }

        .btn {
            display: inline-flex; align-items: center; gap: .4rem;
            padding: .55rem 1rem;
            border-radius: 8px;
            font-family: 'DM Sans', sans-serif;
            font-size: .85rem;
            font-weight: 600;
            cursor: pointer;
            border: 1px solid transparent;
            text-decoration: none;
            transition: all .2s;
        }

        .btn-approve { background: #d1fae5; color: #059669; border-color: #059669; }
        .btn-approve:hover { background: #059669; color: white; }

        .btn-reject { background: var(--red-light); color: var(--red); border-color: var(--red); }
        .btn-reject:hover { background: var(--red); color: white; }

        .btn-back { background: #f3f4f6; color: var(--text-mid); border-color: var(--border); }
        .btn-back:hover { background: var(--text-mid); color: white; }

        .btn svg { width: 14px; height: 14px; fill: currentColor; }
        .btn.disabled { opacity: .5; cursor: not-allowed; }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(16px); }
            to   { opacity: 1; transform: translateY(0); }
        }
        .detail-card { animation: fadeUp .4s ease both; }
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

        <a href="${pageContext.request.contextPath}/admin/requests" class="back-link">
            <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
            Back to Requests
        </a>

        <div class="detail-card">
            <div class="detail-header">
                <div class="detail-header-left">
                    <div class="detail-avatar">${requestDetail.initials}</div>
                    <div class="detail-title">
                        <h2>${requestDetail.requesterName}</h2>
                        <p>${requestDetail.formattedRequestId}</p>
                    </div>
                </div>
                <c:choose>
                    <c:when test="${requestDetail.status == 'PENDING'}">
                        <span class="status-pill pending">Pending</span>
                    </c:when>
                    <c:when test="${requestDetail.status == 'APPROVED'}">
                        <span class="status-pill approved">Approved</span>
                    </c:when>
                    <c:when test="${requestDetail.status == 'REJECTED'}">
                        <span class="status-pill rejected">Rejected</span>
                    </c:when>
                </c:choose>
            </div>

            <div class="detail-body">
                <div class="field">
                    <span class="field-label">Request ID</span>
                    <span class="field-value">${requestDetail.formattedRequestId}</span>
                </div>
                <div class="field">
                    <span class="field-label">Requester Name</span>
                    <span class="field-value">${requestDetail.requesterName}</span>
                </div>
                <div class="field">
                    <span class="field-label">Email</span>
                    <span class="field-value">${requestDetail.requesterEmail}</span>
                </div>
                <div class="field">
                    <span class="field-label">Blood Group</span>
                    <c:choose>
                        <c:when test="${requestDetail.bloodGroup == 'A+'}"><span class="blood-badge bg-red">A+</span></c:when>
                        <c:when test="${requestDetail.bloodGroup == 'A-'}"><span class="blood-badge bg-blue">A-</span></c:when>
                        <c:when test="${requestDetail.bloodGroup == 'B+'}"><span class="blood-badge bg-purple">B+</span></c:when>
                        <c:when test="${requestDetail.bloodGroup == 'B-'}"><span class="blood-badge bg-orange">B-</span></c:when>
                        <c:when test="${requestDetail.bloodGroup == 'O+'}"><span class="blood-badge bg-green">O+</span></c:when>
                        <c:when test="${requestDetail.bloodGroup == 'O-'}"><span class="blood-badge bg-blue">O-</span></c:when>
                        <c:when test="${requestDetail.bloodGroup == 'AB+'}"><span class="blood-badge bg-red">AB+</span></c:when>
                        <c:when test="${requestDetail.bloodGroup == 'AB-'}"><span class="blood-badge bg-teal">AB-</span></c:when>
                        <c:otherwise><span class="blood-badge bg-red">${requestDetail.bloodGroup}</span></c:otherwise>
                    </c:choose>
                </div>
                <div class="field">
                    <span class="field-label">Units Requested</span>
                    <span class="field-value">${requestDetail.units} unit${requestDetail.units > 1 ? 's' : ''}</span>
                </div>
                <div class="field">
                    <span class="field-label">Request Date</span>
                    <span class="field-value">${requestDetail.formattedDate}</span>
                </div>
            </div>

            <div class="detail-footer">
                <a href="${pageContext.request.contextPath}/admin/requests" class="btn btn-back">
                    <svg viewBox="0 0 24 24"><polyline points="15 18 9 12 15 6"/></svg>
                    Back
                </a>

                <c:choose>
                    <c:when test="${requestDetail.status == 'PENDING'}">
                        <form method="post" action="${pageContext.request.contextPath}/admin/requests/action" style="display:inline;">
                            <input type="hidden" name="id" value="${requestDetail.id}"/>
                            <input type="hidden" name="action" value="approve"/>
                            <button type="submit" class="btn btn-approve">
                                <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                                Approve
                            </button>
                        </form>
                        <form method="post" action="${pageContext.request.contextPath}/admin/requests/action" style="display:inline;">
                            <input type="hidden" name="id" value="${requestDetail.id}"/>
                            <input type="hidden" name="action" value="reject"/>
                            <button type="submit" class="btn btn-reject">
                                <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                                Reject
                            </button>
                        </form>
                    </c:when>
                    <c:otherwise>
                        <button class="btn btn-approve disabled" disabled>
                            <svg viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>
                            Approve
                        </button>
                        <button class="btn btn-reject disabled" disabled>
                            <svg viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>
                            Reject
                        </button>
                    </c:otherwise>
                </c:choose>
            </div>
        </div><!-- /detail-card -->

    </div><!-- /content -->
</div><!-- /main -->

</body>
</html>
