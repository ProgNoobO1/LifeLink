<%--
  Created by IntelliJ IDEA.
  User: ektarai
  Date: 02/05/2026
  Time: 17:30
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="com.lifelink.model.User" %>
<%@ page import="com.lifelink.dao.UserDAO" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    UserDAO loginUserDAO = new UserDAO();
    long loginTotalDonors = loginUserDAO.countByRole(User.Role.DONOR);
    long loginTotalHospitals = loginUserDAO.countByRole(User.Role.HOSPITAL);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <title>Login – LifeLink</title>
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
            .login-card { order: 1; }
            .stats { flex-direction: column; }
            .stat-card { min-width: auto; }
            main { padding: 2rem 1rem; }
            .toast { min-width: auto; max-width: calc(100vw - 2rem); right: 1rem; left: 1rem; }
        }

        /* ── STEP 5: Left-side hero text ── */
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

        .stats {
            display: flex;
            gap: 1rem;
            margin-top: .5rem;
        }

        .stat-card {
            background: var(--white);
            border: 1px solid var(--border);
            border-radius: 14px;
            padding: 1.1rem 1.4rem;
            display: flex;
            flex-direction: column;
            gap: .5rem;
            min-width: 150px;
            box-shadow: var(--shadow);
        }

        .stat-icon {
            width: 38px; height: 38px;
            background: var(--red-light);
            border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
        }

        .stat-icon svg { width: 20px; height: 20px; fill: var(--red); }

        .stat-card .stat-num {
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--text-dark);
            line-height: 1;
        }

        .stat-card .stat-label {
            font-size: .78rem;
            color: var(--text-mid);
        }

        /* ── STEP 6: Login Card ── */
        .login-card {
            background: var(--white);
            border-radius: 20px;
            border: 2px solid var(--blue-focus);
            padding: 2.5rem 2rem;
            box-shadow: 0 8px 40px rgba(59,130,246,.12);
            display: flex;
            flex-direction: column;
            gap: 1.5rem;
            animation: fadeUp .5s ease both;
        }

        @keyframes fadeUp {
            from { opacity: 0; transform: translateY(20px); }
            to   { opacity: 1; transform: translateY(0); }
        }

        .card-header { text-align: center; display: flex; flex-direction: column; gap: .6rem; align-items: center; }

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

        /* ── STEP 7: Form Fields ── */
        .form-group { display: flex; flex-direction: column; gap: .45rem; }

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

        .input-wrapper input {
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
        }

        .input-wrapper input:focus {
            border-color: var(--blue-focus);
            box-shadow: 0 0 0 3px rgba(59,130,246,.15);
            background: white;
        }

        .input-wrapper input::placeholder { color: var(--text-light); }

        /* Toggle password visibility */
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

        /* ── STEP 8: Remember me + Forgot password row ── */
        .form-options {
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: .82rem;
        }

        .remember {
            display: flex;
            align-items: center;
            gap: .45rem;
            cursor: pointer;
            color: var(--text-mid);
        }

        .remember input[type="checkbox"] {
            width: 16px; height: 16px;
            border: 1.5px solid var(--border);
            border-radius: 4px;
            cursor: pointer;
            accent-color: var(--red);
        }

        .forgot-link {
            color: var(--red);
            text-decoration: none;
            font-weight: 600;
            transition: opacity .2s;
        }

        .forgot-link:hover { opacity: .75; }

        /* ── STEP 9: Login Button ── */
        .btn-login {
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

        .btn-login:hover {
            background: var(--red-dark);
            transform: translateY(-1px);
            box-shadow: 0 6px 20px rgba(185,28,28,.4);
        }

        .btn-login:active { transform: translateY(0); }

        .btn-login svg { width: 18px; height: 18px; }

        /* ── STEP 10: Register link ── */
        .register-row {
            text-align: center;
            font-size: .83rem;
            color: var(--text-mid);
        }

        .register-row a {
            color: var(--red);
            font-weight: 700;
            text-decoration: none;
            transition: opacity .2s;
        }

        .register-row a:hover { opacity: .75; }

        /* TOAST NOTIFICATION */
        .toast {
            position: fixed;
            top: 1.5rem;
            right: 1.5rem;
            z-index: 200;
            min-width: 300px;
            max-width: 420px;
            padding: 1rem 1.2rem;
            border-radius: 12px;
            display: flex;
            align-items: flex-start;
            gap: .75rem;
            font-size: .9rem;
            font-weight: 500;
            box-shadow: 0 8px 32px rgba(0,0,0,.15);
            transform: translateX(120%);
            transition: transform .4s cubic-bezier(.34,1.56,.64,1);
            pointer-events: none;
            opacity: 0;
        }

        .toast.show {
            transform: translateX(0);
            pointer-events: auto;
            opacity: 1;
        }

        .toast.error {
            background: #fef2f2;
            border: 1.5px solid #fecaca;
            color: #991b1b;
        }

        .toast.success {
            background: #f0fdf4;
            border: 1.5px solid #bbf7d0;
            color: #166534;
        }

        .toast-icon {
            width: 22px; height: 22px;
            flex-shrink: 0;
            margin-top: 1px;
        }

        .toast.error .toast-icon { fill: #dc2626; }
        .toast.success .toast-icon { fill: #16a34a; }

        .toast-body { flex: 1; line-height: 1.5; }

        .toast-close {
            background: none;
            border: none;
            cursor: pointer;
            padding: 0;
            color: inherit;
            opacity: .5;
            transition: opacity .2s;
            display: flex;
        }
        .toast-close:hover { opacity: 1; }
        .toast-close svg { width: 16px; height: 16px; }

    </style>
</head>
<body>

<!--Nav Bar-->
<jsp:include page="/includes/navbar.jsp" />


<!-- ═══════════ STEP 4: Main Content ═══════════ -->
<main>
    <div class="container">

        <!-- ── LEFT: Hero Section ── -->
        <div class="hero">

            <!-- Badge -->
            <div class="hero-badge">
                <svg viewBox="0 0 24 24"><path d="M12 21.593c-5.63-5.539-11-10.297-11-14.402 0-3.791 3.068-5.191 5.281-5.191 1.312 0 4.151.501 5.719 4.457 1.59-3.968 4.464-4.447 5.726-4.447 2.54 0 5.274 1.621 5.274 5.181 0 4.069-5.136 8.625-11 14.402z"/></svg>
                Save Lives Today
            </div>

            <!-- Headline -->
            <h1>Connecting<br/>Donors with Those<br/>in Need</h1>

            <!-- Sub-text -->
            <p>Join our community of heroes. Every drop counts in making a difference in someone's life.</p>

            <!-- Stat Cards -->
            <div class="stats">
                <div class="stat-card">
                    <div class="stat-icon">
                        <!-- People/donors icon -->
                        <svg viewBox="0 0 24 24"><path d="M16 11c1.66 0 2.99-1.34 2.99-3S17.66 5 16 5c-1.66 0-3 1.34-3 3s1.34 3 3 3zm-8 0c1.66 0 2.99-1.34 2.99-3S9.66 5 8 5C6.34 5 5 6.34 5 8s1.34 3 3 3zm0 2c-2.33 0-7 1.17-7 3.5V19h14v-2.5c0-2.33-4.67-3.5-7-3.5zm8 0c-.29 0-.62.02-.97.05 1.16.84 1.97 1.97 1.97 3.45V19h6v-2.5c0-2.33-4.67-3.5-7-3.5z"/></svg>
                    </div>
                    <span class="stat-num"><%= loginTotalDonors %></span>
                    <span class="stat-label">Active Donors</span>
                </div>

                <div class="stat-card">
                    <div class="stat-icon">
                        <!-- Hospital icon -->
                        <svg viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 3c1.93 0 3.5 1.57 3.5 3.5S13.93 13 12 13s-3.5-1.57-3.5-3.5S10.07 6 12 6zm7 13H5v-.23c0-.62.28-1.2.76-1.58C7.47 15.82 9.64 15 12 15s4.53.82 6.24 2.19c.48.38.76.97.76 1.58V19z"/></svg>
                    </div>
                    <span class="stat-num"><%= loginTotalHospitals %></span>
                    <span class="stat-label">Partner Hospitals</span>
                </div>
            </div>
        </div><!-- /hero -->

        <!-- ── RIGHT: Login Card ── -->
        <div class="login-card">

            <!-- Card Header -->
            <div class="card-header">
                <div class="card-logo">
                    <svg viewBox="0 0 24 24"><path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/></svg>
                </div>
                <h2>Welcome Back</h2>
                <p>Please enter your details to sign in.</p>
            </div>

            <!-- ═══════════ STEP 7 & 8: Form ═══════════ -->

            <!-- Toast Notification -->
            <div id="toast" class="toast">
                <svg class="toast-icon" viewBox="0 0 24 24"><path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-1 15v-2h2v2h-2zm0-10v6h2V7h-2z"/></svg>
                <span class="toast-body" id="toastBody"></span>
                <button type="button" class="toast-close" onclick="hideToast()">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>
                </button>
            </div>

            <form id="loginForm" action="<%= request.getContextPath() %>/login" method="post" novalidate>

                <!-- Email Field -->
                <div class="form-group" style="margin-bottom:1rem;">
                    <label for="email">Email Address</label>
                    <div class="input-wrapper">
              <span class="icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="2" y="4" width="20" height="16" rx="2"/>
                  <path d="M22 7l-10 7L2 7"/>
                </svg>
              </span>
                        <input type="email" id="email" name="email" placeholder="Enter your email" required autocomplete="email"/>
                    </div>
                </div>

                <!-- Password Field -->
                <div class="form-group" style="margin-bottom:1rem;">
                    <label for="password">Password</label>
                    <div class="input-wrapper">
              <span class="icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                  <rect x="3" y="11" width="18" height="11" rx="2"/>
                  <path d="M7 11V7a5 5 0 0110 0v4"/>
                </svg>
              </span>
                        <input type="password" id="password" name="password" placeholder="Enter your password" required autocomplete="current-password"/>
                        <!-- Toggle Show/Hide Password -->
                        <button type="button" class="toggle-pw" id="togglePw" title="Show/hide password">
                            <!-- Eye-off icon (default: hidden) -->
                            <svg id="eyeIcon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M17.94 17.94A10.97 10.97 0 0112 19c-5 0-9.27-3.11-11-8a10.94 10.94 0 012.92-4.36"/>
                                <path d="M9.9 4.24A9 9 0 0112 4c4.97 0 9.16 3.06 11 8-.84 2.28-2.29 4.25-4.06 5.62"/>
                                <line x1="1" y1="1" x2="23" y2="23"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <!-- Remember Me + Forgot Password -->
                <div class="form-options" style="margin-bottom:1.3rem;">
                    <label class="remember">
                        <input type="checkbox" name="remember" id="remember"/>
                        Remember me
                    </label>
                    <a href="#" class="forgot-link">Forgot Password?</a>
                </div>

                <!-- Login Button -->
                <button type="submit" class="btn-login">
                    Login
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                        <line x1="5" y1="12" x2="19" y2="12"/>
                        <polyline points="12 5 19 12 12 19"/>
                    </svg>
                </button>

                <!-- Register Link -->
                <p class="register-row" style="margin-top:1.1rem;">
                    Don't have an account? <a href="<%= request.getContextPath() %>/register">Register</a>
                </p>

            </form><!-- /loginForm -->
        </div><!-- /login-card -->

    </div><!-- /container -->
</main>

<%--footer--%>
<jsp:include page="/includes/footer.jsp" />


<!-- ═══════════ STEP 12: JavaScript (Toggle + Validation) ═══════════ -->
<script>
    // --- Toggle password visibility ---
    const toggleBtn = document.getElementById('togglePw');
    const pwInput   = document.getElementById('password');
    const eyeIcon   = document.getElementById('eyeIcon');

    const eyeOpen = `
      <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
      <circle cx="12" cy="12" r="3"/>
    `;
    const eyeClosed = `
      <path d="M17.94 17.94A10.97 10.97 0 0112 19c-5 0-9.27-3.11-11-8a10.94 10.94 0 012.92-4.36"/>
      <path d="M9.9 4.24A9 9 0 0112 4c4.97 0 9.16 3.06 11 8-.84 2.28-2.29 4.25-4.06 5.62"/>
      <line x1="1" y1="1" x2="23" y2="23"/>
    `;

    toggleBtn.addEventListener('click', () => {
        const isHidden = pwInput.type === 'password';
        pwInput.type = isHidden ? 'text' : 'password';
        eyeIcon.innerHTML = isHidden ? eyeOpen : eyeClosed;
    });

    // --- Toast notification ---
    const toast = document.getElementById('toast');
    const toastBody = document.getElementById('toastBody');
    let toastTimer;

    function showToast(message, type) {
        toastBody.textContent = message;
        toast.className = 'toast ' + type + ' show';
        clearTimeout(toastTimer);
        toastTimer = setTimeout(hideToast, 4500);
    }

    function hideToast() {
        toast.classList.remove('show');
    }

    // --- Form submit handler (client-side validation) ---
    document.getElementById('loginForm').addEventListener('submit', function(e) {
        const email    = document.getElementById('email').value.trim();
        const password = document.getElementById('password').value;

        if (!email || !password) {
            e.preventDefault();
            showToast('Please fill in both email and password.', 'error');
            return;
        }

        // Form will POST normally to LoginServlet
    });

    <% if (request.getAttribute("error") != null) { %>
        showToast('<%= request.getAttribute("error").toString().replace("'", "\\'") %>', 'error');
    <% } %>
    <% if (request.getParameter("error") != null) { %>
        showToast('<%= request.getParameter("error").replace("'", "\\'") %>', 'error');
    <% } %>
    <% if ("true".equals(request.getParameter("registered"))) { %>
        showToast('Registration successful! Please log in.', 'success');
    <% } %>
    <% if ("true".equals(request.getParameter("pending"))) { %>
        showToast('Registration successful! Your account is pending admin approval.', 'success');
    <% } %>
</script>

</body>
</html>