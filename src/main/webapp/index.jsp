<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // TEMPORARY REDIRECT FOR SANDBOX TESTING
    if (true) {
        response.sendRedirect(request.getContextPath() + "/hospital/dashboard");
        return;
    }
%>
<%
    /* INTEGRATION POINT: Member 1 (Auth) handles login session and redirection
    // If user is already logged in, redirect to their dashboard
    Object userId = session.getAttribute("userId");
    String role   = (String) session.getAttribute("role");
    if (userId != null && role != null) {
        String ctx = request.getContextPath();
        switch (role) {
            case "hospital":  response.sendRedirect(ctx + "/hospital/dashboard"); return;
            case "admin":     response.sendRedirect(ctx + "/admin/dashboard");    return;
            case "donor":     response.sendRedirect(ctx + "/donor/dashboard");    return;
            case "recipient": response.sendRedirect(ctx + "/recipient/dashboard");return;
        }
    }
    */
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LifeLink — Blood Donation Management System</title>
    <meta name="description" content="LifeLink connects blood donors, recipients, and hospitals. Save lives by donating blood or finding the blood you need.">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/hospital.css">
    <style>
        .hero-stats { display: flex; gap: 40px; margin-top: 48px; }
        .hero-stat-value { font-size: 32px; font-weight: 800; color: var(--accent); }
        .hero-stat-label { font-size: 13px; color: var(--text-muted); margin-top: 2px; }
        .features-section { padding: 80px 40px; background: var(--bg-secondary); }
        .features-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(280px,1fr)); gap: 24px; max-width: 1100px; margin: 0 auto; }
        .feature-card { background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-md); padding: 32px; transition: all var(--transition); }
        .feature-card:hover { border-color: var(--border-hover); transform: translateY(-4px); box-shadow: var(--shadow-md); }
        .feature-icon { font-size: 36px; margin-bottom: 16px; }
        .feature-title { font-size: 18px; font-weight: 600; margin-bottom: 8px; }
        .feature-desc { font-size: 14px; color: var(--text-secondary); line-height: 1.6; }
        .section-title { text-align: center; font-size: 32px; font-weight: 700; margin-bottom: 12px; }
        .section-subtitle { text-align: center; font-size: 15px; color: var(--text-muted); margin-bottom: 48px; }
        .landing-footer { text-align: center; padding: 32px; color: var(--text-muted); font-size: 13px; border-top: 1px solid var(--border); }
        .landing-nav { position: fixed; top: 0; left: 0; right: 0; z-index: 100; display: flex; align-items: center; justify-content: space-between; padding: 16px 40px; background: rgba(11,17,32,0.85); backdrop-filter: blur(12px); border-bottom: 1px solid var(--border); }
        .landing-logo { display: flex; align-items: center; gap: 10px; }
        .landing-logo-icon { width: 36px; height: 36px; background: var(--accent); border-radius: 8px; display: flex; align-items: center; justify-content: center; font-size: 18px; }
        .landing-logo-text { font-size: 20px; font-weight: 700; color: var(--text-primary); }
        .landing-nav-links { display: flex; gap: 12px; }
        .hero { padding-top: 120px; }
        @media (max-width: 768px) {
            .hero-stats { flex-direction: column; gap: 20px; }
            .landing-nav { padding: 12px 20px; }
        }
    </style>
</head>
<body>

<!-- Navigation -->
<nav class="landing-nav">
    <div class="landing-logo">
        <div class="landing-logo-icon">🩸</div>
        <div class="landing-logo-text">LifeLink</div>
    </div>
    <div class="landing-nav-links">
        <a href="${pageContext.request.contextPath}/login" class="btn btn-secondary">Sign In</a>
        <a href="${pageContext.request.contextPath}/register" class="btn btn-primary">Get Started</a>
    </div>
</nav>

<!-- Hero Section -->
<section class="hero">
    <div class="hero-content fade-in">
        <div class="hero-badge">🩸 Blood Donation Made Simple</div>
        <h1>Every Drop <span>Saves a Life</span></h1>
        <p class="hero-desc">
            LifeLink connects blood donors, recipients, and hospitals in a seamless digital platform.
            Find blood when you need it most, or become a hero by donating today.
        </p>
        <div class="hero-actions">
            <a href="${pageContext.request.contextPath}/register" class="btn btn-primary btn-lg">🩸 Become a Donor</a>
            <a href="${pageContext.request.contextPath}/register" class="btn btn-secondary btn-lg">🆘 Request Blood</a>
        </div>
        <div class="hero-stats">
            <div class="fade-in delay-1">
                <div class="hero-stat-value">8</div>
                <div class="hero-stat-label">Blood Groups Supported</div>
            </div>
            <div class="fade-in delay-2">
                <div class="hero-stat-value">24/7</div>
                <div class="hero-stat-label">Emergency Support</div>
            </div>
            <div class="fade-in delay-3">
                <div class="hero-stat-value">100%</div>
                <div class="hero-stat-label">Secure & Private</div>
            </div>
        </div>
    </div>
</section>

<!-- Features Section -->
<section class="features-section">
    <h2 class="section-title">How LifeLink Works</h2>
    <p class="section-subtitle">A complete blood donation management system for everyone</p>
    <div class="features-grid">
        <div class="feature-card fade-in delay-1">
            <div class="feature-icon">🩸</div>
            <div class="feature-title">Donor Registration</div>
            <div class="feature-desc">Register as a blood donor and set your availability. Get notified when someone needs your blood type.</div>
        </div>
        <div class="feature-card fade-in delay-2">
            <div class="feature-icon">🆘</div>
            <div class="feature-title">Blood Requests</div>
            <div class="feature-desc">Need blood urgently? Submit a request and get matched with nearby hospitals that have your blood type in stock.</div>
        </div>
        <div class="feature-card fade-in delay-3">
            <div class="feature-icon">🏥</div>
            <div class="feature-title">Hospital Management</div>
            <div class="feature-desc">Hospitals can manage their blood stock inventory, respond to requests, and track usage history in real-time.</div>
        </div>
        <div class="feature-card fade-in delay-4">
            <div class="feature-icon">🔍</div>
            <div class="feature-title">Smart Search</div>
            <div class="feature-desc">Search for available blood across all registered hospitals or find willing donors in your area.</div>
        </div>
        <div class="feature-card fade-in delay-1">
            <div class="feature-icon">📊</div>
            <div class="feature-title">Admin Dashboard</div>
            <div class="feature-desc">System administrators can approve registrations, manage users, and oversee the entire blood donation network.</div>
        </div>
        <div class="feature-card fade-in delay-2">
            <div class="feature-icon">📧</div>
            <div class="feature-title">Email Notifications</div>
            <div class="feature-desc">Stay informed with automated email notifications for account approval, request updates, and more.</div>
        </div>
    </div>
</section>

<!-- Footer -->
<footer class="landing-footer">
    <p>&copy; 2026 LifeLink Blood Donation Management System — London Metropolitan University</p>
</footer>

</body>
</html>
