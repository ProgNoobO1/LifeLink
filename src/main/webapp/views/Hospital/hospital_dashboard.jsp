<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<% request.setAttribute("pageTitle", "Hospital Dashboard"); %>
<%@ include file="/includes/hospital_header.jsp" %>

<div class="app-shell">
    <%@ include file="/includes/hospital_sidebar.jsp" %>
    <div class="main-content">
        <div class="top-header">
            <div>
                <div class="page-title">Hospital Dashboard</div>
                <div class="page-subtitle">Monitor your blood stock and requests</div>
            </div>
            <div class="header-actions">
                <div class="user-pill">
                    <div class="user-avatar">🏥</div>
                    <div><div class="user-name">${hospital.hospitalName}</div><div class="user-role">Hospital</div></div>
                </div>
            </div>
        </div>

        <div class="page-body">
            <!-- Advanced Global Shortage Alert Banner -->
            <c:if test="${lowStockCount > 0}">
                <div class="alert alert-warning mb-28">
                    🚨 <strong>Blood Shortage Alert:</strong> You have <strong>${lowStockCount}</strong> blood group(s) running low or critically low!
                    <a href="${pageContext.request.contextPath}/hospital/request/new" class="btn btn-warning btn-sm" style="margin-left:auto;">Request Blood Now</a>
                </div>
            </c:if>

            <!-- Stat Cards -->
            <div class="stats-grid mb-28">
                <div class="stat-card fade-in delay-1">
                    <div class="stat-icon red">🩸</div>
                    <div><div class="stat-value">${totalUnits}</div><div class="stat-label">Total Stock</div></div>
                </div>
                <div class="stat-card fade-in delay-2">
                    <div class="stat-icon yellow">⚠️</div>
                    <div><div class="stat-value">${lowStockCount}</div><div class="stat-label">Low Stock Alerts</div></div>
                </div>
                <div class="stat-card fade-in delay-3">
                    <div class="stat-icon blue">📋</div>
                    <div><div class="stat-value">${pendingRequests}</div><div class="stat-label">Pending Requests</div></div>
                </div>
            </div>

            <div class="grid-2 mb-28">
                <!-- Stock Overview Table -->
                <div class="card fade-in">
                    <div class="card-header">
                        <div>
                            <div class="card-title">Stock Overview</div>
                            <div class="card-subtitle">Current blood units by group</div>
                        </div>
                        <a href="${pageContext.request.contextPath}/hospital/stock" class="btn btn-secondary btn-sm">View All</a>
                    </div>
                    <div class="table-wrap">
                        <table>
                            <thead>
                                <tr>
                                    <th>Blood Group</th>
                                    <th>Units Available</th>
                                    <th>Stock Level</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="stock" items="${stockList}">
                                    <tr>
                                        <td>
                                            <div class="blood-badge">${stock.bloodGroup}</div>
                                        </td>
                                        <td><strong>${stock.unitsAvailable}</strong> units</td>
                                        <td>
                                            <div class="progress" style="width: 100px; height: 6px;">
                                                <div class="progress-bar ${stock.unitsAvailable < 5 ? 'red' : stock.unitsAvailable < 15 ? 'yellow' : 'green'}"
                                                     style="width: ${stock.progressWidth}%"></div>
                                            </div>
                                        </td>
                                        <td>
                                            <span class="badge badge-${stock.unitsAvailable < 5 ? 'danger' : stock.unitsAvailable < 15 ? 'warning' : 'success'}">
                                                ${stock.stockLevelDisplay}
                                            </span>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty stockList}">
                                    <tr><td colspan="4" class="text-center text-muted py-4">No stock entries yet. <a href="${pageContext.request.contextPath}/hospital/stock/form">Add stock</a></td></tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <!-- Right Sidebar -->
                <div style="display:flex; flex-direction:column; gap:20px;">
                    <!-- Quick Actions -->
                    <div class="card fade-in delay-1">
                        <div class="card-header">
                            <div>
                                <div class="card-title">⚡ Quick Actions</div>
                                <div class="card-subtitle">Manage your hospital stock</div>
                            </div>
                        </div>
                        <div style="display:flex;flex-direction:column;gap:12px">
                            <a href="${pageContext.request.contextPath}/hospital/stock/form" class="quick-action-btn btn-add-stock">
                                <span>➕ Add Stock</span>
                                <span style="font-size:16px;">→</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/hospital/requests" class="quick-action-btn btn-create-request">
                                <span>📋 Create Request</span>
                                <span style="font-size:16px;">→</span>
                            </a>
                            <a href="${pageContext.request.contextPath}/hospital/requests?status=pending" class="quick-action-btn btn-view-pending">
                                <span>⏰ View Pending</span>
                                <c:if test="${pendingRequests > 0}">
                                    <span class="pending-badge">${pendingRequests}</span>
                                </c:if>
                            </a>
                        </div>
                    </div>

                    <!-- Low Stock Alerts Detail -->
                    <c:if test="${not empty lowStockAlerts}">
                        <div class="card fade-in delay-2">
                            <div class="card-header mb-16">
                                <div>
                                    <div class="card-title text-warning">⚠️ Low Stock Alerts</div>
                                    <div class="card-subtitle">Requires immediate attention</div>
                                </div>
                            </div>
                            <c:forEach var="alert" items="${lowStockAlerts}">
                                <div class="low-stock-alert-item">
                                    <div class="d-flex align-center gap-12">
                                        <div class="blood-badge" style="width:32px;height:32px;font-size:11px;">${alert.bloodGroup}</div>
                                        <span class="fs-13 text-muted">Only ${alert.unitsAvailable} units left</span>
                                    </div>
                                    <span class="badge badge-danger">Low</span>
                                </div>
                            </c:forEach>
                            <div class="mt-16 pt-16" style="border-top:1px solid var(--border);">
                                <small class="text-muted">Last updated: <fmt:formatDate value="<%= new java.util.Date() %>" pattern="hh:mm a"/></small>
                            </div>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </div>
</div>
<%@ include file="/includes/hospital_footer.jsp" %>
