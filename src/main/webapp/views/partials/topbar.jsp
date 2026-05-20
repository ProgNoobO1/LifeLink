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
        
        <div class="user-dropdown-wrap">
            <div style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;" id="userDropdownTrigger">
                <span style="font-size: 0.9rem; font-weight: 500;">${donor.name}</span>
                <i class="fas fa-chevron-down" style="font-size: 0.7rem; color: var(--text-muted);"></i>
            </div>
            
            <div class="user-dropdown" id="userDropdown">
                <a href="${pageContext.request.contextPath}/donor/profile" class="ud-item">
                    <i class="fas fa-user" style="flex-shrink: 0;"></i>
                    My Profile
                </a>
                <div style="height: 1px; background: var(--border-light); margin: 0.3rem 0.5rem;"></div>
                <a href="${pageContext.request.contextPath}/logout" class="ud-item logout">
                    <i class="fas fa-sign-out-alt" style="flex-shrink: 0;"></i>
                    Logout
                </a>
            </div>
        </div>
    </div>
</div>

<style>
    .user-dropdown-wrap {
        position: relative;
    }
    .user-dropdown {
        position: absolute;
        top: calc(100% + 0.5rem);
        right: 0;
        background: var(--white);
        border: 1px solid var(--border-light);
        border-radius: 12px;
        box-shadow: var(--shadow-md);
        min-width: 180px;
        padding: 0.5rem;
        display: none;
        flex-direction: column;
        gap: 0.15rem;
        z-index: 1000;
    }
    .user-dropdown.show {
        display: flex;
    }
    .ud-item {
        display: flex;
        align-items: center;
        gap: 0.6rem;
        padding: 0.6rem 0.8rem;
        border-radius: 8px;
        font-size: 0.85rem;
        font-weight: 500;
        color: var(--text-main);
        text-decoration: none;
        cursor: pointer;
        transition: var(--transition);
    }
    .ud-item:hover {
        background: rgba(217, 4, 41, 0.05);
        color: var(--active-red);
    }
    .ud-item.logout {
        color: var(--active-red);
    }
    .ud-item.logout:hover {
        background: rgba(217, 4, 41, 0.1);
    }
</style>

<script>
    document.getElementById('notificationTrigger').addEventListener('click', function(e) {
        e.stopPropagation();
        document.getElementById('notificationDropdown').classList.toggle('show');
        document.getElementById('userDropdown').classList.remove('show');
    });

    document.getElementById('userDropdownTrigger').addEventListener('click', function(e) {
        e.stopPropagation();
        document.getElementById('userDropdown').classList.toggle('show');
        document.getElementById('notificationDropdown').classList.remove('show');
    });

    document.addEventListener('click', function() {
        document.getElementById('notificationDropdown').classList.remove('show');
        document.getElementById('userDropdown').classList.remove('show');
    });
</script>
