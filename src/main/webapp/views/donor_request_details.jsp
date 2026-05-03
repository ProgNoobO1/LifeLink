<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Request Details - LifeLink</title>
    <jsp:include page="partials/head_styles.jsp" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <jsp:include page="partials/sidebar.jsp" />

    <main class="main-content">
        <jsp:include page="partials/topbar.jsp" />

        <div class="content-wrapper">
            <a href="${pageContext.request.contextPath}/donor/dashboard" style="display: inline-flex; align-items: center; gap: 0.5rem; color: var(--text-muted); text-decoration: none; font-size: 0.85rem; margin-bottom: 1.5rem;">
                <i class="fas fa-arrow-left"></i> Back to Dashboard
            </a>

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem;">
                <div>
                    <div class="card-premium">
                        <div class="request-header" style="padding-bottom: 1.5rem; border-bottom: 1px solid var(--border-light); margin-bottom: 1.5rem;">
                            <div class="stat-icon icon-red" style="width: 64px; height: 64px; font-size: 2rem;"><i class="fas fa-hospital"></i></div>
                            <div style="flex: 1;">
                                <span style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase;">Source Hospital</span>
                                <h2 style="font-size: 1.5rem;">${req != null ? req.hospitalName : 'Hospital'}</h2>
                                <p style="font-size: 0.85rem; color: var(--text-muted);">${req != null ? req.location : ''}</p>
                            </div>
                            <span class="badge-urgency urgency-high" style="font-size: 0.85rem; padding: 0.4rem 1rem;"><i class="fas fa-exclamation-circle"></i> Urgent Request</span>
                        </div>

                        <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; margin-bottom: 2rem;">
                            <div style="background: var(--background-gray); padding: 1rem; border-radius: 12px;">
                                <span style="display: block; font-size: 0.7rem; color: var(--text-muted); text-transform: uppercase; margin-bottom: 0.5rem;"><i class="fas fa-hospital"></i> Hospital</span>
                                <span style="font-weight: 600; font-size: 0.9rem;">${req != null ? req.hospitalName : 'General Hospital'}</span><br>
                                <span style="font-size: 0.75rem; color: var(--text-muted);">${req != null ? req.location : 'Downtown'}</span>
                            </div>
                            <div style="background: rgba(217, 4, 41, 0.05); padding: 1rem; border-radius: 12px;">
                                <span style="display: block; font-size: 0.7rem; color: var(--active-red); text-transform: uppercase; margin-bottom: 0.5rem;"><i class="fas fa-tint"></i> Blood Group</span>
                                <span style="font-weight: 700; font-size: 1.1rem; color: var(--active-red);">${req != null ? req.bloodGroup : 'O+'}</span><br>
                                <span style="font-size: 0.75rem; color: var(--text-muted);">Universal Donor Match</span>
                            </div>
                            <div style="background: var(--background-gray); padding: 1rem; border-radius: 12px;">
                                <span style="display: block; font-size: 0.7rem; color: var(--text-muted); text-transform: uppercase; margin-bottom: 0.5rem;"><i class="fas fa-layer-group"></i> Units Needed</span>
                                <span style="font-weight: 600; font-size: 1.1rem;">2</span><br>
                                <span style="font-size: 0.75rem; color: var(--text-muted);">Units of whole blood</span>
                            </div>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem; margin-bottom: 2rem;">
                            <div style="border: 1px solid var(--border-light); padding: 1rem; border-radius: 12px;">
                                <span style="display: block; font-size: 0.7rem; color: var(--text-muted); text-transform: uppercase; margin-bottom: 0.5rem;"><i class="fas fa-bolt"></i> Urgency Level</span>
                                <div style="display: flex; gap: 0.25rem; align-items: center;">
                                    <div style="height: 6px; width: 30px; background: var(--active-red); border-radius: 3px;"></div>
                                    <div style="height: 6px; width: 30px; background: var(--active-red); border-radius: 3px;"></div>
                                    <div style="height: 6px; width: 30px; background: var(--active-red); border-radius: 3px;"></div>
                                    <div style="height: 6px; width: 30px; background: var(--border-light); border-radius: 3px;"></div>
                                    <span style="font-size: 0.8rem; font-weight: 600; margin-left: 0.5rem; color: var(--active-red);">Critical</span>
                                </div>
                                <span style="font-size: 0.75rem; color: var(--text-muted);">Required within 24 hours</span>
                            </div>
                            <div style="border: 1px solid var(--border-light); padding: 1rem; border-radius: 12px;">
                                <span style="display: block; font-size: 0.7rem; color: var(--text-muted); text-transform: uppercase; margin-bottom: 0.5rem;"><i class="far fa-calendar-alt"></i> Request Date</span>
                                <span style="font-weight: 600; font-size: 0.9rem;">October 15, 2024</span><br>
                                <span style="font-size: 0.75rem; color: var(--text-muted);">Needed by: Oct 16 — 08:00 AM</span>
                            </div>
                        </div>

                        <div class="card-premium" style="background: var(--background-gray); box-shadow: none;">
                            <span style="display: block; font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; margin-bottom: 1rem;"><i class="fas fa-comment-medical"></i> Request Message</span>
                            <p style="font-size: 0.9rem; line-height: 1.6; color: var(--text-main);">
                                Hospital is requesting ${req != null ? req.bloodGroup : ''} blood donation at ${req != null ? req.location : ''}. Please review the details and respond as soon as possible.
                            </p>
                        </div>
                    </div>
                </div>

                <div>
                    <div class="card-premium">
                        <div class="card-title">Take Action</div>
                        <p style="font-size: 0.8rem; color: var(--text-muted); margin-bottom: 1.5rem;">Your response directly impacts the patient's care. Please decide as soon as possible.</p>
                        
                        <div style="display: flex; flex-direction: column; gap: 0.75rem;">
                            <form action="${pageContext.request.contextPath}/donor/updateStatus" method="POST">
                                <input type="hidden" name="requestId" value="${req.id}">
                                <input type="hidden" name="status" value="Accepted">
                                <button type="submit" class="btn-premium btn-primary" style="width: 100%; justify-content: center;"><i class="fas fa-check"></i> Accept Request</button>
                            </form>
                            <form action="${pageContext.request.contextPath}/donor/updateStatus" method="POST">
                                <input type="hidden" name="requestId" value="${req.id}">
                                <input type="hidden" name="status" value="Rejected">
                                <button type="submit" class="btn-premium btn-secondary" style="width: 100%; justify-content: center;"><i class="fas fa-times"></i> Decline Request</button>
                            </form>
                            <a href="${pageContext.request.contextPath}/donor/dashboard" class="btn-premium btn-secondary" style="width: 100%; justify-content: center; border: none; background: transparent;"><i class="fas fa-arrow-left"></i> Back to List</a>
                        </div>
                    </div>

                    <div class="card-premium" style="background: rgba(217, 4, 41, 0.03); border: 1px solid rgba(217, 4, 41, 0.1);">
                        <div style="display: flex; gap: 1rem;">
                            <div class="stat-icon icon-red" style="width: 40px; height: 40px;"><i class="fas fa-info-circle"></i></div>
                            <div>
                                <h4 style="font-size: 0.9rem; margin-bottom: 0.5rem;">Why this matters</h4>
                                <p style="font-size: 0.75rem; color: var(--text-muted); line-height: 1.5;">Accepting this request means committing to donate. A coordinator will contact you within 30 minutes to confirm the details.</p>
                            </div>
                        </div>
                    </div>

                    <div class="card-premium">
                        <div class="card-title">Hospital Contact</div>
                        <div style="display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem;">
                            <div class="stat-icon icon-red" style="width: 40px; height: 40px; border-radius: 8px;"><i class="fas fa-hospital"></i></div>
                            <div>
                                <h4 style="font-size: 0.9rem;">${req != null ? req.hospitalName : 'General Hospital'}</h4>
                                <p style="font-size: 0.75rem; color: var(--text-muted);">Blood Bank Department</p>
                            </div>
                        </div>
                        <ul style="list-style: none; display: flex; flex-direction: column; gap: 1rem; font-size: 0.85rem;">
                            <li><i class="fas fa-phone-alt" style="color: var(--text-muted); margin-right: 0.75rem; width: 16px;"></i> +1 (555) 012-3456</li>
                            <li><i class="far fa-envelope" style="color: var(--text-muted); margin-right: 0.75rem; width: 16px;"></i> bloodbank@hospital.org</li>
                            <li><i class="fas fa-map-marker-alt" style="color: var(--text-muted); margin-right: 0.75rem; width: 16px;"></i> ${req != null ? req.location : 'Downtown'}</li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
