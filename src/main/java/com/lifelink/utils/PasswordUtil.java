package com.lifelink.utils;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    public static String hash(String plainTextPassword) {
        return BCrypt.hashpw(plainTextPassword, BCrypt.gensalt(12));
    }

    public static boolean verify(String plainTextPassword, String hashedPassword) {
        return BCrypt.checkpw(plainTextPassword, hashedPassword);
    }
}
