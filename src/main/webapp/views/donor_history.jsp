<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Donation History - LifeLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <jsp:include page="partials/sidebar.jsp" />

    <main class="main-content">
        <jsp:include page="partials/topbar.jsp" />

        <div class="content-wrapper">
            <!-- Summary Stats -->
            <div class="stats-grid">
                <div class="stat-card-white" style="flex-direction: row; align-items: center; gap: 1.5rem;">
                    <div class="stat-icon icon-red" style="width: 50px; height: 50px;"><i class="fas fa-tint"></i></div>
                    <div>
                        <span class="value" style="font-size: 1.5rem;">5</span>
                        <span class="label">Total Donations</span>
                    </div>
                </div>
                <div class="stat-card-white" style="flex-direction: row; align-items: center; gap: 1.5rem;">
                    <div class="stat-icon icon-red" style="width: 50px; height: 50px; background: rgba(59, 130, 246, 0.1); color: #3B82F6;"><i class="fas fa-flask"></i></div>
                    <div>
                        <span class="value" style="font-size: 1.5rem;">6</span>
                        <span class="label">Total Units</span>
                    </div>
                </div>
                <div class="stat-card-white" style="flex-direction: row; align-items: center; gap: 1.5rem;">
                    <div class="stat-icon icon-green" style="width: 50px; height: 50px;"><i class="fas fa-heart"></i></div>
                    <div>
                        <span class="value" style="font-size: 1.5rem;">15</span>
                        <span class="label">Lives Saved</span>
                    </div>
                </div>
            </div>

            <!-- History Table -->
            <div class="card-premium">
                <div class="card-title">
                    <span>Donation Records</span>
                    <div style="display: flex; gap: 0.5rem;">
                        <button class="btn-premium btn-secondary" style="font-size: 0.75rem;"><i class="fas fa-filter"></i> Filter</button>
                        <button class="btn-premium btn-primary" style="font-size: 0.75rem;"><i class="fas fa-file-export"></i> Export All</button>
                    </div>
                </div>
                
                <div class="table-container">
                    <table class="table-premium">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Hospital / Center</th>
                                <th>Blood Group</th>
                                <th>Units</th>
                                <th>Status</th>
                                <th>Certificate</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="item" items="${history}">
                                <tr>
                                    <td>
                                        <div style="display: flex; align-items: center; gap: 0.75rem;">
                                            <div style="background: rgba(217, 4, 41, 0.05); color: var(--active-red); padding: 0.4rem; border-radius: 6px; text-align: center; min-width: 45px;">
                                                <span style="display: block; font-size: 0.65rem; text-transform: uppercase;">Jul</span>
                                                <span style="display: block; font-size: 0.9rem; font-weight: 700;">20</span>
                                            </div>
                                            <div style="font-size: 0.8rem;">
                                                <span style="display: block; font-weight: 600;">Jul 20, 2024</span>
                                                <span style="color: var(--text-muted);">10:00 AM</span>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span style="font-weight: 600;">${item.hospitalName}</span><br>
                                        <span style="font-size: 0.75rem; color: var(--text-muted);"><i class="fas fa-map-marker-alt"></i> ${item.location}</span>
                                    </td>
                                    <td><span style="font-weight: 700; color: var(--active-red);">${item.bloodGroup}</span></td>
                                    <td><div style="display: flex; align-items: center; gap: 0.5rem;"><i class="fas fa-flask" style="color: #3B82F6;"></i> 1 Unit</div></td>
                                    <td><span class="status-pill status-active"><i class="fas fa-check"></i> Completed</span></td>
                                    <td><button class="btn-premium btn-secondary" style="font-size: 0.75rem; color: var(--active-red); border-color: var(--active-red);"><i class="fas fa-download"></i> Download</button></td>
                                </tr>
                            </c:forEach>
                            <c:if test="${empty history}">
                                <tr>
                                    <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 2rem;">No donation records found.</td>
                                </tr>
                            </c:if>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Promotion Card -->
            <div style="background: rgba(217, 4, 41, 0.03); border: 1px solid rgba(217, 4, 41, 0.1); padding: 1.5rem; border-radius: 16px; display: flex; align-items: center; justify-content: space-between;">
                <div style="display: flex; align-items: center; gap: 1rem;">
                    <div class="stat-icon icon-red" style="width: 40px; height: 40px;"><i class="fas fa-info-circle"></i></div>
                    <p style="font-size: 0.9rem;">Your next eligible donation date is <span style="font-weight: 700; color: var(--active-red);">October 20, 2024</span>. Keep donating to reach Hero donor status!</p>
                </div>
                <button class="btn-premium btn-primary">Book Next Session</button>
            </div>
        </div>
    </main>
</body>
</html>
