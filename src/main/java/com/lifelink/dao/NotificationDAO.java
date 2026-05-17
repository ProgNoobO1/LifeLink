package com.lifelink.dao;

import com.lifelink.model.Notification;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

/**
 * In-memory notification store.
 * The user's schema does not include a {@code notifications} table;
 * only {@code email_notifications} exists.  This DAO keeps recent
 * in-app notifications in memory for the SSE feed and unread counts.
 */
public class NotificationDAO {

    private static final List<Notification> STORE = new CopyOnWriteArrayList<>();
    private static final int MAX_SIZE = 200;

    public boolean save(Notification notification) {
        STORE.add(0, notification);
        if (STORE.size() > MAX_SIZE) {
            STORE.remove(STORE.size() - 1);
        }
        return true;
    }

    public List<Notification> findUnread() {
        List<Notification> unread = new ArrayList<>();
        for (Notification n : STORE) {
            if (!n.isRead()) {
                unread.add(n);
            }
        }
        return unread;
    }

    public long countUnread() {
        int count = 0;
        for (Notification n : STORE) {
            if (!n.isRead()) {
                count++;
            }
        }
        return count;
    }

    public boolean markRead(Long id) {
        for (Notification n : STORE) {
            if (n.getId() != null && n.getId().equals(id)) {
                n.setRead(true);
                return true;
            }
        }
        return false;
    }

    public boolean markAllRead() {
        for (Notification n : STORE) {
            n.setRead(true);
        }
        return true;
    }

    public List<Notification> findAll() {
        return new ArrayList<>(STORE);
    }
}
