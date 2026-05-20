package com.lifelink.service;

import com.lifelink.dao.UserDAO;
import com.lifelink.model.User;
import com.lifelink.utils.PasswordUtil;

public class UserService {

    private final UserDAO userDAO = new UserDAO();

    public void registerUser(String fullName, String email,
                             String phone, String bloodGroup, String password,
                             User.Role role, User.Status status, boolean approved) throws AuthException {

        if (fullName == null || fullName.trim().isEmpty()) {
            throw new AuthException("Full name is required.");
        }
        if (email == null || email.trim().isEmpty()) {
            throw new AuthException("Email is required.");
        }
        if (password == null || password.length() < 8) {
            throw new AuthException("Password must be at least 8 characters.");
        }
        if (role == null) {
            throw new AuthException("Role is required.");
        }

        User existing = userDAO.findByEmail(email.trim());
        if (existing != null) {
            throw new AuthException("A user with this email already exists.");
        }

        User user = new User(
            fullName.trim(),
            email.trim().toLowerCase(),
            phone != null && !phone.trim().isEmpty() ? phone.trim() : null,
            bloodGroup != null && !bloodGroup.isEmpty() ? bloodGroup : null,
            PasswordUtil.hash(password),
            role,
            status != null ? status : User.Status.ACTIVE,
            approved
        );

        boolean saved = userDAO.save(user);
        if (!saved) {
            throw new AuthException("Failed to save user. Please try again.");
        }
    }

    public void updateUser(Long id, String fullName, String email,
                           String phone, String bloodGroup, String password,
                           User.Role role, User.Status status, User currentAdmin) throws AuthException {

        if (id == null) throw new AuthException("User ID is required.");
        if (fullName == null || fullName.trim().isEmpty()) throw new AuthException("Full name is required.");
        if (email == null || email.trim().isEmpty()) throw new AuthException("Email is required.");
        if (role == null) throw new AuthException("Role is required.");
        if (status == null) throw new AuthException("Status is required.");

        User existing = userDAO.findById(id);
        if (existing == null) throw new AuthException("User not found.");

        // Self-edit protection
        if (currentAdmin.getId().equals(id)) {
            if (role != User.Role.ADMIN) {
                throw new AuthException("You cannot demote yourself from Admin.");
            }
            if (status != User.Status.ACTIVE) {
                throw new AuthException("You cannot deactivate or suspend your own account.");
            }
        }

        // Email uniqueness check (exclude self)
        User emailOwner = userDAO.findByEmail(email.trim());
        if (emailOwner != null && !emailOwner.getId().equals(id)) {
            throw new AuthException("Another user with this email already exists.");
        }

        existing.setFullName(fullName.trim());
        existing.setEmail(email.trim().toLowerCase());
        existing.setPhone(phone != null && !phone.trim().isEmpty() ? phone.trim() : null);
        existing.setBloodGroup(bloodGroup != null && !bloodGroup.isEmpty() ? bloodGroup : null);
        existing.setRole(role);
        existing.setStatus(status);

        // Auto-approve non-admin users when activated by admin
        if (status == User.Status.ACTIVE && role != User.Role.ADMIN) {
            existing.setApproved(true);
        }

        // Only update password if provided
        if (password != null && !password.trim().isEmpty()) {
            if (password.length() < 8) {
                throw new AuthException("Password must be at least 8 characters.");
            }
            existing.setPasswordHash(PasswordUtil.hash(password));
        }

        boolean saved = userDAO.update(existing);
        if (!saved) throw new AuthException("Failed to update user. Please try again.");
    }

    public void deleteUser(Long id, User currentAdmin) throws AuthException {
        if (id == null) {
            throw new AuthException("User ID is required.");
        }

        User existing = userDAO.findById(id);
        if (existing == null) {
            throw new AuthException("User not found.");
        }

        // Self-delete protection
        if (currentAdmin.getId().equals(id)) {
            throw new AuthException("You cannot delete your own account.");
        }

        // Last admin protection — prevent locking the system
        if (existing.getRole() == User.Role.ADMIN) {
            long adminCount = userDAO.countByRole(User.Role.ADMIN);
            if (adminCount <= 1) {
                throw new AuthException("Cannot delete the last admin account.");
            }
        }

        boolean deleted = userDAO.delete(id);
        if (!deleted) {
            throw new AuthException("Failed to delete user. Please try again.");
        }
    }
}
