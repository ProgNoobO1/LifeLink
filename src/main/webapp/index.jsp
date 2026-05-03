<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // If already logged in, redirect accordingly
    if (session != null && session.getAttribute("currentUser") != null) {
        backend.model.User user = (backend.model.User) session.getAttribute("currentUser");
        if (user.getRole() == backend.model.User.Role.ADMIN) {
            response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
        return;
    }
    // Otherwise forward to the login page
    request.getRequestDispatcher("/views/login.jsp").forward(request, response);
%>
