package dev.laszlo.controller;

import dev.laszlo.model.StoryContent;
import dev.laszlo.model.UserCurrency;
import dev.laszlo.service.CurrencyService;
import dev.laszlo.service.GalleryService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/gallery")
@CrossOrigin(origins = "*")
public class GalleryController {
    private static final Logger logger = LoggerFactory.getLogger(GalleryController.class);

    private final GalleryService galleryService;
    private final CurrencyService currencyService;

    // Constructor injection
    public GalleryController(GalleryService galleryService, CurrencyService currencyService) {
        this.galleryService = galleryService;
        this.currencyService = currencyService;
    }

    /**
     * GET /api/gallery/{storyId}/content?type=scene
     * Get all content for a story with optional type filter
     */
    @GetMapping("/{storyId}/content")
    public ResponseEntity<Map<String, Object>> getGalleryContent(
            @PathVariable String storyId,
            @RequestParam(required = false) String type) {

        try {
            String userId = "default"; // TODO: Get from auth in future

            // Get content catalog
            List<StoryContent> content = galleryService.getStoryContent(storyId, type);

            // Get user's unlocked content IDs
            List<Integer> unlockedIds = galleryService.getUserUnlocks(userId, storyId);

            // Get user's gem balance
            int gemBalance = currencyService.getGemBalance(userId);

            Map<String, Object> response = new HashMap<>();
            response.put("content", content);
            response.put("unlockedIds", unlockedIds);
            response.put("gemBalance", gemBalance);
            response.put("storyId", storyId);

            logger.info("🖼️ Gallery content retrieved for story: {} ({} items, {} unlocked)",
                    storyId, content.size(), unlockedIds.size());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("❌ Error retrieving gallery content: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", "Failed to retrieve gallery content"));
        }
    }

    /**
     * GET /api/gallery/user/{userId}/balance
     * Get user's current gem balance
     */
    @GetMapping("/user/{userId}/balance")
    public ResponseEntity<Map<String, Object>> getGemBalance(@PathVariable String userId) {
        try {
            UserCurrency currency = currencyService.getUserCurrency(userId);

            if (currency == null) {
                return ResponseEntity.notFound().build();
            }

            Map<String, Object> response = new HashMap<>();
            response.put("userId", currency.getUserId());
            response.put("gemBalance", currency.getGemBalance());
            response.put("totalEarned", currency.getTotalEarned());
            response.put("totalSpent", currency.getTotalSpent());

            logger.debug("💰 Balance retrieved for user {}: {} gems", userId, currency.getGemBalance());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("❌ Error retrieving gem balance: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", "Failed to retrieve gem balance"));
        }
    }

    /**
     * POST /api/gallery/unlock
     * Unlock a piece of content by spending gems
     * Request body: {"userId": "default", "contentId": 1}
     */
    @PostMapping("/unlock")
    public ResponseEntity<Map<String, Object>> unlockContent(@RequestBody Map<String, Object> request) {
        try {
            String userId = request.getOrDefault("userId", "default").toString();
            int contentId = Integer.parseInt(request.get("contentId").toString());

            // Attempt to unlock
            boolean unlocked = galleryService.unlockContent(userId, contentId);

            if (unlocked) {
                // Get updated balance
                int newBalance = currencyService.getGemBalance(userId);

                Map<String, Object> response = new HashMap<>();
                response.put("success", true);
                response.put("contentId", contentId);
                response.put("newBalance", newBalance);

                logger.info("🔓 Content {} unlocked for user {} (new balance: {})",
                        contentId, userId, newBalance);

                return ResponseEntity.ok(response);
            } else {
                Map<String, Object> response = new HashMap<>();
                response.put("success", false);
                response.put("error", "Insufficient gems or content already unlocked");

                return ResponseEntity.badRequest().body(response);
            }

        } catch (Exception e) {
            logger.error("❌ Error unlocking content: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "error", "Failed to unlock content"));
        }
    }

    /**
     * GET /api/gallery/user/{userId}/unlocks?storyId=pirates
     * Get list of unlocked content IDs for a user
     */
    @GetMapping("/user/{userId}/unlocks")
    public ResponseEntity<Map<String, Object>> getUserUnlocks(
            @PathVariable String userId,
            @RequestParam(required = false) String storyId) {

        try {
            List<Integer> unlockedIds = galleryService.getUserUnlocks(userId, storyId);

            Map<String, Object> response = new HashMap<>();
            response.put("userId", userId);
            response.put("unlockedIds", unlockedIds);
            if (storyId != null) {
                response.put("storyId", storyId);
            }

            logger.debug("🔓 Retrieved {} unlocked items for user {}", unlockedIds.size(), userId);

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("❌ Error retrieving unlocks: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", "Failed to retrieve unlocks"));
        }
    }

    /**
     * GET /api/gallery/status
     * Health check endpoint
     */
    @GetMapping("/status")
    public ResponseEntity<Map<String, String>> getStatus() {
        Map<String, String> status = new HashMap<>();
        status.put("service", "gallery");
        status.put("status", "running");
        return ResponseEntity.ok(status);
    }
}