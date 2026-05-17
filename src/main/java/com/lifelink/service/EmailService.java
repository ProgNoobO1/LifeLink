package com.lifelink.service;

import com.lifelink.dao.EmailNotificationDAO;
import com.lifelink.model.EmailNotification;
import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.io.IOException;
import java.io.InputStream;
import java.time.LocalDateTime;
import java.util.Properties;

public class EmailService {

    private static final Properties config = new Properties();
    private static final EmailNotificationDAO emailLogDAO = new EmailNotificationDAO();

    static {
        try (InputStream is = EmailService.class.getClassLoader().getResourceAsStream("email.properties")) {
            if (is != null) {
                config.load(is);
            } else {
                System.err.println("⚠️ email.properties not found. Email notifications will be logged only.");
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void sendEmail(String toEmail, String subject, String body) {
        String host = config.getProperty("smtp.host", "");
        String port = config.getProperty("smtp.port", "587");
        String auth = config.getProperty("smtp.auth", "false");
        String starttls = config.getProperty("smtp.starttls", "false");
        String from = config.getProperty("mail.from", "");
        String password = config.getProperty("mail.password", "");
        String fromName = config.getProperty("mail.from.name", "LifeLink");

        boolean hasSmtp = !host.isEmpty() && !from.isEmpty() && !password.isEmpty();

        // Log to database regardless
        logEmail(toEmail, subject, body, hasSmtp ? "queued" : "failed");

        if (!hasSmtp) {
            System.out.println("[EMAIL] No SMTP configured. Would send to: " + toEmail);
            System.out.println("[EMAIL] Subject: " + subject);
            return;
        }

        Properties props = new Properties();
        props.put("mail.smtp.host", host);
        props.put("mail.smtp.port", port);
        props.put("mail.smtp.auth", auth);
        props.put("mail.smtp.starttls.enable", starttls);

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(from, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from, fromName));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject(subject);
            message.setContent(body, "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("✅ Email sent to " + toEmail);

            // Update log to sent
            logEmail(toEmail, subject, body, "sent");
        } catch (Exception e) {
            System.err.println("❌ Failed to send email to " + toEmail + ": " + e.getMessage());
            logEmail(toEmail, subject, body, "failed");
        }
    }

    private static void logEmail(String toEmail, String subject, String body, String status) {
        try {
            // Find user id by email for FK
            com.lifelink.dao.UserDAO userDAO = new com.lifelink.dao.UserDAO();
            com.lifelink.model.User user = userDAO.findByEmail(toEmail);
            Integer userId = user != null ? user.getId().intValue() : null;

            EmailNotification log = new EmailNotification();
            log.setUserId(userId);
            log.setSubject(subject);
            log.setBody(body);
            log.setStatus(status);
            log.setCreatedAt(LocalDateTime.now());
            emailLogDAO.save(log);
        } catch (Exception e) {
            // Don't let logging failure break email flow
            e.printStackTrace();
        }
    }

    public static String buildHtmlBody(String title, String message, String actionLink, String actionText) {
        StringBuilder sb = new StringBuilder();
        sb.append("<html><body style='font-family:Arial,sans-serif;color:#333;'>");
        sb.append("<div style='max-width:600px;margin:0 auto;padding:20px;border:1px solid #e5e7eb;border-radius:8px;'>");
        sb.append("<h2 style='color:#b91c1c;'>").append(escapeHtml(title)).append("</h2>");
        sb.append("<p>").append(escapeHtml(message)).append("</p>");
        if (actionLink != null && !actionLink.isEmpty()) {
            sb.append("<a href='").append(actionLink).append("' style='display:inline-block;padding:10px 20px;background:#b91c1c;color:#fff;text-decoration:none;border-radius:4px;'>");
            sb.append(actionText != null ? actionText : "View").append("</a>");
        }
        sb.append("<hr style='margin-top:20px;border:none;border-top:1px solid #e5e7eb;'>");
        sb.append("<p style='font-size:12px;color:#6b7280;'>LifeLink Blood Management System</p>");
        sb.append("</div></body></html>");
        return sb.toString();
    }

    private static String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;")
                   .replace("<", "&lt;")
                   .replace(">", "&gt;")
                   .replace("\"", "&quot;");
    }
}
