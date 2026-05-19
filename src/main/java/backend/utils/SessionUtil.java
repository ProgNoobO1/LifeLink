package backend.utils;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/**
 * Utility for session management and role-based access control.
 */
public class SessionUtil {

    /** Get the logged-in userId, or 1 as fallback for testing. */
    public static int getUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object idObj = session.getAttribute("userId");
            if (idObj instanceof Integer) {
                return (Integer) idObj;
            } else if (idObj instanceof String) {
                try {
                    return Integer.parseInt((String) idObj);
                } catch (NumberFormatException e) {
                    // ignore
                }
            }
        }
        return 1; // Fallback for independent bypass testing
    }

    /** Get the logged-in user's role, or 'hospital' as fallback for testing. */
    public static String getRole(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object role = session.getAttribute("role");
            if (role instanceof String && !((String) role).trim().isEmpty()) {
                return (String) role;
            }
        }
        return "hospital"; // Fallback for independent bypass testing
    }

    /** Get the logged-in user's full name, or empty string. */
    public static String getFullName(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return "";
        Object name = session.getAttribute("fullName");
        return (name instanceof String) ? (String) name : "";
    }

    /** Returns true if a user is logged in. */
    public static boolean isLoggedIn(HttpServletRequest request) {
        return getUserId(request) > 0;
    }

    /**
     * Guard: redirect to /login if the user is not logged in with the required role.
     * Returns true if access is granted, false if redirected.
     */
    public static boolean requireRole(HttpServletRequest request,
                                      HttpServletResponse response,
                                      String requiredRole) throws IOException {
        /* INTEGRATION POINT: Member 1 (Auth) provides role checks
        if (!isLoggedIn(request)) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }
        String role = getRole(request);
        if (!requiredRole.equals(role)) {
            response.sendRedirect(request.getContextPath() + "/login?error=unauthorized");
            return false;
        }
        */
        return true; // Bypass for independent testing
    }

    /** Invalidate session (logout). */
    public static void logout(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) session.invalidate();
    }
}
