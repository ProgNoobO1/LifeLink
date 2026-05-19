<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>LifeLink – About Us</title>
  <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@700;900&family=DM+Sans:wght@300;400;500;600&display=swap" rel="stylesheet"/>
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }

    :root {
      --red:        #C0201F;
      --red-dark:   #8B1010;
      --red-light:  #F9E8E8;
      --red-mid:    #D94040;
      --white:      #FFFFFF;
      --off-white:  #F7F5F3;
      --dark:       #1A1A2E;
      --dark2:      #232336;
      --muted:      #6B7280;
      --border:     #E5E0DC;
      --font-head:  'Playfair Display', serif;
      --font-body:  'DM Sans', sans-serif;
    }

    html { scroll-behavior: smooth; }
    body {
      font-family: var(--font-body);
      background: var(--white);
      color: var(--dark);
      overflow-x: hidden;
    }

    /* ── NAVBAR ── */
    nav {
      position: fixed; top: 0; left: 0; right: 0; z-index: 100;
      display: flex; align-items: center; justify-content: space-between;
      padding: 0 6vw; height: 68px;
      background: rgba(255,255,255,0.92);
      backdrop-filter: blur(14px);
      border-bottom: 1px solid var(--border);
    }
    .nav-logo {
      display: flex; align-items: center; gap: 10px;
      font-family: var(--font-head); font-size: 1.35rem; color: var(--dark);
      text-decoration: none;
    }
    .nav-logo .dot {
      width: 30px; height: 30px; border-radius: 50%;
      background: var(--red);
      display: flex; align-items: center; justify-content: center;
    }
    .nav-logo .dot svg { width: 16px; height: 16px; fill: white; }
    .nav-links { display: flex; gap: 36px; list-style: none; }
    .nav-links a {
      font-size: .9rem; font-weight: 500; color: var(--muted);
      text-decoration: none; letter-spacing: .02em; transition: color .2s;
    }
    .nav-links a:hover, .nav-links a.active { color: var(--dark); }
    .nav-links a.active { border-bottom: 2px solid var(--red); padding-bottom: 2px; }
    .nav-btn {
      background: var(--red); color: white; border: none; border-radius: 8px;
      padding: 10px 24px; font-size: .88rem; font-weight: 600;
      cursor: pointer; transition: background .2s; text-decoration: none;
    }
    .nav-btn:hover { background: var(--red-dark); }

    /* ── HERO ── */
    .hero {
      margin-top: 68px;
      background: linear-gradient(135deg, var(--red) 0%, #7A0D0D 100%);
      position: relative; overflow: hidden;
      padding: 100px 6vw 90px; text-align: center; color: white;
    }
    .hero::before {
      content: ''; position: absolute; top: -80px; right: -80px;
      width: 420px; height: 420px; border-radius: 50%;
      background: rgba(255,255,255,.06); pointer-events: none;
    }
    .hero::after {
      content: ''; position: absolute; bottom: -100px; left: -60px;
      width: 340px; height: 340px; border-radius: 50%;
      background: rgba(255,255,255,.05); pointer-events: none;
    }
    .hero-badge {
      display: inline-flex; align-items: center; gap: 8px;
      background: rgba(255,255,255,.15); border: 1px solid rgba(255,255,255,.25);
      border-radius: 99px; padding: 7px 18px;
      font-size: .82rem; font-weight: 500; letter-spacing: .04em;
      margin-bottom: 28px; animation: fadeUp .7s ease both;
    }
    .hero-badge svg { width: 14px; height: 14px; fill: white; }
    .hero h1 {
      font-family: var(--font-head);
      font-size: clamp(2.6rem, 6vw, 4.2rem);
      font-weight: 900; line-height: 1.1; margin-bottom: 22px;
      animation: fadeUp .7s .1s ease both;
    }
    .hero p {
      max-width: 540px; margin: 0 auto 52px;
      font-size: 1.05rem; line-height: 1.7;
      color: rgba(255,255,255,.82); animation: fadeUp .7s .2s ease both;
    }
    .hero-stats {
      display: flex; justify-content: center; flex-wrap: wrap;
      animation: fadeUp .7s .3s ease both;
    }
    .hero-stat { padding: 0 40px; border-right: 1px solid rgba(255,255,255,.2); }
    .hero-stat:last-child { border-right: none; }
    .hero-stat .num {
      font-family: var(--font-head); font-size: 2.4rem; font-weight: 900; display: block;
    }
    .hero-stat .label { font-size: .82rem; color: rgba(255,255,255,.7); letter-spacing: .04em; margin-top: 4px; }

    /* ── SECTIONS ── */
    section { padding: 100px 6vw; }
    .section-kicker {
      font-size: .78rem; font-weight: 600; letter-spacing: .12em;
      color: var(--red); text-transform: uppercase; margin-bottom: 12px;
    }
    .section-title {
      font-family: var(--font-head); font-size: clamp(1.9rem, 3.5vw, 2.7rem);
      font-weight: 700; line-height: 1.2; margin-bottom: 14px;
    }
    .section-sub { font-size: .98rem; color: var(--muted); max-width: 480px; line-height: 1.65; }
    .center { text-align: center; }
    .center .section-sub { margin: 0 auto; }

    /* ── MISSION CARDS ── */
    .mission-grid {
      display: grid; grid-template-columns: repeat(3, 1fr);
      gap: 24px; margin-top: 56px;
    }
    .mission-card {
      background: var(--white); border: 1.5px solid var(--border);
      border-radius: 20px; padding: 40px 32px; text-align: center;
      transition: transform .25s, box-shadow .25s;
    }
    .mission-card:hover { transform: translateY(-6px); box-shadow: 0 20px 48px rgba(192,32,31,.12); }
    .mission-card.featured { background: var(--red); border-color: var(--red); color: white; }
    .mission-card .icon-wrap {
      width: 64px; height: 64px; border-radius: 16px; background: var(--red-light);
      display: flex; align-items: center; justify-content: center; margin: 0 auto 24px;
    }
    .mission-card.featured .icon-wrap { background: rgba(255,255,255,.2); }
    .mission-card .icon-wrap svg { width: 28px; height: 28px; fill: var(--red); }
    .mission-card.featured .icon-wrap svg { fill: white; }
    .mission-card h3 { font-family: var(--font-head); font-size: 1.3rem; font-weight: 700; margin-bottom: 12px; }
    .mission-card p { font-size: .92rem; line-height: 1.65; color: var(--muted); }
    .mission-card.featured p { color: rgba(255,255,255,.8); }

    /* ── HOW IT WORKS ── */
    .how-section { background: var(--off-white); }
    .steps {
      display: grid; grid-template-columns: repeat(4, 1fr);
      gap: 32px; margin-top: 60px; position: relative;
    }
    .steps::before {
      content: ''; position: absolute; top: 28px; left: 10%; right: 10%; height: 2px;
      background: repeating-linear-gradient(90deg, var(--border) 0px, var(--border) 8px, transparent 8px, transparent 16px);
    }
    .step { text-align: center; position: relative; z-index: 1; }
    .step-num {
      width: 56px; height: 56px; border-radius: 50%;
      background: var(--red); color: white;
      font-family: var(--font-head); font-size: 1.3rem; font-weight: 700;
      display: flex; align-items: center; justify-content: center;
      margin: 0 auto 20px; box-shadow: 0 4px 20px rgba(192,32,31,.35);
    }
    .step-icon {
      width: 48px; height: 48px; background: var(--red-light); border-radius: 12px;
      display: flex; align-items: center; justify-content: center; margin: 0 auto 16px;
    }
    .step-icon svg { width: 24px; height: 24px; fill: var(--red); }
    .step h4 { font-family: var(--font-head); font-size: 1.05rem; font-weight: 700; margin-bottom: 8px; }
    .step p { font-size: .88rem; color: var(--muted); line-height: 1.6; }

    /* ── CTA BANNER ── */
    .cta-banner {
      background: var(--red-light); border-radius: 20px; padding: 52px 48px;
      display: flex; align-items: center; justify-content: space-between;
      gap: 32px; flex-wrap: wrap; margin: 0 6vw 100px;
    }
    .cta-banner h2 { font-family: var(--font-head); font-size: 1.7rem; font-weight: 700; margin-bottom: 8px; }
    .cta-banner p { font-size: .95rem; color: var(--muted); }
    .cta-btn {
      background: var(--red); color: white; border: none; border-radius: 12px;
      padding: 16px 32px; font-size: .95rem; font-weight: 600;
      cursor: pointer; white-space: nowrap; display: flex; align-items: center; gap: 10px;
      transition: background .2s, transform .15s; text-decoration: none;
    }
    .cta-btn:hover { background: var(--red-dark); transform: translateX(4px); }

    /* ── FOOTER ── */
    footer { background: var(--dark2); color: rgba(255,255,255,.7); padding: 64px 6vw 32px; }
    .footer-grid {
      display: grid; grid-template-columns: 1.8fr 1fr 1fr 1fr;
      gap: 40px; margin-bottom: 48px;
    }
    .footer-brand .nav-logo { color: white; margin-bottom: 14px; display: inline-flex; }
    .footer-brand p { font-size: .88rem; line-height: 1.65; max-width: 240px; }
    .footer-social { display: flex; gap: 12px; margin-top: 20px; }
    .footer-social a {
      width: 34px; height: 34px; border-radius: 8px; background: rgba(255,255,255,.1);
      display: flex; align-items: center; justify-content: center; transition: background .2s;
    }
    .footer-social a:hover { background: var(--red); }
    .footer-social svg { width: 15px; height: 15px; fill: rgba(255,255,255,.8); }
    .footer-col h5 {
      font-size: .82rem; font-weight: 700; letter-spacing: .08em; color: white;
      text-transform: uppercase; margin-bottom: 18px;
    }
    .footer-col ul { list-style: none; }
    .footer-col li { margin-bottom: 10px; }
    .footer-col a { font-size: .88rem; color: rgba(255,255,255,.6); text-decoration: none; transition: color .2s; }
    .footer-col a:hover { color: white; }
    .footer-contact-item {
      display: flex; align-items: flex-start; gap: 10px;
      margin-bottom: 10px; font-size: .88rem;
    }
    .footer-contact-item svg { width: 15px; height: 15px; fill: var(--red-mid); flex-shrink: 0; margin-top: 2px; }
    .footer-bottom {
      border-top: 1px solid rgba(255,255,255,.08); padding-top: 24px;
      display: flex; justify-content: space-between; align-items: center;
      flex-wrap: wrap; gap: 12px; font-size: .82rem; color: rgba(255,255,255,.35);
    }
    .footer-bottom .hearts { color: var(--red-mid); }

    /* ── ANIMATIONS ── */
    @keyframes fadeUp {
      from { opacity: 0; transform: translateY(20px); }
      to   { opacity: 1; transform: translateY(0); }
    }
    .reveal { opacity: 0; transform: translateY(28px); transition: opacity .65s ease, transform .65s ease; }
    .reveal.visible { opacity: 1; transform: none; }

    /* ── RESPONSIVE ── */
    @media (max-width: 900px) {
      .mission-grid { grid-template-columns: 1fr; }
      .steps { grid-template-columns: 1fr 1fr; }
      .steps::before { display: none; }
      .footer-grid { grid-template-columns: 1fr 1fr; }
    }
    @media (max-width: 600px) {
      .nav-links { display: none; }
      .hero { padding: 70px 5vw 60px; }
      .hero-stat { padding: 0 20px; }
      .steps { grid-template-columns: 1fr; }
      .cta-banner { flex-direction: column; }
      .footer-grid { grid-template-columns: 1fr; }
    }
  </style>
</head>
<body>

<!-- ── NAVBAR ── -->
<nav>
  <a class="nav-logo" href="${pageContext.request.contextPath}/index.jsp">
    <span class="dot">
      <svg viewBox="0 0 24 24"><path d="M12 21.593c-5.63-5.539-11-10.297-11-14.402 0-3.791 3.068-5.191 5.281-5.191 1.312 0 4.151.501 5.719 4.457 1.59-3.968 4.464-4.447 5.726-4.447 2.54 0 5.274 1.621 5.274 5.181 0 4.069-5.136 8.625-11 14.402z"/></svg>
    </span>
    LifeLink
  </a>
  <ul class="nav-links">
    <li><a href="${pageContext.request.contextPath}/views/Home.jsp">Home</a></li>
    <li><a href="${pageContext.request.contextPath}/views/aboutus.jsp" class="active">About</a></li>
    <li><a href="#">Contact</a></li>
  </ul>
  <a class="nav-btn" href="${pageContext.request.contextPath}/views/login.jsp">Login</a>
</nav>

<!-- ── HERO ── -->
<section class="hero">
  <div class="hero-badge">
    <svg viewBox="0 0 24 24"><path d="M12 21.593c-5.63-5.539-11-10.297-11-14.402 0-3.791 3.068-5.191 5.281-5.191 1.312 0 4.151.501 5.719 4.457 1.59-3.968 4.464-4.447 5.726-4.447 2.54 0 5.274 1.621 5.274 5.181 0 4.069-5.136 8.625-11 14.402z"/></svg>
    Our Mission
  </div>
  <h1>Saving Lives Together</h1>
  <p>LifeLink bridges the gap between blood donors and those in critical need — making every donation count, every moment matter.</p>
  <div class="hero-stats">
    <div class="hero-stat"><span class="num">10k+</span><span class="label">Donors</span></div>
    <div class="hero-stat"><span class="num">25k+</span><span class="label">Lives Saved</span></div>
    <div class="hero-stat"><span class="num">50+</span><span class="label">Hospitals</span></div>
    <div class="hero-stat"><span class="num">30+</span><span class="label">Cities</span></div>
  </div>
</section>

<!-- ── MISSION ── -->
<section>
  <div class="center reveal">
    <p class="section-kicker">What We Do</p>
    <h2 class="section-title">Our Mission</h2>
    <p class="section-sub">Three simple goals that drive everything we do at LifeLink.</p>
  </div>
  <div class="mission-grid">
    <div class="mission-card reveal">
      <div class="icon-wrap">
        <svg viewBox="0 0 24 24" fill="none" stroke="var(--red)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:28px;height:28px">
          <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71"/>
          <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71"/>
        </svg>
      </div>
      <h3>Connect</h3>
      <p>We instantly connect donors with patients and hospitals that need blood the most.</p>
    </div>
    <div class="mission-card featured reveal">
      <div class="icon-wrap">
        <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
      </div>
      <h3>Donate</h3>
      <p>Making blood donation simple, safe, and rewarding for every willing hero.</p>
    </div>
    <div class="mission-card reveal">
      <div class="icon-wrap">
        <svg viewBox="0 0 24 24"><path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 0 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/></svg>
      </div>
      <h3>Save</h3>
      <p>Every unit of blood donated through LifeLink helps save a precious life in need.</p>
    </div>
  </div>
</section>

<!-- ── HOW IT WORKS ── -->
<section class="how-section">
  <div class="center reveal">
    <p class="section-kicker">Simple Process</p>
    <h2 class="section-title">How It Works</h2>
    <p class="section-sub">Get started in four easy steps and make a difference today.</p>
  </div>
  <div class="steps">
    <div class="step reveal">
      <div class="step-num">1</div>
      <div class="step-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="var(--red)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:24px;height:24px">
          <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>
        </svg>
      </div>
      <h4>Sign Up</h4>
      <p>Create your free LifeLink account in under a minute.</p>
    </div>
    <div class="step reveal">
      <div class="step-num">2</div>
      <div class="step-icon">
        <svg viewBox="0 0 24 24"><path d="M12 21.593c-5.63-5.539-11-10.297-11-14.402 0-3.791 3.068-5.191 5.281-5.191 1.312 0 4.151.501 5.719 4.457 1.59-3.968 4.464-4.447 5.726-4.447 2.54 0 5.274 1.621 5.274 5.181 0 4.069-5.136 8.625-11 14.402z" fill="var(--red)"/></svg>
      </div>
      <h4>Set Blood Type</h4>
      <p>Tell us your blood type and location details.</p>
    </div>
    <div class="step reveal">
      <div class="step-num">3</div>
      <div class="step-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="var(--red)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:24px;height:24px">
          <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/>
          <path d="M13.73 21a2 2 0 0 1-3.46 0"/>
        </svg>
      </div>
      <h4>Get Matched</h4>
      <p>Receive instant alerts when someone nearby needs your help.</p>
    </div>
    <div class="step reveal">
      <div class="step-num">4</div>
      <div class="step-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="var(--red)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="width:24px;height:24px">
          <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/>
          <polyline points="9 22 9 12 15 12 15 22"/>
        </svg>
      </div>
      <h4>Donate &amp; Save</h4>
      <p>Visit the hospital and save a life with your donation.</p>
    </div>
  </div>
</section>

<!-- ── CTA BANNER ── -->
<div class="cta-banner reveal">
  <div>
    <h2>Ready to make a difference?</h2>
    <p>Join thousands of donors who are saving lives every day.</p>
  </div>
  <a class="cta-btn" href="${pageContext.request.contextPath}/views/Register.jsp">
    Become a Donor
    <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" style="width:18px;height:18px">
      <path d="M5 12h14"/><path d="M12 5l7 7-7 7"/>
    </svg>
  </a>
</div>

<!-- ── FOOTER ── -->
<footer>
  <div class="footer-grid">
    <div class="footer-brand">
      <a class="nav-logo" href="${pageContext.request.contextPath}/index.jsp">
        <span class="dot">
          <svg viewBox="0 0 24 24"><path d="M12 21.593c-5.63-5.539-11-10.297-11-14.402 0-3.791 3.068-5.191 5.281-5.191 1.312 0 4.151.501 5.719 4.457 1.59-3.968 4.464-4.447 5.726-4.447 2.54 0 5.274 1.621 5.274 5.181 0 4.069-5.136 8.625-11 14.402z"/></svg>
        </span>
        LifeLink
      </a>
      <p>Connecting blood donors with those in need.<br/>Every drop saves a life.</p>
      <div class="footer-social">
        <a href="#"><svg viewBox="0 0 24 24"><path d="M18 2h-3a5 5 0 0 0-5 5v3H7v4h3v8h4v-8h3l1-4h-4V7a1 1 0 0 1 1-1h3z"/></svg></a>
        <a href="#"><svg viewBox="0 0 24 24"><path d="M23 3a10.9 10.9 0 0 1-3.14 1.53 4.48 4.48 0 0 0-7.86 3v1A10.66 10.66 0 0 1 3 4s-4 9 5 13a11.64 11.64 0 0 1-7 2c9 5 20 0 20-11.5a4.5 4.5 0 0 0-.08-.83A7.72 7.72 0 0 0 23 3z"/></svg></a>
        <a href="#"><svg viewBox="0 0 24 24"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg></a>
      </div>
    </div>
    <div class="footer-col">
      <h5>Quick Links</h5>
      <ul>
        <li><a href="${pageContext.request.contextPath}/views/Home.jsp">Home</a></li>
        <li><a href="${pageContext.request.contextPath}/views/aboutus.jsp">About</a></li>
        <li><a href="#">Contact</a></li>
        <li><a href="${pageContext.request.contextPath}/views/login.jsp">Login</a></li>
      </ul>
    </div>
    <div class="footer-col">
      <h5>Legal</h5>
      <ul>
        <li><a href="#">Privacy Policy</a></li>
        <li><a href="#">Terms of Service</a></li>
        <li><a href="#">Help Center</a></li>
      </ul>
    </div>
    <div class="footer-col">
      <h5>Contact</h5>
      <div class="footer-contact-item">
        <svg viewBox="0 0 24 24"><path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"/><polyline points="22,6 12,13 2,6"/></svg>
        hello@lifelink.org
      </div>
      <div class="footer-contact-item">
        <svg viewBox="0 0 24 24"><path d="M22 16.92v3a2 2 0 0 1-2.18 2 19.79 19.79 0 0 1-8.63-3.07A19.5 19.5 0 0 1 4.69 12 19.79 19.79 0 0 1 1.63 3.42 2 2 0 0 1 3.6 1.24h3a2 2 0 0 1 2 1.72c.127.96.361 1.903.7 2.81a2 2 0 0 1-.45 2.11L7.91 8.96a16 16 0 0 0 6.13 6.13l.96-.96a2 2 0 0 1 2.11-.45c.907.339 1.85.573 2.81.7A2 2 0 0 1 22 16.92z"/></svg>
        +1 800 LIFELINK
      </div>
      <div class="footer-contact-item">
        <svg viewBox="0 0 24 24"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
        New York, NY 10001
      </div>
    </div>
  </div>
  <div class="footer-bottom">
    <span>&copy; 2026 LifeLink. All rights reserved.</span>
    <span>Made with <span class="hearts">&#9829;</span> to save lives</span>
  </div>
</footer>
<script>
  const reveals = document.querySelectorAll('.reveal');
  const observer = new IntersectionObserver((entries) => {
    entries.forEach((entry, i) => {
      if (entry.isIntersecting) {
        setTimeout(() => entry.target.classList.add('visible'), i * 80);
        observer.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });
  reveals.forEach(el => observer.observe(el));
</script>

</body>
</html>
