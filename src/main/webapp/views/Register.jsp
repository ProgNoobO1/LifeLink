<%--
  Created by IntelliJ IDEA.
  User: ektarai
  Date: 02/05/2026
  Time: 17:30
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Register</title>
</head>
<link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700&family=DM+Sans:wght@400;500;600&display=swap" rel="stylesheet"/>

    <style>

        :root {
            --red:        #b91c1c;
            --red-dark:   #991b1b;
            --red-light:  #fee2e2;
            --text-dark:  #111827;
            --text-mid:   #4b5563;
            --text-light: #9ca3af;
            --border:     #e5e7eb;
            --bg:         #f5f5f5;
            --white:      #ffffff;
            --blue-focus: #3b82f6;
            --shadow:     0 4px 24px rgba(0,0,0,.08);
        }

        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

        body {
            font-family: 'DM Sans', sans-serif;
            background: var(--bg);
            color: var(--text-dark);
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* ── Main Layout ── */
        main {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 3rem 1.5rem;
        }

        .container {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 4rem;
            max-width: 1100px;
            width: 100%;
            align-items: center;
        }

        @media (max-width: 860px) {
            .container {
                grid-template-columns: 1fr;
                gap: 2.5rem;
            }
            .hero { order: 2; }
            .register-card { order: 1; }
        }

        /* ── Left Hero ── */
        .hero { display: flex; flex-direction: column; gap: 1.5rem; }

        .hero-badge {
            display: inline-flex;
            align-items: center;
            gap: .4rem;
            background: var(--red-light);
            color: var(--red);
            font-size: .8rem;
            font-weight: 600;
            padding: .35rem .85rem;
            border-radius: 999px;
            width: fit-content;
        }

        .hero-badge svg { width: 14px; height: 14px; fill: var(--red); }

        .hero h1 {
            font-family: 'Playfair Display', serif;
            font-size: 3rem;
            line-height: 1.15;
            color: var(--text-dark);
            letter-spacing: -.02em;
        }

        .hero p {
            font-size: .97rem;
            color: var(--text-mid);
            line-height: 1.7;
            max-width: 380px;
        }

        /* Stats Grid – 2×2 */
        .stats {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-top: .5rem;
        }

        .stat-card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 1.3rem 1.4rem;
            display: flex;
            flex-direction: column;
            gap: .5rem;
            box-shadow: var(--shadow);
        }

        .stat-icon {
            width: 40px; height: 40px;
            background: var(--red-light);
            border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
        }

        .stat-icon svg { width: 20px; height: 20px; fill: var(--red); }

        .stat-card .stat-num {
            font-size: 1.7rem;
            font-weight: 700;
            color: var(--text-dark);
            line-height: 1;
        }

        .stat-card .stat-label {
            font-size: .78rem;
            color: var(--text-mid);
        }

        /* ── Register Card ── */
        .register-card {
            background: var(--white);
            border-radius: 20px;
            border: 2px solid var(--blue-focus);
            padding: 2.5rem 2rem;
            box-shadow: 0 8px 40px rgba(59,130,246,.12);
            display: flex;
            flex-direction: column;
            gap: 1.25rem;
            animation: fadeUp .5s ease both;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        /* Card Header */
        .card-header {
            text-align: center;
            display: flex;
            flex-direction: column;
            gap: .5rem;
            align-items: center;
        }

        .card-logo {
            width: 60px; height: 60px;
            background: var(--red-light);
            border-radius: 14px;
            display: flex; align-items: center; justify-content: center;
            margin-bottom: .3rem;
        }

        .card-logo svg { width: 28px; height: 28px; fill: var(--red); }

        .card-header h2 {
            font-family: 'Playfair Display', serif;
            font-size: 1.5rem;
            color: var(--text-dark);
        }

        .card-header p {
            font-size: .85rem;
            color: var(--text-mid);
        }

        /* Form Fields */
        .form-group { display: flex; flex-direction: column; gap: .4rem; margin-bottom: .9rem; }

        .form-group label {
            font-size: .85rem;
            font-weight: 600;
            color: var(--text-dark);
        }

        .input-wrapper {
            position: relative;
            display: flex;
            align-items: center;
        }

        .input-wrapper .icon {
            position: absolute;
            left: .9rem;
            color: var(--text-light);
            display: flex;
        }

        .input-wrapper .icon svg { width: 17px; height: 17px; }

        .input-wrapper input,
        .input-wrapper select {
            width: 100%;
            padding: .72rem 2.8rem;
            border: 1.5px solid var(--border);
            border-radius: 10px;
            font-family: 'DM Sans', sans-serif;
            font-size: .9rem;
            background: #fafafa;
            color: var(--text-dark);
            outline: none;
            transition: border-color .2s, box-shadow .2s;
            appearance: none;
            -webkit-appearance: none;
        }

        .input-wrapper select {
            padding-right: 2.8rem;
            cursor: pointer;
        }

        .input-wrapper input:focus,
        .input-wrapper select:focus {
            border-color: var(--blue-focus);
            box-shadow: 0 0 0 3px rgba(59,130,246,.15);
            background: white;
        }

        .input-wrapper input::placeholder { color: var(--text-light); }
        .input-wrapper select option[value=""] { color: var(--text-light); }

        /* Dropdown arrow */
        .select-arrow {
            position: absolute;
            right: .9rem;
            pointer-events: none;
            color: var(--text-light);
            display: flex;
        }

        .select-arrow svg { width: 16px; height: 16px; }

        /* Toggle password */
        .toggle-pw {
            position: absolute;
            right: .9rem;
            background: none;
            border: none;
            cursor: pointer;
            color: var(--text-light);
            display: flex;
            padding: 0;
            transition: color .2s;
        }

        .toggle-pw:hover { color: var(--text-mid); }
        .toggle-pw svg { width: 18px; height: 18px; }

        /* Two-column row */
        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 1rem;
            margin-bottom: .9rem;
        }

        /* Role selector */
        .role-label {
            font-size: .85rem;
            font-weight: 600;
            color: var(--text-dark);
            margin-bottom: .5rem;
        }

        .role-group {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: .6rem;
            margin-bottom: .9rem;
        }

        .role-btn {
            display: flex;
            flex-direction: column;
            align-items: center;
            gap: .4rem;
            padding: .75rem .5rem;
            border: 1.5px solid var(--border);
            border-radius: 12px;
            background: #fafafa;
            cursor: pointer;
            font-family: 'DM Sans', sans-serif;
            font-size: .8rem;
            font-weight: 500;
            color: var(--text-mid);
            transition: border-color .2s, background .2s, color .2s;
        }

        .role-btn svg {
            width: 22px; height: 22px;
            fill: var(--text-light);
            transition: fill .2s;
        }

        .role-btn:hover {
            border-color: var(--red);
            color: var(--red);
        }

        .role-btn:hover svg { fill: var(--red); }

        .role-btn.active {
            border-color: var(--red);
            background: var(--red-light);
            color: var(--red);
            font-weight: 600;
        }

        .role-btn.active svg { fill: var(--red); }

        /* Register Button */
        .btn-register {
            width: 100%;
            padding: .85rem 1rem;
            background: var(--red);
            color: white;
            font-family: 'DM Sans', sans-serif;
            font-size: .95rem;
            font-weight: 600;
            border: none;
            border-radius: 12px;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: .5rem;
            letter-spacing: .01em;
            transition: background .2s, transform .15s, box-shadow .2s;
            box-shadow: 0 4px 16px rgba(185,28,28,.3);
        }

        .btn-register:hover {
            background: var(--red-dark);
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(185,28,28,.4);
        }

        .btn-register:active { transform: translateY(0); }
        .btn-register svg { width: 18px; height: 18px; }

        /* Login link */
        .login-row {
            text-align: center;
            font-size: .83rem;
            color: var(--text-mid);
        }

        .login-row a {
            color: var(--red);
            font-weight: 700;
            text-decoration: none;
            transition: opacity .2s;
        }

        .login-row a:hover { opacity: .75; }

    </style>
<body>

<!-- Nav Bar -->
<jsp:include page="/includes/navbar.jsp" />

<main>
    <div class="container">

        <!-- ── LEFT: Hero Section ── -->
        <div class="hero">

            <div class="hero-badge">
                <svg viewBox="0 0 24 24"><path d="M12 21.593c-5.63-5.539-11-10.297-11-14.402 0-3.791 3.068-5.191 5.281-5.191 1.312 0 4.151.501 5.719 4.457 1.59-3.968 4.464-4.447 5.726-4.447 2.54 0 5.274 1.621 5.274 5.181 0 4.069-5.136 8.625-11 14.402z"/></svg>
                Join the Community
            </div>

            <h1>Be the Reason<br/>Someone Survives</h1>

            <p>Register today and become part of a life-saving network. Every role matters — donor, recipient, or hospital.</p>

            <!-- 2×2 Stat Cards -->
            <div class="stats">

                <div class="stat-card">
                    <div class="stat-icon">
                        <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                    </div>
                    <span class="stat-num">10k+</span>
                    <span class="stat-label">Active Donors</span>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                    </div>
                    <span class="stat-num">50+</span>
                    <span class="stat-label">Partner Hospitals</span>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
                    </div>
                    <span class="stat-num">25k+</span>
                    <span class="stat-label">Lives Saved</span>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <svg viewBox="0 0 24 24"><path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5c-1.38 0-2.5-1.12-2.5-2.5s1.12-2.5 2.5-2.5 2.5 1.12 2.5 2.5-1.12 2.5-2.5 2.5z"/></svg>
                    </div>
                    <span class="stat-num">30+</span>
                    <span class="stat-label">Cities Covered</span>
                </div>

            </div>
        </div><!-- /hero -->

        <!-- ── RIGHT: Register Card ── -->
        <div class="register-card">

            <div class="card-header">
                <div class="card-logo">
                    <!-- Person-add icon -->
                    <svg viewBox="0 0 24 24"><path d="M15 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm-9-2V7H4v3H1v2h3v3h2v-3h3v-2H6zm9 4c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/></svg>
                </div>
                <h2>Create Account</h2>
                <p>Fill in your details to get started.</p>
            </div>

            <%--
                In Java (JSP), set action="/RegisterServlet" method="post"
                The servlet handles validation and DB insertion.
            --%>
            <form id="registerForm" action="/RegisterServlet" method="post" novalidate>

                <!-- Full Name -->
                <div class="form-group">
                    <label for="fullName">Full Name</label>
                    <div class="input-wrapper">
                        <span class="icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M20 21v-2a4 4 0 00-4-4H8a4 4 0 00-4 4v2"/>
                                <circle cx="12" cy="7" r="4"/>
                            </svg>
                        </span>
                        <input type="text" id="fullName" name="fullName"
                               placeholder="Enter your full name" required autocomplete="name"/>
                    </div>
                </div>

                <!-- Email -->
                <div class="form-group">
                    <label for="email">Email Address</label>
                    <div class="input-wrapper">
                        <span class="icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="2" y="4" width="20" height="16" rx="2"/>
                                <path d="M22 7l-10 7L2 7"/>
                            </svg>
                        </span>
                        <input type="email" id="email" name="email"
                               placeholder="Enter your email" required autocomplete="email"/>
                    </div>
                </div>

                <!-- Phone + Blood Group (2-column) -->
                <div class="form-row">

                    <div class="form-group" style="margin-bottom:0;">
                        <label for="phone">Phone Number</label>
                        <div class="input-wrapper">
                            <span class="icon">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72c.127.96.361 1.903.7 2.81a2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0122 16.92z"/>
                                </svg>
                            </span>
                            <input type="tel" id="phone" name="phone"
                                   placeholder="+1 000 000 0000" autocomplete="tel"/>
                        </div>
                    </div>

                    <div class="form-group" style="margin-bottom:0;">
                        <label for="bloodGroup">Blood Group</label>
                        <div class="input-wrapper">
                            <span class="icon">
                                <svg viewBox="0 0 24 24" fill="var(--red)">
                                    <path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/>
                                </svg>
                            </span>
                            <select id="bloodGroup" name="bloodGroup">
                                <option value="">Select</option>
                                <option value="A+">A+</option>
                                <option value="A-">A-</option>
                                <option value="B+">B+</option>
                                <option value="B-">B-</option>
                                <option value="AB+">AB+</option>
                                <option value="AB-">AB-</option>
                                <option value="O+">O+</option>
                                <option value="O-">O-</option>
                            </select>
                            <span class="select-arrow">
                                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <polyline points="6 9 12 15 18 9"/>
                                </svg>
                            </span>
                        </div>
                    </div>

                </div><!-- /form-row -->

                <!-- I am a (Role selector) -->
                <div>
                    <p class="role-label">I am a</p>
                    <div class="role-group">

                        <button type="button" class="role-btn active" data-role="donor" id="roleдонор">
                            <svg viewBox="0 0 24 24">
                                <path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/>
                            </svg>
                            Donor
                        </button>

                        <button type="button" class="role-btn" data-role="recipient">
                            <svg viewBox="0 0 24 24">
                                <path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/>
                            </svg>
                            Recipient
                        </button>

                        <button type="button" class="role-btn" data-role="hospital">
                            <svg viewBox="0 0 24 24">
                                <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/>
                            </svg>
                            Hospital
                        </button>

                    </div>
                    <!-- Hidden input to carry the selected role value -->
                    <input type="hidden" id="role" name="role" value="donor"/>
                </div>

                <!-- Password -->
                <div class="form-group">
                    <label for="password">Password</label>
                    <div class="input-wrapper">
                        <span class="icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2"/>
                                <path d="M7 11V7a5 5 0 0110 0v4"/>
                            </svg>
                        </span>
                        <input type="password" id="password" name="password"
                               placeholder="Create a password" required autocomplete="new-password"/>
                        <button type="button" class="toggle-pw" id="togglePw1" title="Show/hide password">
                            <svg id="eyeIcon1" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M17.94 17.94A10.97 10.97 0 0112 19c-5 0-9.27-3.11-11-8a10.94 10.94 0 012.92-4.36"/>
                                <path d="M9.9 4.24A9 9 0 0112 4c4.97 0 9.16 3.06 11 8-.84 2.28-2.29 4.25-4.06 5.62"/>
                                <line x1="1" y1="1" x2="23" y2="23"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Confirm Password -->
                <div class="form-group">
                    <label for="confirmPassword">Confirm Password</label>
                    <div class="input-wrapper">
                        <span class="icon">
                            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="11" width="18" height="11" rx="2"/>
                                <path d="M7 11V7a5 5 0 0110 0v4"/>
                            </svg>
                        </span>
                        <input type="password" id="confirmPassword" name="confirmPassword"
                               placeholder="Confirm your password" required autocomplete="new-password"/>
                        <button type="button" class="toggle-pw" id="togglePw2" title="Show/hide password">
                            <svg id="eyeIcon2" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M17.94 17.94A10.97 10.97 0 0112 19c-5 0-9.27-3.11-11-8a10.94 10.94 0 012.92-4.36"/>
                                <path d="M9.9 4.24A9 9 0 0112 4c4.97 0 9.16 3.06 11 8-.84 2.28-2.29 4.25-4.06 5.62"/>
                                <line x1="1" y1="1" x2="23" y2="23"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Register Button -->
                <button type="submit" class="btn-register">
                    Register
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <line x1="5" y1="12" x2="19" y2="12"/>
                        <polyline points="12 5 19 12 12 19"/>
                    </svg>
                </button>

                <!-- Login Link -->
                <p class="login-row" style="margin-top:.9rem;">
                    Already have an account? <a href="login.jsp">Login</a>
                </p>

            </form><!-- /registerForm -->
        </div><!-- /register-card -->

    </div><!-- /container -->
</main>

<jsp:include page="/includes/footer.jsp" />

<!-- ═══════════ JavaScript ═══════════ -->
<script>
    /* ── Role selector ── */
    const roleBtns = document.querySelectorAll('.role-btn');
    const roleInput = document.getElementById('role');

    roleBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            roleBtns.forEach(b => b.classList.remove('active'));
            btn.classList.add('active');
            roleInput.value = btn.dataset.role;
        });
    });

    /* ── Toggle password visibility (helper) ── */
    const eyeOpen = `
        <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
        <circle cx="12" cy="12" r="3"/>
    `;
    const eyeClosed = `
        <path d="M17.94 17.94A10.97 10.97 0 0112 19c-5 0-9.27-3.11-11-8a10.94 10.94 0 012.92-4.36"/>
        <path d="M9.9 4.24A9 9 0 0112 4c4.97 0 9.16 3.06 11 8-.84 2.28-2.29 4.25-4.06 5.62"/>
        <line x1="1" y1="1" x2="23" y2="23"/>
    `;

    function setupToggle(btnId, inputId, iconId) {
        document.getElementById(btnId).addEventListener('click', () => {
            const input = document.getElementById(inputId);
            const icon  = document.getElementById(iconId);
            const isHidden = input.type === 'password';
            input.type = isHidden ? 'text' : 'password';
            icon.innerHTML = isHidden ? eyeOpen : eyeClosed;
        });
    }

    setupToggle('togglePw1', 'password',        'eyeIcon1');
    setupToggle('togglePw2', 'confirmPassword',  'eyeIcon2');

    /* ── Client-side validation ── */
    document.getElementById('registerForm').addEventListener('submit', function(e) {
        // Remove e.preventDefault() in production — let the form POST to RegisterServlet
        e.preventDefault();

        const fullName  = document.getElementById('fullName').value.trim();
        const email     = document.getElementById('email').value.trim();
        const password  = document.getElementById('password').value;
        const confirm   = document.getElementById('confirmPassword').value;

        if (!fullName || !email || !password || !confirm) {
            alert('Please fill in all required fields.');
            return;
        }

        if (password !== confirm) {
            alert('Passwords do not match. Please try again.');
            return;
        }

        if (password.length < 6) {
            alert('Password must be at least 6 characters long.');
            return;
        }

        // In production, the form POSTs to RegisterServlet which validates
        // against the DB and creates the user account.
        alert('✅ Demo Register\nName: ' + fullName + '\nEmail: ' + email +
            '\nRole: ' + roleInput.value +
            '\n\nIn your Java app, this would POST to RegisterServlet.');
    });
</script>

</body>
</html>


