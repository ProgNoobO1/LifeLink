<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Incoming Requests - LifeLink</title>
    <jsp:include page="partials/head_styles.jsp" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <jsp:include page="partials/sidebar.jsp" />

    <main class="main-content">
        <jsp:include page="partials/topbar.jsp" />

        <div class="content-wrapper">
            <div class="card-premium">
                <div class="card-title">
                    <span>Active Blood Requests</span>
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
                                <span class="badge-urgency urgency-high">Urgent</span>
                            </div>
                            <div class="request-info-row">
                                <span><i class="fas fa-tint"></i> ${req.bloodGroup}</span>
                                <span><i class="fas fa-layer-group"></i> 2 Units</span>
                            </div>
                            <p style="font-size: 0.8rem; color: var(--text-muted); line-height: 1.5; margin-top: 0.5rem;">
                                Hospital is requesting ${req.bloodGroup} blood donation at ${req.location}.
                            </p>
                            <div style="display: flex; gap: 0.75rem; margin-top: 1rem;">
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
                        <div style="text-align: center; padding: 3rem; width: 100%;">
                            <div class="stat-icon icon-green" style="margin: 0 auto 1.5rem; width: 60px; height: 60px; font-size: 2rem;"><i class="fas fa-check-circle"></i></div>
                            <h3>All Clear!</h3>
                            <p style="color: var(--text-muted); margin-top: 0.5rem;">No pending blood requests at the moment.</p>
                        </div>
                    </c:if>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
