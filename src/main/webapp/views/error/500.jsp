<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>500 — Server Error | LifeLink</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/hospital.css">
</head>
<body>
<div class="auth-page">
    <div class="auth-card fade-in" style="text-align:center;max-width:480px">
        <div style="font-size:72px;margin-bottom:16px;opacity:0.6">⚠️</div>
        <h1 style="font-size:64px;font-weight:800;color:var(--accent);margin-bottom:8px">500</h1>
        <h2 style="font-size:20px;font-weight:600;margin-bottom:12px">Internal Server Error</h2>
        <p style="color:var(--text-muted);font-size:15px;margin-bottom:28px;line-height:1.6">
            Something went wrong on our end. Please try again later
            or contact the administrator if the problem persists.
        </p>
        <% 
           if (exception != null) {
        %>
            <pre style="text-align:left; background: #111b27; color: #ff6b6b; border: 1px solid var(--border); padding: 16px; margin-bottom: 20px; overflow: auto; max-height: 250px; font-size: 11px; font-family: monospace; border-radius: 6px; white-space: pre-wrap; word-break: break-all;">
<%
               java.io.StringWriter sw = new java.io.StringWriter();
               java.io.PrintWriter pw = new java.io.PrintWriter(sw);
               exception.printStackTrace(pw);
               out.print(sw.toString());
%>
            </pre>
        <%
           }
        %>
        <div style="display:flex;gap:12px;justify-content:center;flex-wrap:wrap">
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">🏠 Go Home</a>
            <a href="javascript:location.reload()" class="btn btn-secondary">🔄 Retry</a>
        </div>
    </div>
</div>
</body>
</html>
