<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<% request.setAttribute("pageTitle", "Request Detail"); %>
<%@ include file="/includes/hospital_header.jsp" %>

<div class="app-shell">
    <%@ include file="/includes/hospital_sidebar.jsp" %>
    <div class="main-content">
        <div class="top-header">
            <div class="d-flex align-center gap-12">
                <a href="${pageContext.request.contextPath}/hospital/requests" class="text-muted" style="font-size:20px;">←</a>
                <div>
                    <div class="page-title">Request Details</div>
                    <div class="page-subtitle">Full information for request #REQ-${bloodRequest.id}</div>
                </div>
            </div>
            <div class="header-actions">
                <div class="user-pill">
                    <div class="user-avatar">🏥</div>
                    <div><div class="user-name">${hospital.hospitalName}</div><div class="user-role">Hospital</div></div>
                </div>
            </div>
        </div>

        <div class="page-body">
            <!-- Alert Messages -->
            <c:if test="${param.msg == 'success'}"><div class="alert alert-success">✅ Action completed successfully.</div></c:if>
            <c:if test="${param.msg == 'insufficient_stock'}"><div class="alert alert-danger">❌ Insufficient stock to accept this request.</div></c:if>

            <div class="grid-2">
                <!-- Left Column -->
                <div style="display:flex; flex-direction:column; gap:20px;">
                    <!-- Request Header Banner -->
                    <div class="card fade-in d-flex justify-between align-center" style="background: rgba(59,130,246,0.05); border-color: rgba(59,130,246,0.2);">
                        <div>
                            <h2 class="mb-4 fs-20">#REQ-${bloodRequest.id}</h2>
                            <small class="text-muted">Submitted on <fmt:formatDate value="${bloodRequest.createdAt}" pattern="MMM dd, yyyy - hh:mm a"/></small>
                        </div>
                        <span class="badge badge-${bloodRequest.status == 'pending' ? 'pending' : bloodRequest.status == 'accepted' ? 'accepted' : bloodRequest.status == 'rejected' ? 'rejected' : 'completed'} fs-13" style="padding:6px 16px;">
                            ${bloodRequest.statusDisplay}
                        </span>
                    </div>

                    <!-- Request Details Card -->
                    <div class="card fade-in delay-1">
                        <div class="grid-2 gap-20 mb-20">
                            <div>
                                <label class="form-label text-muted">🧑 Requester</label>
                                <div class="fw-600">${bloodRequest.requesterName}</div>
                            </div>
                            <div>
                                <label class="form-label text-muted">🩸 Blood Group</label>
                                <div class="d-flex align-center gap-8">
                                    <div class="blood-badge" style="width:28px;height:28px;font-size:11px;">${bloodRequest.bloodGroup}</div>
                                    <span class="fw-600">Type ${bloodRequest.bloodGroup}</span>
                                </div>
                            </div>
                            <div>
                                <label class="form-label text-muted">📦 Units Requested</label>
                                <div class="fw-600">${bloodRequest.unitsNeeded} units</div>
                            </div>
                            <div>
                                <label class="form-label text-muted">📋 Status</label>
                                <div>
                                    <span class="badge badge-${bloodRequest.status == 'pending' ? 'pending' : bloodRequest.status == 'accepted' ? 'accepted' : bloodRequest.status == 'rejected' ? 'rejected' : 'completed'}">
                                        ${bloodRequest.statusDisplay}
                                    </span>
                                </div>
                            </div>
                            <div>
                                <label class="form-label text-muted">📞 Phone</label>
                                <div class="fw-600">${bloodRequest.requesterPhone != null ? bloodRequest.requesterPhone : 'N/A'}</div>
                            </div>
                            <div>
                                <label class="form-label text-muted">📧 Email</label>
                                <div class="fw-600">${bloodRequest.requesterEmail}</div>
                            </div>
                        </div>

                        <!-- Requester Notes -->
                        <c:if test="${not empty bloodRequest.message}">
                            <div class="p-16 rounded mt-16" style="background: var(--bg-primary); border: 1px solid var(--border); border-radius: var(--radius-sm);">
                                <strong>📝 Requester Notes</strong>
                                <p class="mb-0 mt-8 text-muted">"${bloodRequest.message}"</p>
                            </div>
                        </c:if>

                        <!-- Action Buttons -->
                        <div class="mt-28 pt-20" style="border-top:1px solid var(--border);">
                            <h5 class="mb-16 fs-16 fw-600">⚡ Take Action</h5>
                            <div class="d-flex gap-12 flex-wrap">
                                <c:if test="${bloodRequest.status == 'pending'}">
                                    <form method="post" action="${pageContext.request.contextPath}/hospital/requests/detail" class="d-inline">
                                        <input type="hidden" name="requestId" value="${bloodRequest.id}">
                                        <button name="action" value="accept" class="btn btn-success">✅ Approve & Dispatch</button>
                                    </form>
                                    <form method="post" action="${pageContext.request.contextPath}/hospital/requests/detail" class="d-inline" onsubmit="return confirm('Are you sure you want to reject this request?');">
                                        <input type="hidden" name="requestId" value="${bloodRequest.id}">
                                        <button name="action" value="reject" class="btn btn-danger">❌ Reject Request</button>
                                    </form>
                                </c:if>
                                <c:if test="${bloodRequest.status == 'accepted'}">
                                    <form method="post" action="${pageContext.request.contextPath}/hospital/requests/detail" class="d-inline">
                                        <input type="hidden" name="requestId" value="${bloodRequest.id}">
                                        <button name="action" value="complete" class="btn btn-success">✔ Mark as Completed</button>
                                    </form>
                                </c:if>
                                <a href="${pageContext.request.contextPath}/hospital/requests" class="btn btn-secondary">← Back to List</a>
                            </div>
                            <c:if test="${bloodRequest.status == 'pending'}">
                                <small class="text-muted mt-12 d-block">⚠️ Approving will immediately notify ${bloodRequest.requesterName} and log dispatch details.</small>
                            </c:if>
                        </div>
                    </div>
                </div>

                <!-- Right Sidebar -->
                <div style="display:flex; flex-direction:column; gap:20px;">
                    <!-- Available Stock -->
                    <div class="card fade-in delay-2">
                        <div class="card-header border-bottom pb-12 mb-16" style="border-bottom: 1px solid var(--border);">
                            <div>
                                <div class="card-title">📊 Available Stock</div>
                                <div class="card-subtitle">${hospital.hospitalName} Inventory</div>
                            </div>
                        </div>

                        <c:if test="${currentStock != null}">
                            <div class="alert ${currentStock.unitsAvailable >= bloodRequest.unitsNeeded ? 'alert-success' : 'alert-danger'} p-12 mb-16">
                                <strong>${currentStock.unitsAvailable >= bloodRequest.unitsNeeded ? '✅ Sufficient Stock' : '⚠️ May be insufficient'}</strong>
                                <br><small>${currentStock.unitsAvailable >= bloodRequest.unitsNeeded ? 'Can fulfill this request' : 'Available stock may not cover this request'}</small>
                            </div>

                            <div class="d-flex align-center justify-between mb-8">
                                <div class="d-flex align-center gap-8">
                                    <div class="blood-badge" style="width:28px;height:28px;font-size:11px;">${bloodRequest.bloodGroup}</div>
                                    <span class="fs-13">Available</span>
                                </div>
                                <span class="fw-700 fs-24">${currentStock.unitsAvailable}</span>
                            </div>
                            <small class="text-muted">Requested: ${bloodRequest.unitsNeeded} units &nbsp; <span class="text-success">+${currentStock.unitsAvailable - bloodRequest.unitsNeeded} remaining</span></small>
                        </c:if>
                        <c:if test="${currentStock == null}">
                            <div class="alert alert-danger p-12">⚠️ No stock entry for ${bloodRequest.bloodGroup}</div>
                        </c:if>

                        <div class="mt-20 pt-16 border-top" style="border-top:1px solid var(--border);">
                            <small class="text-muted fw-700 mb-12 d-block">OTHER BLOOD GROUPS</small>
                            <c:forEach var="s" items="${allStock}">
                                <c:if test="${s.bloodGroup != bloodRequest.bloodGroup}">
                                    <div class="d-flex justify-between align-center py-8">
                                        <div class="d-flex align-center gap-8">
                                            <div class="blood-badge" style="width:24px;height:24px;font-size:10px;">${s.bloodGroup}</div>
                                        </div>
                                        <div class="d-flex align-center gap-12">
                                            <span class="fw-600">${s.unitsAvailable}</span>
                                            <span class="text-muted fs-12">units</span>
                                            <div class="progress" style="width:40px;height:4px;">
                                                <div class="progress-bar ${s.unitsAvailable < 5 ? 'red' : s.unitsAvailable < 15 ? 'yellow' : 'green'}" style="width:${s.progressWidth}%"></div>
                                            </div>
                                        </div>
                                    </div>
                                </c:if>
                            </c:forEach>
                        </div>
                    </div>

                    <!-- Request Summary -->
                    <div class="card fade-in delay-3">
                        <div class="card-header border-bottom pb-12 mb-16" style="border-bottom: 1px solid var(--border);">
                            <div class="card-title">📋 Request Summary</div>
                        </div>
                        <div class="d-flex flex-direction-column gap-12">
                            <div class="d-flex justify-between">
                                <span class="text-muted fs-13">Request ID</span>
                                <span class="fw-600 fs-13">#REQ-${bloodRequest.id}</span>
                            </div>
                            <div class="d-flex justify-between">
                                <span class="text-muted fs-13">Contact</span>
                                <span class="fw-600 fs-13">${bloodRequest.requesterName}</span>
                            </div>
                            <div class="d-flex justify-between">
                                <span class="text-muted fs-13">Phone</span>
                                <span class="fw-600 fs-13">${bloodRequest.requesterPhone != null ? bloodRequest.requesterPhone : 'N/A'}</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/hospital_footer.jsp" %>
