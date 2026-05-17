<%@ page import="com.lifelink.model.User" %>
<%@ page import="com.lifelink.dao.BloodRequestDAO" %>
<%@ page import="com.lifelink.model.BloodRequest" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    /* Recipient sidebar — only recipient-scoped navigation links */
    User sidebarUser = (User) session.getAttribute("currentUser");
    String sidebarName  = (sidebarUser != null) ? sidebarUser.getFullName()  : "Recipient";
    String sidebarEmail = (sidebarUser != null) ? sidebarUser.getEmail()     : "";

    /* Count pending requests for THIS recipient only */
    long recipientPendingCount = 0;
    if (sidebarUser != null) {
        BloodRequestDAO brdao = new BloodRequestDAO();
        // We use the existing countByStatus but scoped DAO will be used in future;
        // for the badge we approximate with countByStatus for ALL pending (admin view)
        // or use the recipient-specific DAO when available.
        // Since BloodRequestDAO.countByStatus is system-wide, we compute inline:
        java.sql.Connection _sc = null;
        java.sql.PreparedStatement _sp = null;
        java.sql.ResultSet _sr = null;
        try {
            _sc = com.lifelink.utils.DBConnection.getConnection();
            _sp = _sc.prepareStatement(
                "SELECT COUNT(*) FROM blood_requests WHERE requester_id = ? AND status = 'pending'");
            _sp.setLong(1, sidebarUser.getId());
            _sr = _sp.executeQuery();
            if (_sr.next()) recipientPendingCount = _sr.getLong(1);
        } catch (Exception _ex) {
            System.err.println("[recipient_sidebar] badge count error: " + _ex.getMessage());
        } finally {
            if (_sr != null) try { _sr.close(); } catch (Exception ignored) {}
            if (_sp != null) try { _sp.close(); } catch (Exception ignored) {}
            if (_sc != null) try { _sc.close(); } catch (Exception ignored) {}
        }
    }

    /* Compute initials for avatar */
    String sidebarInitials = "R";
    if (sidebarUser != null) sidebarInitials = sidebarUser.getInitials();

    /* Active page detection */
    String _uri = request.getRequestURI();
    String _fwd = (String) request.getAttribute("jakarta.servlet.forward.request_uri");
    if (_fwd != null) _uri = _fwd;
%>
<style>
    :root {
        --red:        #b91c1c;
        --red-dark:   #991b1b;
        --red-light:  #fee2e2;
        --sidebar-bg: #1a0a0a;
        --sidebar-w:  210px;
    }

    .sidebar {
        width: var(--sidebar-w);
        background: var(--sidebar-bg);
        display: flex;
        flex-direction: column;
        position: fixed;
        top: 0; left: 0; bottom: 0;
        z-index: 100;
        overflow-y: auto;
    }

    .sidebar-logo {
        display: flex;
        align-items: center;
        gap: .75rem;
        padding: 1.4rem 1.25rem;
        border-bottom: 1px solid rgba(255,255,255,.07);
        flex-shrink: 0;
    }

    .logo-icon {
        width: 38px; height: 38px;
        background: var(--red);
        border-radius: 10px;
        display: flex; align-items: center; justify-content: center;
        flex-shrink: 0;
    }
    .logo-icon svg { width: 20px; height: 20px; fill: white; }

    .logo-name {
        font-family: 'Playfair Display', serif;
        font-size: 1.2rem;
        color: white;
        letter-spacing: -.01em;
    }

    .sidebar-section { padding: 1.2rem .9rem .4rem; }

    .sidebar-section-label {
        font-size: .63rem;
        font-weight: 700;
        letter-spacing: .1em;
        text-transform: uppercase;
        color: rgba(255,255,255,.28);
        padding: 0 .4rem;
        margin-bottom: .55rem;
    }

    .nav-item {
        display: flex;
        align-items: center;
        gap: .7rem;
        padding: .65rem .8rem;
        border-radius: 10px;
        font-size: .87rem;
        font-weight: 500;
        color: rgba(255,255,255,.52);
        text-decoration: none;
        transition: background .18s, color .18s;
        position: relative;
        margin-bottom: .12rem;
    }
    .nav-item svg { width: 18px; height: 18px; fill: currentColor; flex-shrink: 0; }
    .nav-item:hover { background: rgba(255,255,255,.07); color: rgba(255,255,255,.82); }
    .nav-item.active { background: var(--red); color: white; }
    .nav-item.active::after {
        content: '';
        margin-left: auto;
        width: 4px; height: 22px;
        background: rgba(255,255,255,.45);
        border-radius: 999px;
        flex-shrink: 0;
    }

    .nav-item .badge {
        margin-left: auto;
        background: rgba(255,255,255,.22);
        color: white;
        font-size: .66rem;
        font-weight: 700;
        padding: .12rem .4rem;
        border-radius: 999px;
        line-height: 1.4;
    }
    .nav-item.active .badge { background: rgba(255,255,255,.3); }

    .sidebar-spacer { flex: 1; }

    .sidebar-bottom {
        border-top: 1px solid rgba(255,255,255,.07);
        padding: .9rem;
        flex-shrink: 0;
    }

    .logout-btn {
        display: flex;
        align-items: center;
        gap: .7rem;
        padding: .62rem .8rem;
        border-radius: 10px;
        font-size: .86rem;
        font-weight: 500;
        color: rgba(255,255,255,.48);
        text-decoration: none;
        transition: background .18s, color .18s;
        margin-bottom: .8rem;
    }
    .logout-btn svg { width: 18px; height: 18px; fill: currentColor; }
    .logout-btn:hover { background: rgba(255,255,255,.07); color: rgba(255,255,255,.8); }

    .sidebar-user {
        display: flex;
        align-items: center;
        gap: .65rem;
        padding: .65rem .8rem;
        background: rgba(255,255,255,.06);
        border-radius: 10px;
    }

    .user-avatar-sm {
        width: 34px; height: 34px;
        background: var(--red);
        border-radius: 8px;
        display: flex; align-items: center; justify-content: center;
        font-size: .74rem;
        font-weight: 700;
        color: white;
        flex-shrink: 0;
        overflow: hidden;
    }

    .user-info-sm { flex: 1; min-width: 0; }
    .user-info-sm .uname {
        font-size: .81rem;
        font-weight: 600;
        color: white;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .user-info-sm .urole {
        font-size: .71rem;
        color: var(--red);
        font-weight: 600;
        text-transform: capitalize;
    }

    .user-more {
        background: none; border: none;
        cursor: pointer;
        color: rgba(255,255,255,.38);
        display: flex;
    }
    .user-more svg { width: 16px; height: 16px; fill: currentColor; }

    /* Mobile overlay */
    .sidebar-overlay {
        display: none;
        position: fixed; inset: 0;
        background: rgba(0,0,0,.45);
        z-index: 99;
    }
    .sidebar-overlay.show { display: block; }

    @media (max-width: 1024px) {
        .sidebar { transform: translateX(-100%); transition: transform .28s ease; }
        .sidebar.open { transform: translateX(0); }
    }
</style>

<div class="sidebar-overlay" id="sidebarOverlay" onclick="closeSidebar()"></div>

<aside class="sidebar" id="mainSidebar">

    <div class="sidebar-logo">
        <div class="logo-icon">
            <svg viewBox="0 0 24 24"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
        </div>
        <span class="logo-name">LifeLink</span>
    </div>

    <div class="sidebar-section">
        <div class="sidebar-section-label">Menu</div>

        <a href="${pageContext.request.contextPath}/recipient/dashboard"
           class="nav-item <%= (_uri.contains("/recipient/dashboard")) ? "active" : "" %>">
            <svg viewBox="0 0 24 24"><path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"/></svg>
            Dashboard
        </a>

        <a href="${pageContext.request.contextPath}/recipient/search"
           class="nav-item <%= (_uri.contains("/recipient/search")) ? "active" : "" %>">
            <svg viewBox="0 0 24 24"><path d="M15.5 14h-.79l-.28-.27A6.471 6.471 0 0 0 16 9.5 6.5 6.5 0 1 0 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/></svg>
            Search Donors
        </a>

        <a href="${pageContext.request.contextPath}/views/recipient/create_request.jsp"
           class="nav-item <%= (_uri.contains("/recipient/requests") || _uri.contains("/views/recipient/create_request.jsp")) ? "active" : "" %>">
            <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
            My Requests
            <% if (recipientPendingCount > 0) { %>
            <span class="badge"><%= recipientPendingCount %></span>
            <% } %>
        </a>

    </div>

    <div class="sidebar-spacer"></div>

    <div class="sidebar-bottom">
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn">
            <svg viewBox="0 0 24 24"><path d="M17 7l-1.41 1.41L18.17 11H8v2h10.17l-2.58 2.58L17 17l5-5-5-5zM4 5h8V3H4c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h8v-2H4V5z"/></svg>
            Logout
        </a>

        <div class="sidebar-user">
            <div class="user-avatar-sm"><%= sidebarInitials %></div>
            <div class="user-info-sm">
                <div class="uname"><%= sidebarName != null ? sidebarName : "Recipient" %></div>
                <div class="urole">Recipient</div>
            </div>
            <button class="user-more" title="More options">
                <svg viewBox="0 0 24 24"><path d="M12 8c1.1 0 2-.9 2-2s-.9-2-2-2-2 .9-2 2 .9 2 2 2zm0 2c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm0 6c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/></svg>
            </button>
        </div>
    </div>

</aside>

<script>
function toggleSidebar() {
    document.getElementById('mainSidebar').classList.toggle('open');
    document.getElementById('sidebarOverlay').classList.toggle('show');
}
function closeSidebar() {
    document.getElementById('mainSidebar').classList.remove('open');
    document.getElementById('sidebarOverlay').classList.remove('show');
}
window.addEventListener('resize', () => { if (window.innerWidth > 1024) closeSidebar(); });
</script>
