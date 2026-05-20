package com.lifelink.service;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.TypeAdapter;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;
import com.lifelink.dao.NotificationDAO;
import com.lifelink.model.Notification;

import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.TimeUnit;

public class NotificationService {

    private static final NotificationService INSTANCE = new NotificationService();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private static final DateTimeFormatter DATE_FORMAT = DateTimeFormatter.ISO_LOCAL_DATE_TIME;
    private final Gson gson = new GsonBuilder()
        .registerTypeAdapter(LocalDateTime.class, new TypeAdapter<LocalDateTime>() {
            @Override
            public void write(JsonWriter out, LocalDateTime value) throws IOException {
                out.value(value != null ? value.format(DATE_FORMAT) : null);
            }
            @Override
            public LocalDateTime read(JsonReader in) throws IOException {
                String s = in.nextString();
                return s != null ? LocalDateTime.parse(s, DATE_FORMAT) : null;
            }
        })
        .create();
    private final List<BlockingQueue<String>> clients = new CopyOnWriteArrayList<>();

    private NotificationService() {}

    public static NotificationService getInstance() {
        return INSTANCE;
    }

    public BlockingQueue<String> subscribe() {
        BlockingQueue<String> queue = new LinkedBlockingQueue<>();
        clients.add(queue);
        return queue;
    }

    public void unsubscribe(BlockingQueue<String> queue) {
        clients.remove(queue);
    }

    public void broadcast(Notification notification) {
        // Persist to database
        notificationDAO.save(notification);

        // Broadcast to all connected SSE clients
        String json = gson.toJson(notification);
        for (BlockingQueue<String> queue : clients) {
            queue.offer(json);
        }
    }

    public List<Notification> getUnreadNotifications() {
        return notificationDAO.findUnread();
    }

    public long getUnreadCount() {
        return notificationDAO.countUnread();
    }

    public boolean markAllRead() {
        return notificationDAO.markAllRead();
    }

    public void streamEvents(PrintWriter out) {
        BlockingQueue<String> queue = subscribe();
        try {
            while (!out.checkError()) {
                String event = queue.poll(25, TimeUnit.SECONDS);
                if (event != null) {
                    out.write("data: " + event + "\n\n");
                    out.flush();
                } else {
                    // Heartbeat to keep connection alive
                    out.write(":hb\n\n");
                    out.flush();
                }
            }
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        } finally {
            unsubscribe(queue);
        }
    }
}
