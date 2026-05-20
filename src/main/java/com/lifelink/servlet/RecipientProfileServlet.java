package com.lifelink.servlet;

import com.lifelink.dao.DistrictDAO;
import com.lifelink.dao.RecipientProfileDAO;
import com.lifelink.dao.UserDAO;
import com.lifelink.model.District;
import com.lifelink.model.Recipient;
import com.lifelink.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.security.SecureRandom;
import java.sql.SQLException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.Base64;
import java.util.List;

@WebServlet(urlPatterns = {"/recipient/edit-details"})
public class RecipientProfileServlet extends HttpServlet {

    private static final int MAX_ADDRESS_LENGTH = 255;
    private final RecipientProfileDAO profileDAO = new RecipientProfileDAO();
    private final DistrictDAO districtDAO = new DistrictDAO();
    private final UserDAO userDAO = new UserDAO();
    private final SecureRandom secureRandom = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = resolveCurrentUser(session);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRole() != User.Role.RECIPIENT) {
            resp.sendRedirect(req.getContextPath() + "/403");
            return;
        }

        try {
            Recipient profile = profileDAO.findByUserId(currentUser.getId());
            forwardForm(req, resp, session, currentUser, profile, null);
        } catch (SQLException e) {
            System.err.println("[RecipientProfileServlet] Unable to load profile: " + e.getMessage());
            req.setAttribute("profileError", "Unable to load your details right now. Please try again shortly.");
            forwardForm(req, resp, session, currentUser, null, null);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User currentUser = resolveCurrentUser(session);
        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        if (currentUser.getRole() != User.Role.RECIPIENT) {
            resp.sendRedirect(req.getContextPath() + "/403");
            return;
        }

        String csrfFromSession = (String) session.getAttribute("recipientProfileCsrfToken");
        String csrfFromRequest = clean(req.getParameter("csrfToken"));
        if (csrfFromSession == null || !csrfFromSession.equals(csrfFromRequest)) {
            forwardForm(req, resp, session, currentUser, formRecipient(req, currentUser, 0), "Your session expired. Please reload the form and try again.");
            return;
        }

        try {
            Recipient existing = profileDAO.findByUserId(currentUser.getId());
            Recipient profile = validateProfile(req, currentUser, existing);
            profileDAO.upsertProfile(profile);
            session.removeAttribute("recipientProfileCsrfToken");
            session.setAttribute("profileSuccess", "Your recipient details were updated successfully.");
            resp.sendRedirect(req.getContextPath() + "/recipient/dashboard");
        } catch (IllegalArgumentException e) {
            forwardForm(req, resp, session, currentUser, formRecipient(req, currentUser, 0), e.getMessage());
        } catch (SQLException e) {
            System.err.println("[RecipientProfileServlet] Unable to save profile: " + e.getMessage());
            forwardForm(req, resp, session, currentUser, formRecipient(req, currentUser, 0), "Unable to save your details right now. Please try again shortly.");
        }
    }

    private Recipient validateProfile(HttpServletRequest req, User currentUser, Recipient existing)
            throws SQLException {
        int bloodGroupId = existing != null ? existing.getBloodGroupId() : profileDAO.findUserBloodGroupId(currentUser.getId());
        if (bloodGroupId <= 0) {
            throw new IllegalArgumentException("Your account does not have a blood group yet. Please contact support.");
        }

        Recipient profile = formRecipient(req, currentUser, bloodGroupId);

        if (profile.getDistrictId() != null && !profileDAO.districtExists(profile.getDistrictId())) {
            throw new IllegalArgumentException("Please select a valid district.");
        }
        if (profile.getAddress() != null && profile.getAddress().length() > MAX_ADDRESS_LENGTH) {
            throw new IllegalArgumentException("Address must be 255 characters or fewer.");
        }
        if (profile.getDateOfBirth() != null && profile.getDateOfBirth().isAfter(LocalDate.now())) {
            throw new IllegalArgumentException("Date of birth cannot be in the future.");
        }
        String gender = profile.getGender();
        if (gender != null && !gender.isEmpty()
                && !"male".equals(gender)
                && !"female".equals(gender)
                && !"other".equals(gender)) {
            throw new IllegalArgumentException("Please select a valid gender.");
        }
        if (gender != null && gender.isEmpty()) {
            profile.setGender(null);
        }
        return profile;
    }

    private Recipient formRecipient(HttpServletRequest req, User currentUser, int bloodGroupId) {
        Recipient profile = new Recipient();
        profile.setUserId(currentUser.getId().intValue());
        profile.setBloodGroupId(bloodGroupId);
        profile.setDistrictId(parseNullableInt(clean(req.getParameter("districtId"))));
        profile.setAddress(cleanLoose(req.getParameter("address")));
        profile.setGender(clean(req.getParameter("gender")).toLowerCase());
        profile.setMedicalNotes(cleanLoose(req.getParameter("medicalNotes")));

        String dobRaw = clean(req.getParameter("dateOfBirth"));
        if (!dobRaw.isEmpty()) {
            try {
                profile.setDateOfBirth(LocalDate.parse(dobRaw));
            } catch (DateTimeParseException e) {
                throw new IllegalArgumentException("Please enter a valid date of birth.");
            }
        }
        return profile;
    }

    private void forwardForm(HttpServletRequest req, HttpServletResponse resp, HttpSession session,
                             User currentUser, Recipient profile, String error)
            throws ServletException, IOException {
        List<District> districts = districtDAO.findAll();
        if (error != null) {
            req.setAttribute("profileError", error);
        }
        req.setAttribute("currentUser", currentUser);
        req.setAttribute("recipientProfile", profile);
        req.setAttribute("districts", districts);
        req.setAttribute("csrfToken", getOrCreateCsrfToken(session));
        req.getRequestDispatcher("/views/recipient/edit_details.jsp").forward(req, resp);
    }

    private User resolveCurrentUser(HttpSession session) {
        if (session == null) {
            return null;
        }
        Object current = session.getAttribute("currentUser");
        if (current instanceof User) {
            return (User) current;
        }
        Object userId = session.getAttribute("userId");
        if (userId == null) {
            return null;
        }
        try {
            return userDAO.findById(Long.valueOf(String.valueOf(userId)));
        } catch (NumberFormatException e) {
            return null;
        }
    }

    private String getOrCreateCsrfToken(HttpSession session) {
        String token = (String) session.getAttribute("recipientProfileCsrfToken");
        if (token == null) {
            byte[] bytes = new byte[32];
            secureRandom.nextBytes(bytes);
            token = Base64.getUrlEncoder().withoutPadding().encodeToString(bytes);
            session.setAttribute("recipientProfileCsrfToken", token);
        }
        return token;
    }

    private Integer parseNullableInt(String raw) {
        if (raw.isEmpty()) {
            return null;
        }
        try {
            int value = Integer.parseInt(raw);
            return value > 0 ? value : null;
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Please select a valid district.");
        }
    }

    private String clean(String value) {
        return value == null ? "" : value.trim();
    }

    private String cleanLoose(String value) {
        if (value == null) {
            return null;
        }
        String cleaned = value.trim();
        return cleaned.isEmpty() ? null : cleaned;
    }
}
