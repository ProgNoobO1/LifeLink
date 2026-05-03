<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<div class="top-bar">
    <div class="page-info">
        <h2>${pageTitle}</h2>
        <p>${pageSubtitle}</p>
    </div>
    
    <div class="top-bar-right">
        <div class="notification-bell" id="notificationTrigger">
            <i class="far fa-bell"></i>
            <c:if test="${not empty notifications}">
                <span class="bell-badge">${notifications.size()}</span>
            </c:if>
            
            <div class="notification-dropdown" id="notificationDropdown">
                <div class="notification-header">
                    <span>Notifications</span>
                    <span style="font-size: 0.7rem; font-weight: 400; color: var(--active-red); cursor: pointer;">Mark all as read</span>
                </div>
                <div style="max-height: 400px; overflow-y: auto;">
                    <c:forEach var="n" items="${notifications}">
                        <a href="${n.type == 'Request' ? pageContext.request.contextPath.concat('/donor/requests') : pageContext.request.contextPath.concat('/donor/dashboard')}" 
                           class="notification-item ${n.type == 'Renewal' ? 'renewal' : ''}">
                            <i class="${n.icon}"></i>
                            <div class="notification-body">
                                <span class="notification-text">${n.message}</span>
                                <span class="notification-time">${n.time}</span>
                            </div>
                        </a>
                    </c:forEach>
                    <c:if test="${empty notifications}">
                        <div style="padding: 2rem; text-align: center; color: var(--text-muted); font-size: 0.8rem;">
                            <i class="fas fa-bell-slash" style="display: block; font-size: 1.5rem; margin-bottom: 0.5rem; opacity: 0.3;"></i>
                            No new notifications
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
        
        <div style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
            <span style="font-size: 0.9rem; font-weight: 500;">${donor.name}</span>
            <i class="fas fa-chevron-down" style="font-size: 0.7rem; color: var(--text-muted);"></i>
        </div>
    </div>
</div>

<script>
    document.getElementById('notificationTrigger').addEventListener('click', function(e) {
        e.stopPropagation();
        document.getElementById('notificationDropdown').classList.toggle('show');
    });

    document.addEventListener('click', function() {
        document.getElementById('notificationDropdown').classList.remove('show');
    });
</script>
