package com.lifelink.utils;

import com.lifelink.model.User;
import com.lifelink.service.UserService;
import com.lifelink.service.AuthException;

/**
 * Development seeder — populates the database with test users.
 * Run from main() or call seed() on application startup.
 */
public class Seeder {

    private static final UserService userService = new UserService();

    public static void seed() {
        System.out.println("🌱 Seeding database...");

        seedUser("System", "Admin", "admin@lifelink.org", "9800000000",
                null, "Admin@123", User.Role.ADMIN, User.Status.ACTIVE);

        seedUser("Sarah", "Johnson", "sarah.j@email.com", "9801111111",
                "A+", "User@123", User.Role.DONOR, User.Status.ACTIVE);

        seedUser("Michael", "Chen", "m.chen@email.com", "9802222222",
                "O-", "User@123", User.Role.RECIPIENT, User.Status.ACTIVE);

        seedUser("Aisha", "Patel", "aisha.p@email.com", "9803333333",
                "B+", "User@123", User.Role.DONOR, User.Status.ACTIVE);

        seedUser("James", "Osei", "james.o@email.com", "9804444444",
                "AB+", "User@123", User.Role.RECIPIENT, User.Status.SUSPENDED);

        seedUser("Priya", "Nair", "priya.n@email.com", "9805555555",
                "O+", "User@123", User.Role.DONOR, User.Status.ACTIVE);

        seedUser("David", "Mensah", "d.mensah@hospital.org", "9806666666",
                null, "User@123", User.Role.HOSPITAL, User.Status.ACTIVE);

        seedUser("Linda", "Torres", "l.torres@email.com", "9807777777",
                "B+", "User@123", User.Role.DONOR, User.Status.INACTIVE);

        seedUser("Rajesh", "Kumar", "rajesh.k@email.com", "9808888888",
                "A-", "User@123", User.Role.RECIPIENT, User.Status.ACTIVE);

        seedUser("City", "General Hospital", "info@citygeneral.org", "9809999999",
                null, "User@123", User.Role.HOSPITAL, User.Status.ACTIVE);

        seedUser("Ekta", "Rai", "ektarai23@gmail.com", "9805463211",
                "A+", "User@123", User.Role.DONOR, User.Status.ACTIVE);

        seedUser("Prativa", "Rai", "prativa23@gmail.com", "9805463213",
                "B+", "User@123", User.Role.RECIPIENT, User.Status.ACTIVE);

        System.out.println("✅ Seeding complete.");
    }

    private static void seedUser(String firstName, String lastName, String email,
                                  String phone, String bloodGroup, String password,
                                  User.Role role, User.Status status) {
        try {
            userService.registerUser(firstName, lastName, email, phone,
                    bloodGroup, password, role, status);
            System.out.println("  ✓ " + email);
        } catch (AuthException e) {
            System.out.println("  ⚠ " + email + " — " + e.getMessage());
        }
    }

    public static void main(String[] args) {
        seed();
        DBConnection.close();
    }
}
