package backend.service;

import backend.dao.UserDAO;
import backend.model.User;
import backend.utils.PasswordUtil;

public class AuthService {

    private final UserDAO userDAO;

    public AuthService() {
        this.userDAO = new UserDAO();
    }

    public User login(String email, String password) throws AuthException {
        if (email == null || email.trim().isEmpty() || password == null || password.isEmpty()) {
            throw new AuthException("Email and password are required.");
        }

        User user = userDAO.findByEmail(email.trim().toLowerCase());
        if (user == null || !PasswordUtil.verify(password, user.getPasswordHash())) {
            throw new AuthException("Invalid email or password.");
        }

        if (user.getStatus() != User.Status.ACTIVE) {
            throw new AuthException("Your account is inactive. Please contact support.");
        }

        return user;
    }
}
