<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<% request.setAttribute("pageTitle", "Manage Requests"); %>
<%@ include file="/includes/hospital_header.jsp" %>

<div class="app-shell">
    <%@ include file="/includes/hospital_sidebar.jsp" %>
    <div class="main-content">
        <div class="top-header">
            <div>
                <div class="page-title">Manage Requests</div>
                <div class="page-subtitle">Review and act on blood requests</div>
            </div>
            <div class="header-actions">
                <a href="${pageContext.request.contextPath}/hospital/request/new" class="btn btn-danger">
                    + New Request
                </a>
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
                    <div class="stat-icon red">📋</div>
                    <div><div class="stat-value">${totalCount}</div><div class="stat-label">Total Requests</div></div>
                </div>
                <div class="stat-card fade-in delay-2">
                    <div class="stat-icon yellow">⏳</div>
                    <div><div class="stat-value">${pendingCount}</div><div class="stat-label">Pending</div></div>
                </div>
                <div class="stat-card fade-in delay-3">
                    <div class="stat-icon green">✅</div>
                    <div><div class="stat-value">${acceptedCount}</div><div class="stat-label">Approved</div></div>
                </div>
                <div class="stat-card fade-in delay-4">
                    <div class="stat-icon blue">❌</div>
                    <div><div class="stat-value">${rejectedCount}</div><div class="stat-label">Rejected</div></div>
                </div>
            </div>

            <!-- Alert Messages -->
            <c:if test="${param.error == 'insufficient_stock'}">
                <div class="alert alert-danger">❌ Cannot accept — insufficient stock.</div>
            </c:if>
            <c:if test="${param.msg == 'accept_success'}">
                <div class="alert alert-success">✅ Request accepted and stock deducted.</div>
            </c:if>
            <c:if test="${param.msg == 'reject_success'}">
                <div class="alert alert-warning">Request rejected.</div>
            </c:if>
            <c:if test="${param.msg == 'complete_success'}">
                <div class="alert alert-success">✅ Request completed.</div>
            </c:if>

            <!-- Filter Tabs -->
            <div class="d-flex align-center justify-between mb-20">
                <div class="d-flex gap-8" style="overflow-x:auto;">
                    <a href="${pageContext.request.contextPath}/hospital/requests?status=all" class="btn ${statusFilter == 'all' ? 'btn-primary' : 'btn-secondary'}">
                        Incoming <c:if test="${pendingCount > 0}"><span class="badge ${statusFilter == 'all' ? 'badge-muted' : 'badge-danger'}" style="margin-left:6px;">${pendingCount}</span></c:if>
                    </a>
                    <a href="${pageContext.request.contextPath}/hospital/requests?status=pending" class="btn ${statusFilter == 'pending' ? 'btn-primary' : 'btn-secondary'}">
                        Pending <c:if test="${pendingCount > 0}"><span class="badge ${statusFilter == 'pending' ? 'badge-muted' : 'badge-danger'}" style="margin-left:6px;">${pendingCount}</span></c:if>
                    </a>
                    <a href="${pageContext.request.contextPath}/hospital/requests?status=accepted" class="btn ${statusFilter == 'accepted' ? 'btn-primary' : 'btn-secondary'}">Accepted</a>
                    <a href="${pageContext.request.contextPath}/hospital/requests?status=rejected" class="btn ${statusFilter == 'rejected' ? 'btn-primary' : 'btn-secondary'}">Rejected</a>
                    <a href="${pageContext.request.contextPath}/hospital/requests?status=completed" class="btn ${statusFilter == 'completed' ? 'btn-primary' : 'btn-secondary'}">Completed</a>
                    <a href="${pageContext.request.contextPath}/hospital/requests?status=outgoing" class="btn ${statusFilter == 'outgoing' ? 'btn-primary' : 'btn-secondary'}">Outgoing to Donors</a>
                </div>
                <div class="d-flex align-center gap-8">
                    <input type="text" id="reqSearch" class="form-control" placeholder="Search requests..." onkeyup="filterReqs()" style="width:200px;">
                </div>
            </div>

            <!-- Requests Table -->
            <div class="card fade-in p-0">
                <c:choose>
                    <c:when test="${statusFilter == 'outgoing'}">
                        <div class="table-wrap" style="border:none;">
                            <table id="reqTable">
                                <thead>
                                    <tr>
                                        <th>Donor Name</th>
                                        <th>Blood Group</th>
                                        <th>Message</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Contact</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="req" items="${outgoingRequests}">
                                    <tr>
                                        <td>
                                            <div class="d-flex align-center gap-8">
                                                <div class="user-avatar" style="width:28px;height:28px;font-size:12px;">D</div>
                                                <strong>${req.donorName}</strong>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="blood-badge" style="width:32px;height:32px;font-size:12px;">${req.bloodGroup}</div>
                                        </td>
                                        <td><span class="fs-13 text-muted">${req.message}</span></td>
                                        <td class="fs-13"><fmt:formatDate value="${req.createdAt}" pattern="MMM dd, yyyy"/></td>
                                        <td>
                                            <span class="badge badge-${req.status == 'pending' ? 'pending' : req.status == 'accepted' ? 'accepted' : req.status == 'declined' ? 'rejected' : 'completed'}">
                                                ${req.status.substring(0, 1).toUpperCase()}${req.status.substring(1)}
                                            </span>
                                        </td>
                                        <td><span class="text-muted fs-13">${req.donorPhone}</span></td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty outgoingRequests}">
                                    <tr><td colspan="6"><div class="empty-state"><h3>No outgoing requests found</h3><p>Requests you send to donors will appear here.</p></div></td></tr>
                                </c:if>
                                </tbody>
                            </table>
                        </div>
                        <c:if test="${not empty outgoingRequests}">
                            <div class="d-flex justify-between align-center p-16 border-top" style="border-top:1px solid var(--border);">
                                <small class="text-muted">Showing ${outgoingRequests.size()} outgoing requests</small>
                            </div>
                        </c:if>
                    </c:when>
                    
                    <c:otherwise>
                        <div class="table-wrap" style="border:none;">
                            <table id="reqTable">
                                <thead>
                                    <tr>
                                        <th>Request ID</th>
                                        <th>Requester</th>
                                        <th>Blood Group</th>
                                        <th>Units</th>
                                        <th>Date</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                <c:forEach var="req" items="${requests}">
                                    <tr>
                                        <td><strong class="text-danger">#REQ-${req.id}</strong></td>
                                        <td>
                                            <div class="d-flex align-center gap-8">
                                                <div class="user-avatar" style="width:28px;height:28px;font-size:12px;">R</div>
                                                <strong class="fs-13">${req.requesterName}</strong>
                                            </div>
                                        </td>
                                        <td>
                                            <div class="blood-badge" style="width:32px;height:32px;font-size:12px;">${req.bloodGroup}</div>
                                        </td>
                                        <td>${req.unitsNeeded} <span class="text-muted fs-12">units</span></td>
                                        <td class="fs-13"><fmt:formatDate value="${req.createdAt}" pattern="MMM dd, yyyy"/></td>
                                        <td>
                                            <span class="badge badge-${req.status == 'pending' ? 'pending' : req.status == 'accepted' ? 'accepted' : req.status == 'rejected' ? 'rejected' : 'completed'}">
                                                ${req.statusDisplay}
                                            </span>
                                        </td>
                                        <td>
                                            <div class="d-flex gap-8 align-center">
                                                <a href="${pageContext.request.contextPath}/hospital/requests/detail?id=${req.id}" class="btn btn-secondary btn-sm">View</a>
                                                <c:if test="${req.status == 'pending'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/hospital/requests" style="display:inline">
                                                        <input type="hidden" name="action" value="accept"><input type="hidden" name="requestId" value="${req.id}">
                                                        <button class="btn btn-success btn-sm">Approve</button>
                                                    </form>
                                                    <form method="post" action="${pageContext.request.contextPath}/hospital/requests" style="display:inline" onsubmit="return confirm('Are you sure you want to reject this request?');">
                                                        <input type="hidden" name="action" value="reject"><input type="hidden" name="requestId" value="${req.id}">
                                                        <button class="btn btn-danger btn-sm">Reject</button>
                                                    </form>
                                                </c:if>
                                                <c:if test="${req.status == 'accepted'}">
                                                    <form method="post" action="${pageContext.request.contextPath}/hospital/requests" style="display:inline">
                                                        <input type="hidden" name="action" value="complete"><input type="hidden" name="requestId" value="${req.id}">
                                                        <button class="btn btn-success btn-sm">Complete</button>
                                                    </form>
                                                    <button class="btn btn-secondary btn-sm" disabled>Reject</button>
                                                </c:if>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty requests}">
                                    <tr><td colspan="7"><div class="empty-state"><h3>No requests found</h3><p>Requests will appear here when submitted.</p></div></td></tr>
                                </c:if>
                                </tbody>
                            </table>
                        </div>
                        <c:if test="${not empty requests}">
                            <div class="d-flex justify-between align-center p-16 border-top" style="border-top:1px solid var(--border);">
                                <small class="text-muted">Showing ${requests.size()} requests</small>
                            </div>
                        </c:if>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/hospital_footer.jsp" %>
<script>
function filterReqs() {
    var input = document.getElementById('reqSearch').value.toLowerCase();
    var rows = document.querySelectorAll('#reqTable tbody tr');
    rows.forEach(function(row) { row.style.display = row.textContent.toLowerCase().includes(input) ? '' : 'none'; });
}
</script>
