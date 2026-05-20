<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>LifeLink – Contact Us</title>

    <%-- Google Fonts: Poppins for headings, Inter for body --%>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">

    <%-- Font Awesome for icons --%>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">

    <style>
        /* =========================================================
           CSS CUSTOM PROPERTIES (Design Tokens)
        ========================================================= */
        :root {
            --red-primary:   #C0392B;   /* hero & button background   */
            --red-dark:      #a93226;   /* hover states               */
            --red-light:     #f8e8e7;   /* icon pill backgrounds      */
            --red-badge:     rgba(255,255,255,0.20); /* hero badge bg  */
            --white:         #ffffff;
            --gray-bg:       #f4f4f6;   /* page body background       */
            --card-shadow:   0 4px 24px rgba(0,0,0,0.09);
            --input-border:  #dde1e7;
            --text-dark:     #1a1a2e;
            --text-muted:    #6b7280;
            --footer-bg:     #1C1C2E;
            --footer-border: rgba(255,255,255,0.08);
        }

        /* =========================================================
           RESET & BASE
        ========================================================= */
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        html { scroll-behavior: smooth; }

        body {
            font-family: 'Inter', sans-serif;
            background: var(--gray-bg);
            color: var(--text-dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* =========================================================
           NAVBAR
        ========================================================= */
        .navbar {
            background: var(--white);
            height: 64px;
            display: flex;
            align-items: center;
            padding: 0 40px;
            box-shadow: 0 1px 8px rgba(0,0,0,0.07);
            position: sticky;
            top: 0;
            z-index: 1000;
        }

        /* Brand / Logo */
        .navbar-brand {
            display: flex;
            align-items: center;
            gap: 10px;
            text-decoration: none;
            font-family: 'Poppins', sans-serif;
            font-weight: 700;
            font-size: 1.25rem;
            color: var(--text-dark);
            flex-shrink: 0;
        }

        .brand-icon {
            width: 36px;
            height: 36px;
            background: var(--red-primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 0.85rem;
        }

        /* Nav links – centred */
        .navbar-links {
            display: flex;
            align-items: center;
            gap: 36px;
            list-style: none;
            margin: 0 auto; /* push to centre */
        }

        .navbar-links a {
            text-decoration: none;
            font-size: 0.95rem;
            font-weight: 500;
            color: var(--text-dark);
            transition: color 0.2s;
        }

        .navbar-links a:hover       { color: var(--red-primary); }

        /* Active / current page link */
        .navbar-links a.active {
            color: var(--red-primary);
            border-bottom: 2px solid var(--red-primary);
            padding-bottom: 2px;
        }

        /* Login button */
        .btn-login {
            background: var(--red-primary);
            color: var(--white);
            border: none;
            border-radius: 8px;
            padding: 9px 22px;
            font-family: 'Inter', sans-serif;
            font-size: 0.9rem;
            font-weight: 600;
            cursor: pointer;
            text-decoration: none;
            transition: background 0.2s, transform 0.15s;
            flex-shrink: 0;
        }

        .btn-login:hover {
            background: var(--red-dark);
            transform: translateY(-1px);
        }

        /* =========================================================
           HERO SECTION
        ========================================================= */
        .hero {
            background: var(--red-primary);
            padding: 56px 40px 64px;
            position: relative;
            overflow: hidden;
        }

        /* Decorative circles (right side) */
        .hero::before,
        .hero::after {
            content: '';
            position: absolute;
            border-radius: 50%;
            background: rgba(255,255,255,0.08);
        }

        .hero::before {
            width: 320px; height: 320px;
            right: 160px; top: -60px;
        }

        .hero::after {
            width: 220px; height: 220px;
            right: 60px;  top: 60px;
        }

        .hero-inner {
            max-width: 1100px;
            margin: 0 auto;
            position: relative;
            z-index: 1;
        }

        /* "Get In Touch" pill badge */
        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: 8px;
            background: var(--red-badge);
            border: 1px solid rgba(255,255,255,0.30);
            color: var(--white);
            font-size: 0.82rem;
            font-weight: 600;
            padding: 6px 16px;
            border-radius: 999px;
            margin-bottom: 20px;
            backdrop-filter: blur(4px);
        }

        .hero h1 {
            font-family: 'Poppins', sans-serif;
            font-size: 2.8rem;
            font-weight: 800;
            color: var(--white);
            margin-bottom: 14px;
            line-height: 1.15;
        }

        .hero p {
            color: rgba(255,255,255,0.85);
            font-size: 1rem;
            max-width: 480px;
            line-height: 1.65;
        }

        /* =========================================================
           MAIN CONTENT AREA
        ========================================================= */
        .main-content {
            flex: 1;
            padding: 48px 40px 60px;
        }

        .content-grid {
            max-width: 1100px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 28px;
            align-items: start;
        }

        /* =========================================================
           CARD SHARED STYLES
        ========================================================= */
        .card {
            background: var(--white);
            border-radius: 16px;
            padding: 36px 32px;
            box-shadow: var(--card-shadow);
        }

        .card-title {
            font-family: 'Poppins', sans-serif;
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 6px;
        }

        .card-subtitle {
            font-size: 0.88rem;
            color: var(--text-muted);
            margin-bottom: 28px;
        }

        /* =========================================================
           FORM CARD  (left column)
        ========================================================= */
        .form-group { margin-bottom: 20px; }

        .form-label {
            display: block;
            font-size: 0.88rem;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: 7px;
        }

        /* Input wrapper for icon + field */
        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-icon {
            position: absolute;
            left: 14px;
            color: var(--text-muted);
            font-size: 0.85rem;
            pointer-events: none;
        }

        .form-control {
            width: 100%;
            padding: 11px 14px 11px 38px;
            border: 1.5px solid var(--input-border);
            border-radius: 8px;
            font-family: 'Inter', sans-serif;
            font-size: 0.9rem;
            color: var(--text-dark);
            background: var(--white);
            transition: border-color 0.2s, box-shadow 0.2s;
            outline: none;
        }

        .form-control::placeholder { color: #b0b8c4; }

        .form-control:focus {
            border-color: var(--red-primary);
            box-shadow: 0 0 0 3px rgba(192,57,43,0.12);
        }

        /* Textarea */
        textarea.form-control {
            resize: vertical;
            min-height: 120px;
            padding-top: 11px;
        }

        /* Send Message Button */
        .btn-send {
            width: 100%;
            padding: 14px;
            background: var(--red-primary);
            color: var(--white);
            border: none;
            border-radius: 10px;
            font-family: 'Inter', sans-serif;
            font-size: 1rem;
            font-weight: 700;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            margin-top: 8px;
            transition: background 0.2s, transform 0.15s, box-shadow 0.2s;
            letter-spacing: 0.02em;
        }

        .btn-send:hover {
            background: var(--red-dark);
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(192,57,43,0.30);
        }

        .btn-send:active { transform: translateY(0); }

        /* Success message (hidden by default) */
        .success-msg {
            display: none;
            background: #e8f5e9;
            border: 1px solid #a5d6a7;
            color: #2e7d32;
            border-radius: 8px;
            padding: 12px 16px;
            font-size: 0.9rem;
            font-weight: 500;
            margin-top: 14px;
            text-align: center;
        }

        /* =========================================================
           INFO CARD  (right column)
        ========================================================= */
        .info-list { list-style: none; display: flex; flex-direction: column; gap: 20px; }

        .info-item {
            display: flex;
            align-items: flex-start;
            gap: 14px;
        }

        .info-icon-box {
            width: 42px;
            height: 42px;
            background: var(--red-light);
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--red-primary);
            font-size: 0.95rem;
            flex-shrink: 0;
        }

        .info-label {
            font-weight: 700;
            font-size: 0.93rem;
            color: var(--text-dark);
            margin-bottom: 2px;
        }

        .info-value {
            font-size: 0.88rem;
            color: var(--text-dark);
            line-height: 1.5;
        }

        .info-note {
            font-size: 0.80rem;
            color: var(--text-muted);
        }

        /* =========================================================
           MAP PLACEHOLDER  (below contact info)
        ========================================================= */
        .map-box {
            margin-top: 24px;
            border: 1.5px solid #e5e7eb;
            border-radius: 12px;
            overflow: hidden;
        }

        .map-visual {
            height: 160px;
            background: linear-gradient(135deg, #f5f0f0 0%, #ede8e8 100%);
            position: relative;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Grid lines to mimic a map */
        .map-visual::before {
            content: '';
            position: absolute;
            inset: 0;
            background-image:
                linear-gradient(rgba(192,57,43,0.07) 1px, transparent 1px),
                linear-gradient(90deg, rgba(192,57,43,0.07) 1px, transparent 1px);
            background-size: 28px 28px;
        }

        .map-pin {
            position: relative;
            z-index: 1;
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: 6px;
        }

        .pin-circle {
            width: 48px;
            height: 48px;
            background: var(--red-primary);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--white);
            font-size: 1.1rem;
            box-shadow: 0 4px 16px rgba(192,57,43,0.4);
        }

        .pin-label {
            background: var(--white);
            color: var(--text-dark);
            font-size: 0.78rem;
            font-weight: 600;
            padding: 4px 10px;
            border-radius: 6px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.12);
            white-space: nowrap;
        }

        .map-footer {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 12px 16px;
            background: var(--white);
            border-top: 1px solid #f0f0f0;
        }

        .map-address {
            font-size: 0.82rem;
            color: var(--text-muted);
        }

        .map-link {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--red-primary);
            text-decoration: none;
            display: flex;
            align-items: center;
            gap: 5px;
            transition: color 0.2s;
        }

        .map-link:hover { color: var(--red-dark); }

        /* =========================================================
           FOOTER
        ========================================================= */
        footer {
            background: var(--footer-bg);
            color: rgba(255,255,255,0.70);
            padding: 52px 40px 0;
        }

        .footer-grid {
            max-width: 1100px;
            margin: 0 auto;
            display: grid;
            grid-template-columns: 2fr 1fr 1fr 1.2fr;
            gap: 40px;
            padding-bottom: 40px;
        }

        /* Brand column */
        .footer-brand-name {
            display: flex;
            align-items: center;
            gap: 10px;
            font-family: 'Poppins', sans-serif;
            font-weight: 700;
            font-size: 1.1rem;
            color: var(--white);
            text-decoration: none;
            margin-bottom: 12px;
        }

        .footer-tagline {
            font-size: 0.85rem;
            line-height: 1.6;
            margin-bottom: 20px;
            color: rgba(255,255,255,0.60);
        }

        .social-icons {
            display: flex;
            gap: 10px;
        }

        .social-icon {
            width: 34px;
            height: 34px;
            border: 1px solid rgba(255,255,255,0.20);
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: rgba(255,255,255,0.70);
            font-size: 0.85rem;
            text-decoration: none;
            transition: background 0.2s, color 0.2s;
        }

        .social-icon:hover {
            background: var(--red-primary);
            border-color: var(--red-primary);
            color: var(--white);
        }

        /* Link columns */
        .footer-col-title {
            font-family: 'Poppins', sans-serif;
            font-weight: 700;
            font-size: 0.92rem;
            color: var(--white);
            margin-bottom: 16px;
        }

        .footer-links {
            list-style: none;
            display: flex;
            flex-direction: column;
            gap: 10px;
        }

        .footer-links a {
            color: rgba(255,255,255,0.60);
            text-decoration: none;
            font-size: 0.875rem;
            transition: color 0.2s;
        }

        .footer-links a:hover { color: var(--white); }

        /* Contact column */
        .footer-contact-item {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.875rem;
            color: rgba(255,255,255,0.70);
            margin-bottom: 10px;
        }

        .footer-contact-item i {
            color: var(--red-primary);
            width: 14px;
            text-align: center;
        }

        /* Bottom bar */
        .footer-bottom {
            border-top: 1px solid var(--footer-border);
            max-width: 1100px;
            margin: 0 auto;
            padding: 18px 0;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 0.82rem;
            color: rgba(255,255,255,0.40);
        }

        .footer-bottom-right { display: flex; align-items: center; gap: 5px; }
        .footer-bottom-right i { color: var(--red-primary); }

        /* =========================================================
           RESPONSIVE  (tablet / mobile)
        ========================================================= */
        @media (max-width: 900px) {
            .content-grid      { grid-template-columns: 1fr; }
            .footer-grid       { grid-template-columns: 1fr 1fr; gap: 28px; }
        }

        @media (max-width: 600px) {
            .navbar            { padding: 0 20px; }
            .hero              { padding: 40px 20px 50px; }
            .hero h1           { font-size: 2rem; }
            .main-content      { padding: 30px 20px 40px; }
            .card              { padding: 28px 20px; }
            .footer-grid       { grid-template-columns: 1fr; }
            footer             { padding: 40px 20px 0; }
            .navbar-links      { display: none; }  /* simplify on mobile */
        }

        /* =========================================================
           ANIMATION  – fade-in on load
        ========================================================= */
        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .hero-inner       { animation: fadeUp 0.55s ease both; }
        .card:first-child { animation: fadeUp 0.55s 0.1s ease both; }
        .card:last-child  { animation: fadeUp 0.55s 0.2s ease both; }
    </style>
</head>
<body>

<%-- ================================================================
     NAVBAR
================================================================ --%>
<nav class="navbar">
    <%-- Logo --%>
    <a href="home.jsp" class="navbar-brand">
        <div class="brand-icon"><i class="fa-solid fa-droplet"></i></div>
        LifeLink
    </a>

    <%-- Navigation Links --%>
    <ul class="navbar-links">
        <li><a href="home.jsp">Home</a></li>
        <li><a href="about.jsp">About</a></li>
        <li><a href="contact.jsp" class="active">Contact</a></li>
    </ul>

    <%-- Login Button --%>
    <a href="login.jsp" class="btn-login">Login</a>
</nav>


<%-- ================================================================
     HERO SECTION
================================================================ --%>
<section class="hero">
    <div class="hero-inner">

        <%-- Pill badge --%>
        <div class="hero-badge">
            <i class="fa-solid fa-envelope"></i>
            Get In Touch
        </div>

        <h1>Contact Us</h1>

        <p>Have a question or need help? We're here for you.
           Reach out and we'll respond within 24 hours.</p>
    </div>
</section>


<%-- ================================================================
     MAIN CONTENT  (2-column grid)
================================================================ --%>
<main class="main-content">
    <div class="content-grid">

        <!-- ======================================================
             LEFT CARD – Send a Message Form
        ====================================================== -->
        <div class="card">
            <h2 class="card-title">Send a Message</h2>
            <p class="card-subtitle">Fill out the form below and we'll get back to you shortly.</p>

            <form id="contactForm" action="ContactServlet" method="post" onsubmit="handleSubmit(event)">

                <%-- Full Name --%>
                <div class="form-group">
                    <label class="form-label" for="fullName">Full Name</label>
                    <div class="input-wrapper">
                        <span class="input-icon"><i class="fa-regular fa-user"></i></span>
                        <input type="text"
                               id="fullName"
                               name="fullName"
                               class="form-control"
                               placeholder="Jane Doe"
                               required>
                    </div>
                </div>

                <%-- Email Address --%>
                <div class="form-group">
                    <label class="form-label" for="emailAddress">Email Address</label>
                    <div class="input-wrapper">
                        <span class="input-icon"><i class="fa-regular fa-envelope"></i></span>
                        <input type="email"
                               id="emailAddress"
                               name="emailAddress"
                               class="form-control"
                               placeholder="jane@example.com"
                               required>
                    </div>
                </div>

                <%-- Subject --%>
                <div class="form-group">
                    <label class="form-label" for="subject">Subject</label>
                    <div class="input-wrapper">
                        <span class="input-icon"><i class="fa-solid fa-tag"></i></span>
                        <input type="text"
                               id="subject"
                               name="subject"
                               class="form-control"
                               placeholder="How can we help?"
                               required>
                    </div>
                </div>

                <%-- Message --%>
                <div class="form-group">
                    <label class="form-label" for="message">Message</label>
                    <div class="input-wrapper">
                        <span class="input-icon" style="top:13px; position:absolute;">
                            <i class="fa-regular fa-comment"></i>
                        </span>
                        <textarea id="message"
                                  name="message"
                                  class="form-control"
                                  placeholder="Write your message here..."
                                  required></textarea>
                    </div>
                </div>

                <%-- Submit Button --%>
                <button type="submit" class="btn-send">
                    <i class="fa-solid fa-paper-plane"></i>
                    Send Message
                </button>

                <%-- Success feedback (shown by JS after submit demo) --%>
                <div class="success-msg" id="successMsg">
                    <i class="fa-solid fa-circle-check"></i>
                    &nbsp;Your message has been sent successfully!
                </div>

            </form>
        </div><!-- /form card -->


        <!-- ======================================================
             RIGHT CARD – Contact Information + Map
        ====================================================== -->
        <div class="card">
            <h2 class="card-title">Contact Information</h2>
            <p class="card-subtitle">Multiple ways to connect with the LifeLink team.</p>

            <ul class="info-list">

                <%-- Address --%>
                <li class="info-item">
                    <div class="info-icon-box">
                        <i class="fa-solid fa-location-dot"></i>
                    </div>
                    <div>
                        <div class="info-label">Our Address</div>
                        <div class="info-value">
                            M842+5Q8 Sundar, Dulari Sadak<br>
                            Koshi Haraicha 56705
                        </div>
                    </div>
                </li>

                <%-- Phone --%>
                <li class="info-item">
                    <div class="info-icon-box">
                        <i class="fa-solid fa-phone"></i>
                    </div>
                    <div>
                        <div class="info-label">Phone</div>
                        <div class="info-value">+977 9876543210</div>
                        <div class="info-note">Sun - Fri, 8am - 4pm Npt</div>
                    </div>
                </li>

                <%-- Email --%>
                <li class="info-item">
                    <div class="info-icon-box">
                        <i class="fa-solid fa-envelope"></i>
                    </div>
                    <div>
                        <div class="info-label">Email</div>
                        <div class="info-value">admin@lifelink.com</div>
                        <div class="info-note">We reply within 24 hours</div>
                    </div>
                </li>

            </ul>

            <%-- Map placeholder --%>
            <div class="map-box">
                <div class="map-visual">
                    <div class="map-pin">
                        <div class="pin-circle">
                            <i class="fa-solid fa-location-dot"></i>
                        </div>
                        <div class="pin-label">LifeLink HQ, Sundar Dulari</div>
                    </div>
                </div>
                <div class="map-footer">
                    <span class="map-address">M842+5Q8 Sundar, Dulari Sadak<br>
                            Koshi Haraicha 56705</span>
                    <a href="https://maps.app.goo.gl/9BceeGgxCk6WWoFE7"
                       target="_blank"
                       class="map-link">
                        Get Directions <i class="fa-solid fa-arrow-right"></i>
                    </a>
                </div>
            </div>

        </div><!-- /info card -->

    </div><!-- /content-grid -->
</main>


<%-- ================================================================
     FOOTER
================================================================ --%>
<footer>
    <div class="footer-grid">

        <%-- Brand Column --%>
        <div>
            <a href="home.jsp" class="footer-brand-name">
                <div class="brand-icon" style="width:30px;height:30px;font-size:0.78rem;">
                    <i class="fa-solid fa-droplet"></i>
                </div>
                LifeLink
            </a>
            <p class="footer-tagline">
                Connecting blood donors with those in need.<br>
                Every drop saves a life.
            </p>
            <div class="social-icons">
                <a href="#" class="social-icon" aria-label="Facebook">
                    <i class="fa-brands fa-facebook-f"></i>
                </a>
                <a href="#" class="social-icon" aria-label="Twitter">
                    <i class="fa-brands fa-x-twitter"></i>
                </a>
                <a href="#" class="social-icon" aria-label="Instagram">
                    <i class="fa-brands fa-instagram"></i>
                </a>
            </div>
        </div>

        <%-- Quick Links --%>
        <div>
            <div class="footer-col-title">Quick Links</div>
            <ul class="footer-links">
                <li><a href="home.jsp">Home</a></li>
                <li><a href="about.jsp">About</a></li>
                <li><a href="contact.jsp">Contact</a></li>
                <li><a href="login.jsp">Login</a></li>
            </ul>
        </div>

        <%-- Legal --%>
        <div>
            <div class="footer-col-title">Legal</div>
            <ul class="footer-links">
                <li><a href="privacy.jsp">Privacy Policy</a></li>
                <li><a href="terms.jsp">Terms of Service</a></li>
                <li><a href="help.jsp">Help Center</a></li>
            </ul>
        </div>

        <%-- Contact --%>
        <div>
            <div class="footer-col-title">Contact</div>
            <div class="footer-contact-item">
                <i class="fa-solid fa-envelope"></i>
                hello@lifelink.org
            </div>
            <div class="footer-contact-item">
                <i class="fa-solid fa-phone"></i>
                +1 800 LIFELINK
            </div>
            <div class="footer-contact-item">
                <i class="fa-solid fa-location-dot"></i>
                New York, NY 10001
            </div>
        </div>

    </div><!-- /footer-grid -->

    <%-- Bottom bar --%>
    <div class="footer-bottom">
        <span>© 2026 LifeLink. All rights reserved.</span>
        <div class="footer-bottom-right">
            Made with <i class="fa-solid fa-heart"></i> to save lives
        </div>
    </div>
</footer>


<%-- ================================================================
     JAVASCRIPT  – Client-side form demo feedback
     (Replace with real Servlet action for production)
================================================================ --%>
<script>
    /**
     * handleSubmit()
     * Prevents default browser POST for demo purposes.
     * Remove this function and the onsubmit attribute when your
     * ContactServlet backend is ready; the form will POST normally.
     */
    function handleSubmit(event) {
        event.preventDefault();  // Comment this line out when Servlet is ready

        const form    = document.getElementById('contactForm');
        const success = document.getElementById('successMsg');

        // Basic validation already handled by HTML 'required' attributes
        success.style.display = 'block';

        // Reset the form after 2 seconds (demo)
        setTimeout(() => {
            form.reset();
            success.style.display = 'none';
        }, 3000);
    }
</script>

</body>
</html>
