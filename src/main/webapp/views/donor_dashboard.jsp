<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Donor Dashboard - LifeLink</title>
    <jsp:include page="partials/head_styles.jsp" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <jsp:include page="partials/sidebar.jsp" />

    <main class="main-content">
        <jsp:include page="partials/topbar.jsp" />

        <div class="content-wrapper">
            <c:if test="${param.error == 'donation_limit'}">
                <div class="alert alert-danger" style="background: rgba(217, 4, 41, 0.1); color: var(--active-red); padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; border: 1px solid rgba(217, 4, 41, 0.2); display: flex; align-items: center; gap: 0.75rem;">
                    <i class="fas fa-exclamation-triangle"></i>
                    <span>You cannot mark yourself as available yet. Please wait at least 15 days after your last donation.</span>
                </div>
            </c:if>
            <c:if test="${param.success == 'accepted'}">
                <div class="alert alert-success" style="background: rgba(39, 174, 96, 0.1); color: var(--success); padding: 1rem; border-radius: 8px; margin-bottom: 1.5rem; border: 1px solid rgba(39, 174, 96, 0.2); display: flex; align-items: center; gap: 0.75rem;">
                    <i class="fas fa-check-circle"></i>
                    <span>Donation accepted and marked as completed. Thank you for your contribution!</span>
                </div>
            </c:if>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card-white">
                    <div class="stat-header">
                        <div class="stat-icon icon-red"><i class="fas fa-tint"></i></div>
                        <span>Total Donations</span>
                    </div>
                    <div class="stat-content">
                        <span class="value">${totalDonations}</span>
                        <span class="label">Donations Completed</span>
                    </div>
                    <div class="progress-bar-container">
                        <div class="progress-bar" style="width: 50%;"></div>
                    </div>
                </div>
                

                <div class="stat-card-white">
                    <div class="stat-header">
                        <div class="stat-icon icon-yellow"><i class="fas fa-toggle-on"></i></div>
                        <span>Donor Status</span>
                    </div>
                    <div class="stat-content">
                        <span class="value" style="color: ${donor.available ? 'var(--success)' : 'var(--text-muted)'}">${donor.available ? 'Available' : 'Unavailable'}</span>
                        <form action="${pageContext.request.contextPath}/donor/toggleAvailability" method="POST" style="margin-top: 10px;">
                            <input type="hidden" name="isAvailable" value="${!donor.available}">
                            <button type="submit" class="btn-premium ${donor.available ? 'btn-secondary' : 'btn-primary'}" style="padding: 0.4rem 0.8rem; font-size: 0.75rem;">
                                Mark as ${donor.available ? 'Unavailable' : 'Available'}
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Recent Activity Card (Real Data) -->
            <div class="card-premium">
                <div class="card-title">
                    <span>Recent Activity</span>
                    <a href="${pageContext.request.contextPath}/donor/history" style="font-size: 0.75rem; color: var(--active-red); text-decoration: none;">View All History</a>
                </div>
                <div class="table-container">
                    <table class="table-premium">
                        <tbody>
                            <c:forEach var="item" items="${history}" varStatus="loop">
                                <c:if test="${loop.index < 5}">
                                    <tr>
                                        <td style="width: 50px;"><div class="stat-icon icon-green" style="width:32px; height:32px; font-size: 0.9rem;"><i class="fas fa-check"></i></div></td>
                                        <td>
                                            <span style="font-weight: 600; font-size: 0.85rem;">Whole Blood Donation</span><br>
                                            <span style="font-size: 0.75rem; color: var(--text-muted);">${item.requestDate} • ${item.hospitalName}</span>
                                        </td>
                                        <td style="text-align: right;"><span class="status-pill status-active">Completed</span></td>
                                    </tr>
                                </c:if>
                            </c:forEach>
                            <c:if test="${empty history}">
                                <tr>
                                    <td colspan="3" style="text-align: center; color: var(--text-muted); padding: 1rem;">No recent activity found.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <!-- Incoming Requests Section -->
            <div class="card-premium">
                <div class="card-title">
                    <span>Incoming Blood Requests</span>
                    <a href="#" style="font-size: 0.75rem; color: var(--active-red); text-decoration: none;">View All</a>
                </div>
                <div class="requests-grid">
                    <c:forEach var="req" items="${requests}">
                        <div class="request-card">
                            <div class="request-header">
                                <div class="stat-icon icon-red" style="width: 48px; height: 48px; font-size: 1.25rem;"><i class="fas fa-hospital"></i></div>
                                <div>
                                    <h4 style="font-size: 0.95rem;">${req.hospitalName}</h4>
                                    <p style="font-size: 0.75rem; color: var(--text-muted);"><i class="fas fa-map-marker-alt"></i> ${req.location}</p>
                                </div>
                                <span class="badge-urgency urgency-high">High Urgency</span>
                            </div>
                            <div class="request-info-row">
                                <span><i class="fas fa-tint"></i> ${req.bloodGroup}</span>
                                <span><i class="fas fa-layer-group"></i> 2 Units</span>
                                <span><i class="far fa-calendar-alt"></i> Oct 15, 2024</span>
                            </div>
                            <p style="font-size: 0.8rem; color: var(--text-muted); line-height: 1.5;">Patient requires ${req.bloodGroup} blood urgently for a surgical procedure scheduled tomorrow morning.</p>
                            <div style="display: flex; gap: 0.75rem; margin-top: 0.5rem;">
                                <a href="${pageContext.request.contextPath}/donor/requestDetails?requestId=${req.id}" class="btn-premium btn-primary" style="flex: 1;">View Details</a>
                                <form action="${pageContext.request.contextPath}/donor/updateStatus" method="POST" style="flex: 0;">
                                    <input type="hidden" name="requestId" value="${req.id}">
                                    <input type="hidden" name="status" value="Rejected">
                                    <button type="submit" class="btn-premium btn-secondary" style="padding: 0.5rem;"><i class="fas fa-times"></i></button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                    <c:if test="${empty requests}">
                        <p style="color: var(--text-muted); font-size: 0.9rem;">No new requests at the moment.</p>
                    </c:if>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
