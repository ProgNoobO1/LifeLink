<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Hospital Details - LifeLink</title>
    <style>
        :root {
            --red: #c0392b;
            --dark-sidebar: #1a0a0a;
            --sidebar-hover: #2a1010;
            --card-bg: #ffffff;
            --text-primary: #1a1a1a;
            --text-muted: #888888;
            --border: #e5e7eb;
            --success-green: #10b981;
            --bg-page: #f5f5f5;
        }

        * { box-sizing: border-box; }
        body { margin: 0; font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif; background: var(--bg-page); color: var(--text-primary); }
        a { color: inherit; text-decoration: none; }
        .layout { display: flex; min-height: 100vh; }
        .sidebar { width: 220px; min-width: 220px; background: linear-gradient(180deg, #220909 0%, var(--dark-sidebar) 100%); color: #f8d7d3; padding: 24px 16px; display: flex; flex-direction: column; position: fixed; inset: 0 auto 0 0; }
        .brand, .nav-link, .logout-link, .hospital-account, .topbar-right, .topbar-profile, .summary-row { display: flex; align-items: center; }
        .brand { gap: 12px; color: #fff; font-size: 20px; font-weight: 700; margin-bottom: 28px; }
        .brand-icon, .nav-icon, .logout-icon, .profile-icon, .topbar-bell, .header-icon, .tip-mark { display: inline-flex; align-items: center; justify-content: center; }
        .brand-icon { width: 38px; height: 38px; background: var(--red); border-radius: 12px; color: #fff; font-weight: 700; }
        .sidebar-label { font-size: 12px; letter-spacing: 2px; text-transform: uppercase; color: #c97b74; margin: 0 8px 12px; }
        .nav-menu { display: flex; flex-direction: column; gap: 10px; }
        .nav-link { gap: 12px; padding: 14px 16px; border-radius: 14px; color: #f7d8d5; transition: background .2s ease; }
        .nav-link:hover { background: var(--sidebar-hover); }
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
        .topbar-left { display: flex; align-items: center; gap: 14px; }
        .back-link { width: 36px; height: 36px; border-radius: 12px; border: 1px solid var(--border); display: inline-flex; align-items: center; justify-content: center; color: #98a2b3; background: #fff; }
        .topbar h1 { margin: 0; font-size: 24px; }
        .topbar p { margin: 4px 0 0; color: #98a2b3; }
        .topbar-right { gap: 16px; }
        .topbar-bell { width: 42px; height: 42px; border-radius: 14px; border: 1px solid var(--border); background: #f8fafc; position: relative; color: #6b7280; }
        .bell-badge { position: absolute; top: -8px; right: -8px; min-width: 22px; height: 22px; font-size: 11px; }
        .profile-icon { width: 42px; height: 42px; border-radius: 14px; background: var(--red); color: #fff; font-weight: 700; }
        .page-body { padding: 28px; }
        .breadcrumb { color: #98a2b3; font-size: 14px; margin-bottom: 18px; }
        .breadcrumb strong { color: var(--red); }
        .page-grid { display: grid; grid-template-columns: 1fr 320px; gap: 24px; }
        .card { background: var(--card-bg); border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.08); overflow: hidden; }
        .form-header { background: linear-gradient(90deg, #fdecec, #fff6f5); padding: 24px 28px; display: flex; align-items: center; justify-content: space-between; gap: 16px; }
        .form-header-left { display: flex; align-items: center; gap: 16px; }
        .header-icon { width: 48px; height: 48px; border-radius: 14px; background: var(--red); color: #fff; font-weight: 700; }
        .form-header h2, .side-card h3 { margin: 0; font-size: 18px; }
        .form-header p, .side-card p { margin: 4px 0 0; color: #98a2b3; }
        .form-body { padding: 28px; }
        .field-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 18px; }
        .field.full { grid-column: 1 / -1; }
        .field-group { margin-bottom: 18px; }
        .field-label { display: block; font-weight: 700; margin-bottom: 8px; color: #344054; }
        .field-label .required { color: #e53e3e; }
        .input-wrap { position: relative; }
        .input-icon, .input-suffix { position: absolute; top: 50%; transform: translateY(-50%); color: #98a2b3; font-size: 14px; }
        .input-icon { left: 14px; }
        .input-suffix { right: 16px; }
        input, select { width: 100%; border: 1px solid var(--border); border-radius: 8px; padding: 12px 16px; font-size: 15px; outline: none; background: #fff; }
        .with-icon { padding-left: 48px; }
        input:focus, select:focus { border-color: var(--red); box-shadow: 0 0 0 3px rgba(192,57,43,.12); }
        .helper { margin-top: 6px; color: #98a2b3; font-size: 14px; }
        .form-error-banner { background: #fef2f2; border-left: 4px solid #ef4444; padding: 12px 16px; border-radius: 8px; color: #b91c1c; margin-bottom: 18px; }
        .success-banner { background: #d1fae5; border-left: 4px solid var(--success-green); padding: 12px 16px; border-radius: 8px; color: #166534; margin-bottom: 18px; }
        .button-row { display: flex; align-items: center; gap: 12px; padding-top: 10px; }
        .submit-btn, .cancel-btn { display: inline-flex; align-items: center; justify-content: center; border-radius: 12px; padding: 14px 28px; font-weight: 700; border: none; cursor: pointer; font-size: 15px; }
        .submit-btn { background: var(--red); color: #fff; box-shadow: 0 6px 16px rgba(192,57,43,.18); }
        .cancel-btn { background: #f3f4f6; color: #6b7280; }
        .side-stack { display: grid; gap: 20px; }
        .side-card { background: #fff; border-radius: 12px; box-shadow: 0 1px 4px rgba(0,0,0,.08); padding: 20px; }
        .tips-list, .summary-list { display: grid; gap: 14px; margin-top: 18px; }
        .tip-item { display: flex; align-items: flex-start; gap: 12px; }
        .tip-mark { width: 22px; height: 22px; border-radius: 50%; background: #ecfdf4; color: var(--success-green); flex-shrink: 0; font-size: 12px; font-weight: 700; }
        .summary-row { justify-content: space-between; gap: 12px; padding: 12px 14px; border-radius: 10px; background: #f9fafb; }
        .summary-row span { color: #667085; }
        .summary-row strong { color: #273449; }
        @media (max-width: 800px) {
            .sidebar { position: static; width: 100%; min-width: 0; }
            .layout { flex-direction: column; }
            .content { margin-left: 0; width: 100%; }
            .page-grid, .field-grid { grid-template-columns: 1fr; }
            .topbar, .form-header { flex-direction: column; align-items: flex-start; }
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
            <a class="nav-link" href="${pageContext.request.contextPath}/hospital/requests"><span class="nav-icon">&#128196;</span><span>Requests</span><span class="nav-badge">${pendingCount}</span></a>
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
            <div class="topbar-left">
                <a class="back-link" href="${pageContext.request.contextPath}/hospital/dashboard">&#8592;</a>
                <div>
                    <h1>Edit Hospital Details</h1>
                    <p>Update the core profile details stored for your hospital account.</p>
                </div>
            </div>
            <div class="topbar-right">
                <jsp:include page="/includes/hospital_notifications.jsp" />
                <div class="topbar-profile"><span class="profile-icon">&#127973;</span><div><strong>${hospitalName}</strong><span>${hospitalEmail}</span></div></div>
            </div>
        </header>

        <div class="page-body">
            <div class="breadcrumb">Hospital Dashboard &gt; <strong>Edit Details</strong></div>

            <div class="page-grid">
                <section class="card">
                    <div class="form-header">
                        <div class="form-header-left">
                            <span class="header-icon">&#9998;</span>
                            <div>
                                <h2>Hospital Profile</h2>
                                <p>Changes here are saved directly to the hospitals table.</p>
                            </div>
                        </div>
                    </div>

                    <div class="form-body">
                        <c:if test="${param.success == '1'}">
                            <div class="success-banner">Hospital details updated successfully.</div>
                        </c:if>
                        <c:if test="${not empty profileError}">
                            <div class="form-error-banner">${profileError}</div>
                        </c:if>

                        <form method="post" action="${pageContext.request.contextPath}/hospital/edit-details">
                            <div class="field-grid">
                                <div class="field-group">
                                    <label class="field-label" for="hospitalName">Hospital Name <span class="required">*</span></label>
                                    <div class="input-wrap">
                                        <span class="input-icon">&#127973;</span>
                                        <input id="hospitalName" name="hospitalName" class="with-icon" maxlength="200" value="${hospitalProfile.hospitalName}">
                                    </div>
                                </div>

                                <div class="field-group">
                                    <label class="field-label" for="licenseNo">License Number</label>
                                    <div class="input-wrap">
                                        <span class="input-icon">&#35;</span>
                                        <input id="licenseNo" name="licenseNo" class="with-icon" maxlength="100" value="${hospitalProfile.licenseNo}">
                                    </div>
                                </div>

                                <div class="field-group">
                                    <label class="field-label" for="districtId">District</label>
                                    <div class="input-wrap">
                                        <span class="input-icon">&#128205;</span>
                                        <select id="districtId" name="districtId" class="with-icon">
                                            <option value="">Select district</option>
                                            <c:forEach var="district" items="${districts}">
                                                <option value="${district.id}" ${hospitalProfile.districtId == district.id ? 'selected' : ''}>
                                                    ${district.name}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="helper">The selected district name is stored as its seeded district id, along with latitude and longitude.</div>
                                </div>

                                <div class="field-group">
                                    <label class="field-label" for="contactPerson">Contact Person</label>
                                    <div class="input-wrap">
                                        <span class="input-icon">&#128100;</span>
                                        <input id="contactPerson" name="contactPerson" class="with-icon" maxlength="150" value="${hospitalProfile.contactPerson}">
                                    </div>
                                </div>

                                <div class="field-group full">
                                    <label class="field-label" for="address">Address</label>
                                    <div class="input-wrap">
                                        <span class="input-icon">&#127968;</span>
                                        <input id="address" name="address" class="with-icon" maxlength="255" value="${hospitalProfile.address}">
                                    </div>
                                </div>

                                <div class="field-group full">
                                    <label class="field-label" for="website">Website</label>
                                    <div class="input-wrap">
                                        <span class="input-icon">&#127760;</span>
                                        <input id="website" name="website" class="with-icon" maxlength="255" placeholder="https://example.com" value="${hospitalProfile.website}">
                                    </div>
                                    <div class="helper">Use a full URL starting with http:// or https://</div>
                                </div>
                            </div>

                            <div class="button-row">
                                <button type="submit" class="submit-btn">Save Details</button>
                                <a class="cancel-btn" href="${pageContext.request.contextPath}/hospital/dashboard">Cancel</a>
                            </div>
                        </form>
                    </div>
                </section>

                <aside class="side-stack">
                    <section class="side-card">
                        <h3>Quick Notes</h3>
                        <div class="tips-list">
                            <div class="tip-item"><span class="tip-mark">&#10003;</span><span>District selection saves the seeded district id to your hospital row.</span></div>
                            <div class="tip-item"><span class="tip-mark">&#10003;</span><span>Latitude and longitude are filled automatically from the district table.</span></div>
                            <div class="tip-item"><span class="tip-mark">&#10003;</span><span>License number should stay unique across hospitals.</span></div>
                        </div>
                    </section>

                    <section class="side-card">
                        <h3>Current Summary</h3>
                        <div class="summary-list">
                            <div class="summary-row"><span>Hospital</span><strong>${hospitalProfile.hospitalName}</strong></div>
                            <div class="summary-row"><span>District</span><strong>${hospitalProfile.districtName != null ? hospitalProfile.districtName : 'Not selected'}</strong></div>
                            <div class="summary-row"><span>Contact</span><strong>${hospitalProfile.contactPerson != null ? hospitalProfile.contactPerson : 'Not set'}</strong></div>
                            <div class="summary-row"><span>Website</span><strong>${hospitalProfile.website != null ? hospitalProfile.website : 'Not set'}</strong></div>
                        </div>
                    </section>
                </aside>
            </div>
        </div>
    </main>
</div>
</body>
</html>
