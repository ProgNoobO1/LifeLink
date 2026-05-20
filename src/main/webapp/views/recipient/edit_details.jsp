<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lifelink.model.District" %>
<%@ page import="com.lifelink.model.Recipient" %>
<%@ page import="com.lifelink.model.User" %>
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
    Recipient profile = (Recipient) request.getAttribute("recipientProfile");
    List<District> districts = (List<District>) request.getAttribute("districts");
    if (districts == null) districts = Collections.emptyList();
    String csrfToken = (String) request.getAttribute("csrfToken");
    String fullName = currentUser.getFullName() != null ? currentUser.getFullName() : "Recipient";
    String firstName = fullName.contains(" ") ? fullName.substring(0, fullName.indexOf(' ')) : fullName;
    String email = currentUser.getEmail() != null ? currentUser.getEmail() : "";
    String initials = currentUser.getInitials();
    String address = profile != null ? profile.getAddress() : "";
    String gender = profile != null ? profile.getGender() : "";
    String medicalNotes = profile != null ? profile.getMedicalNotes() : "";
    String dateOfBirth = profile != null && profile.getDateOfBirth() != null ? profile.getDateOfBirth().toString() : "";
    Integer districtId = profile != null ? profile.getDistrictId() : null;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Recipient Details | LifeLink</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        body{min-height:100vh;background:#f3f4f6;color:#111827;font-family:'Inter',sans-serif}
        button,input,select,textarea{font:inherit}
        .main-content{min-height:100vh;margin-left:210px}
        .topbar{position:sticky;top:0;z-index:50;display:flex;align-items:center;justify-content:space-between;gap:1rem;padding:1.3rem 2rem;background:#fff;border-bottom:1px solid #e5e7eb}
        .topbar-left{display:flex;align-items:center;gap:.8rem}
        .hamburger{display:none;background:none;border:0;cursor:pointer;padding:.4rem;color:#374151}
        .hamburger svg{width:24px;height:24px;fill:currentColor}
        .page-title h1{font-size:1.25rem;font-weight:800;color:#111827}
        .page-title p{font-size:.82rem;color:#6b7280;margin-top:.15rem}
        .topbar-right{display:flex;align-items:center;gap:1rem}
        .top-user{display:flex;align-items:center;gap:.6rem}
        .avatar{width:36px;height:36px;background:linear-gradient(135deg,#b91c1c,#dc2626);border-radius:50%;display:grid;place-items:center;color:#fff;font-size:.78rem;font-weight:800}
        .top-user strong{display:block;font-size:.85rem;color:#111827}
        .top-user span{display:block;font-size:.72rem;color:#9ca3af}
        .page-body{padding:1.6rem 2rem 2.5rem}
        .layout{max-width:1040px;margin:0 auto;display:grid;grid-template-columns:minmax(0,1fr)300px;gap:1.4rem;align-items:start}
        .form-card,.side-card{background:#fff;border:1px solid #f0f0f0;border-radius:14px;box-shadow:0 1px 4px rgba(0,0,0,.04)}
        .form-head{display:flex;align-items:center;justify-content:space-between;gap:1rem;padding:1.25rem 1.4rem;background:#fff7f7;border-bottom:1px solid #f3f4f6;border-radius:14px 14px 0 0}
        .form-title{display:flex;align-items:center;gap:.8rem}
        .head-icon{width:42px;height:42px;border-radius:11px;background:#fee2e2;color:#b91c1c;display:grid;place-items:center;flex-shrink:0}
        .head-icon svg{width:21px;height:21px;fill:currentColor}
        .form-title h2{font-size:1rem;font-weight:800;color:#111827}
        .form-title p{font-size:.78rem;color:#9ca3af;margin-top:.18rem}
        .back-link{display:inline-flex;align-items:center;justify-content:center;min-height:34px;padding:0 .8rem;border-radius:9px;background:#fee2e2;color:#b91c1c;font-size:.78rem;font-weight:800;text-decoration:none}
        .profile-form{padding:1.45rem}
        .alert{margin-bottom:1rem;border-radius:11px;padding:.85rem 1rem;font-size:.84rem;font-weight:700}
        .alert.error{background:#fef2f2;border:1px solid #fecaca;color:#b91c1c}
        .field-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:1.15rem}
        .field.full{grid-column:1/-1}
        label{display:block;margin-bottom:.48rem;font-size:.82rem;font-weight:800;color:#374151}
        input,select,textarea{width:100%;border:1px solid #d1d5db;border-radius:10px;background:#fbfcfe;color:#111827;outline:0;transition:border-color .16s,box-shadow .16s,background .16s}
        input,select{height:45px;padding:0 .9rem}
        textarea{min-height:126px;resize:vertical;padding:.85rem .9rem;line-height:1.5}
        input:focus,select:focus,textarea:focus{border-color:#b91c1c;box-shadow:0 0 0 4px rgba(185,28,28,.09);background:#fff}
        .hint{margin-top:.45rem;font-size:.74rem;color:#9ca3af}
        .form-actions{display:flex;align-items:center;justify-content:space-between;gap:1rem;margin-top:1.5rem;padding-top:1.2rem;border-top:1px solid #f3f4f6}
        .secure-note{font-size:.78rem;color:#6b7280;line-height:1.45}
        .save-btn{border:0;border-radius:10px;background:linear-gradient(135deg,#b91c1c,#dc2626);color:#fff;font-size:.86rem;font-weight:800;padding:.78rem 1.45rem;cursor:pointer;box-shadow:0 10px 18px rgba(185,28,28,.18)}
        .side-stack{display:grid;gap:1.2rem}
        .side-card{padding:1.2rem}
        .side-title{font-size:.94rem;font-weight:800;color:#111827;margin-bottom:.7rem}
        .side-card p,.side-card li{font-size:.8rem;color:#6b7280;line-height:1.5}
        .side-card ul{list-style:none;display:grid;gap:.55rem}
        .side-card li{position:relative;padding-left:1rem}
        .side-card li::before{content:"";position:absolute;left:0;top:.55rem;width:6px;height:6px;border-radius:50%;background:#b91c1c}
        .summary{display:grid;gap:.7rem}
        .summary-row{display:flex;justify-content:space-between;gap:1rem;padding:.65rem .75rem;border-radius:10px;background:#f9fafb;font-size:.8rem}
        .summary-row span:first-child{color:#6b7280}
        .summary-row span:last-child{font-weight:800;color:#111827;text-align:right}
        @media(max-width:1024px){.main-content{margin-left:0}.hamburger{display:block}.layout{grid-template-columns:1fr}}
        @media(max-width:700px){.topbar{padding:1rem}.top-user div:not(.avatar){display:none}.page-body{padding:1rem}.form-head{align-items:flex-start;flex-direction:column}.field-grid{grid-template-columns:1fr}.form-actions{align-items:stretch;flex-direction:column}.save-btn{width:100%}}
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
                <h1>Edit Details</h1>
                <p>Keep your recipient profile current, <%= esc(firstName) %>.</p>
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
            </div>
        </div>
    </header>

    <section class="page-body">
        <div class="layout">
            <section class="form-card">
                <div class="form-head">
                    <div class="form-title">
                        <div class="head-icon">
                            <svg viewBox="0 0 24 24"><path d="M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8Zm0 2c-4.42 0-8 2.24-8 5v1h16v-1c0-2.76-3.58-5-8-5Z"/></svg>
                        </div>
                        <div>
                            <h2>Recipient Profile</h2>
                            <p>District selection stores the district id in your profile.</p>
                        </div>
                    </div>
                    <a class="back-link" href="${pageContext.request.contextPath}/recipient/dashboard">Back to Dashboard</a>
                </div>

                <form class="profile-form" method="post" action="${pageContext.request.contextPath}/recipient/edit-details" novalidate>
                    <input type="hidden" name="csrfToken" value="<%= esc(csrfToken) %>">
                    <% if (request.getAttribute("profileError") != null) { %>
                        <div class="alert error"><%= esc(request.getAttribute("profileError")) %></div>
                    <% } %>

                    <div class="field-grid">
                        <div class="field">
                            <label for="districtId">District</label>
                            <select id="districtId" name="districtId">
                                <option value="">Select district</option>
                                <% for (District district : districts) { %>
                                    <option value="<%= district.getId() %>" <%= selected(districtId, district.getId()) %>>
                                        <%= esc(district.getName()) %><%= district.getProvince() != null && !district.getProvince().isEmpty() ? " - " + esc(district.getProvince()) : "" %>
                                    </option>
                                <% } %>
                            </select>
                            <div class="hint">The database stores the district id, not the display name.</div>
                        </div>

                        <div class="field">
                            <label for="dateOfBirth">Date of Birth</label>
                            <input id="dateOfBirth" name="dateOfBirth" type="date" max="<%= java.time.LocalDate.now() %>" value="<%= esc(dateOfBirth) %>">
                        </div>

                        <div class="field">
                            <label for="gender">Gender</label>
                            <select id="gender" name="gender">
                                <option value="">Select gender</option>
                                <option value="male" <%= selected(gender, "male") %>>Male</option>
                                <option value="female" <%= selected(gender, "female") %>>Female</option>
                                <option value="other" <%= selected(gender, "other") %>>Other</option>
                            </select>
                        </div>

                        <div class="field">
                            <label for="address">Address</label>
                            <input id="address" name="address" type="text" maxlength="255" placeholder="Street, ward, city" value="<%= esc(address) %>">
                        </div>

                        <div class="field full">
                            <label for="medicalNotes">Medical Notes</label>
                            <textarea id="medicalNotes" name="medicalNotes" placeholder="Add allergies, conditions, medication, or request context."><%= esc(medicalNotes) %></textarea>
                        </div>
                    </div>

                    <div class="form-actions">
                        <div class="secure-note">Your details help hospitals and donors coordinate faster during urgent requests.</div>
                        <button class="save-btn" type="submit">Save Details</button>
                    </div>
                </form>
            </section>

            <aside class="side-stack">
                <section class="side-card">
                    <div class="side-title">Current Account</div>
                    <div class="summary">
                        <div class="summary-row"><span>Name</span><span><%= esc(fullName) %></span></div>
                        <div class="summary-row"><span>Email</span><span><%= esc(email) %></span></div>
                        <div class="summary-row"><span>Blood Group</span><span><%= esc(currentUser.getBloodGroup() != null ? currentUser.getBloodGroup() : "Not set") %></span></div>
                    </div>
                </section>

                <section class="side-card">
                    <div class="side-title">Why Update This?</div>
                    <ul>
                        <li>District helps nearby donors and hospitals find you.</li>
                        <li>Medical notes give responders important context.</li>
                        <li>Accurate contact details speed up request handling.</li>
                    </ul>
                </section>
            </aside>
        </div>
    </section>
</main>
</body>
</html>
