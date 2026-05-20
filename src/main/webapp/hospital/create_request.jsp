<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Request - LifeLink</title>
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

        * { box-sizing: border-box; }
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: var(--bg-page); color: var(--text-primary); }
        a { color: inherit; text-decoration: none; }
        .layout { display: flex; min-height: 100vh; }
        .sidebar { width: 220px; min-width: 220px; background: linear-gradient(180deg, #220909 0%, var(--dark-sidebar) 100%); color: #f8d7d3; padding: 24px 16px; display: flex; flex-direction: column; position: fixed; inset: 0 auto 0 0; }
        .brand { display: flex; align-items: center; gap: 12px; color: #fff; font-size: 20px; font-weight: 700; margin-bottom: 28px; }
        .brand-icon, .nav-icon, .logout-icon, .profile-icon, .topbar-bell, .header-icon, .tip-mark { display: inline-flex; align-items: center; justify-content: center; }
        .brand-icon { width: 38px; height: 38px; background: var(--red); border-radius: 12px; color: #fff; font-weight: 700; }
        .sidebar-label { font-size: 12px; letter-spacing: 2px; text-transform: uppercase; color: #c97b74; margin: 0 8px 12px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; }
        .nav-link { display: flex; align-items: center; gap: 12px; padding: 14px 16px; border-radius: 14px; color: #f7d8d5; transition: background .2s ease; }
        .nav-link:hover { background: var(--sidebar-hover); }
        .nav-link.active { background: var(--red); color: #fff; font-weight: 700; box-shadow: inset -4px 0 0 rgba(255,255,255,.7); }
        .nav-icon, .logout-icon { width: 32px; height: 32px; border-radius: 10px; background: rgba(255,255,255,.08); flex-shrink: 0; }
        .nav-badge, .bell-badge { min-width: 24px; height: 24px; padding: 0 8px; border-radius: 999px; background: var(--red); color: #fff; font-size: 12px; font-weight: 700; display: inline-flex; align-items: center; justify-content: center; }
        .nav-badge { margin-left: auto; }
        .sidebar-spacer { flex: 1; }
        .sidebar-footer { border-top: 1px solid rgba(255,255,255,.08); padding-top: 18px; }
        .logout-link { display: flex; align-items: center; gap: 12px; color: #ffd8d2; margin-bottom: 18px; padding: 10px 12px; border-radius: 12px; }
        .hospital-account { background: rgba(192,57,43,.2); border: 1px solid rgba(255,255,255,.08); border-radius: 14px; padding: 12px 14px; display: flex; align-items: center; gap: 12px; color: #fff; }
        .hospital-account strong, .topbar-profile strong { display: block; font-size: 15px; line-height: 1.2; }
        .hospital-account span, .topbar-profile span { display: block; color: #d0d5dd; font-size: 13px; line-height: 1.3; }
        .content { margin-left: 220px; width: calc(100% - 220px); }
        .topbar { background: #fff; padding: 16px 28px; border-bottom: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; gap: 20px; }
        .topbar-left { display: flex; align-items: center; gap: 14px; }
        .back-link { width: 36px; height: 36px; border-radius: 12px; border: 1px solid var(--border); display: inline-flex; align-items: center; justify-content: center; color: #98a2b3; background: #fff; }
        .topbar h1 { margin: 0; font-size: 24px; }
        .topbar p { margin: 4px 0 0; color: #98a2b3; }
        .topbar-right { display: flex; align-items: center; gap: 16px; }
        .topbar-bell { width: 42px; height: 42px; border-radius: 14px; border: 1px solid var(--border); background: #f8fafc; position: relative; color: #6b7280; }
        .bell-badge { position: absolute; top: -8px; right: -8px; min-width: 22px; height: 22px; font-size: 11px; }
        .profile-icon { width: 42px; height: 42px; border-radius: 14px; background: var(--red); color: #fff; font-weight: 700; }
        .topbar-profile { display: flex; align-items: center; gap: 12px; }
        .page-body { padding: 28px; }
        .breadcrumb { color: #98a2b3; font-size: 14px; margin-bottom: 18px; }
        .breadcrumb strong { color: var(--red); }
        .page-grid { display: grid; grid-template-columns: 1fr 320px; gap: 24px; }
        .card, .side-card { background: var(--card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
        .card { overflow: hidden; }
        .form-header { background: linear-gradient(90deg, #fdecec, #fff6f5); padding: 24px 28px; display: flex; align-items: center; justify-content: space-between; gap: 16px; }
        .form-header-left { display: flex; align-items: center; gap: 16px; }
        .header-icon { width: 48px; height: 48px; border-radius: 14px; background: var(--red); color: #fff; font-weight: 700; }
        .new-entry { padding: 10px 14px; border-radius: 999px; background: #fff; color: var(--red); font-weight: 700; border: 1px solid #f7d1cc; }
        .form-header h2, .side-card h3 { margin: 0; font-size: 18px; }
        .form-header p, .side-card p { margin: 4px 0 0; color: #98a2b3; }
        .form-body { padding: 28px; }
        .form-error-banner { background: #fef2f2; border-left: 4px solid #ef4444; padding: 12px 16px; border-radius: 8px; color: #b91c1c; margin-bottom: 18px; }
        .field-group { margin-bottom: 18px; }
        .field-label { display: block; font-weight: 700; margin-bottom: 8px; color: #344054; }
        .required { color: #e53e3e; }
        .input-wrap { position: relative; }
        .input-icon, .input-suffix { position: absolute; top: 50%; transform: translateY(-50%); color: #98a2b3; font-size: 14px; }
        .input-icon { left: 14px; }
        .input-suffix { right: 16px; }
        input, select, textarea { width: 100%; border: 1px solid var(--border); border-radius: 8px; padding: 12px 16px; font-size: 15px; outline: none; background: #fff; }
        textarea { min-height: 140px; resize: vertical; }
        .with-icon { padding-left: 48px; }
        .with-suffix { padding-right: 64px; }
        input:focus, select:focus, textarea:focus { border-color: var(--red); box-shadow: 0 0 0 3px rgba(192,57,43,.12); }
        .helper { margin-top: 6px; color: #98a2b3; font-size: 14px; }
        .error { color: #e53e3e; font-size: 12px; margin-top: 4px; display: block; }
        .two-col { display: grid; grid-template-columns: 1fr 1fr; gap: 18px; }
        .button-row { display: flex; align-items: center; gap: 12px; padding-top: 10px; }
        .submit-btn, .cancel-btn { display: inline-flex; align-items: center; justify-content: center; border-radius: 12px; padding: 14px 28px; font-weight: 700; border: none; cursor: pointer; font-size: 15px; }
        .submit-btn { background: var(--red); color: #fff; box-shadow: 0 6px 16px rgba(192,57,43,.18); }
        .cancel-btn { background: #f3f4f6; color: #6b7280; }
        .side-stack { display: grid; gap: 20px; }
        .side-card { padding: 20px; }
        .tips-list, .stock-list { display: grid; gap: 14px; margin-top: 18px; }
        .tip-item, .stock-item { display: flex; align-items: flex-start; gap: 12px; }
        .tip-mark { width: 22px; height: 22px; border-radius: 50%; background: #ecfdf4; color: var(--success-green); flex-shrink: 0; font-size: 12px; font-weight: 700; }
        .stock-item { align-items: center; justify-content: space-between; gap: 10px; }
        .stock-left { display: flex; align-items: center; gap: 10px; min-width: 0; }
        .stock-name { color: #475467; font-size: 14px; }
        .stock-right { text-align: right; min-width: 110px; }
        .stock-right strong { color: #273449; }
        .stock-right span { color: #98a2b3; font-size: 13px; }
        .blood-pill { display: inline-flex; align-items: center; justify-content: center; min-width: 32px; padding: 4px 8px; border-radius: 8px; color: #fff; font-weight: 700; }
        .blood-red { background: #c0392b; }
        .blood-blue { background: #3f7ded; }
        .blood-teal { background: #1fb7aa; }
        .blood-purple { background: #a154f2; }
        .progress-track { width: 48px; height: 5px; border-radius: 3px; background: #e5e7eb; overflow: hidden; margin-left: auto; margin-top: 4px; }
        .progress-fill { height: 100%; }
        .inventory-total { margin-top: 18px; padding-top: 14px; border-top: 1px solid var(--border); display: flex; align-items: center; justify-content: space-between; color: #667085; }
        .inventory-total strong { color: #273449; }
        @media (max-width: 800px) {
            .sidebar { position: static; width: 100%; min-width: 0; }
            .layout { flex-direction: column; }
            .content { margin-left: 0; width: 100%; }
            .page-grid, .two-col { grid-template-columns: 1fr; }
            .topbar, .form-header { flex-direction: column; align-items: flex-start; }
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
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/stock">
                <span class="nav-icon">&#128230;</span>
                <span>Manage Stock</span>
            </a>
            <a class="nav-link active" href="${pageContext.request.contextPath}/hospital/requests">
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
            <div class="topbar-left">
                <a class="back-link" href="${pageContext.request.contextPath}/hospital/requests">&#8592;</a>
                <div>
                    <h1>Create Request</h1>
                    <p>Submit a new blood request from your hospital account.</p>
                </div>
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
            <div class="breadcrumb">
                Requests &gt;
                <strong>Create Request</strong>
            </div>

            <div class="page-grid">
                <section class="card">
                    <div class="form-header">
                        <div class="form-header-left">
                            <span class="header-icon">&#9998;</span>
                            <div>
                                <h2>Request Details</h2>
                                <p>Enter the blood requirement information below</p>
                            </div>
                        </div>
                        <span class="new-entry">+ New Request</span>
                    </div>

                    <div class="form-body">
                        <c:if test="${not empty formError}">
                            <div class="form-error-banner">${formError}</div>
                        </c:if>

                        <form method="post" action="${pageContext.request.contextPath}/hospital/requests">
                            <input type="hidden" name="action" value="create">

                            <div class="field-group">
                                <label class="field-label" for="bloodGroupId">Blood Group <span class="required">*</span></label>
                                <div class="input-wrap">
                                    <span class="input-icon">&#128167;</span>
                                    <select id="bloodGroupId" name="bloodGroupId" class="with-icon">
                                        <option value="">Select blood group</option>
                                        <c:forEach var="group" items="${bloodGroups}">
                                            <option value="${group.id}" <c:if test="${group.id == formData.bloodGroupId}">selected</c:if>>
                                                ${group.name} - ${group.fullName}
                                            </option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="helper">Choose the blood group required for this outgoing request.</div>
                                <c:if test="${errors.bloodGroupId != null}">
                                    <span class="error">${errors.bloodGroupId}</span>
                                </c:if>
                            </div>

                            <div class="two-col">
                                <div class="field-group">
                                    <label class="field-label" for="unitsNeeded">Units Needed <span class="required">*</span></label>
                                    <div class="input-wrap">
                                        <span class="input-icon">&#128202;</span>
                                        <input type="number" id="unitsNeeded" name="unitsNeeded" min="1" max="20" class="with-icon with-suffix"
                                               placeholder="e.g. 4" value="${formData.unitsNeeded}">
                                        <span class="input-suffix">units</span>
                                    </div>
                                    <div class="helper">Hospital requests are limited to 20 units per submission.</div>
                                    <c:if test="${errors.unitsNeeded != null}">
                                        <span class="error">${errors.unitsNeeded}</span>
                                    </c:if>
                                </div>

                                <div class="field-group">
                                    <label class="field-label" for="urgency">Urgency <span class="required">*</span></label>
                                    <div class="input-wrap">
                                        <span class="input-icon">&#9888;</span>
                                        <select id="urgency" name="urgency" class="with-icon">
                                            <option value="">Select urgency</option>
                                            <option value="normal" <c:if test="${formData.urgency == 'normal'}">selected</c:if>>Normal</option>
                                            <option value="urgent" <c:if test="${formData.urgency == 'urgent'}">selected</c:if>>Urgent</option>
                                            <option value="critical" <c:if test="${formData.urgency == 'critical'}">selected</c:if>>Critical</option>
                                        </select>
                                    </div>
                                    <div class="helper">Use critical only for immediate life-saving need.</div>
                                    <c:if test="${errors.urgency != null}">
                                        <span class="error">${errors.urgency}</span>
                                    </c:if>
                                </div>
                            </div>

                            <div class="field-group">
                                <label class="field-label" for="notes">Clinical Notes</label>
                                <div class="input-wrap">
                                    <textarea id="notes" name="notes" placeholder="Add context for the request, patient status, or dispatch notes.">${formData.notes}</textarea>
                                </div>
                                <div class="helper">Optional, up to 500 characters.</div>
                                <c:if test="${errors.notes != null}">
                                    <span class="error">${errors.notes}</span>
                                </c:if>
                            </div>

                            <div class="button-row">
                                <button type="submit" class="submit-btn">Create Request</button>
                                <a class="cancel-btn" href="${pageContext.request.contextPath}/hospital/requests">Cancel</a>
                            </div>
                        </form>
                    </div>
                </section>

                <aside class="side-stack">
                    <section class="side-card">
                        <h3>Quick Tips</h3>
                        <div class="tips-list">
                            <div class="tip-item"><span class="tip-mark">&#10003;</span><span>Double-check the blood group before submitting.</span></div>
                            <div class="tip-item"><span class="tip-mark">&#10003;</span><span>Use urgency levels consistently so other hospitals can prioritise.</span></div>
                            <div class="tip-item"><span class="tip-mark">&#10003;</span><span>Adding notes helps responders approve faster.</span></div>
                            <div class="tip-item"><span class="tip-mark">&#10003;</span><span>Submitted requests will appear instantly in My Requests.</span></div>
                        </div>
                    </section>

                    <section class="side-card">
                        <h3>Current Stock</h3>
                        <div class="stock-list">
                            <c:forEach var="stock" items="${sidebarStock}">
                                <div class="stock-item">
                                    <div class="stock-left">
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
                                        <span class="stock-name">${stock.fullName}</span>
                                    </div>
                                    <div class="stock-right">
                                        <div><strong>${stock.units}</strong> <span>units</span></div>
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
                                </div>
                            </c:forEach>
                        </div>
                        <div class="inventory-total">
                            <span>Available groups</span>
                            <strong>${sidebarStock.size()}</strong>
                        </div>
                    </section>
                </aside>
            </div>
        </div>
    </main>
</div>
</body>
</html>
