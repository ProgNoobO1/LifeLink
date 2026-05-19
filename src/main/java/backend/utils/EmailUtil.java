package backend.utils;

import jakarta.mail.*;
import jakarta.mail.internet.*;

import java.util.Properties;

/**
 * Email notification utility.
 * Sends HTML emails via SMTP (Gmail).
 * Update SMTP_USER and SMTP_PASS with your Gmail + App Password.
 */
public class EmailUtil {

    private static final String SMTP_HOST = "smtp.gmail.com";
    private static final int    SMTP_PORT = 587;
    private static final String SMTP_USER = "your.email@gmail.com";   // ← UPDATE
    private static final String SMTP_PASS = "your_app_password";       // ← UPDATE (Gmail App Password)

    private static Session buildSession() {
        Properties props = new Properties();
        props.put("mail.smtp.host",            SMTP_HOST);
        props.put("mail.smtp.port",            String.valueOf(SMTP_PORT));
        props.put("mail.smtp.auth",            "true");
        props.put("mail.smtp.starttls.enable", "true");

        return Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_USER, SMTP_PASS);
            }
        });
    }

    /**
     * Send an HTML email. Returns true on success.
     */
    public static boolean sendHtml(String toEmail, String subject, String htmlBody) {
        try {
            Session session = buildSession();
            Message msg = new MimeMessage(session);
            msg.setFrom(new InternetAddress(SMTP_USER, "LifeLink System"));
            msg.setRecipient(Message.RecipientType.TO, new InternetAddress(toEmail));
            msg.setSubject(subject);
            msg.setContent(htmlBody, "text/html; charset=utf-8");
            Transport.send(msg);
            return true;
        } catch (Exception e) {
            System.err.println("[EmailUtil] Failed to send email to " + toEmail + ": " + e.getMessage());
            return false;
        }
    }

    // ─── Pre-built email templates ───────────────────────────────────────────

    public static void sendWelcome(String toEmail, String fullName) {
        String subject = "Welcome to LifeLink – Registration Received";
        String body = "<div style='font-family:Inter,sans-serif;background:#0B1120;color:#fff;padding:32px;border-radius:12px'>"
            + "<h2 style='color:#DC2626'>🩸 LifeLink Blood Donation System</h2>"
            + "<p>Hi <strong>" + fullName + "</strong>,</p>"
            + "<p>Thank you for registering with LifeLink. Your account is <strong>pending admin approval</strong>.</p>"
            + "<p>You will receive another email once your account is activated.</p>"
            + "<p style='color:#DC2626;margin-top:24px'>Save lives. Donate blood.</p>"
            + "</div>";
        sendHtml(toEmail, subject, body);
    }

    public static void sendApprovalNotification(String toEmail, String fullName) {
        String subject = "LifeLink – Your Account Has Been Approved!";
        String body = "<div style='font-family:Inter,sans-serif;background:#0B1120;color:#fff;padding:32px;border-radius:12px'>"
            + "<h2 style='color:#DC2626'>🩸 LifeLink – Account Approved</h2>"
            + "<p>Hi <strong>" + fullName + "</strong>,</p>"
            + "<p>Great news! Your LifeLink account has been <strong style='color:#22C55E'>approved</strong>.</p>"
            + "<p>You can now <a href='http://localhost:8080/lifelink/login' style='color:#DC2626'>log in</a> and start using the system.</p>"
            + "</div>";
        sendHtml(toEmail, subject, body);
    }

    public static void sendRequestNotification(String toEmail, String recipientName,
                                                String bloodGroup, int units) {
        String subject = "LifeLink – New Blood Request Received";
        String body = "<div style='font-family:Inter,sans-serif;background:#0B1120;color:#fff;padding:32px;border-radius:12px'>"
            + "<h2 style='color:#DC2626'>🚨 Urgent Blood Request</h2>"
            + "<p>Hi <strong>" + recipientName + "</strong>,</p>"
            + "<p>A new blood request has been submitted:</p>"
            + "<ul><li>Blood Group: <strong>" + bloodGroup + "</strong></li>"
            + "<li>Units Needed: <strong>" + units + "</strong></li></ul>"
            + "<p>Please log in to respond.</p>"
            + "</div>";
        sendHtml(toEmail, subject, body);
    }

    public static void sendRequestStatusUpdate(String toEmail, String fullName,
                                                String bloodGroup, String newStatus) {
        String subject = "LifeLink – Blood Request Status: " + newStatus.toUpperCase();
        String color = "accepted".equals(newStatus) ? "#22C55E" : "#DC2626";
        String body = "<div style='font-family:Inter,sans-serif;background:#0B1120;color:#fff;padding:32px;border-radius:12px'>"
            + "<h2 style='color:#DC2626'>🩸 LifeLink – Request Update</h2>"
            + "<p>Hi <strong>" + fullName + "</strong>,</p>"
            + "<p>Your blood request for <strong>" + bloodGroup + "</strong> has been "
            + "<strong style='color:" + color + "'>" + newStatus.toUpperCase() + "</strong>.</p>"
            + "<p>Log in to view full details.</p>"
            + "</div>";
        sendHtml(toEmail, subject, body);
    }
}
