<%@ page import="com.lifelink.model.User" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>   
<%
    User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

    if (currentUser != null && currentUser.getRole() != null) {
        String contextPath = request.getContextPath();

        if (currentUser.getRole() == User.Role.ADMIN) {
            response.sendRedirect(contextPath + "/admin/dashboard");
        } else if (currentUser.getRole() == User.Role.RECIPIENT) {
            response.sendRedirect(contextPath + "/recipient/dashboard");
        } else if (currentUser.getRole() == User.Role.DONOR) {
            response.sendRedirect(contextPath + "/donor/dashboard");
        } else {
            request.getRequestDispatcher("/views/Home.jsp").forward(request, response);
        }
        return;
    }
%>
<jsp:forward page="/views/Home.jsp" />
