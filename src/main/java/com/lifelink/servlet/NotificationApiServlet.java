package com.lifelink.servlet;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;
import com.lifelink.model.Notification;
import com.lifelink.model.User;
import com.lifelink.service.NotificationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class NotificationApiServlet extends HttpServlet {

    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
    private final Gson gson = new GsonBuilder()
        .registerTypeAdapter(LocalDateTime.class, new TypeAdapter<LocalDateTime>() {
            @Override
            public void write(com.google.gson.stream.JsonWriter out, LocalDateTime value) throws IOException {
                out.value(value != null ? value.format(DATE_FORMAT) : null);
            }
            @Override
            public LocalDateTime read(com.google.gson.stream.JsonReader in) throws IOException {
                String s = in.nextString();
                return s != null ? LocalDateTime.parse(s, DATE_FORMAT) : null;
            }
        })
        .create();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Login required");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String action = req.getParameter("action");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        if ("unread".equals(action)) {
            List<Notification> unread = NotificationService.getInstance().getUnreadNotifications();
            long count = NotificationService.getInstance().getUnreadCount();
            Map<String, Object> result = new HashMap<>();
            result.put("count", count);
            result.put("notifications", unread);
            resp.getWriter().write(gson.toJson(result));
        } else if ("count".equals(action)) {
            long count = NotificationService.getInstance().getUnreadCount();
            Map<String, Object> result = new HashMap<>();
            result.put("count", count);
            resp.getWriter().write(gson.toJson(result));
        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Login required");
            return;
        }

        User user = (User) session.getAttribute("currentUser");
        if (user.getRole() != User.Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin access required");
            return;
        }

        String action = req.getParameter("action");
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        if ("markAllRead".equals(action)) {
            boolean ok = NotificationService.getInstance().markAllRead();
            Map<String, Object> result = new HashMap<>();
            result.put("success", ok);
            resp.getWriter().write(gson.toJson(result));
        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
        }
    }
}
