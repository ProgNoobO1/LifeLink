<%@ page import="com.lifelink.model.User" %>
<%@ page import="com.lifelink.dao.UserDAO" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
    boolean isLoggedIn = currentUser != null;
    boolean isAdmin = isLoggedIn && currentUser.getRole() == User.Role.ADMIN;

    // Fetch public stats
    UserDAO userDAO = new UserDAO();
    long totalDonors = userDAO.countByRole(User.Role.DONOR);
    long totalRecipients = userDAO.countByRole(User.Role.RECIPIENT);
    long totalHospitals = userDAO.countByRole(User.Role.HOSPITAL);
    long totalUsers = userDAO.countAll();

    // Blood group counts
    String[] bloodGroups = {"A+", "A-", "B+", "B-", "AB+", "AB-", "O+", "O-"};
    Map<String, Long> bgCounts = new LinkedHashMap<>();
    for (String bg : bloodGroups) {
        bgCounts.put(bg, userDAO.countByBloodGroup(bg));
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>LifeLink – Blood Management System</title>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@400;500;600;700&display=swap" rel="stylesheet"/>

    <style>
        :root {
            --red:         #b91c1c;
            --red-dark:    #991b1b;
            --red-light:   #fee2e2;
            --text-dark:   #111827;
            --text-mid:    #4b5563;
            --text-light:  #9ca3af;
            --border:      #e5e7eb;
            --bg:          #f3f4f6;
            --white:       #ffffff;
            --shadow:      0 2px 12px rgba(0,0,0,.07);
            --shadow-md:   0 4px 24px rgba(0,0,0,.10);
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html { scroll-behavior: smooth; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--white);
            color: var(--text-dark);
            line-height: 1.6;
        }

        a { text-decoration: none; color: inherit; }

        /* NAVBAR */
        .navbar {
            position: fixed;
            top: 0; left: 0; right: 0;
            z-index: 100;
            background: rgba(255,255,255,0.92);
            backdrop-filter: blur(12px);
            border-bottom: 1px solid var(--border);
            padding: .9rem 2.5rem;
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .nav-logo {
            display: flex;
            align-items: center;
            gap: .6rem;
            font-family: 'Playfair Display', serif;
            font-size: 1.4rem;
            font-weight: 700;
            color: var(--red);
        }

        .nav-logo svg { width: 28px; height: 28px; fill: var(--red); }

        .nav-links {
            display: flex;
            align-items: center;
            gap: 2rem;
        }

        .nav-links a {
            font-size: .9rem;
            font-weight: 600;
            color: var(--text-mid);
            transition: color .2s;
        }
        .nav-links a:hover { color: var(--red); }

        .nav-cta {
            display: flex;
            gap: .75rem;
            align-items: center;
        }

        .btn {
            padding: .55rem 1.2rem;
            border-radius: 10px;
            font-family: 'DM Sans', sans-serif;
            font-size: .85rem;
            font-weight: 600;
            cursor: pointer;
            transition: all .2s;
            border: none;
            display: inline-flex;
            align-items: center;
            gap: .4rem;
        }

        .btn-outline {
            background: transparent;
            border: 1.5px solid var(--border);
            color: var(--text-mid);
        }
        .btn-outline:hover { border-color: var(--red); color: var(--red); }

        .btn-red {
            background: var(--red);
            color: white;
        }
        .btn-red:hover { background: var(--red-dark); }

        .user-pill {
            display: flex;
            align-items: center;
            gap: .5rem;
            padding: .4rem .9rem;
            background: var(--red-light);
            border-radius: 10px;
            font-size: .85rem;
            font-weight: 600;
            color: var(--red);
        }

        .user-pill .dot {
            width: 8px; height: 8px;
            border-radius: 50%;
            background: #059669;
        }

        /* HERO */
        .hero {
            padding: 9rem 2.5rem 5rem;
            background: linear-gradient(135deg, #fff5f5 0%, #ffffff 50%, #fff5f5 100%);
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 4rem;
            max-width: 1200px;
            margin: 0 auto;
        }

        .hero-text { flex: 1; max-width: 540px; }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            padding: .35rem .9rem;
            background: var(--red-light);
            color: var(--red);
            border-radius: 999px;
            font-size: .78rem;
            font-weight: 700;
            margin-bottom: 1.2rem;
        }

        .hero-badge svg { width: 14px; height: 14px; fill: var(--red); }

        .hero h1 {
            font-family: 'Playfair Display', serif;
            font-size: 3.2rem;
            font-weight: 700;
            color: var(--text-dark);
            line-height: 1.15;
            margin-bottom: 1.2rem;
        }

        .hero h1 span { color: var(--red); }

        .hero p {
            font-size: 1.05rem;
            color: var(--text-mid);
            margin-bottom: 2rem;
            line-height: 1.7;
        }

        .hero-actions { display: flex; gap: .75rem; flex-wrap: wrap; }

        .btn-lg {
            padding: .8rem 1.6rem;
            border-radius: 12px;
            font-size: .95rem;
        }

        .hero-visual {
            flex: 1;
            max-width: 460px;
            position: relative;
        }

        .hero-card {
            background: var(--white);
            border-radius: 20px;
            border: 1px solid var(--border);
            box-shadow: var(--shadow-md);
            padding: 1.8rem;
            display: flex;
            flex-direction: column;
            gap: 1.2rem;
        }

        .hero-card-row {
            display: flex;
            align-items: center;
            gap: 1rem;
            padding: .8rem;
            border-radius: 12px;
            background: #fafafa;
        }

        .hero-avatar {
            width: 44px; height: 44px;
            border-radius: 50%;
            background: var(--red-light);
            display: flex; align-items: center; justify-content: center;
            font-size: .85rem;
            font-weight: 700;
            color: var(--red);
            flex-shrink: 0;
        }

        .hero-card-info { flex: 1; }
        .hero-card-name { font-weight: 600; font-size: .9rem; }
        .hero-card-meta { font-size: .78rem; color: var(--text-light); }

        .hero-badge-pill {
            padding: .25rem .7rem;
            border-radius: 6px;
            font-size: .72rem;
            font-weight: 700;
            color: white;
            flex-shrink: 0;
        }

        /* STATS BAR */
        .stats-bar {
            background: var(--red);
            padding: 2.5rem 2rem;
        }

        .stats-bar-inner {
            max-width: 1000px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 2rem;
            text-align: center;
        }

        .stat-item .stat-num {
            font-size: 2.4rem;
            font-weight: 700;
            color: white;
            line-height: 1;
        }

        .stat-item .stat-label {
            font-size: .85rem;
            color: rgba(255,255,255,0.8);
            margin-top: .4rem;
            font-weight: 500;
        }

        /* HOW IT WORKS */
        .section {
            padding: 4rem 2rem;
            max-width: 1100px;
            margin: 0 auto;
        }

        .section-title {
            text-align: center;
            margin-bottom: 3rem;
        }

        .section-title h2 {
            font-family: 'Playfair Display', serif;
            font-size: 2.2rem;
            font-weight: 700;
            margin-bottom: .5rem;
        }

        .section-title p {
            color: var(--text-mid);
            font-size: 1rem;
        }

        .steps-row {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 2rem;
        }

        .step-card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 2rem 1.5rem;
            text-align: center;
            box-shadow: var(--shadow);
            transition: transform .2s, box-shadow .2s;
        }

        .step-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-md);
        }

        .step-num {
            width: 48px; height: 48px;
            border-radius: 14px;
            background: var(--red-light);
            color: var(--red);
            display: flex; align-items: center; justify-content: center;
            font-size: 1.2rem;
            font-weight: 700;
            margin: 0 auto 1.2rem;
        }

        .step-card h3 {
            font-size: 1.1rem;
            font-weight: 700;
            margin-bottom: .5rem;
        }

        .step-card p {
            font-size: .88rem;
            color: var(--text-mid);
            line-height: 1.6;
        }

        /* BLOOD GROUPS */
        .bg-section {
            background: var(--bg);
            padding: 4rem 2rem;
        }

        .bg-section-inner {
            max-width: 1100px;
            margin: 0 auto;
        }

        .bg-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 1rem;
            margin-top: 2rem;
        }

        .bg-card {
            background: var(--white);
            border-radius: 14px;
            border: 1px solid var(--border);
            padding: 1.5rem;
            text-align: center;
            box-shadow: var(--shadow);
            transition: transform .2s;
        }

        .bg-card:hover { transform: translateY(-3px); }

        .bg-card-type {
            font-size: 1.5rem;
            font-weight: 700;
            color: var(--red);
            margin-bottom: .3rem;
        }

        .bg-card-count {
            font-size: .85rem;
            color: var(--text-mid);
            font-weight: 500;
        }

        /* CTA SECTION */
        .cta-section {
            padding: 4rem 2rem;
            text-align: center;
            background: linear-gradient(135deg, var(--red-dark) 0%, var(--red) 100%);
        }

        .cta-section h2 {
            font-family: 'Playfair Display', serif;
            font-size: 2.4rem;
            color: white;
            margin-bottom: .8rem;
        }

        .cta-section p {
            color: rgba(255,255,255,0.85);
            font-size: 1.05rem;
            margin-bottom: 2rem;
        }

        .btn-white {
            background: white;
            color: var(--red);
            padding: .85rem 2rem;
            border-radius: 12px;
            font-size: 1rem;
            font-weight: 700;
        }
        .btn-white:hover { background: var(--red-light); }

        /* FOOTER */
        .footer {
            background: #1a0a0a;
            color: rgba(255,255,255,0.7);
            padding: 2.5rem 2rem;
            text-align: center;
        }

        .footer-logo {
            font-family: 'Playfair Display', serif;
            font-size: 1.3rem;
            color: white;
            margin-bottom: .5rem;
        }

        .footer p { font-size: .85rem; }

        /* ANIMATIONS */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .hero-text { animation: fadeUp .6s ease both; }
        .hero-visual { animation: fadeUp .6s ease .15s both; }
        .stats-bar { animation: fadeUp .6s ease .3s both; }
        .section { animation: fadeUp .6s ease .1s both; }

        /* MOBILE */
        @media (max-width: 900px) {
            .hero { flex-direction: column; padding-top: 7rem; }
            .hero h1 { font-size: 2.4rem; }
            .stats-bar-inner { grid-template-columns: repeat(2, 1fr); }
            .steps-row { grid-template-columns: 1fr; }
            .bg-grid { grid-template-columns: repeat(2, 1fr); }
            .nav-links { display: none; }
        }
    </style>
</head>
<body>

<!-- NAVBAR -->
<nav class="navbar">
    <a href="<%= request.getContextPath() %>/" class="nav-logo">
        <svg viewBox="0 0 24 24"><path d="M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z"/></svg>
        LifeLink
    </a>
    <div class="nav-links">
        <a href="#how-it-works">How it Works</a>
        <a href="#blood-groups">Blood Types</a>
        <a href="#stats">Impact</a>
    </div>
    <div class="nav-cta">
        <% if (isLoggedIn) { %>
            <% if (isAdmin) { %>
                <a href="<%= request.getContextPath() %>/admin/dashboard" class="btn btn-red">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><rect x="3" y="3" width="7" height="7"/><rect x="14" y="3" width="7" height="7"/><rect x="14" y="14" width="7" height="7"/><rect x="3" y="14" width="7" height="7"/></svg>
                    Dashboard
                </a>
            <% } else { %>
                <div class="user-pill">
                    <span class="dot"></span>
                    <%= currentUser.getFullName() %>
                </div>
                <a href="<%= request.getContextPath() %>/logout" class="btn btn-outline">Log Out</a>
            <% } %>
        <% } else { %>
            <a href="<%= request.getContextPath() %>/login" class="btn btn-outline">Log In</a>
            <a href="<%= request.getContextPath() %>/register" class="btn btn-red">Get Started</a>
        <% } %>
    </div>
</nav>

<!-- HERO -->
<section class="hero">
    <div class="hero-text">
        <div class="hero-badge">
            <svg viewBox="0 0 24 24"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
            Saving Lives Every Day
        </div>
        <h1>Donate Blood.<br><span>Save a Life.</span></h1>
        <p>LifeLink connects donors, recipients, and hospitals in one seamless platform. Join our community and be the reason someone gets a second chance at life.</p>
        <div class="hero-actions">
            <% if (isLoggedIn) { %>
                <% if (isAdmin) { %>
                    <a href="<%= request.getContextPath() %>/admin/dashboard" class="btn btn-red btn-lg">Go to Dashboard</a>
                    <a href="<%= request.getContextPath() %>/admin/reports" class="btn btn-outline btn-lg">View Reports</a>
                <% } else { %>
                    <a href="<%= request.getContextPath() %>/login" class="btn btn-red btn-lg">My Account</a>
                <% } %>
            <% } else { %>
                <a href="<%= request.getContextPath() %>/register" class="btn btn-red btn-lg">Become a Donor</a>
                <a href="<%= request.getContextPath() %>/login" class="btn btn-outline btn-lg">Request Blood</a>
            <% } %>
        </div>
    </div>
    <div class="hero-visual">
        <div class="hero-card">
            <div class="hero-card-row">
                <div class="hero-avatar">SJ</div>
                <div class="hero-card-info">
                    <div class="hero-card-name">Sarah Johnson</div>
                    <div class="hero-card-meta">Donor &middot; A+ &middot; 3 donations</div>
                </div>
                <span class="hero-badge-pill" style="background:#059669;">Active</span>
            </div>
            <div class="hero-card-row">
                <div class="hero-avatar">MC</div>
                <div class="hero-card-info">
                    <div class="hero-card-name">Michael Chen</div>
                    <div class="hero-card-meta">Recipient &middot; O- &middot; Request fulfilled</div>
                </div>
                <span class="hero-badge-pill" style="background:#2563eb;">Matched</span>
            </div>
            <div class="hero-card-row">
                <div class="hero-avatar">GH</div>
                <div class="hero-card-info">
                    <div class="hero-card-name">General Hospital</div>
                    <div class="hero-card-meta">Hospital Partner &middot; 12 requests</div>
                </div>
                <span class="hero-badge-pill" style="background:#d97706;">Partner</span>
            </div>
        </div>
    </div>
</section>

<!-- STATS BAR -->
<section class="stats-bar" id="stats">
    <div class="stats-bar-inner">
        <div class="stat-item">
            <div class="stat-num"><%= totalDonors %></div>
            <div class="stat-label">Registered Donors</div>
        </div>
        <div class="stat-item">
            <div class="stat-num"><%= totalRecipients %></div>
            <div class="stat-label">Recipients Helped</div>
        </div>
        <div class="stat-item">
            <div class="stat-num"><%= totalHospitals %></div>
            <div class="stat-label">Hospital Partners</div>
        </div>
        <div class="stat-item">
            <div class="stat-num"><%= totalUsers %></div>
            <div class="stat-label">Total Community</div>
        </div>
    </div>
</section>

<!-- HOW IT WORKS -->
<section class="section" id="how-it-works">
    <div class="section-title">
        <h2>How LifeLink Works</h2>
        <p>Three simple steps to make a life-saving difference</p>
    </div>
    <div class="steps-row">
        <div class="step-card">
            <div class="step-num">1</div>
            <h3>Register</h3>
            <p>Create your profile as a donor, recipient, or hospital. It takes less than 2 minutes to join our life-saving network.</p>
        </div>
        <div class="step-card">
            <div class="step-num">2</div>
            <h3>Connect</h3>
            <p>Our platform matches blood requests with compatible donors nearby. Get real-time notifications when help is needed.</p>
        </div>
        <div class="step-card">
            <div class="step-num">3</div>
            <h3>Donate</h3>
            <p>Schedule your donation, visit the nearest partner hospital, and save a life. Every drop counts in our community.</p>
        </div>
    </div>
</section>

<!-- BLOOD GROUPS -->
<section class="bg-section" id="blood-groups">
    <div class="bg-section-inner">
        <div class="section-title">
            <h2>Blood Group Availability</h2>
            <p>Real-time overview of donors by blood type in our network</p>
        </div>
        <div class="bg-grid">
            <% for (Map.Entry<String, Long> entry : bgCounts.entrySet()) { %>
            <div class="bg-card">
                <div class="bg-card-type"><%= entry.getKey() %></div>
                <div class="bg-card-count"><%= entry.getValue() %> donor<%= entry.getValue() != 1 ? "s" : "" %></div>
            </div>
            <% } %>
        </div>
    </div>
</section>

<!-- CTA -->
<section class="cta-section">
    <h2>Ready to Save a Life?</h2>
    <p>Join thousands of donors and recipients on LifeLink. Your contribution can make all the difference.</p>
    <% if (isLoggedIn) { %>
        <% if (isAdmin) { %>
            <a href="<%= request.getContextPath() %>/admin/dashboard" class="btn btn-white">Go to Dashboard</a>
        <% } else { %>
            <a href="<%= request.getContextPath() %>/login" class="btn btn-white">My Account</a>
        <% } %>
    <% } else { %>
        <a href="<%= request.getContextPath() %>/register" class="btn btn-white">Join LifeLink Today</a>
    <% } %>
</section>

<!-- FOOTER -->
<footer class="footer">
    <div class="footer-logo">LifeLink</div>
    <p>Connecting hearts, saving lives. &copy; 2026 LifeLink Blood Management System.</p>
</footer>

</body>
</html>
