<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="jakarta.tags.core" prefix="c" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Donor Profile - LifeLink</title>
    <jsp:include page="partials/head_styles.jsp" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
</head>
<body>
    <jsp:include page="partials/sidebar.jsp" />

    <main class="main-content">
        <jsp:include page="partials/topbar.jsp" />

        <div class="content-wrapper">
            <div class="profile-header-card">
                <div class="stat-icon icon-red" style="width: 100px; height: 100px; border-radius: 12px; font-size: 3rem; background: rgba(255,255,255,0.2); color: white;"><i class="fas fa-user"></i></div>
                <div style="flex: 1;">
                    <h1 style="font-size: 1.75rem; margin-bottom: 0.25rem;">${donor.name} <span class="status-pill status-active" style="vertical-align: middle; margin-left: 0.5rem; background: rgba(255,255,255,0.2); color: white;">Active Donor</span></h1>
                    <p style="font-size: 0.9rem; opacity: 0.9; margin-bottom: 1rem;">${donor.email}</p>
                    <div style="display: flex; gap: 1.5rem; font-size: 0.85rem;">
                        <span><i class="fas fa-tint"></i> Blood Group: ${donor.bloodGroup}</span>
                        <span><i class="fas fa-history"></i> ${totalDonations} Total Donations</span>
                    </div>
                </div>
                <div style="display: flex; gap: 0.75rem;">
                    <button id="edit-profile-btn" class="btn-premium btn-secondary" style="border: none;"><i class="fas fa-edit"></i> Edit Profile</button>
                </div>
            </div>

            <div class="card-premium">
                <div class="card-title">
                    <span>Personal Information</span>
                </div>
                <form action="${pageContext.request.contextPath}/donor/profile" method="POST">
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1.5rem;">
                        <div class="form-group">
                            <label class="form-label">Full Name</label>
                            <input type="text" class="form-control" name="name" value="${donor.name}" required disabled>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Email Address</label>
                            <input type="email" class="form-control" value="${donor.email}" disabled style="background: var(--background-gray);">
                        </div>
                        <div class="form-group">
                            <label class="form-label">Phone Number</label>
                            <input type="tel" class="form-control" name="phone" value="${donor.phone}" required disabled>
                        </div>
                        <div class="form-group">
                            <label class="form-label">Blood Group</label>
                            <select class="form-control" name="bloodGroup" required disabled>
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
                        <input type="text" class="form-control" name="location" value="${donor.location}" required disabled>
                    </div>
                    <div id="form-actions" style="margin-top: 1rem; display: none; gap: 1rem;">
                        <button type="submit" class="btn-premium btn-primary">Save Changes</button>
                        <button type="button" id="cancel-edit" class="btn-premium btn-secondary">Cancel</button>
                    </div>
                </form>
            </div>
        </div>
    </main>
    <script>
        document.getElementById('edit-profile-btn').addEventListener('click', function() {
            const inputs = document.querySelectorAll('.form-control:not([disabled][style*="background"])');
            const actions = document.getElementById('form-actions');
            
            inputs.forEach(input => input.disabled = false);
            actions.style.display = 'flex';
            this.style.display = 'none';
        });

        document.getElementById('cancel-edit').addEventListener('click', function() {
            window.location.reload();
        });
    </script>
</body>
</html>
