package dev.laszlo.security;

import dev.laszlo.model.User;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;

/**
 * Helper class to get current authenticated user or fallback to "default"
 *
 * This enables backward compatibility:
 * - New authenticated users: Returns their actual user ID
 * - Unauthenticated requests: Returns "default" (existing behavior)
 *
 * In SESSION_44, we'll replace all hardcoded "default" with this helper.
 */
@Component
public class SecurityContextHelper {

    /**
     * Get current user ID as String (for VARCHAR user_id columns)
     *
     * Returns authenticated user's ID if present, otherwise "default"
     */
    public String getCurrentUserId() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth != null && auth.isAuthenticated() && auth.getPrincipal() instanceof User user) {
            // User is authenticated - return their ID
            return user.getId().toString();
        }

        // No authentication - return "default" for backward compatibility
        return "default";
    }

    /**
     * Get current authenticated user (optional)
     *
     * Returns null if not authenticated
     */
    public User getCurrentUser() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();

        if (auth != null && auth.isAuthenticated() && auth.getPrincipal() instanceof User user) {
            return user;
        }

        return null;
    }

    /**
     * Check if current request is authenticated
     */
    public boolean isAuthenticated() {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        return auth != null && auth.isAuthenticated() && auth.getPrincipal() instanceof User;
    }
}