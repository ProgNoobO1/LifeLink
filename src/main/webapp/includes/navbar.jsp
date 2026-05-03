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
    <ul>
        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
        <li><a href="#">About</a></li>
        <li><a href="#">Contact</a></li>
    </ul>
</nav>
