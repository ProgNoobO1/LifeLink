<%--
  Admin Top Bar – LifeLink
--%>
<%@ page import="com.lifelink.model.User" %>
<%@ page import="com.lifelink.dao.BloodRequestDAO" %>
<%@ page import="com.lifelink.model.BloodRequest" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User currentAdmin = (User) session.getAttribute("currentUser");
    String adminName = (currentAdmin != null) ? currentAdmin.getFullName() : "Admin User";
    String adminEmail = (currentAdmin != null) ? currentAdmin.getEmail() : "admin@lifelink.com";

    // Real notification data
    BloodRequestDAO notifRequestDAO = new BloodRequestDAO();
    long notifPendingCount = notifRequestDAO.countByStatus(BloodRequest.Status.PENDING);
    List<BloodRequest> notifPendingRequests = notifRequestDAO.findByStatus(BloodRequest.Status.PENDING);
%>
<style>

  /* TOP BAR */
  .topbar {
    background: var(--white);
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    padding: .9rem 2rem;
    gap: 1rem;
    position: sticky;
    top: 0;
    z-index: 50;
  }

  .topbar-title { flex: 1; }
  .topbar-title h1 { font-size: 1.2rem; font-weight: 700; color: var(--text-dark); }
  .topbar-title p  { font-size: .8rem; color: var(--text-mid); margin-top: .1rem; }

  .topbar-search {
    position: relative;
    display: flex;
    align-items: center;
  }

  .topbar-search svg {
    position: absolute;
    left: .8rem;
    width: 16px; height: 16px;
    fill: none;
    stroke: var(--text-light);
    stroke-width: 2;
  }

  .topbar-search input {
    padding: .5rem 1rem .5rem 2.3rem;
    border: 1.5px solid var(--border);
    border-radius: 10px;
    font-family: 'DM Sans', sans-serif;
    font-size: .85rem;
    background: #fafafa;
    color: var(--text-dark);
    outline: none;
    width: 200px;
    transition: border-color .2s, box-shadow .2s;
  }

  .topbar-search input:focus {
    border-color: var(--red);
    box-shadow: 0 0 0 3px var(--red-light);
  }

  .topbar-actions { display: flex; align-items: center; gap: .75rem; }

  /* NOTIFICATION */
  .notif-wrap { position: relative; }

  .notif-btn {
    position: relative;
    width: 38px; height: 38px;
    background: #fafafa;
    border: 1.5px solid var(--border);
    border-radius: 10px;
    display: flex; align-items: center; justify-content: center;
    cursor: pointer;
    transition: background .2s;
  }

  .notif-btn:hover { background: var(--red-light); }
  .notif-btn svg { width: 18px; height: 18px; fill: none; stroke: var(--text-mid); stroke-width: 2; }

  .notif-dot {
    position: absolute;
    top: -4px; right: -4px;
    background: var(--red);
    color: white;
    font-size: .6rem;
    font-weight: 700;
    width: 17px; height: 17px;
    border-radius: 999px;
    display: flex;
    align-items: center;
    justify-content: center;
    border: 2px solid white;
  }

  .notif-dropdown {
    position: absolute;
    top: calc(100% + .5rem);
    right: 0;
    background: var(--white);
    border: 1px solid var(--border);
    border-radius: 14px;
    box-shadow: var(--shadow-md);
    min-width: 300px;
    max-width: 360px;
    max-height: 380px;
    overflow-y: auto;
    display: none;
    flex-direction: column;
    z-index: 100;
  }

  .notif-dropdown.show { display: flex; }

  .notif-head {
    padding: 1rem 1.2rem;
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  .notif-head h4 {
    font-size: .9rem;
    font-weight: 700;
    color: var(--text-dark);
  }

  .notif-head a {
    font-size: .78rem;
    font-weight: 600;
    color: var(--red);
    text-decoration: none;
  }

  .notif-head a:hover { opacity: .8; }

  .notif-list {
    display: flex;
    flex-direction: column;
  }

  .notif-item {
    display: flex;
    align-items: flex-start;
    gap: .75rem;
    padding: .85rem 1.2rem;
    border-bottom: 1px solid #f3f4f6;
    text-decoration: none;
    transition: background .2s;
  }

  .notif-item:last-child { border-bottom: none; }
  .notif-item:hover { background: #fafafa; }

  .notif-icon {
    width: 36px; height: 36px;
    border-radius: 10px;
    background: var(--red-light);
    display: flex; align-items: center; justify-content: center;
    flex-shrink: 0;
  }

  .notif-icon svg { width: 18px; height: 18px; fill: var(--red); }

  .notif-body { flex: 1; min-width: 0; }
  .notif-title {
    font-size: .85rem;
    font-weight: 600;
    color: var(--text-dark);
    line-height: 1.4;
  }
  .notif-desc {
    font-size: .78rem;
    color: var(--text-mid);
    margin-top: .15rem;
  }
  .notif-time {
    font-size: .72rem;
    color: var(--text-light);
    margin-top: .2rem;
    font-weight: 500;
  }

  .notif-empty {
    padding: 2rem;
    text-align: center;
    color: var(--text-light);
    font-size: .85rem;
  }

  .notif-footer {
    padding: .75rem 1.2rem;
    border-top: 1px solid var(--border);
    text-align: center;
  }

  .notif-footer a {
    font-size: .82rem;
    font-weight: 600;
    color: var(--red);
    text-decoration: none;
  }

  .topbar-user {
    display: flex;
    align-items: center;
    gap: .65rem;
    cursor: pointer;
  }

  .user-avatar {
    width: 38px; height: 38px;
    background: var(--red-light);
    border: 2px solid var(--border);
    border-radius: 10px;
  }

  .topbar-user .uname { font-size: .85rem; font-weight: 600; color: var(--text-dark); }
  .topbar-user .uemail { font-size: .75rem; color: var(--text-mid); }

  .topbar-user svg { width: 16px; height: 16px; fill: none; stroke: var(--text-mid); stroke-width: 2; }

  .user-dropdown-wrap { position: relative; }

  .user-dropdown {
    position: absolute;
    top: calc(100% + .5rem);
    right: 0;
    background: var(--white);
    border: 1px solid var(--border);
    border-radius: 12px;
    box-shadow: var(--shadow-md);
    min-width: 180px;
    padding: .5rem;
    display: none;
    flex-direction: column;
    gap: .15rem;
    z-index: 100;
  }

  .user-dropdown.show { display: flex; }

  .ud-item {
    display: flex;
    align-items: center;
    gap: .6rem;
    padding: .6rem .8rem;
    border-radius: 8px;
    font-size: .85rem;
    font-weight: 500;
    color: var(--text-dark);
    text-decoration: none;
    cursor: pointer;
    transition: background .2s;
  }

  .ud-item:hover { background: var(--red-light); color: var(--red); }
  .ud-item svg { width: 16px; height: 16px; fill: none; stroke: currentColor; stroke-width: 2; flex-shrink: 0; }

  .ud-divider { height: 1px; background: var(--border); margin: .3rem .5rem; }

  .ud-item.logout { color: var(--red); }
  .ud-item.logout:hover { background: var(--red-light); }
</style>
<!-- TOP BAR -->
<header class="topbar">
  <%
      String topUri = request.getRequestURI();
      String topForwardUri = (String) request.getAttribute("jakarta.servlet.forward.request_uri");
      if (topForwardUri != null) topUri = topForwardUri;
      String pageTitle = "Admin Dashboard";
      String pageSubtitle = "Welcome back! Here's what's happening today.";
      if (topUri != null && topUri.contains("/admin/users")) {
          pageTitle = "Manage Users";
          pageSubtitle = "View, add, edit, and manage system users.";
      } else if (topUri != null && topUri.contains("/admin/requests")) {
          pageTitle = "Manage Requests";
          pageSubtitle = "Review, approve, or reject blood requests.";
      } else if (topUri != null && topUri.contains("/admin/reports")) {
          pageTitle = "System Reports";
          pageSubtitle = "Analytics and insights for the LifeLink platform.";
      }
  %>
  <div class="topbar-title">
    <h1><%= pageTitle %></h1>
    <p><%= pageSubtitle %></p>
  </div>

  <form class="topbar-search" method="get" action="<%= request.getContextPath() %><%= (topUri != null && topUri.contains("/admin/requests")) ? "/admin/requests" : "/admin/dashboard" %>">
    <svg viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/></svg>
    <input type="text" name="search" placeholder="<%= (topUri != null && topUri.contains("/admin/requests")) ? "Search requests..." : "Search..." %>" value="<%= request.getParameter("search") != null ? request.getParameter("search") : "" %>"/>
  </form>

  <div class="topbar-actions">

    <!-- NOTIFICATIONS -->
    <div class="notif-wrap">
      <div class="notif-btn" onclick="document.getElementById('notifDropdown').classList.toggle('show')">
        <svg viewBox="0 0 24 24"><path d="M18 8A6 6 0 006 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 01-3.46 0"/></svg>
        <% if (notifPendingCount > 0) { %>
        <span class="notif-dot"><%= notifPendingCount > 99 ? "99+" : notifPendingCount %></span>
        <% } %>
      </div>
      <div class="notif-dropdown" id="notifDropdown">
        <div class="notif-head">
          <h4>Notifications</h4>
          <% if (notifPendingCount > 0) { %>
          <a href="<%= request.getContextPath() %>/admin/requests?status=PENDING"><%= notifPendingCount %> pending</a>
          <% } %>
        </div>
        <div class="notif-list">
          <% if (notifPendingRequests != null && !notifPendingRequests.isEmpty()) { %>
            <% for (BloodRequest reqItem : notifPendingRequests) { %>
            <a href="<%= request.getContextPath() %>/admin/requests/action?id=<%= reqItem.getId() %>" class="notif-item">
              <div class="notif-icon">
                <svg viewBox="0 0 24 24"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
              </div>
              <div class="notif-body">
                <div class="notif-title">New blood request from <%= reqItem.getRequesterName() %></div>
                <div class="notif-desc"><%= reqItem.getBloodGroup() %> &middot; <%= reqItem.getUnits() %> unit<%= reqItem.getUnits() > 1 ? "s" : "" %></div>
                <div class="notif-time"><%= reqItem.getFormattedDate() %></div>
              </div>
            </a>
            <% } %>
          <% } else { %>
            <div class="notif-empty">No pending requests</div>
          <% } %>
        </div>
        <div class="notif-footer">
          <a href="<%= request.getContextPath() %>/admin/requests">View all requests</a>
        </div>
      </div>
    </div>

    <!-- USER PROFILE -->
    <div class="user-dropdown-wrap">
      <div class="topbar-user" onclick="document.getElementById('userDropdown').classList.toggle('show')">
        <div class="user-avatar"></div>
        <div>
          <div class="uname"><%= adminName %></div>
          <div class="uemail"><%= adminEmail %></div>
        </div>
        <svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>
      </div>
      <div class="user-dropdown" id="userDropdown">
        <a href="<%= request.getContextPath() %>/admin/users/view?id=<%= currentAdmin != null ? currentAdmin.getId() : "" %>" class="ud-item">
          <svg viewBox="0 0 24 24"><path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
          Profile
        </a>
        <div class="ud-divider"></div>
        <a href="<%= request.getContextPath() %>/logout" class="ud-item logout">
          <svg viewBox="0 0 24 24"><path d="M9 21H5a2 2 0 01-2-2V5a2 2 0 012-2h4"/><polyline points="16 17 21 12 16 7"/><line x1="21" y1="12" x2="9" y2="12"/></svg>
          Logout
        </a>
      </div>
    </div>

  </div>
</header>

<script>
  document.addEventListener('click', function(e) {
    const userWrap = document.querySelector('.user-dropdown-wrap');
    const userDropdown = document.getElementById('userDropdown');
    if (userWrap && userDropdown && !userWrap.contains(e.target)) {
      userDropdown.classList.remove('show');
    }

    const notifWrap = document.querySelector('.notif-wrap');
    const notifDropdown = document.getElementById('notifDropdown');
    if (notifWrap && notifDropdown && !notifWrap.contains(e.target)) {
      notifDropdown.classList.remove('show');
    }
  });
</script>
