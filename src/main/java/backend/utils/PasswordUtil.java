package backend.utils;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Utility for hashing and verifying passwords using BCrypt.
 */
public class PasswordUtil {

    private static final int BCRYPT_ROUNDS = 12;

    /** Hash a plain-text password. */
    public static String hash(String plainText) {
        return BCrypt.hashpw(plainText, BCrypt.gensalt(BCRYPT_ROUNDS));
    }

    /** Verify a plain-text password against a stored hash. */
    public static boolean verify(String plainText, String hashed) {
        if (hashed == null || !hashed.startsWith("$2")) return false;
        return BCrypt.checkpw(plainText, hashed);
    }
}
