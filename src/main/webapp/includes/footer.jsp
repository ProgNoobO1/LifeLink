<%--
  Created by IntelliJ IDEA.
  User: ektarai
  Date: 02/05/2026
  Time: 15:12
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>

<style>
    :root {

        --border:     #e5e7eb;
        --white:      #ffffff;

    }
    footer {
        background: var(--white);
        border-top: 1px solid var(--border);
        padding: 1.1rem 2.5rem;
        display: flex;
        align-items: center;
        justify-content: space-between;
        font-size: .78rem;
        color: var(--text-light);
    }

    footer .footer-links { display: flex; gap: 1.5rem; }

    footer .footer-links a {
        color: var(--text-mid);
        text-decoration: none;
        transition: color .2s;
    }

    footer .footer-links a:hover {
        text-decoration: none;
    }

    /* ── Responsive: Stack on small screens ── */
    @media (max-width: 768px) {
        .container { grid-template-columns: 1fr; gap: 2rem; }
        .hero h1 { font-size: 2rem; }
        nav { padding: 0 1rem; }
    }
</style>


    <footer>
        <span>© 2026 LifeLink. All rights reserved.</span>

        <nav class="footer-links">
            <a href="#">Privacy Policy</a>
            <a href="#">Terms</a>
            <a href="#">Help</a>
        </nav>
    </footer>

</head>
<body>

</body>
</html>
