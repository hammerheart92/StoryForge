package dev.laszlo.security;

import dev.laszlo.database.UserDatabaseService;
import dev.laszlo.model.User;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

/**
 * JWT authentication filter that intercepts requests and validates tokens
 */
@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService;
    private final UserDatabaseService userDatabaseService;

    public JwtAuthenticationFilter(JwtService jwtService, UserDatabaseService userDatabaseService) {
        this.jwtService = jwtService;
        this.userDatabaseService = userDatabaseService;
    }

    @Override
    protected void doFilterInternal(
            @NonNull HttpServletRequest request,
            @NonNull HttpServletResponse response,
            @NonNull FilterChain filterChain
    ) throws ServletException, IOException {

        // Extract Authorization header
        final String authHeader = request.getHeader("Authorization");

        // If no token, continue without authentication (permitAll endpoints)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        try {
            // Extract token
            final String jwt = authHeader.substring(7);
            final String username = jwtService.extractUsername(jwt);

            // If token is valid and user not already authenticated
            if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
                User user = userDatabaseService.findByUsername(username)
                        .orElse(null);

                // Validate token and set authentication
                if (user != null && jwtService.isTokenValid(jwt, user)) {
                    UsernamePasswordAuthenticationToken authToken = new UsernamePasswordAuthenticationToken(
                            user,
                            null,
                            user.getAuthorities()
                    );
                    authToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authToken);
                }
            }
        } catch (Exception e) {
            // Log but don't block request - let it proceed unauthenticated
            System.err.println("JWT validation error: " + e.getMessage());
        }

        filterChain.doFilter(request, response);
    }
}