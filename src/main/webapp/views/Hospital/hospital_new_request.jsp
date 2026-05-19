<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<% request.setAttribute("pageTitle", "New Request"); %>
<%@ include file="/includes/hospital_header.jsp" %>

<div class="app-shell">
    <%@ include file="/includes/hospital_sidebar.jsp" %>
    <div class="main-content">
        <div class="top-header">
            <div class="d-flex align-center gap-12">
                <a href="${pageContext.request.contextPath}/hospital/requests" class="text-muted" style="font-size:20px;">←</a>
                <div>
                    <div class="page-title">New Request</div>
                    <div class="page-subtitle">Find available donors and send a blood request</div>
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
            <c:if test="${param.msg == 'request_sent'}">
                <div class="alert alert-success">✅ Request sent successfully to the donor!</div>
            </c:if>
            <c:if test="${param.error == 'request_failed'}">
                <div class="alert alert-danger">❌ Failed to send request. Please try again.</div>
            </c:if>

            <!-- Search Form -->
            <div class="card fade-in mb-28">
                <div class="card-header">
                    <div class="card-title">Search Criteria</div>
                </div>
                <form method="get" action="${pageContext.request.contextPath}/hospital/request/new">
                    <div class="form-row">
                        <div class="form-group">
                            <label class="form-label">Blood Group *</label>
                            <select name="bloodGroup" class="form-control" required>
                                <option value="">— Select Blood Group —</option>
                                <c:forEach var="group" items="${['A+','A-','B+','B-','AB+','AB-','O+','O-']}">
                                    <option value="${group}" ${searchBloodGroup == group ? 'selected' : ''}>${group}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="form-group">
                            <label class="form-label">District (Optional)</label>
                            <input type="text" name="district" class="form-control" placeholder="e.g. Kathmandu" value="${searchDistrict}">
                        </div>
                        <div class="form-group d-flex" style="align-items:flex-end;">
                            <button type="submit" class="btn btn-primary w-100" style="justify-content:center;">🔍 Search</button>
                        </div>
                    </div>
                </form>
            </div>

            <!-- Search Results -->
            <c:if test="${searched}">
                <div class="card fade-in delay-1">
                    <div class="card-header">
                        <div class="card-title">🩸 Available Donors (${donors != null ? donors.size() : 0})</div>
                    </div>
                    <div class="card-body" style="padding:0;">
                        <c:choose>
                            <c:when test="${not empty donors}">
                                <div class="table-wrap">
                                    <table class="table" style="margin:0;">
                                        <thead>
                                            <tr>
                                                <th>Donor Name</th>
                                                <th>Blood Group</th>
                                                <th>Location / District</th>
                                                <th>Contact Details</th>
                                                <th>Donations</th>
                                                <th>Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="d" items="${donors}">
                                                <tr>
                                                    <td>
                                                        <div class="d-flex align-center gap-12">
                                                            <div style="width:36px; height:36px; background:#F1F5F9; border-radius:50%; display:flex; align-items:center; justify-content:center; font-weight:600; color:var(--text-muted);">
                                                                👤
                                                            </div>
                                                            <div>
                                                                <div class="fw-600">${d.fullName}</div>
                                                                <div class="fs-12 text-muted">ID: #${d.userId}</div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="blood-badge">${d.bloodGroup}</div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-500">${d.district}</div>
                                                        <div class="fs-12 text-muted">${d.address}</div>
                                                    </td>
                                                    <td>
                                                        <div style="margin-bottom:2px;">
                                                            <a href="tel:${d.phone}" style="color:var(--accent); text-decoration:none;" class="fs-13 fw-600">📞 ${d.phone}</a>
                                                        </div>
                                                        <div>
                                                            <a href="mailto:${d.email}" style="color:var(--text-muted); text-decoration:none;" class="fs-12">✉️ ${d.email}</a>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="fw-600">${d.totalDonations} times</div>
                                                        <div class="fs-11 text-muted">
                                                            Last: 
                                                            <c:choose>
                                                                <c:when test="${d.lastDonatedAt != null}">
                                                                    ${d.lastDonatedAt}
                                                                </c:when>
                                                                <c:otherwise>Never</c:otherwise>
                                                            </c:choose>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <form action="${pageContext.request.contextPath}/hospital/request-donor" method="POST" style="margin:0;">
                                                            <input type="hidden" name="donorUserId" value="${d.userId}">
                                                            <input type="hidden" name="bloodGroup" value="${d.bloodGroup}">
                                                            <input type="hidden" name="message" value="We urgently need ${d.bloodGroup} blood at ${hospital.hospitalName}. Please consider donating.">
                                                            <input type="hidden" name="origin" value="hospital_new_request">
                                                            <button type="submit" class="btn btn-primary btn-sm" style="background:#C51B27; border-color:#C51B27; padding: 6px 12px; font-size:12px;">
                                                                Request Blood
                                                            </button>
                                                        </form>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="empty-state">
                                    <div class="empty-state-icon">🔍</div>
                                    <h3>No Donors Found</h3>
                                    <p>We couldn't find any donors matching your criteria. Try widening your search.</p>
                                </div>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </c:if>
        </div>
    </div>
</div>
<%@ include file="/includes/hospital_footer.jsp" %>
