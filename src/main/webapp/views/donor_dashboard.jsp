<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Donor Dashboard - LifeLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <jsp:include page="partials/sidebar.jsp" />

    <main class="main-content">
        <jsp:include page="partials/topbar.jsp" />

        <div class="content-wrapper">
            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card-white">
                    <div class="stat-header">
                        <div class="stat-icon icon-red"><i class="fas fa-tint"></i></div>
                        <span>Total Donations</span>
                    </div>
                    <div class="stat-content">
                        <span class="value">5</span>
                        <span class="label">50% toward next milestone</span>
                    </div>
                    <div class="progress-bar-container">
                        <div class="progress-bar" style="width: 50%;"></div>
                    </div>
                </div>
                
                <div class="stat-card-white">
                    <div class="stat-header">
                        <div class="stat-icon icon-green"><i class="fas fa-heart"></i></div>
                        <span>Lives Saved</span>
                    </div>
                    <div class="stat-content">
                        <span class="value">15</span>
                        <span class="label">Each donation helps up to 3 people</span>
                    </div>
                    <div class="progress-bar-container">
                        <div class="progress-bar" style="width: 75%; background-color: var(--success);"></div>
                    </div>
                </div>

                <div class="stat-card-white">
                    <div class="stat-header">
                        <div class="stat-icon icon-yellow"><i class="fas fa-calendar-check"></i></div>
                        <span>Next Eligible Date</span>
                    </div>
                    <div class="stat-content">
                        <span class="value">Oct 20, 2024</span>
                        <span class="label">Almost eligible to donate again!</span>
                    </div>
                    <div class="progress-bar-container">
                        <div class="progress-bar" style="width: 85%; background-color: var(--warning);"></div>
                    </div>
                </div>
            </div>

            <!-- Two Column Layout -->
            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem;">
                <div>
                    <div class="card-premium">
                        <div class="card-title">
                            <span>Upcoming Appointments</span>
                            <button class="btn-premium btn-secondary" style="font-size: 0.75rem;">+ Schedule New</button>
                        </div>
                        <div style="padding: 1rem; border-radius: 12px; background: rgba(217, 4, 41, 0.05); border: 1px solid rgba(217, 4, 41, 0.1); display: flex; align-items: center; gap: 1.5rem;">
                            <div style="background: var(--active-red); color: white; padding: 0.5rem 1rem; border-radius: 8px; text-align: center;">
                                <span style="display: block; font-size: 0.7rem; text-transform: uppercase;">Oct</span>
                                <span style="display: block; font-size: 1.25rem; font-weight: 700;">20</span>
                            </div>
                            <div style="flex: 1;">
                                <h4 style="font-size: 0.9rem;">Whole Blood Donation <span class="status-pill status-active" style="font-size: 0.65rem;">Confirmed</span></h4>
                                <p style="font-size: 0.8rem; color: var(--text-muted);"><i class="far fa-clock"></i> 10:00 AM - 11:00 AM &nbsp; <i class="fas fa-map-marker-alt"></i> City Blood Bank, Downtown</p>
                            </div>
                            <button class="btn-premium btn-primary" style="padding: 0.4rem 0.8rem; font-size: 0.75rem;">Details</button>
                        </div>
                    </div>

                    <div class="card-premium">
                        <div class="card-title">
                            <span>Recent Activity</span>
                            <a href="#" style="font-size: 0.75rem; color: var(--active-red); text-decoration: none;">View All</a>
                        </div>
                        <div class="table-container">
                            <table class="table-premium">
                                <tbody>
                                    <c:forEach var="item" begin="1" end="2">
                                        <tr>
                                            <td style="width: 50px;"><div class="stat-icon icon-green" style="width:32px; height:32px; font-size: 0.9rem;"><i class="fas fa-check"></i></div></td>
                                            <td>
                                                <span style="font-weight: 600; font-size: 0.85rem;">Whole Blood Donation</span><br>
                                                <span style="font-size: 0.75rem; color: var(--text-muted);">Jul 20, 2024 • City Blood Bank</span>
                                            </td>
                                            <td style="text-align: right;"><span class="status-pill status-active">Completed</span></td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <div>
                    <div class="card-premium" style="text-align: center;">
                        <div class="stat-icon icon-red" style="margin: 0 auto 1rem; width: 50px; height: 50px; font-size: 1.5rem;"><i class="fas fa-award"></i></div>
                        <h4 style="margin-bottom: 0.5rem;">Champion Donor</h4>
                        <p style="font-size: 0.8rem; color: var(--text-muted); margin-bottom: 1rem;">You've earned this badge for 5 donations</p>
                        <div style="display: flex; justify-content: center; gap: 0.5rem; margin-bottom: 1rem;">
                            <i class="fas fa-star" style="color: var(--active-red);"></i>
                            <i class="fas fa-star" style="color: var(--active-red);"></i>
                            <i class="fas fa-star" style="color: var(--active-red);"></i>
                            <i class="far fa-star" style="color: var(--text-muted);"></i>
                            <i class="far fa-star" style="color: var(--text-muted);"></i>
                        </div>
                        <p style="font-size: 0.75rem; color: var(--text-muted);">2 more donations to reach <span style="color: var(--active-red); font-weight: 600;">Hero</span> status</p>
                    </div>

                    <div class="card-premium">
                        <div class="card-title">Health Overview</div>
                        <ul style="list-style: none; display: flex; flex-direction: column; gap: 1rem;">
                            <li style="display: flex; justify-content: space-between; font-size: 0.85rem;">
                                <span style="color: var(--text-muted);"><i class="fas fa-tint" style="color: var(--active-red); margin-right: 0.5rem;"></i> Blood Type</span>
                                <span style="font-weight: 600; color: var(--active-red);">${donor.bloodGroup}</span>
                            </li>
                            <li style="display: flex; justify-content: space-between; font-size: 0.85rem;">
                                <span style="color: var(--text-muted);"><i class="fas fa-heartbeat" style="color: #3B82F6; margin-right: 0.5rem;"></i> Hemoglobin</span>
                                <span style="font-weight: 600;">14.5 g/dL</span>
                            </li>
                            <li style="display: flex; justify-content: space-between; font-size: 0.85rem;">
                                <span style="color: var(--text-muted);"><i class="fas fa-weight" style="color: #10B981; margin-right: 0.5rem;"></i> Weight</span>
                                <span style="font-weight: 600;">72 kg</span>
                            </li>
                        </ul>
                    </div>
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
                                <img src="https://i.pravatar.cc/150?u=${req.hospitalId}" class="user-avatar" style="width: 48px; height: 48px;">
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
