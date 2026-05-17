<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lifelink.dao.RequestDAO" %>
<%@ page import="com.lifelink.model.User" %>
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
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

    private String selected(Object left, Object right) {
        return left != null && right != null && String.valueOf(left).equals(String.valueOf(right)) ? "selected" : "";
    }
%>
<%
    User currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) {
        response.sendRedirect(request.getContextPath() + "/login");
        return;
    }
    if (currentUser.getRole() != User.Role.RECIPIENT) {
        response.sendRedirect(request.getContextPath() + "/403");
        return;
    }

    RequestDAO requestDAO = new RequestDAO();
    List<RequestDAO.BloodGroupOption> bloodGroups = Collections.emptyList();
    Integer recipientBloodGroupId = null;
    String loadError = null;
    try {
        bloodGroups = requestDAO.findAllBloodGroups();
        recipientBloodGroupId = requestDAO.findRecipientBloodGroupId(currentUser.getId());
    } catch (SQLException e) {
        System.err.println("[create_request.jsp] Unable to load form data: " + e.getMessage());
        loadError = "Unable to load blood groups right now. Please refresh the page.";
    }

    String csrfToken = (String) session.getAttribute("csrfToken");
    if (csrfToken == null) {
        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        csrfToken = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute("csrfToken", csrfToken);
    }

    String fullName = currentUser.getFullName() != null ? currentUser.getFullName() : "Recipient";
    String firstName = fullName.contains(" ") ? fullName.substring(0, fullName.indexOf(' ')) : fullName;
    String email = currentUser.getEmail() != null ? currentUser.getEmail() : "";
    String initials = currentUser.getInitials();

    Object error = request.getAttribute("error");
    String patientNameValue = request.getAttribute("patientNameValue") != null ? String.valueOf(request.getAttribute("patientNameValue")) : fullName;
    String selectedBloodGroup = request.getAttribute("bloodGroupValue") != null
        ? String.valueOf(request.getAttribute("bloodGroupValue"))
        : (recipientBloodGroupId != null ? String.valueOf(recipientBloodGroupId) : "");
    String unitsNeededValue = request.getAttribute("unitsNeededValue") != null ? String.valueOf(request.getAttribute("unitsNeededValue")) : "";
    String hospitalNameValue = request.getAttribute("hospitalNameValue") != null ? String.valueOf(request.getAttribute("hospitalNameValue")) : "";
    String urgencyLevelValue = request.getAttribute("urgencyLevelValue") != null ? String.valueOf(request.getAttribute("urgencyLevelValue")) : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Blood Request | LifeLink</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { min-height: 100vh; background: #f6f7f9; color: #1f2937; font-family: 'Inter', sans-serif; }
        button, input, select { font: inherit; }
        .main-content { min-height: 100vh; margin-left: 210px; }
        .topbar { position: sticky; top: 0; z-index: 50; display: flex; align-items: center; justify-content: space-between; gap: 1rem; min-height: 78px; padding: 1.05rem 2rem; background: #fff; border-bottom: 1px solid #eceff3; }
        .topbar-left { display: flex; align-items: center; gap: .85rem; }
        .hamburger { display: none; border: 0; background: transparent; color: #4b5563; cursor: pointer; padding: .35rem; }
        .hamburger svg { width: 24px; height: 24px; fill: currentColor; }
        .page-title h1 { font-size: 1.25rem; line-height: 1.2; font-weight: 800; color: #1f2937; }
        .page-title p { margin-top: .35rem; font-size: .78rem; color: #98a2b3; }
        .topbar-right { display: flex; align-items: center; gap: .95rem; }
        .top-user { display: flex; align-items: center; gap: .7rem; min-width: 0; }
        .avatar { width: 38px; height: 38px; border-radius: 999px; background: linear-gradient(135deg, #b91c1c, #ef4444); color: #fff; display: grid; place-items: center; font-weight: 800; font-size: .78rem; border: 2px solid #f4d0d0; }
        .top-user strong { display: block; font-size: .84rem; color: #344054; }
        .top-user span { display: block; font-size: .74rem; color: #98a2b3; }
        .chevron { width: 18px; height: 18px; fill: #98a2b3; }
        .page-body { padding: 2.1rem 2.1rem 3rem; }
        .layout { display: grid; grid-template-columns: minmax(0, 1fr) 288px; gap: 2rem; max-width: 1120px; margin: 0 auto; }
        .form-card, .side-card { background: #fff; border: 1px solid #edf0f4; border-radius: 16px; box-shadow: 0 1px 3px rgba(16,24,40,.04); }
        .form-card { overflow: hidden; }
        .form-header { display: flex; align-items: center; justify-content: space-between; gap: 1rem; padding: 1.25rem 1.9rem; background: linear-gradient(90deg, #fff1f1 0%, #fff7f7 100%); border-bottom: 1px solid #f1f2f4; }
        .form-heading { display: flex; align-items: center; gap: .8rem; min-width: 0; }
        .drop-icon { width: 40px; height: 40px; border-radius: 10px; background: #c91c20; display: grid; place-items: center; box-shadow: 0 7px 16px rgba(185,28,28,.18); flex-shrink: 0; }
        .drop-icon svg { width: 20px; height: 20px; fill: #fff; }
        .form-heading h2 { font-size: 1rem; font-weight: 800; color: #1f2937; }
        .form-heading p { margin-top: .18rem; color: #667085; font-size: .78rem; }
        .help-pill { display: inline-flex; align-items: center; gap: .45rem; padding: .45rem .75rem; border-radius: 999px; background: #fee4e2; color: #b42318; font-size: .72rem; font-weight: 800; white-space: nowrap; }
        .help-pill svg { width: 14px; height: 14px; fill: currentColor; }
        .request-form { padding: 2rem 1.9rem 1.9rem; }
        .alert { margin-bottom: 1rem; padding: .85rem 1rem; border-radius: 12px; background: #fef2f2; color: #b42318; border: 1px solid #fecaca; font-size: .83rem; font-weight: 600; }
        .field-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 1.45rem 1.45rem; }
        .field.full { grid-column: 1 / -1; }
        label { display: flex; align-items: center; gap: .45rem; margin-bottom: .55rem; color: #344054; font-size: .86rem; font-weight: 800; }
        label svg { width: 15px; height: 15px; fill: #c91c20; flex-shrink: 0; }
        .control { position: relative; }
        .control svg.leading { position: absolute; left: .9rem; top: 50%; transform: translateY(-50%); width: 17px; height: 17px; fill: #cfd5de; pointer-events: none; }
        input, select { width: 100%; height: 45px; border: 1px solid #dce2ea; border-radius: 11px; background: #fbfcfe; color: #374151; padding: 0 1rem 0 2.45rem; outline: none; transition: border-color .16s, box-shadow .16s, background .16s; }
        select { appearance: none; padding-right: 2.55rem; cursor: pointer; }
        input::placeholder { color: #9aa4b2; }
        input:focus, select:focus { border-color: #d92d20; box-shadow: 0 0 0 4px rgba(217,45,32,.09); background: #fff; }
        .select-arrow { position: absolute; right: .9rem; top: 50%; transform: translateY(-50%); width: 18px; height: 18px; fill: #98a2b3; pointer-events: none; }
        .hint { margin-top: .55rem; font-size: .74rem; color: #98a2b3; }
        .urgency-pills { display: flex; flex-wrap: wrap; gap: .65rem; margin-top: 1rem; }
        .urgency-pill { display: inline-flex; align-items: center; gap: .45rem; padding: .38rem .68rem; border-radius: 999px; font-size: .72rem; font-weight: 800; border: 1px solid transparent; }
        .urgency-pill::before { content: ""; width: 8px; height: 8px; border-radius: 50%; }
        .critical { color: #d92d20; background: #fff1f1; border-color: #fecaca; }
        .critical::before { background: #f04438; }
        .high { color: #c05621; background: #fff7ed; border-color: #fed7aa; }
        .high::before { background: #fb923c; }
        .medium { color: #b7791f; background: #fffbeb; border-color: #fde68a; }
        .medium::before { background: #fbbf24; }
        .low { color: #039855; background: #ecfdf3; border-color: #bbf7d0; }
        .low::before { background: #22c55e; }
        .form-footer { display: flex; align-items: center; justify-content: space-between; gap: 1rem; margin-top: 2rem; padding-top: 1.75rem; border-top: 1px solid #f0f2f5; }
        .secure-note { display: flex; align-items: center; gap: .65rem; color: #98a2b3; font-size: .78rem; }
        .secure-note svg { width: 18px; height: 18px; fill: #22c55e; flex-shrink: 0; }
        .submit-btn { display: inline-flex; align-items: center; justify-content: center; gap: .55rem; min-width: 198px; height: 48px; border: 0; border-radius: 11px; color: #fff; background: linear-gradient(135deg, #c91c20, #9f1418); font-size: .86rem; font-weight: 800; cursor: pointer; box-shadow: 0 10px 18px rgba(153,27,27,.22); transition: transform .14s, box-shadow .14s; }
        .submit-btn:hover { transform: translateY(-1px); box-shadow: 0 13px 22px rgba(153,27,27,.26); }
        .submit-btn svg { width: 18px; height: 18px; fill: currentColor; }
        .side-stack { display: flex; flex-direction: column; gap: 1.25rem; }
        .side-card { padding: 1.35rem 1.4rem; }
        .side-title { display: flex; align-items: center; gap: .5rem; margin-bottom: 1.2rem; color: #1f2937; font-size: .92rem; font-weight: 800; }
        .side-title svg { width: 15px; height: 15px; fill: #c91c20; }
        .step { display: grid; grid-template-columns: 30px 1fr; gap: .7rem; align-items: start; margin-bottom: 1.1rem; }
        .step:last-child { margin-bottom: 0; }
        .step-number { width: 28px; height: 28px; border-radius: 999px; background: #c91c20; color: #fff; display: grid; place-items: center; font-size: .74rem; font-weight: 800; }
        .step strong { display: block; color: #344054; font-size: .78rem; margin-bottom: .18rem; }
        .step span, .tip-list li, .helpline-card p { color: #7b8493; font-size: .78rem; line-height: 1.35; }
        .helpline-card { background: linear-gradient(135deg, #fff0f0, #fff8f8); border-color: #ffd5d2; }
        .phone-box { margin-top: 1rem; padding: .8rem .9rem; border-radius: 11px; background: #fff; border: 1px solid #ffd5d2; display: flex; align-items: center; gap: .75rem; }
        .phone-icon { width: 36px; height: 36px; border-radius: 9px; background: #c91c20; color: #fff; display: grid; place-items: center; flex-shrink: 0; }
        .phone-icon svg { width: 18px; height: 18px; fill: currentColor; }
        .phone-number { color: #c91c20; font-size: .9rem; font-weight: 800; }
        .phone-status { color: #98a2b3; font-size: .75rem; margin-top: .12rem; }
        .tip-title svg { fill: #fbbf24; }
        .tip-list { list-style: none; display: grid; gap: .75rem; }
        .tip-list li { position: relative; padding-left: 1.35rem; }
        .tip-list li::before { content: "✓"; position: absolute; left: 0; top: 0; color: #c91c20; font-weight: 800; }
        .tip-list strong { color: #c91c20; }
        @media (max-width: 1024px) {
            .main-content { margin-left: 0; }
            .hamburger { display: inline-grid; place-items: center; }
            .layout { grid-template-columns: 1fr; }
            .side-stack { grid-row: auto; }
        }
        @media (max-width: 700px) {
            .topbar { align-items: flex-start; padding: 1rem; }
            .topbar-right { gap: .5rem; }
            .top-user div:not(.avatar) { display: none; }
            .chevron { display: none; }
            .page-body { padding: 1rem; }
            .form-header { align-items: flex-start; flex-direction: column; padding: 1.15rem; }
            .request-form { padding: 1.2rem; }
            .field-grid { grid-template-columns: 1fr; gap: 1.1rem; }
            .form-footer { flex-direction: column; align-items: stretch; }
            .submit-btn { width: 100%; min-width: 0; }
        }
        @media (max-width: 600px) {
            .page-title h1 { font-size: 1.05rem; }
            .page-title p { font-size: .72rem; }
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
                <h1>Create Blood Request</h1>
                <p>Fill in the details below to submit a new blood request.</p>
            </div>
        </div>
        <div class="topbar-right">
            <jsp:include page="/includes/recipient_notifications.jsp" />
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
        <div class="layout">
            <section class="form-card">
                <div class="form-header">
                    <div class="form-heading">
                        <div class="drop-icon">
                            <svg viewBox="0 0 24 24"><path d="M12 2S5 9.67 5 15a7 7 0 0 0 14 0C19 9.67 12 2 12 2Zm0 17a4 4 0 0 1-4-4h2a2 2 0 0 0 2 2v2Z"/></svg>
                        </div>
                        <div>
                            <h2>Blood Request Form</h2>
                            <p>All fields are required. We'll match donors immediately.</p>
                        </div>
                    </div>
                    <span class="help-pill">
                        <svg viewBox="0 0 24 24"><path d="M11 17h2v-6h-2v6Zm1-14a9 9 0 1 0 0 18 9 9 0 0 0 0-18Zm0 16a7 7 0 1 1 0-14 7 7 0 0 1 0 14Zm-1-10h2V7h-2v2Z"/></svg>
                        Urgent Help Available
                    </span>
                </div>

                <form class="request-form" method="post" action="${pageContext.request.contextPath}/recipient/create-request" novalidate>
                    <input type="hidden" name="csrfToken" value="<%= esc(csrfToken) %>">
                    <% if (error != null) { %>
                        <div class="alert"><%= esc(error) %></div>
                    <% } else if (loadError != null) { %>
                        <div class="alert"><%= esc(loadError) %></div>
                    <% } %>

                    <div class="field-grid">
                        <div class="field">
                            <label for="patientName">
                                <svg viewBox="0 0 24 24"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm0 2c-4.42 0-8 2.24-8 5v1h16v-1c0-2.76-3.58-5-8-5Z"/></svg>
                                Patient Name
                            </label>
                            <div class="control">
                                <svg class="leading" viewBox="0 0 24 24"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm0 2c-4.42 0-8 2.24-8 5v1h16v-1c0-2.76-3.58-5-8-5Z"/></svg>
                                <input id="patientName" name="patientName" type="text" maxlength="150" required placeholder="e.g. Sarah Johnson" value="<%= esc(patientNameValue) %>">
                            </div>
                        </div>

                        <div class="field">
                            <label for="bloodGroupId">
                                <svg viewBox="0 0 24 24"><path d="M12 2S5 9.67 5 15a7 7 0 0 0 14 0C19 9.67 12 2 12 2Z"/></svg>
                                Blood Group
                            </label>
                            <div class="control">
                                <svg class="leading" viewBox="0 0 24 24"><path d="M12 2S5 9.67 5 15a7 7 0 0 0 14 0C19 9.67 12 2 12 2Z"/></svg>
                                <select id="bloodGroupId" name="bloodGroupId" required>
                                    <option value="">Select blood group</option>
                                    <% for (RequestDAO.BloodGroupOption group : bloodGroups) { %>
                                        <option value="<%= group.getId() %>" <%= selected(selectedBloodGroup, group.getId()) %>><%= esc(group.getName()) %></option>
                                    <% } %>
                                </select>
                                <svg class="select-arrow" viewBox="0 0 24 24"><path d="M7.41 8.59 12 13.17l4.59-4.58L18 10l-6 6-6-6z"/></svg>
                            </div>
                        </div>

                        <div class="field">
                            <label for="unitsNeeded">
                                <svg viewBox="0 0 24 24"><path d="M19 3H5v18h14V3Zm-2 16H7V5h10v14ZM9 9h6v2H9V9Zm0 4h6v2H9v-2Z"/></svg>
                                Units Needed
                            </label>
                            <div class="control">
                                <svg class="leading" viewBox="0 0 24 24"><path d="M7 20h10v-2H7v2Zm12-14h-4.18C14.4 4.84 13.3 4 12 4s-2.4.84-2.82 2H5v12h14V6Zm-7 0a1 1 0 1 1 0 2 1 1 0 0 1 0-2Z"/></svg>
                                <input id="unitsNeeded" name="unitsNeeded" type="number" min="1" max="20" step="1" required placeholder="e.g. 2" value="<%= esc(unitsNeededValue) %>">
                            </div>
                            <div class="hint">1 unit = approx. 450 ml of whole blood</div>
                        </div>

                        <div class="field">
                            <label for="hospitalName">
                                <svg viewBox="0 0 24 24"><path d="M19 3H5v18h14V3Zm-8 16H7v-4h4v4Zm0-6H7V9h4v4Zm6 6h-4v-4h4v4Zm0-6h-4V9h4v4ZM9 5h6v2H9V5Z"/></svg>
                                Hospital Name
                            </label>
                            <div class="control">
                                <svg class="leading" viewBox="0 0 24 24"><path d="M19 3H5v18h14V3Zm-8 16H7v-4h4v4Zm6 0h-4v-4h4v4ZM9 5h6v2H9V5Z"/></svg>
                                <input id="hospitalName" name="hospitalName" type="text" maxlength="200" required placeholder="e.g. City General Hospital" value="<%= esc(hospitalNameValue) %>">
                            </div>
                        </div>

                        <div class="field full">
                            <label for="urgencyLevel">
                                <svg viewBox="0 0 24 24"><path d="M1 21h22L12 2 1 21Zm12-3h-2v-2h2v2Zm0-4h-2v-4h2v4Z"/></svg>
                                Urgency Level
                            </label>
                            <div class="control">
                                <svg class="leading" viewBox="0 0 24 24"><path d="M1 21h22L12 2 1 21Zm12-3h-2v-2h2v2Zm0-4h-2v-4h2v4Z"/></svg>
                                <select id="urgencyLevel" name="urgencyLevel" required>
                                    <option value="">Select urgency level</option>
                                    <option value="critical" <%= selected(urgencyLevelValue, "critical") %>>Critical</option>
                                    <option value="high" <%= selected(urgencyLevelValue, "high") %>>High</option>
                                    <option value="medium" <%= selected(urgencyLevelValue, "medium") %>>Medium</option>
                                    <option value="low" <%= selected(urgencyLevelValue, "low") %>>Low</option>
                                </select>
                                <svg class="select-arrow" viewBox="0 0 24 24"><path d="M7.41 8.59 12 13.17l4.59-4.58L18 10l-6 6-6-6z"/></svg>
                            </div>
                            <div class="urgency-pills" aria-hidden="true">
                                <span class="urgency-pill critical">Critical</span>
                                <span class="urgency-pill high">High</span>
                                <span class="urgency-pill medium">Medium</span>
                                <span class="urgency-pill low">Low</span>
                            </div>
                        </div>
                    </div>

                    <div class="form-footer">
                        <div class="secure-note">
                            <svg viewBox="0 0 24 24"><path d="M12 1 4 5v6c0 5.55 3.84 10.74 8 12 4.16-1.26 8-6.45 8-12V5l-8-4Zm0 19.9C8.8 19.85 6 15.36 6 11V6.3l6-3 6 3V11c0 4.36-2.8 8.85-6 9.9Z"/></svg>
                            Your data is secure. Donor matching starts immediately after submission.
                        </div>
                        <button class="submit-btn" type="submit">
                            <svg viewBox="0 0 24 24"><path d="M2 21 23 12 2 3v7l15 2-15 2v7Z"/></svg>
                            Submit Request
                        </button>
                    </div>
                </form>
            </section>

            <aside class="side-stack">
                <section class="side-card">
                    <h2 class="side-title">
                        <svg viewBox="0 0 24 24"><path d="M11 17h2v-6h-2v6Zm1-14a9 9 0 1 0 0 18 9 9 0 0 0 0-18Z"/></svg>
                        How It Works
                    </h2>
                    <div class="step">
                        <div class="step-number">1</div>
                        <div><strong>Fill the form</strong><span>Provide patient &amp; hospital details.</span></div>
                    </div>
                    <div class="step">
                        <div class="step-number">2</div>
                        <div><strong>Submit request</strong><span>We notify matching donors instantly.</span></div>
                    </div>
                    <div class="step">
                        <div class="step-number">3</div>
                        <div><strong>Donor responds</strong><span>You'll be notified once confirmed.</span></div>
                    </div>
                </section>

                <section class="side-card helpline-card">
                    <h2 class="side-title">
                        <svg viewBox="0 0 24 24"><path d="M6.62 10.79a15.1 15.1 0 0 0 6.59 6.59l2.2-2.2a1 1 0 0 1 1.01-.24 11.36 11.36 0 0 0 3.58.57 1 1 0 0 1 1 1V20a1 1 0 0 1-1 1A17 17 0 0 1 3 4a1 1 0 0 1 1-1h3.5a1 1 0 0 1 1 1 11.36 11.36 0 0 0 .57 3.58 1 1 0 0 1-.24 1.01l-2.21 2.2Z"/></svg>
                        Emergency Helpline
                    </h2>
                    <p>For life-threatening emergencies, call our 24/7 blood helpline.</p>
                    <div class="phone-box">
                        <div class="phone-icon">
                            <svg viewBox="0 0 24 24"><path d="M6.62 10.79a15.1 15.1 0 0 0 6.59 6.59l2.2-2.2a1 1 0 0 1 1.01-.24 11.36 11.36 0 0 0 3.58.57 1 1 0 0 1 1 1V20a1 1 0 0 1-1 1A17 17 0 0 1 3 4a1 1 0 0 1 1-1h3.5a1 1 0 0 1 1 1 11.36 11.36 0 0 0 .57 3.58 1 1 0 0 1-.24 1.01l-2.21 2.2Z"/></svg>
                        </div>
                        <div>
                            <div class="phone-number">1800-LIFELINK</div>
                            <div class="phone-status">Available 24/7</div>
                        </div>
                    </div>
                </section>

                <section class="side-card">
                    <h2 class="side-title tip-title">
                        <svg viewBox="0 0 24 24"><path d="M9 21h6v-1H9v1Zm3-19a7 7 0 0 0-4 12.74V17a1 1 0 0 0 1 1h6a1 1 0 0 0 1-1v-2.26A7 7 0 0 0 12 2Z"/></svg>
                        Quick Tips
                    </h2>
                    <ul class="tip-list">
                        <li>Double-check the blood group before submitting.</li>
                        <li>Set urgency accurately for faster donor response.</li>
                        <li>You can track your request under <strong>My Requests</strong>.</li>
                    </ul>
                </section>
            </aside>
        </div>
    </section>
</main>
</body>
</html>
