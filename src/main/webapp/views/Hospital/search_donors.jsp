<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<%@ taglib uri="jakarta.tags.fmt" prefix="fmt" %>
<% request.setAttribute("pageTitle", "Search Donors"); %>
<%@ include file="/includes/hospital_header.jsp" %>

<div class="app-shell">
    <%@ include file="/includes/hospital_sidebar.jsp" %>
    <div class="main-content">
        <div class="top-header">
            <div>
                <div class="page-title">Search Blood Donors</div>
                <div class="page-subtitle">Find registered blood donors by blood group and region</div>
            </div>
            <div class="header-actions">
                <div class="user-pill">
                    <div class="user-avatar">🏥</div>
                    <div><div class="user-name">${hospital.hospitalName}</div><div class="user-role">Hospital</div></div>
                </div>
            </div>
        </div>

        <div class="page-body">
            <!-- Search Filter Bar -->
            <div class="card mb-28">
                <div class="card-header">
                    <div class="card-title">🔍 Search Filters</div>
                </div>
                <div class="card-body">
                    <form method="get" action="${pageContext.request.contextPath}/search">
                        <div style="display: grid; grid-template-columns: 1fr 1fr auto; gap: 16px; align-items: end;">
                            <div class="form-group" style="margin:0;">
                                <label for="bloodGroup" class="form-label">Blood Group</label>
                                <select name="bloodGroup" id="bloodGroup" class="form-control">
                                    <option value="">All Blood Groups</option>
                                    <c:forEach var="group" items="${['A+','A-','B+','B-','AB+','AB-','O+','O-']}">
                                        <option value="${group}" ${selectedGroup == group ? 'selected' : ''}>${group}</option>
                                    </c:forEach>
                                </select>
                            </div>
                            <div class="form-group" style="margin:0;">
                                <label for="district" class="form-label">District / Region</label>
                                <input type="text" name="district" id="district" class="form-control" 
                                       value="${selectedDistrict}" placeholder="e.g. Kathmandu, Lalitpur">
                            </div>
                            <div>
                                <button type="submit" class="btn btn-primary" style="background:#C51B27; border-color:#C51B27; height:42px; padding: 0 24px;">
                                    🔍 Search Donors
                                </button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Results Table -->
            <div class="card">
                <div class="card-header">
                    <div class="card-title">👥 Registered Donors Found (${donorList.size()})</div>
                </div>
                <div class="card-body" style="padding:0;">
                    <c:choose>
                        <c:when test="${empty donorList}">
                            <div style="padding: 40px; text-align: center;">
                                <div style="font-size: 40px; margin-bottom: 12px;">🔍</div>
                                <h3 class="fw-600 mb-8" style="color:var(--text);">No Matching Donors</h3>
                                <p class="text-muted fs-14" style="max-width:400px; margin: 0 auto;">
                                    We couldn't find any available donors matching your filter criteria. Try adjusting your filters.
                                </p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="table" style="margin:0;">
                                <thead>
                                    <tr>
                                        <th>Donor Name</th>
                                        <th>Blood Group</th>
                                        <th>Location / District</th>
                                        <th>Contact Details</th>
                                        <th>Donations</th>
                                        <th>Last Donated</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach var="donor" items="${donorList}">
                                        <tr>
                                            <td>
                                                <div class="d-flex align-center gap-12">
                                                    <div style="width:36px; height:36px; background:#F1F5F9; border-radius:50%; display:flex; align-items:center; justify-content:center; font-weight:600; color:var(--text-muted);">
                                                        👤
                                                    </div>
                                                    <div>
                                                        <div class="fw-600">${donor.fullName}</div>
                                                        <div class="fs-12 text-muted">ID: #${donor.userId}</div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <div class="blood-badge">${donor.bloodGroup}</div>
                                            </td>
                                            <td>
                                                <div class="fw-500">${donor.district}</div>
                                                <div class="fs-12 text-muted">${donor.address}</div>
                                            </td>
                                            <td>
                                                <div style="margin-bottom:2px;">
                                                    <a href="tel:${donor.phone}" style="color:var(--accent); text-decoration:none;" class="fs-13 fw-600">📞 ${donor.phone}</a>
                                                </div>
                                                <div>
                                                    <a href="mailto:${donor.email}" style="color:var(--text-muted); text-decoration:none;" class="fs-12">✉️ ${donor.email}</a>
                                                </div>
                                            </td>
                                            <td class="fw-600">${donor.totalDonations} times</td>
                                            <td class="text-muted fs-13">
                                                <c:choose>
                                                    <c:when test="${donor.lastDonatedAt != null}">
                                                        <fmt:formatDate value="${donor.lastDonatedAt}" pattern="dd MMM yyyy"/>
                                                    </c:when>
                                                    <c:otherwise>Never</c:otherwise>
                                                </c:choose>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
        </div>
    </div>
</div>

<%@ include file="/includes/hospital_footer.jsp" %>
