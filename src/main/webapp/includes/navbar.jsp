<%--
  Created by IntelliJ IDEA.
  User: ektarai
  Date: 02/05/2026
  Time: 15:11
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
<style>



    nav {
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

    .nav-brand {
        display: flex;
        align-items: center;
        gap: .55rem;
        text-decoration: none;
    }

    .nav-brand .logo-circle {
        width: 36px; height: 36px;
        background: var(--red);
        border-radius: 50%;
        display: flex; align-items: center; justify-content: center;
    }

    .nav-brand .logo-circle svg { width: 18px; height: 18px; fill: white; }

    .nav-brand span {
        font-family: 'DM Sans', sans-serif;
        font-weight: 700;
        font-size: 1.2rem;
        color: white;
        letter-spacing: -.01em;
    }

    nav ul {
        list-style: none;
        display: flex;
        gap: 2rem;
    }

    nav ul li a {
        color: #d1d5db;
        text-decoration: none;
        font-size: .9rem;
        font-weight: 500;
        transition: color .2s;
    }

    nav ul li a:hover { color: white; }

    /* ── STEP 4: Main Hero / Layout ── */
    main {
        flex: 1;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 3rem 2rem;
        background: linear-gradient(135deg, #fafafa 0%, #f0f0f0 100%);
    }

    .container {
        width: 100%;
        max-width: 1100px;
        display: grid;
        grid-template-columns: 1fr 420px;
        gap: 4rem;
        align-items: center;
    }

</style>
    <nav>
        <a href="#" class="nav-brand">
            <div class="logo-circle">
                <svg viewBox="0 0 24 24">
                    <path d="M12 2C12 2 4 10 4 15a8 8 0 0016 0C20 10 12 2 12 2z"/>
                </svg>
            </div>
            <span>LifeLink</span>
        </a>

        <ul>
            <li><a href="index.jsp">Home</a></li>
            <li><a href="#">About</a></li>
            <li><a href="#">Contact</a></li>
        </ul>
    </nav>

</head>
<body>

</body>
</html>
