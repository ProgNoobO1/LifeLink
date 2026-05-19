<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<% request.setAttribute("pageTitle", "Manage Stock"); %>
<%@ include file="/includes/hospital_header.jsp" %>

<div class="app-shell">
    <%@ include file="/includes/hospital_sidebar.jsp" %>
    <div class="main-content">
        <div class="top-header">
            <div>
                <div class="page-title">Manage Blood Stock</div>
                <div class="page-subtitle">Add, update or remove blood units from your inventory</div>
            </div>
            <div class="header-actions">
                <div class="user-pill">
                    <div class="user-avatar">🏥</div>
                    <div><div class="user-name">${hospital.hospitalName}</div><div class="user-role">Hospital</div></div>
                </div>
            </div>
        </div>

        <div class="page-body">
            <!-- Stat Cards -->
            <div class="stats-grid mb-28">
                <div class="stat-card fade-in delay-1">
                    <div class="stat-icon red">🩸</div>
                    <div><div class="stat-value">${totalUnits}</div><div class="stat-label">Total Units</div></div>
                </div>
                <div class="stat-card fade-in delay-2">
                    <div class="stat-icon green">✅</div>
                    <div><div class="stat-value">${normalGroups}</div><div class="stat-label">Normal Groups</div></div>
                </div>
                <div class="stat-card fade-in delay-3">
                    <div class="stat-icon yellow">⚠️</div>
                    <div><div class="stat-value">${lowStockCount}</div><div class="stat-label">Low Stock</div></div>
                </div>
            </div>

            <!-- Advanced Global Shortage Alert Banner -->
            <c:if test="${lowStockCount > 0}">
                <div class="alert alert-warning mb-20">
                    🚨 <strong>Blood Shortage Alert:</strong> You have <strong>${lowStockCount}</strong> blood group(s) running low or critically low!
                    <a href="${pageContext.request.contextPath}/hospital/request/new" class="btn btn-warning btn-sm" style="margin-left:auto;">Request Blood Now</a>
                </div>
            </c:if>

            <!-- Success/Error Messages -->
            <c:if test="${param.msg == 'deleted'}">
                <div class="alert alert-success">✅ Stock entry deleted successfully.</div>
            </c:if>
            <c:if test="${param.msg == 'added'}">
                <div class="alert alert-success">✅ New blood stock entry added successfully.</div>
            </c:if>
            <c:if test="${param.msg == 'updated'}">
                <div class="alert alert-success">✅ Blood stock updated successfully.</div>
            </c:if>

            <!-- Blood Stock Inventory -->
            <div class="card fade-in">
                <div class="card-header">
                    <div>
                        <div class="card-title">Blood Stock Inventory</div>
                        <div class="card-subtitle">All blood groups currently tracked in your inventory</div>
                    </div>
                    <div class="d-flex align-center gap-16">
                        <input type="text" id="stockSearch" class="form-control" placeholder="Search stock..." onkeyup="filterStock()" style="width:200px;">
                        <a href="${pageContext.request.contextPath}/hospital/stock/form" class="btn btn-primary">+ Add New Stock</a>
                    </div>
                </div>

                <div class="table-wrap">
                    <table id="stockTable">
                        <thead>
                            <tr>
                                <th>Blood Group</th>
                                <th>Units Available</th>
                                <th>Status</th>
                                <th>Last Updated</th>
                                <th>Avg. Expiry Date</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="stock" items="${stockList}">
                                <tr>
                                    <td>
                                        <div class="d-flex align-center gap-12">
                                            <div class="blood-badge">${stock.bloodGroup}</div>
                                            <div>
                                                <div class="fw-600">Type ${stock.bloodGroup == 'A+' ? 'A Positive' : 
                                                       stock.bloodGroup == 'A-' ? 'A Negative' : 
                                                       stock.bloodGroup == 'B+' ? 'B Positive' : 
                                                       stock.bloodGroup == 'B-' ? 'B Negative' : 
                                                       stock.bloodGroup == 'O+' ? 'O Positive' : 
                                                       stock.bloodGroup == 'O-' ? 'O Negative' : 
                                                       stock.bloodGroup == 'AB+' ? 'AB Positive' : 
                                                       stock.bloodGroup == 'AB-' ? 'AB Negative' : stock.bloodGroup}</div>
                                                <div class="fs-12 text-muted">ABO/Rh factor</div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="d-flex align-center gap-12">
                                            <div><strong style="font-size:15px;">${stock.unitsAvailable}</strong> <span class="text-muted fs-12">units</span></div>
                                            <div class="progress" style="width: 80px; height: 5px; margin: 0; background: #E2E8F0;">
                                                <div class="progress-bar ${stock.unitsAvailable < 5 ? 'red' : stock.unitsAvailable < 15 ? 'yellow' : 'green'}"
                                                     style="width: ${stock.progressWidth}%"></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge badge-${stock.unitsAvailable < 5 ? 'danger' : stock.unitsAvailable < 15 ? 'warning' : 'success'}">
                                            ${stock.stockLevelDisplay}
                                        </span>
                                    </td>
                                    <td class="text-muted fs-13">
                                        <c:choose>
                                            <c:when test="${stock.lastUpdated != null}">
                                                <fmt:formatDate value="${stock.lastUpdated}" pattern="dd MMM yyyy, hh:mm a"/>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td class="text-muted fs-13">
                                        <jsp:useBean id="calendar" class="java.util.GregorianCalendar" scope="request" />
                                        <c:set var="lastUpdatedTime" value="${stock.lastUpdated}" />
                                        <%
                                            java.sql.Timestamp ts = (java.sql.Timestamp) pageContext.getAttribute("lastUpdatedTime");
                                            if (ts != null) {
                                                java.util.Calendar cal = java.util.Calendar.getInstance();
                                                cal.setTimeInMillis(ts.getTime());
                                                cal.add(java.util.Calendar.DAY_OF_YEAR, 35);
                                                pageContext.setAttribute("expiryDate", cal.getTime());
                                            } else {
                                                pageContext.setAttribute("expiryDate", null);
                                            }
                                        %>
                                        <c:choose>
                                            <c:when test="${expiryDate != null}">
                                                <fmt:formatDate value="${expiryDate}" pattern="dd MMM yyyy"/>
                                            </c:when>
                                            <c:otherwise>—</c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex gap-8">
                                            <a href="${pageContext.request.contextPath}/hospital/stock/form?id=${stock.id}" class="btn-icon-action btn-edit" title="Edit Stock">✏️</a>
                                            <form method="post" action="${pageContext.request.contextPath}/hospital/stock" style="display:inline" onsubmit="return confirm('Are you sure you want to remove ${stock.bloodGroup} stock entry?');">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="stockId" value="${stock.id}">
                                                <button type="submit" class="btn-icon-action btn-delete" title="Delete Stock">🗑️</button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty stockList}">
                                <tr>
                                    <td colspan="6">
                                        <div class="empty-state">
                                            <div class="empty-state-icon">🩸</div>
                                            <h3>No stock entries found</h3>
                                            <p>Start by adding blood group stock to your inventory.</p>
                                            <a href="${pageContext.request.contextPath}/hospital/stock/form" class="btn btn-primary mt-16">+ Add Stock</a>
                                        </div>
                                    </td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
<%@ include file="/includes/hospital_footer.jsp" %>
<script>
function filterStock() {
    var input = document.getElementById('stockSearch').value.toLowerCase();
    var rows = document.querySelectorAll('#stockTable tbody tr');
    rows.forEach(function(row) {
        var text = row.textContent.toLowerCase();
        row.style.display = text.includes(input) ? '' : 'none';
    });
}
</script>
