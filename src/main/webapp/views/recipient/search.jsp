<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.lifelink.dao.SearchDAO" %>
<%@ page import="com.lifelink.model.User" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%!
    private String esc(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;").replace("'","&#39;");
    }
    private String bgClass(String bg) {
        if ("AB+".equals(bg)) return "bg-ab-pos";
        if ("AB-".equals(bg)) return "bg-ab-neg";
        if ("O+".equals(bg)) return "bg-o-pos";
        if ("O-".equals(bg)) return "bg-o-neg";
        if ("B+".equals(bg)) return "bg-b-pos";
        if ("B-".equals(bg)) return "bg-b-neg";
        if ("A-".equals(bg)) return "bg-a-neg";
        return "bg-a-pos";
    }
    private String initials(String name) {
        if (name == null || name.trim().isEmpty()) return "U";
        String[] p = name.trim().split("\\s+");
        return p.length > 1 ? (p[0].substring(0,1) + p[p.length - 1].substring(0,1)).toUpperCase() : p[0].substring(0, Math.min(2, p[0].length())).toUpperCase();
    }
%>
<%
    User currentUser = (User) request.getAttribute("currentUser");
    if (currentUser == null) currentUser = (User) session.getAttribute("currentUser");
    if (currentUser == null) { response.sendRedirect(request.getContextPath() + "/login"); return; }
    List<SearchDAO.BloodGroupOption> bloodGroups = (List<SearchDAO.BloodGroupOption>) request.getAttribute("bloodGroups");
    List<SearchDAO.HospitalResult> hospitals = (List<SearchDAO.HospitalResult>) request.getAttribute("nearbyHospitals");
    List<SearchDAO.DonorResult> donors = (List<SearchDAO.DonorResult>) request.getAttribute("nearbyDonors");
    List<SearchDAO.PopularSearch> popular = (List<SearchDAO.PopularSearch>) request.getAttribute("popularSearches");
    if (bloodGroups == null) bloodGroups = Collections.emptyList();
    if (hospitals == null) hospitals = Collections.emptyList();
    if (donors == null) donors = Collections.emptyList();
    if (popular == null) popular = Collections.emptyList();
    String fullName = currentUser.getFullName() != null ? currentUser.getFullName() : "User";
    String email = currentUser.getEmail() != null ? currentUser.getEmail() : "";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search for Blood | LifeLink</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&family=Playfair+Display:wght@700&display=swap" rel="stylesheet">
    <style>
        *,*::before,*::after{box-sizing:border-box;margin:0;padding:0}
        body{min-height:100vh;background:#f6f7f9;color:#1f2937;font-family:'Inter',sans-serif}
        button,input,select{font:inherit}.main-content{min-height:100vh;margin-left:210px}.topbar{position:sticky;top:0;z-index:50;display:flex;align-items:center;justify-content:space-between;gap:1rem;min-height:78px;padding:1.05rem 2rem;background:#fff;border-bottom:1px solid #eceff3}.topbar-left{display:flex;align-items:center;gap:.85rem}.hamburger{display:none;border:0;background:transparent;color:#4b5563;cursor:pointer;padding:.35rem}.hamburger svg{width:24px;height:24px;fill:currentColor}.page-title h1{font-size:1.25rem;line-height:1.2;font-weight:800}.page-title p{margin-top:.35rem;font-size:.78rem;color:#98a2b3}.topbar-right{display:flex;align-items:center;gap:.95rem}.top-user{display:flex;align-items:center;gap:.7rem}.avatar{width:38px;height:38px;border-radius:999px;background:linear-gradient(135deg,#b91c1c,#ef4444);color:#fff;display:grid;place-items:center;font-weight:800;font-size:.78rem;border:2px solid #f4d0d0}.top-user strong{display:block;font-size:.84rem;color:#344054}.top-user span{display:block;font-size:.74rem;color:#98a2b3}.chevron{width:18px;height:18px;fill:#98a2b3}.page-body{padding:2.1rem 2.1rem 3rem}.shell{max-width:1120px;margin:0 auto;display:grid;gap:1.8rem}.layout{display:grid;grid-template-columns:minmax(0,1fr)356px;gap:1.5rem;align-items:start}.search-card,.card,.side-card{background:#fff;border:1px solid #edf0f4;border-radius:16px;box-shadow:0 1px 3px rgba(16,24,40,.04)}.search-card{position:relative;overflow:hidden;padding:1.55rem}.search-card::after{content:"";position:absolute;right:80px;top:-35px;width:180px;height:180px;border-radius:50%;background:#fff1f1;opacity:.7}.search-head{display:flex;align-items:center;gap:.8rem;margin-bottom:1.35rem;position:relative;z-index:1}.search-icon{width:42px;height:42px;border-radius:12px;background:#c91c20;color:#fff;display:grid;place-items:center;box-shadow:0 8px 16px rgba(185,28,28,.2)}.search-icon svg{width:20px;height:20px;fill:currentColor}.search-head h2{font-size:1.05rem;font-weight:800}.search-head p{font-size:.78rem;color:#98a2b3;margin-top:.25rem}.search-form{position:relative;z-index:1}.filters{display:grid;grid-template-columns:1fr 1fr 1fr 140px;gap:1rem;align-items:end}.field label{display:block;margin-bottom:.55rem;color:#667085;font-size:.74rem;text-transform:uppercase;letter-spacing:.05em;font-weight:800}.control{position:relative}.control svg{position:absolute;left:.85rem;top:50%;transform:translateY(-50%);width:17px;height:17px;fill:#98a2b3}select,input{width:100%;height:48px;border:1px solid #dce2ea;border-radius:12px;background:#fbfcfe;color:#344054;padding:0 1rem 0 2.45rem;outline:none}select{appearance:none;cursor:pointer}.search-btn{height:48px;border:0;border-radius:12px;background:#c91c20;color:#fff;font-weight:800;display:inline-flex;align-items:center;justify-content:center;gap:.55rem;cursor:pointer;box-shadow:0 10px 18px rgba(185,28,28,.22)}.search-btn svg{width:17px;height:17px;fill:currentColor}.quick{display:flex;align-items:center;gap:.55rem;flex-wrap:wrap;margin-top:1.2rem;color:#98a2b3;font-size:.78rem}.quick-pill{border:0;border-radius:8px;padding:.44rem .78rem;background:#fee2e2;color:#c91c20;font-weight:800;cursor:pointer}.quick-pill.active,.quick-pill:hover{background:#c91c20;color:#fff}.section-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:1rem}.section-head h2{font-size:1rem;font-weight:800}.section-head p{font-size:.78rem;color:#98a2b3;margin-top:.25rem}.view-all{color:#c91c20;background:#fee2e2;text-decoration:none;border-radius:9px;padding:.45rem .8rem;font-size:.76rem;font-weight:800}.hospital-grid{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:1rem}.hospital-card{padding:1.05rem;border-radius:14px;background:#fff;border:1px solid #edf0f4;box-shadow:0 1px 3px rgba(16,24,40,.04)}.hospital-top{display:flex;align-items:flex-start;justify-content:space-between;gap:.8rem}.hospital-main{display:flex;gap:.8rem;min-width:0}.hospital-icon{width:44px;height:44px;border-radius:12px;background:#fee2e2;color:#c91c20;display:grid;place-items:center;flex-shrink:0}.hospital-icon svg{width:22px;height:22px;fill:currentColor}.hospital-card h3{font-size:.9rem;font-weight:800}.muted{color:#98a2b3;font-size:.78rem}.status{display:inline-flex;align-items:center;gap:.35rem;border-radius:999px;padding:.3rem .62rem;font-size:.72rem;font-weight:800}.status.open,.status.available{background:#ecfdf3;color:#16a34a}.status.busy{background:#fffbeb;color:#d97706}.status.unavailable{background:#f1f3f6;color:#98a2b3}.stock{display:flex;align-items:center;gap:.4rem;flex-wrap:wrap;margin:1rem 0 .85rem}.stock-count{border-radius:8px;padding:.28rem .5rem;font-size:.72rem;font-weight:800}.stock-count.ok{background:#ecfdf3;color:#16a34a}.stock-count.low{background:#fee2e2;color:#c91c20}.blood-pill{display:inline-flex;align-items:center;justify-content:center;min-width:34px;height:23px;border-radius:7px;color:#fff;font-size:.72rem;font-weight:800}.bg-a-pos,.bg-o-pos,.bg-b-neg{background:#c91c20}.bg-a-neg,.bg-o-neg{background:#881337}.bg-b-pos{background:#d92d20}.bg-ab-pos{background:#7c3aed}.bg-ab-neg{background:#5b21b6}.card-foot{display:flex;align-items:center;justify-content:space-between;color:#667085;font-size:.78rem}.contact,.request-btn{border:0;border-radius:9px;background:#fee2e2;color:#c91c20;padding:.5rem .8rem;font-weight:800;text-decoration:none;font-size:.76rem}.donor-panel{padding:1.35rem}.donor-scroll{display:flex;gap:1rem;overflow-x:auto;padding:.25rem .1rem}.donor-card{flex:0 0 186px;border:1px solid #edf0f4;border-radius:13px;background:#fafbfc;padding:1rem}.donor-avatar{position:relative;width:44px;height:44px;border-radius:12px;background:linear-gradient(135deg,#c91c20,#0ea5e9);color:#fff;display:grid;place-items:center;font-weight:800;margin-bottom:.8rem}.donor-avatar .blood-pill{position:absolute;left:130px;top:0}.donor-card h3{font-size:.86rem;font-weight:800;margin-bottom:.2rem}.dot{display:inline-block;width:7px;height:7px;border-radius:50%;background:#22c55e;box-shadow:0 0 0 4px rgba(34,197,94,.14)}.dot.grey{background:#c0c7d1;box-shadow:none}.donor-action{display:block;text-align:center;margin-top:.8rem;border-radius:9px;padding:.62rem;background:#fee2e2;color:#c91c20;text-decoration:none;font-size:.76rem;font-weight:800}.donor-action.disabled{background:#f1f3f6;color:#98a2b3;pointer-events:none}.side-stack{display:grid;gap:1.5rem}.side-card{padding:1.25rem}.side-title{display:flex;align-items:center;gap:.5rem;font-size:.92rem;font-weight:800;margin-bottom:1rem}.popular-list{display:grid;gap:.7rem}.popular-item{display:flex;align-items:center;justify-content:space-between;gap:.8rem;padding:.8rem;border-radius:12px;background:#fafbfc;border:1px solid #edf0f4}.popular-left{display:flex;align-items:center;gap:.7rem}.popular-name{font-size:.8rem;font-weight:800}.popular-sub{font-size:.74rem;color:#98a2b3}.count-pill{padding:.28rem .55rem;border-radius:8px;border:1px solid #dce2ea;color:#98a2b3;font-size:.72rem}.tip-list{display:grid;gap:1rem;color:#667085;font-size:.8rem;line-height:1.4}.tip-list div{display:flex;gap:.65rem}.check{width:24px;height:24px;border-radius:8px;background:#fee2e2;color:#c91c20;display:grid;place-items:center;flex-shrink:0;font-weight:800}.empty{padding:1.5rem;text-align:center;color:#98a2b3;border:1px dashed #dce2ea;border-radius:14px;background:#fff}.empty-illustration{width:44px;height:44px;margin:0 auto .7rem;border-radius:14px;background:#fee2e2;color:#c91c20;display:grid;place-items:center;font-weight:800}.loading-card{min-height:142px;border-radius:14px;background:linear-gradient(90deg,#f2f4f7 25%,#fff 38%,#f2f4f7 63%);background-size:400% 100%;animation:shine 1.2s ease infinite}@keyframes shine{0%{background-position:100% 0}100%{background-position:0 0}}.skeleton .ajax-zone{opacity:.65}
        @media(max-width:1024px){.main-content{margin-left:0}.hamburger{display:inline-grid;place-items:center}.layout{grid-template-columns:1fr}.filters{grid-template-columns:1fr 1fr}.search-btn{grid-column:1/-1}.hospital-grid{grid-template-columns:1fr}}@media(max-width:700px){.topbar{padding:1rem}.top-user div:not(.avatar),.chevron{display:none}.page-body{padding:1rem}.filters{grid-template-columns:1fr}.search-card{padding:1.1rem}}
    </style>
</head>
<body>
<jsp:include page="/includes/recipient_sidebar.jsp" />
<main class="main-content">
    <header class="topbar">
        <div class="topbar-left">
            <button class="hamburger" type="button" onclick="toggleSidebar()" aria-label="Open menu"><svg viewBox="0 0 24 24"><path d="M3 18h18v-2H3v2zm0-5h18v-2H3v2zm0-7v2h18V6H3z"/></svg></button>
            <div class="page-title"><h1>Search for Blood</h1><p>Find available donors or hospitals near you</p></div>
        </div>
        <div class="topbar-right"><jsp:include page="/includes/recipient_notifications.jsp" /><div class="top-user"><div class="avatar"><%= esc(currentUser.getInitials()) %></div><div><strong><%= esc(fullName) %></strong><span><%= esc(email) %></span></div><svg class="chevron" viewBox="0 0 24 24"><path d="M7.41 8.59 12 13.17l4.59-4.58L18 10l-6 6-6-6z"/></svg></div></div>
    </header>
    <section class="page-body">
        <div class="shell">
            <% if (request.getAttribute("searchError") != null) { %>
                <div class="empty"><div class="empty-illustration">!</div><%= esc(request.getAttribute("searchError")) %></div>
            <% } %>
            <section class="search-card">
                <div class="search-head"><div class="search-icon"><svg viewBox="0 0 24 24"><path d="M9.5 3a6.5 6.5 0 0 1 5.16 10.45l4.45 4.44-1.42 1.42-4.44-4.45A6.5 6.5 0 1 1 9.5 3Zm0 2a4.5 4.5 0 1 0 0 9 4.5 4.5 0 0 0 0-9Z"/></svg></div><div><h2>Find a Donor</h2><p>Search by blood group and location</p></div></div>
                <form class="search-form" id="searchForm" method="get" action="${pageContext.request.contextPath}/search">
                    <div class="filters">
                        <div class="field"><label>Blood Group</label><div class="control"><svg viewBox="0 0 24 24"><path d="M12 2S5 9.67 5 15a7 7 0 0 0 14 0C19 9.67 12 2 12 2Z"/></svg><select name="bloodGroup" id="bloodGroup"><option value="">Select Blood Group</option><% for (SearchDAO.BloodGroupOption g : bloodGroups) { %><option value="<%= esc(g.getName()) %>"><%= esc(g.getName()) %></option><% } %></select></div></div>
                        <div class="field"><label>Location / City</label><div class="control"><svg viewBox="0 0 24 24"><path d="M12 2a7 7 0 0 0-7 7c0 5.25 7 13 7 13s7-7.75 7-13a7 7 0 0 0-7-7Zm0 9.5A2.5 2.5 0 1 1 12 6a2.5 2.5 0 0 1 0 5.5Z"/></svg><input id="locationInput" name="location" type="text" placeholder="e.g. Kathmandu"></div></div>
                        <div class="field"><label>Urgency Level</label><div class="control"><svg viewBox="0 0 24 24"><path d="M1 21h22L12 2 1 21Zm12-3h-2v-2h2v2Zm0-4h-2v-4h2v4Z"/></svg><select name="urgency"><option value="">Any Urgency</option><option value="normal">Normal</option><option value="urgent">Urgent</option><option value="critical">Critical</option></select></div></div>
                        <button class="search-btn" type="submit"><svg viewBox="0 0 24 24"><path d="M9.5 3a6.5 6.5 0 0 1 5.16 10.45l4.45 4.44-1.42 1.42-4.44-4.45A6.5 6.5 0 1 1 9.5 3Z"/></svg>Search</button>
                    </div>
                    <div class="quick"><span>Quick select:</span><% String[] quick = {"A+","B+","O+","O-","AB+","AB-"}; for (String q : quick) { %><button class="quick-pill" type="button" data-blood-group="<%= q %>"><%= q %></button><% } %></div>
                </form>
            </section>

            <div class="layout">
                <div>
                    <div class="section-head"><div><h2>Nearby Hospitals</h2><p>Hospitals with active blood banks near you</p></div><a class="view-all" href="${pageContext.request.contextPath}/search?type=hospitals">View All</a></div>
                    <div class="hospital-grid ajax-zone" id="landingHospitalGrid">
                        <% if (hospitals.isEmpty()) { %><div class="empty"><div class="empty-illustration">+</div>No hospitals with stock found.</div><% } %>
                        <% for (SearchDAO.HospitalResult h : hospitals) { %>
                        <article class="hospital-card"><div class="hospital-top"><div class="hospital-main"><div class="hospital-icon"><svg viewBox="0 0 24 24"><path d="M19 3H5v18h14V3Zm-8 16H7v-4h4v4Zm6 0h-4v-4h4v4ZM9 5h6v2H9V5Z"/></svg></div><div><h3><%= esc(h.getHospitalName()) %></h3><div class="muted"><%= esc(h.getDistrict()) %></div></div></div><span class="status <%= h.isOpen() ? "open" : "busy" %>"><%= h.isOpen() ? "Open" : "Busy" %></span></div><div class="stock"><% int shown=0; for (SearchDAO.StockItem s : h.getStock()) { if (shown++ < 3) { %><span class="blood-pill <%= bgClass(s.getBloodGroup()) %>" title="<%= s.getUnitsAvailable() %> units available"><%= esc(s.getBloodGroup()) %></span><span class="stock-count <%= s.isLowStock() ? "low" : "ok" %>"><%= s.getUnitsAvailable() %></span><% }} if (h.getStock().size()>3) { %><span class="muted">+<%= h.getStock().size()-3 %> more</span><% } %></div><div class="card-foot"><span><%= String.format("%.1f", h.getDistanceKm()) %> km away</span><a class="contact" href="${pageContext.request.contextPath}/views/recipient/create_request.jsp?hospitalId=<%= h.getId() %>">Contact</a></div></article>
                        <% } %>
                    </div>
                </div>
                <aside class="side-stack">
                    <section class="side-card"><h2 class="side-title">Popular Searches</h2><div class="popular-list"><% int pcount=0; for (SearchDAO.PopularSearch p : popular) { if (pcount++ < 5) { %><div class="popular-item"><div class="popular-left"><span class="blood-pill <%= bgClass(p.getBloodGroup()) %>"><%= esc(p.getBloodGroup()) %></span><div><div class="popular-name"><%= esc(p.getBloodGroup()) %></div><div class="popular-sub">Available donors</div></div></div><span class="count-pill"><%= p.getDonorCount() %> results</span></div><% }} %></div></section>
                    <section class="side-card"><h2 class="side-title">Search Tips</h2><div class="tip-list"><div><span class="check">✓</span><span>Enter your city name for best results.</span></div><div><span class="check">✓</span><span>O- donors can donate to all blood types.</span></div><div><span class="check">✓</span><span>Use urgency filter for critical situations.</span></div></div></section>
                </aside>
            </div>

            <section class="card donor-panel"><div class="section-head"><div><h2>Available Donors Nearby</h2><p>Donors currently available in your area</p></div><a class="view-all" href="${pageContext.request.contextPath}/search?type=donors">View All</a></div><div class="donor-scroll ajax-zone" id="landingDonorRow"><% if (donors.isEmpty()) { %><div class="empty"><div class="empty-illustration">0</div>No donors found for this blood group in your area.</div><% } %><% for (SearchDAO.DonorResult d : donors) { %><article class="donor-card"><div class="donor-avatar"><%= esc(initials(d.getFullName())) %><span class="blood-pill <%= bgClass(d.getBloodGroup()) %>"><%= esc(d.getBloodGroup()) %></span></div><h3><%= esc(d.getFullName()) %></h3><div class="muted"><%= esc(d.getDistrict()) %></div><div class="muted" style="margin-top:.6rem;"><span class="dot <%= d.isAvailable() ? "" : "grey" %>"></span> <%= d.isAvailable() ? "Available" : "Busy" %> &nbsp; <%= String.format("%.1f", d.getDistanceKm()) %> km</div><a class="donor-action <%= d.isAvailable() ? "" : "disabled" %>" href="${pageContext.request.contextPath}/views/recipient/create_request.jsp?bloodGroup=<%= esc(d.getBloodGroup()) %>&donorId=<%= d.getId() %>"><%= d.isAvailable() ? "Request" : "Unavailable" %></a></article><% } %></div></section>
        </div>
    </section>
</main>
<script>
window.LifeLinkSearch = {
    requestPath: '${pageContext.request.contextPath}/views/recipient/create_request.jsp'
};
</script>
<script src="${pageContext.request.contextPath}/views/recipient/search.js"></script>
</body>
</html>
