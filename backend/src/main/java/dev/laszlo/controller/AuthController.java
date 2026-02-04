package dev.laszlo.controller;

import dev.laszlo.database.UserDatabaseService;
import dev.laszlo.dto.AuthResponse;
import dev.laszlo.dto.LoginRequest;
import dev.laszlo.dto.RegisterRequest;
import dev.laszlo.model.Role;
import dev.laszlo.model.User;
import dev.laszlo.security.JwtService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

/**
 * Authentication endpoints for registration and login
 */
@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final UserDatabaseService userDatabaseService;
    private final JwtService jwtService;

    public AuthController(UserDatabaseService userDatabaseService, JwtService jwtService) {
        this.userDatabaseService = userDatabaseService;
        this.jwtService = jwtService;
    }

    /**
     * Register new user (role: USER by default)
     *
     * POST /api/auth/register
     * Body: { "username": "string", "email": "string", "password": "string" }
     */
    @PostMapping("/register")
    public ResponseEntity<?> register(@Valid @RequestBody RegisterRequest request) {
        try {
            // Check if email already exists
            if (userDatabaseService.existsByEmail(request.getEmail())) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Email already registered");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
            }

            // Check if username already exists
            if (userDatabaseService.existsByUsername(request.getUsername())) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Username already taken");
                return ResponseEntity.status(HttpStatus.CONFLICT).body(error);
            }

            // Create user (default role: USER)
            User user = userDatabaseService.createUser(
                    request.getUsername(),
                    request.getEmail(),
                    request.getPassword(),
                    Role.USER
            );

            // Return success (don't auto-login, redirect to login page)
            Map<String, String> response = new HashMap<>();
            response.put("message", "Registration successful");
            response.put("username", user.getUsername());

            return ResponseEntity.status(HttpStatus.CREATED).body(response);

        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Registration failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Login user and return JWT token
     *
     * POST /api/auth/login
     * Body: { "email": "string", "password": "string" }
     */
    @PostMapping("/login")
    public ResponseEntity<?> login(@Valid @RequestBody LoginRequest request) {
        try {
            // Find user by email
            User user = userDatabaseService.findByEmail(request.getEmail())
                    .orElse(null);

            if (user == null) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Invalid email or password");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }

            // Verify password
            if (!userDatabaseService.verifyPassword(request.getPassword(), user.getPasswordHash())) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Invalid email or password");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }

            // Generate JWT token
            String token = jwtService.generateToken(user);

            // Return token and user info
            AuthResponse response = new AuthResponse(
                    token,
                    user.getId(),
                    user.getUsername(),
                    user.getEmail(),
                    user.getRole()
            );

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Login failed: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    /**
     * Get current authenticated user info
     *
     * GET /api/auth/me
     * Headers: Authorization: Bearer {token}
     */
    @GetMapping("/me")
    public ResponseEntity<?> getCurrentUser(@RequestHeader("Authorization") String authHeader) {
        try {
            // Extract token
            String token = authHeader.substring(7); // Remove "Bearer " prefix
            String username = jwtService.extractUsername(token);

            // Find user
            User user = userDatabaseService.findByUsername(username)
                    .orElse(null);

            if (user == null) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "User not found");
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error);
            }

            // Return user info (no password hash!)
            Map<String, Object> response = new HashMap<>();
            response.put("userId", user.getId());
            response.put("username", user.getUsername());
            response.put("email", user.getEmail());
            response.put("role", user.getRole().name());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            Map<String, String> error = new HashMap<>();
            error.put("error", "Failed to get user info: " + e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        }
    }
}