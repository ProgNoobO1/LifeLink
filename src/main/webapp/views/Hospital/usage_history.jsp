<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<% request.setAttribute("pageTitle", "Usage History"); %>
<%@ include file="/includes/hospital_header.jsp" %>

<div class="app-shell">
    <%@ include file="/includes/hospital_sidebar.jsp" %>
    <div class="main-content">
        <div class="top-header">
            <div>
                <div class="page-title">Blood Usage History</div>
                <div class="page-subtitle">Track all blood usage events and recipients</div>
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
                    <div class="stat-icon red">📊</div>
                    <div><div class="stat-value">${totalUsed}</div><div class="stat-label">Total Units Used</div></div>
                </div>
                <%-- Calculate surgery, emergency, transfer counts from reason field --%>
                <c:set var="surgeryCount" value="0"/>
                <c:set var="emergencyCount" value="0"/>
                <c:set var="transferCount" value="0"/>
                <c:forEach var="h" items="${history}">
                    <c:if test="${h.reason != null && h.reason.toLowerCase().contains('surgery')}">
                        <c:set var="surgeryCount" value="${surgeryCount + h.unitsUsed}"/>
                    </c:if>
                    <c:if test="${h.reason != null && (h.reason.toLowerCase().contains('emergency') || h.reason.toLowerCase().contains('accident') || h.reason.toLowerCase().contains('urgent'))}">
                        <c:set var="emergencyCount" value="${emergencyCount + h.unitsUsed}"/>
                    </c:if>
                    <c:if test="${h.reason != null && (h.reason.toLowerCase().contains('transfer') || h.reason.toLowerCase().contains('transfusion'))}">
                        <c:set var="transferCount" value="${transferCount + h.unitsUsed}"/>
                    </c:if>
                </c:forEach>
                <div class="stat-card fade-in delay-2">
                    <div class="stat-icon" style="background:rgba(128,90,213,0.1);color:#805ad5;">🏥</div>
                    <div><div class="stat-value">${surgeryCount}</div><div class="stat-label">Surgery</div></div>
                </div>
                <div class="stat-card fade-in delay-3">
                    <div class="stat-icon yellow">⚡</div>
                    <div><div class="stat-value">${emergencyCount}</div><div class="stat-label">Emergency</div></div>
                </div>
                <div class="stat-card fade-in delay-4">
                    <div class="stat-icon blue">🔄</div>
                    <div><div class="stat-value">${transferCount}</div><div class="stat-label">Transfer</div></div>
                </div>
            </div>

            <!-- Filters -->
            <div class="d-flex align-center justify-between mb-20">
                <div class="d-flex align-center gap-12">
                    <input type="text" id="usageSearch" class="form-control" placeholder="Search recipient or blood group..." style="width:250px;" onkeyup="filterUsage()">
                    <form method="get" action="${pageContext.request.contextPath}/hospital/usage" class="d-flex align-center gap-8 m-0">
                        <select name="bloodGroup" class="form-control" style="width:auto;">
                            <option value="">🩸 All Purposes</option>
                            <c:forEach var="g" items="${['A+','A-','B+','B-','AB+','AB-','O+','O-']}">
                                <option value="${g}" ${bloodGroupFilter == g ? 'selected' : ''}>${g}</option>
                            </c:forEach>
                        </select>
                        <button class="btn btn-secondary">Filter</button>
                    </form>
                </div>
                <button class="btn btn-primary" onclick="window.print();">
                    📥 Export CSV
                </button>
            </div>

            <!-- Usage Records Table -->
            <div class="card fade-in p-0">
                <div class="card-header border-bottom p-16 d-flex justify-between align-center" style="border-bottom: 1px solid var(--border);">
                    <div>
                        <div class="card-title">Usage Records</div>
                        <div class="card-subtitle">Showing ${history.size()} records</div>
                    </div>
                    <small class="text-muted">🔽 Sorted by latest date</small>
                </div>
                <div class="table-wrap" style="border:none;">
                    <table id="usageTable">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Blood Group</th>
                                <th>Units</th>
                                <th>Purpose</th>
                                <th>Recipient Name</th>
                                <th>Processed By</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="h" items="${history}">
                                <tr>
                                    <td>
                                        <div class="fw-600 fs-13"><fmt:formatDate value="${h.usedAt}" pattern="dd MMM yyyy"/></div>
                                        <div class="fs-12 text-muted"><fmt:formatDate value="${h.usedAt}" pattern="hh:mm a"/></div>
                                    </td>
                                    <td>
                                        <div class="blood-badge" style="width:32px;height:32px;font-size:12px;">${h.bloodGroup}</div>
                                    </td>
                                    <td>${h.unitsUsed} <span class="text-muted fs-12">units</span></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${h.reason != null && (h.reason.toLowerCase().contains('surgery'))}">
                                                <span class="badge badge-accepted">
                                                    Surgery
                                                </span>
                                            </c:when>
                                            <c:when test="${h.reason != null && (h.reason.toLowerCase().contains('emergency') || h.reason.toLowerCase().contains('accident') || h.reason.toLowerCase().contains('urgent'))}">
                                                <span class="badge badge-rejected">
                                                    ⚡ Emergency
                                                </span>
                                            </c:when>
                                            <c:when test="${h.reason != null && (h.reason.toLowerCase().contains('transfer') || h.reason.toLowerCase().contains('transfusion'))}">
                                                <span class="badge badge-completed">
                                                    🔄 Transfer
                                                </span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-pending">
                                                    📋 ${h.reason != null ? h.reason : 'General'}
                                                </span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div class="d-flex align-center gap-8">
                                            <div class="user-avatar" style="width:28px;height:28px;font-size:12px;">R</div>
                                            <span class="fs-13">${h.requesterName != null ? h.requesterName : '—'}</span>
                                        </div>
                                    </td>
                                    <td class="fs-13 text-muted">${hospital.hospitalName}</td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty history}">
                                <tr><td colspan="6">
                                    <div class="empty-state">
                                        <h3>No usage history found</h3>
                                        <p>Blood usage records will appear here after requests are fulfilled.</p>
                                    </div>
                                </td></tr>
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
function filterUsage() {
    var input = document.getElementById('usageSearch').value.toLowerCase();
    var rows = document.querySelectorAll('#usageTable tbody tr');
    rows.forEach(function(row) { row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none'; });
}
</script>
