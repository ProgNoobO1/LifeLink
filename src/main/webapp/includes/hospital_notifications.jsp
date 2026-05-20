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
    private String hospitalNotifEsc(Object value) {
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
    User hospitalNotifUser = (User) request.getAttribute("currentUser");
    if (hospitalNotifUser == null) {
        hospitalNotifUser = (User) session.getAttribute("currentUser");
    }

    Object hospitalNotifUserIdValue = session.getAttribute("userId");
    Integer hospitalNotifUserId = null;
    if (hospitalNotifUser != null && hospitalNotifUser.getId() != null) {
        hospitalNotifUserId = hospitalNotifUser.getId().intValue();
    } else if (hospitalNotifUserIdValue != null) {
        try {
            hospitalNotifUserId = Integer.valueOf(String.valueOf(hospitalNotifUserIdValue));
        } catch (NumberFormatException ignored) {
            hospitalNotifUserId = null;
        }
    }

    int hospitalUnreadNotificationCount = 0;
    List<NotificationDAO.NotificationItem> recentHospitalNotifications = Collections.emptyList();
    if (hospitalNotifUserId != null) {
        try {
            NotificationDAO notificationDAO = new NotificationDAO();
            hospitalUnreadNotificationCount = notificationDAO.getUnreadCount(hospitalNotifUserId);
            recentHospitalNotifications = notificationDAO.getRecent(hospitalNotifUserId);
        } catch (SQLException e) {
            System.err.println("[hospital_notifications] Unable to load notifications: " + e.getMessage());
        }
    }

    String hospitalNotifCsrf = (String) session.getAttribute("csrfToken");
    if (hospitalNotifCsrf == null) {
        byte[] bytes = new byte[32];
        new SecureRandom().nextBytes(bytes);
        hospitalNotifCsrf = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
        session.setAttribute("csrfToken", hospitalNotifCsrf);
    }

    String hospitalNotifPath = request.getRequestURI();
    String hospitalNotifQuery = request.getQueryString();
    String hospitalNotifReturnUrl = hospitalNotifPath + (hospitalNotifQuery != null ? "?" + hospitalNotifQuery : "");
    DateTimeFormatter hospitalNotifFmt = DateTimeFormatter.ofPattern("MMM d, h:mm a");
%>
<style>
    .hospital-notif-wrap { position: relative; }
    .hospital-notif-btn {
        position: relative;
        width: 42px;
        height: 42px;
        border: 1px solid #e5e7eb;
        border-radius: 14px;
        background: #f8fafc;
        color: #6b7280;
        display: grid;
        place-items: center;
        cursor: pointer;
        font-size: 18px;
        transition: background .16s, color .16s, border-color .16s;
    }
    .hospital-notif-btn:hover { background: #ffffff; color: #c0392b; border-color: #f1d2ce; }
    .hospital-notif-count {
        position: absolute;
        top: -8px;
        right: -8px;
        min-width: 22px;
        height: 22px;
        padding: 0 6px;
        border-radius: 999px;
        background: #c0392b;
        color: #fff;
        font-size: 11px;
        font-weight: 800;
        line-height: 22px;
        text-align: center;
    }
    .hospital-notif-menu {
        position: absolute;
        top: calc(100% + 10px);
        right: 0;
        width: 340px;
        display: none;
        background: #fff;
        border: 1px solid #e5e7eb;
        border-radius: 14px;
        box-shadow: 0 18px 40px rgba(16,24,40,.14);
        overflow: hidden;
        z-index: 25;
    }
    .hospital-notif-menu.open { display: block; }
    .hospital-notif-head {
        display: flex;
        align-items: center;
        justify-content: space-between;
        gap: .75rem;
        padding: .95rem 1rem;
        border-bottom: 1px solid #edf0f4;
    }
    .hospital-notif-head strong { color: #1f2937; font-size: .88rem; }
    .hospital-mark-read {
        border: 0;
        background: transparent;
        color: #c0392b;
        font-size: .72rem;
        font-weight: 800;
        cursor: pointer;
        white-space: nowrap;
    }
    .hospital-notif-list { max-height: 340px; overflow-y: auto; }
    .hospital-notif-item { padding: .85rem 1rem; border-bottom: 1px solid #f2f4f7; }
    .hospital-notif-item strong { display: block; color: #344054; font-size: .8rem; margin-bottom: .22rem; }
    .hospital-notif-item p { margin: 0; color: #667085; font-size: .74rem; line-height: 1.38; }
    .hospital-notif-item span { display: block; margin-top: .35rem; color: #98a2b3; font-size: .7rem; }
    .hospital-notif-empty { padding: 1.3rem; color: #98a2b3; font-size: .8rem; text-align: center; }
    @media (max-width: 700px) {
        .hospital-notif-menu { right: -4.5rem; width: min(340px, calc(100vw - 2rem)); }
    }
</style>

<div class="hospital-notif-wrap">
    <button class="hospital-notif-btn" type="button" title="Notifications" aria-label="Notifications">
        &#128276;
        <% if (hospitalUnreadNotificationCount > 0) { %>
            <span class="hospital-notif-count"><%= hospitalUnreadNotificationCount > 99 ? "99+" : hospitalUnreadNotificationCount %></span>
        <% } %>
    </button>
    <div class="hospital-notif-menu">
        <div class="hospital-notif-head">
            <strong>Notifications</strong>
            <form method="post" action="${pageContext.request.contextPath}/hospital/dashboard">
                <input type="hidden" name="csrfToken" value="<%= hospitalNotifEsc(hospitalNotifCsrf) %>">
                <input type="hidden" name="action" value="markNotificationsRead">
                <input type="hidden" name="returnUrl" value="<%= hospitalNotifEsc(hospitalNotifReturnUrl) %>">
                <button class="hospital-mark-read" type="submit">Mark all as read</button>
            </form>
        </div>
        <div class="hospital-notif-list">
            <% if (recentHospitalNotifications.isEmpty()) { %>
                <div class="hospital-notif-empty">No notifications yet</div>
            <% } else { %>
                <% for (NotificationDAO.NotificationItem item : recentHospitalNotifications) {
                    long notifMillis = item.getCreatedAt() != null
                        ? item.getCreatedAt().atZone(ZoneId.systemDefault()).toInstant().toEpochMilli()
                        : 0L;
                    String notifTime = item.getCreatedAt() != null ? hospitalNotifFmt.format(item.getCreatedAt()) : "";
                %>
                <div class="hospital-notif-item" data-notif-time="<%= notifMillis %>">
                    <strong><%= hospitalNotifEsc(item.getSubject()) %></strong>
                    <p><%= hospitalNotifEsc(item.getBody()) %></p>
                    <span class="hospital-notif-relative" title="<%= hospitalNotifEsc(notifTime) %>">Just now</span>
                </div>
                <% } %>
            <% } %>
        </div>
    </div>
</div>

<script>
(function() {
    if (window.hospitalNotificationsReady) return;
    window.hospitalNotificationsReady = true;

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
        root.querySelectorAll('.hospital-notif-relative').forEach(el => {
            const row = el.closest('[data-notif-time]');
            el.textContent = relativeTime(Number(row ? row.dataset.notifTime : 0));
        });
    }

    document.addEventListener('click', event => {
        document.querySelectorAll('.hospital-notif-menu.open').forEach(menu => {
            if (!menu.closest('.hospital-notif-wrap').contains(event.target)) {
                menu.classList.remove('open');
            }
        });
    });

    document.querySelectorAll('.hospital-notif-wrap').forEach(wrap => {
        refreshTimes(wrap);
        const button = wrap.querySelector('.hospital-notif-btn');
        const menu = wrap.querySelector('.hospital-notif-menu');
        button.addEventListener('click', event => {
            event.stopPropagation();
            menu.classList.toggle('open');
        });
    });
})();
</script>
