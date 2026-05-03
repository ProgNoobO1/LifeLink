<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LifeLink - Blood Donation Management System</title>
    <jsp:include page="views/partials/head_styles.jsp" />
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { display: block; }
        .hero {
            height: 70vh;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            text-align: center;
            background: linear-gradient(135deg, rgba(161, 27, 27, 0.05), #ffffff);
            padding: 2rem;
        }
        .hero h1 {
            font-size: 5rem;
            color: var(--primary-red);
            margin-bottom: 1rem;
            font-weight: 800;
        }
        .hero p {
            font-size: 1.25rem;
            color: var(--text-muted);
            max-width: 600px;
            margin-bottom: 2.5rem;
        }
        .features-container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 4rem 2rem;
        }
        .features-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
        }
        .nav-home {
            padding: 1rem 4rem;
            display: flex;
            justify-content: space-between;
            align-items: center;
            background: white;
            border-bottom: 1px solid var(--border-light);
        }
    </style>
</head>
<body>
    <nav class="nav-home">
        <div class="sidebar-logo" style="padding: 0; color: var(--primary-red);">
            <i class="fas fa-heartbeat"></i> LifeLink
        </div>
        <div>
            <a href="${pageContext.request.contextPath}/donor/dashboard" class="btn-premium btn-primary">Donor Portal</a>
        </div>
    </nav>

    <div class="hero">
        <h1>LifeLink</h1>
        <p>Connecting heroes with those in need. A modern, real-time blood donation management system designed to save lives.</p>
        <div style="display: flex; gap: 1rem;">
            <a href="${pageContext.request.contextPath}/donor/dashboard" class="btn-premium btn-primary" style="padding: 1rem 2.5rem; font-size: 1.1rem;">Get Started</a>
            <a href="#" class="btn-premium btn-secondary" style="padding: 1rem 2.5rem; font-size: 1.1rem;">Learn More</a>
        </div>
    </div>

    <div class="features-container">
        <div class="features-grid">
            <div class="card-premium" style="text-align: center; padding: 3rem 2rem;">
                <div class="stat-icon icon-red" style="margin: 0 auto 1.5rem; width: 60px; height: 60px; font-size: 2rem;"><i class="fas fa-user-plus"></i></div>
                <h3>Quick Registration</h3>
                <p style="color: var(--text-muted); font-size: 0.95rem; margin-top: 1rem;">Register as a donor or hospital in minutes and start saving lives today.</p>
            </div>
            <div class="card-premium" style="text-align: center; padding: 3rem 2rem;">
                <div class="stat-icon icon-red" style="margin: 0 auto 1.5rem; width: 60px; height: 60px; font-size: 2rem; background: rgba(59, 130, 246, 0.1); color: #3B82F6;"><i class="fas fa-search"></i></div>
                <h3>Real-time Search</h3>
                <p style="color: var(--text-muted); font-size: 0.95rem; margin-top: 1rem;">Find blood donors by blood group and location instantly during emergencies.</p>
            </div>
            <div class="card-premium" style="text-align: center; padding: 3rem 2rem;">
                <div class="stat-icon icon-green" style="margin: 0 auto 1.5rem; width: 60px; height: 60px; font-size: 2rem;"><i class="fas fa-hospital"></i></div>
                <h3>Hospital Management</h3>
                <p style="color: var(--text-muted); font-size: 0.95rem; margin-top: 1rem;">Hospitals can manage their blood stock and send requests directly to matching donors.</p>
            </div>
        </div>
    </div>

    <footer style="padding: 3rem; text-align: center; background: white; border-top: 1px solid var(--border-light); color: var(--text-muted); font-size: 0.9rem;">
        <p>&copy; 2024 LifeLink - Blood Donation Management System. All rights reserved.</p>
    </footer>
</body>
</html>
