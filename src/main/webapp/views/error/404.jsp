<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="false" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 — Page Not Found | LifeLink</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/hospital.css">
</head>
<body>
<div class="auth-page">
    <div class="auth-card fade-in" style="text-align:center;max-width:480px">
        <div style="font-size:72px;margin-bottom:16px;opacity:0.6">🔍</div>
        <h1 style="font-size:64px;font-weight:800;color:var(--accent);margin-bottom:8px">404</h1>
        <h2 style="font-size:20px;font-weight:600;margin-bottom:12px">Page Not Found</h2>
        <p style="color:var(--text-muted);font-size:15px;margin-bottom:28px;line-height:1.6">
            The page you're looking for doesn't exist or has been moved.
            Let's get you back on track.
        </p>
        <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap">
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">🏠 Go Home</a>
            <a href="${pageContext.request.contextPath}/login" class="btn btn-secondary">🔐 Sign In</a>
        </div>
    </div>
</div>
</body>
</html>
