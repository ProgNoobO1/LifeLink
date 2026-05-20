<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<style>
    .site-navbar {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 0 2.5rem;
        height: 64px;
        background: #1a1a1a;
        position: sticky;
        top: 0;
        z-index: 100;
    }
    .site-navbar .nav-brand {
        display: flex;
        align-items: center;
        gap: .55rem;
        text-decoration: none;
    }
    .site-navbar .nav-brand .logo-circle {
        width: 36px; height: 36px;
        background: #b91c1c;
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
    }
    .site-navbar .nav-brand .logo-circle svg { width: 18px; height: 18px; fill: white; }
    .site-navbar .nav-brand span {
        font-family: 'DM Sans', sans-serif;
        font-weight: 700;
        font-size: 1.2rem;
        color: white;
        letter-spacing: -.01em;
    }
    .site-navbar ul {
        list-style: none;
        display: flex;
        gap: 2rem;
    }
    .site-navbar ul li a {
        color: #d1d5db;
        text-decoration: none;
        font-size: .9rem;
        font-weight: 500;
        transition: color .2s;
    }
    .site-navbar ul li a:hover { color: white; }

    .nav-hamburger {
        display: none;
        background: none;
        border: none;
        cursor: pointer;
        color: white;
        padding: .25rem;
    }
    .nav-hamburger svg { width: 24px; height: 24px; }

    @media (max-width: 768px) {
        .site-navbar { padding: 0 1rem; }
        .site-navbar ul {
            display: none;
            position: absolute;
            top: 64px;
            left: 0; right: 0;
            background: #1a1a1a;
            flex-direction: column;
            padding: 1rem 1.5rem;
            gap: 1rem;
            border-top: 1px solid rgba(255,255,255,.1);
        }
        .site-navbar ul.show { display: flex; }
        .nav-hamburger { display: block; }
    }
</style>
<nav class="site-navbar">
    <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
        <div class="logo-circle">
            <svg viewBox="0 0 24 24">
                <path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/>
            </svg>
        </div>
        <span>LifeLink</span>
    </a>
    <button type="button" class="nav-hamburger" onclick="document.querySelector('.site-navbar ul').classList.toggle('show')">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="21" y2="12"/><line x1="3" y1="18" x2="21" y2="18"/></svg>
    </button>
    <ul>
    </ul>
</nav>
