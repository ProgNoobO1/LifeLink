package com.lifelink.servlet;

import com.lifelink.dao.BloodRequestDAO;
import com.lifelink.model.BloodRequest;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

public class RequestExportServlet extends HttpServlet {

    private final BloodRequestDAO requestDAO = new BloodRequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/views/login.jsp?error=Please login first");
            return;
        }

        User admin = (User) session.getAttribute("currentUser");
        if (admin.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        List<BloodRequest> requests = requestDAO.findAll();

        resp.setContentType("text/csv");
        resp.setHeader("Content-Disposition", "attachment; filename=\"blood_requests.csv\"");

        PrintWriter out = resp.getWriter();
        out.println("Request ID,Requester Name,Email,Blood Group,Units,Date,Status");
        for (BloodRequest r : requests) {
            out.printf("%s,%s,%s,%s,%d,%s,%s%n",
                r.getFormattedRequestId(),
                escapeCsv(r.getRequesterName()),
                escapeCsv(r.getRequesterEmail()),
                r.getBloodGroup(),
                r.getUnits(),
                r.getRequestDate(),
                r.getStatus()
            );
        }
        out.flush();
    }

    private String escapeCsv(String value) {
        if (value == null) return "";
        if (value.contains(",") || value.contains("\"") || value.contains("\n")) {
            return "\"" + value.replace("\"", "\"\"") + "\"";
        }
        return value;
    }
}
