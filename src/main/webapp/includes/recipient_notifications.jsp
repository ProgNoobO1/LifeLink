<%@ page import="com.lifelink.dao.NotificationDAO" %>
<%@ page import="com.lifelink.model.User" %>
<%@ page import="java.security.SecureRandom" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Base64" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%!
    private String notifEsc(Object value) {
        if (value == null) return "";
        return String.valueOf(value)
            .replace("&", "&amp;")
            .replace("<", "&lt;")
            .replace(">", "&gt;")
            .replace("\"", "&quot;")
            .replace("'", "&#39;");
    }
%>
<%
    User notifUser = (User) request.getAttribute("currentUser");
    if (notifUser == null) {
        notifUser = (User) session.getAttribute("currentUser");
    }

    int unreadNotificationCount = 0;
    List<NotificationDAO.NotificationItem> recentRecipientNotifications = Collections.emptyList();
    if (notifUser != null) {
        try {
            NotificationDAO notificationDAO = new NotificationDAO();
            unreadNotificationCount = notificationDAO.getUnreadCount(notifUser.getId().intValue());
            recentRecipientNotifications = notificationDAO.getRecent(notifUser.getId().intValue());
        } catch (SQLException e) {
            System.err.println("[recipient_notifications] Unable to load notifications: " + e.getMessage());
        }
    }

    String recipientNotifCsrf = (String) session.getAttribute("csrfToken");
    if (recipientNotifCsrf == null) {
        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        recipientNotifCsrf = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute("csrfToken", recipientNotifCsrf);
    }

    String currentPath = request.getRequestURI();
    String queryString = request.getQueryString();
    String returnUrl = currentPath + (queryString != null ? "?" + queryString : "");
    DateTimeFormatter recipientNotifFmt = DateTimeFormatter.ofPattern("MMM d, h:mm a");
%>
<style>
    .recipient-notif-wrap { position: relative; }
    .recipient-notif-btn {
        position: relative;
        width: 40px;
        height: 40px;
        border: 1px solid #e5e7eb;
        border-radius: 12px;
        background: #fff;
        color: #6b7280;
        display: grid;
        place-items: center;
        cursor: pointer;
        transition: background .16s, color .16s;
    }
    .recipient-notif-btn:hover { background: #f9fafb; color: #c91c20; }
    .recipient-notif-btn svg { width: 19px; height: 19px; fill: currentColor; }
    .recipient-notif-count {
        position: absolute;
        top: -5px;
        right: -4px;
        min-width: 16px;
        height: 16px;
        border-radius: 999px;
        background: #c91c20;
        color: #fff;
        font-size: .62rem;
        font-weight: 800;
        line-height: 16px;
        text-align: center;
    }
    .recipient-notif-menu {
        position: absolute;
        top: calc(100% + .55rem);
        right: 0;
        width: 330px;
        display: none;
        background: #fff;
        border: 1px solid #edf0f4;
        border-radius: 14px;
        box-shadow: 0 18px 40px rgba(16,24,40,.14);
        overflow: hidden;
        z-index: 200;
    }
    .recipient-notif-menu.open { display: block; }
    .recipient-notif-head {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: .75rem;
        padding: .9rem 1rem;
        border-bottom: 1px solid #edf0f4;
    }
    .recipient-notif-head strong { color: #1f2937; font-size: .88rem; }
    .recipient-mark-read {
        border: 0;
        background: transparent;
        color: #c91c20;
        font-size: .72rem;
        font-weight: 800;
        cursor: pointer;
        white-space: nowrap;
    }
    .recipient-notif-list { max-height: 340px; overflow-y: auto; }
    .recipient-notif-item { padding: .85rem 1rem; border-bottom: 1px solid #f2f4f7; }
    .recipient-notif-item strong { display: block; color: #344054; font-size: .8rem; margin-bottom: .22rem; }
    .recipient-notif-item p { color: #667085; font-size: .74rem; line-height: 1.35; margin: 0; }
    .recipient-notif-item span { display: block; margin-top: .35rem; color: #98a2b3; font-size: .7rem; }
    .recipient-notif-empty { padding: 1.3rem; color: #98a2b3; font-size: .8rem; text-align: center; }
    @media (max-width: 700px) {
        .recipient-notif-menu { right: -4.5rem; width: min(330px, calc(100vw - 2rem)); }
    }
</style>

<div class="recipient-notif-wrap">
    <button class="recipient-notif-btn" type="button" title="Notifications" aria-label="Notifications">
        <svg viewBox="0 0 24 24"><path d="M12 22a2.5 2.5 0 0 0 2.45-2h-4.9A2.5 2.5 0 0 0 12 22Zm7-6v-5a7 7 0 0 0-5-6.71V3a2 2 0 1 0-4 0v1.29A7 7 0 0 0 5 11v5l-2 2v1h18v-1l-2-2Z"/></svg>
        <% if (unreadNotificationCount > 0) { %>
            <span class="recipient-notif-count"><%= unreadNotificationCount > 99 ? "99+" : unreadNotificationCount %></span>
        <% } %>
    </button>
    <div class="recipient-notif-menu">
        <div class="recipient-notif-head">
            <strong>Notifications</strong>
            <form method="post" action="${pageContext.request.contextPath}/recipient/requests">
                <input type="hidden" name="csrfToken" value="<%= notifEsc(recipientNotifCsrf) %>">
                <input type="hidden" name="action" value="markNotificationsRead">
                <input type="hidden" name="returnUrl" value="<%= notifEsc(returnUrl) %>">
                <button class="recipient-mark-read" type="submit">Mark all as read</button>
            </form>
        </div>
        <div class="recipient-notif-list">
            <% if (recentRecipientNotifications.isEmpty()) { %>
                <div class="recipient-notif-empty">No notifications yet</div>
            <% } else { %>
                <% for (NotificationDAO.NotificationItem item : recentRecipientNotifications) {
                    long notifMillis = item.getCreatedAt() != null
                        ? item.getCreatedAt().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
                        : 0L;
                    String notifTime = item.getCreatedAt() != null ? recipientNotifFmt.format(item.getCreatedAt()) : "";
                %>
                <div class="recipient-notif-item" data-notif-time="<%= notifMillis %>">
                    <strong><%= notifEsc(item.getSubject()) %></strong>
                    <p><%= notifEsc(item.getBody()) %></p>
                    <span class="recipient-notif-relative" title="<%= notifEsc(notifTime) %>">Just now</span>
                </div>
                <% } %>
            <% } %>
        </div>
    </div>
</div>

<script>
(function() {
    if (window.recipientNotificationsReady) return;
    window.recipientNotificationsReady = true;

    function relativeTime(time) {
        if (!time) return 'recently';
        const seconds = Math.max(1, Math.floor((Date.now() - time) / 1000));
        const units = [['year',31536000], ['month',2592000], ['day',86400], ['hour',3600], ['minute',60]];
        for (const [label, value] of units) {
            const amount = Math.floor(seconds / value);
            if (amount >= 1) return amount + ' ' + label + (amount === 1 ? '' : 's') + ' ago';
        }
        return 'just now';
    }

    function refreshTimes(root) {
        root.querySelectorAll('.recipient-notif-relative').forEach(el => {
            const row = el.closest('[data-notif-time]');
            el.textContent = relativeTime(Number(row ? row.dataset.notifTime : 0));
        });
    }

    document.addEventListener('click', event => {
        document.querySelectorAll('.recipient-notif-menu.open').forEach(menu => {
            if (!menu.closest('.recipient-notif-wrap').contains(event.target)) {
                menu.classList.remove('open');
            }
        });
    });

    document.querySelectorAll('.recipient-notif-wrap').forEach(wrap => {
        refreshTimes(wrap);
        const button = wrap.querySelector('.recipient-notif-btn');
        const menu = wrap.querySelector('.recipient-notif-menu');
        button.addEventListener('click', event => {
            event.stopPropagation();
            menu.classList.toggle('open');
        });
    });
})();
</script>
