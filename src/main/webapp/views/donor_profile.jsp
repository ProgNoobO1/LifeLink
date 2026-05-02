<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Donor Profile - LifeLink</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <jsp:include page="partials/sidebar.jsp" />

    <main class="main-content">
        <jsp:include page="partials/topbar.jsp" />

        <div class="content-wrapper">
            <div class="profile-header-card">
                <img src="https://i.pravatar.cc/150?u=${donor.email}" class="profile-img-large" alt="Profile">
                <div style="flex: 1;">
                    <h1 style="font-size: 1.75rem; margin-bottom: 0.25rem;">${donor.name} <span class="status-pill status-active" style="vertical-align: middle; margin-left: 0.5rem; background: rgba(255,255,255,0.2); color: white;">Active Donor</span></h1>
                    <p style="font-size: 0.9rem; opacity: 0.9; margin-bottom: 1rem;">${donor.email} • Member since Jan 2024</p>
                    <div style="display: flex; gap: 1.5rem; font-size: 0.85rem;">
                        <span><i class="fas fa-tint"></i> Blood Group: ${donor.bloodGroup}</span>
                        <span><i class="fas fa-award"></i> Champion Donor</span>
                        <span><i class="fas fa-history"></i> 5 Total Donations</span>
                    </div>
                </div>
                <div style="display: flex; gap: 0.75rem;">
                    <button class="btn-premium btn-secondary" style="border: none;"><i class="fas fa-edit"></i> Edit Profile</button>
                    <button class="btn-premium btn-secondary" style="border: none; background: rgba(255,255,255,0.1); color: white;"><i class="fas fa-key"></i> Change Password</button>
                </div>
            </div>

            <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 1.5rem;">
                <div>
                    <div class="card-premium">
                        <div class="card-title">
                            <span>Personal Information</span>
                            <button class="btn-premium btn-secondary" style="font-size: 0.75rem;"><i class="fas fa-edit"></i> Edit</button>
                        </div>
                        <form action="${pageContext.request.contextPath}/donor/profile" method="POST">
                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                                <div class="form-group">
                                    <label class="form-label">Full Name</label>
                                    <input type="text" class="form-control" name="name" value="${donor.name}" required>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Email Address</label>
                                    <input type="email" class="form-control" value="${donor.email}" disabled style="background: var(--background-gray);">
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Phone Number</label>
                                    <input type="tel" class="form-control" name="phone" value="${donor.phone}" required>
                                </div>
                                <div class="form-group">
                                    <label class="form-label">Blood Group</label>
                                    <select class="form-control" name="bloodGroup" required>
                                        <option value="A+" ${donor.bloodGroup == 'A+' ? 'selected' : ''}>A+</option>
                                        <option value="A-" ${donor.bloodGroup == 'A-' ? 'selected' : ''}>A-</option>
                                        <option value="B+" ${donor.bloodGroup == 'B+' ? 'selected' : ''}>B+</option>
                                        <option value="B-" ${donor.bloodGroup == 'B-' ? 'selected' : ''}>B-</option>
                                        <option value="AB+" ${donor.bloodGroup == 'AB+' ? 'selected' : ''}>AB+</option>
                                        <option value="AB-" ${donor.bloodGroup == 'AB-' ? 'selected' : ''}>AB-</option>
                                        <option value="O+" ${donor.bloodGroup == 'O+' ? 'selected' : ''}>O+</option>
                                        <option value="O-" ${donor.bloodGroup == 'O-' ? 'selected' : ''}>O-</option>
                                    </select>
                                </div>
                            </div>
                            <div class="form-group">
                                <label class="form-label">Location (City)</label>
                                <input type="text" class="form-control" name="location" value="${donor.location}" required>
                            </div>
                            <button type="submit" class="btn-premium btn-primary" style="margin-top: 1rem;">Update Information</button>
                        </form>
                    </div>

                    <div class="card-premium">
                        <div class="card-title">
                            <span>Medical Information</span>
                            <button class="btn-premium btn-secondary" style="font-size: 0.75rem;"><i class="fas fa-edit"></i> Edit</button>
                        </div>
                        <div style="background: rgba(16, 185, 129, 0.05); border: 1px solid rgba(16, 185, 129, 0.1); padding: 1rem; border-radius: 12px; display: flex; align-items: center; gap: 1rem; margin-bottom: 1.5rem;">
                            <div class="stat-icon icon-green" style="background: var(--success); color: white;"><i class="fas fa-calendar-check"></i></div>
                            <div style="flex: 1;">
                                <span style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase;">Last Donation Date</span>
                                <h4 style="font-size: 1rem;">July 20, 2024</h4>
                                <p style="font-size: 0.75rem; color: var(--text-muted);">Whole Blood • City Blood Bank, Downtown</p>
                            </div>
                            <span class="status-pill status-active">Completed</span>
                        </div>
                        <div style="display: flex; flex-direction: column; gap: 1rem;">
                            <div style="display: flex; align-items: center; gap: 1rem; padding: 0.75rem; border: 1px solid var(--border-light); border-radius: 8px;">
                                <i class="fas fa-check-circle" style="color: var(--success);"></i>
                                <div style="flex: 1;">
                                    <span style="font-size: 0.85rem; font-weight: 600;">No Chronic Illnesses</span>
                                    <p style="font-size: 0.75rem; color: var(--text-muted);">No diabetes, heart disease, or autoimmune conditions</p>
                                </div>
                                <span class="status-pill status-active">Clear</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div>
                    <div class="card-premium">
                        <div class="card-title">Health Stats</div>
                        <ul style="list-style: none; display: flex; flex-direction: column; gap: 1.25rem;">
                            <li style="display: flex; align-items: center; gap: 1rem;">
                                <div class="stat-icon icon-red" style="width:32px; height:32px; font-size: 0.9rem;"><i class="fas fa-weight"></i></div>
                                <div style="flex: 1;"><span style="font-size: 0.85rem; color: var(--text-muted);">Weight</span></div>
                                <span style="font-weight: 600; font-size: 0.85rem;">72 kg</span>
                            </li>
                            <li style="display: flex; align-items: center; gap: 1rem;">
                                <div class="stat-icon icon-red" style="width:32px; height:32px; font-size: 0.9rem;"><i class="fas fa-heartbeat"></i></div>
                                <div style="flex: 1;"><span style="font-size: 0.85rem; color: var(--text-muted);">Hemoglobin</span></div>
                                <span style="font-weight: 600; font-size: 0.85rem; color: var(--success);">14.5 g/dL</span>
                            </li>
                            <li style="display: flex; align-items: center; gap: 1rem;">
                                <div class="stat-icon icon-red" style="width:32px; height:32px; font-size: 0.9rem;"><i class="fas fa-ruler-vertical"></i></div>
                                <div style="flex: 1;"><span style="font-size: 0.85rem; color: var(--text-muted);">Height</span></div>
                                <span style="font-weight: 600; font-size: 0.85rem;">5' 10"</span>
                            </li>
                        </ul>
                    </div>

                    <div class="card-premium">
                        <div class="card-title">Account Actions</div>
                        <div style="display: flex; flex-direction: column; gap: 0.75rem;">
                            <button class="btn-premium btn-primary" style="justify-content: space-between;">Edit Profile <i class="fas fa-arrow-right"></i></button>
                            <button class="btn-premium btn-secondary" style="justify-content: space-between; background: rgba(217, 4, 41, 0.05); color: var(--active-red); border-color: rgba(217, 4, 41, 0.1);">Change Password <i class="fas fa-arrow-right"></i></button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </main>
</body>
</html>
