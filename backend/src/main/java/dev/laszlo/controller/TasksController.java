package dev.laszlo.controller;

import dev.laszlo.service.CurrencyService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/tasks")
@CrossOrigin(origins = "*")
public class TasksController {
    private static final Logger logger = LoggerFactory.getLogger(TasksController.class);
    private final Map<String, Integer> userGems = new HashMap<>();

    private final CurrencyService currencyService;

    // Constructor injection
    public TasksController(CurrencyService currencyService) {
        this.currencyService = currencyService;
    }

    /**
     * POST /api/tasks/check-in
     * Perform daily check-in and award gems
     * <p>
     * Request body:
     * {
     * "userId": "default",
     * "day": 1,
     * "gemAmount": 20
     * }
     * <p>
     * Response:
     * {
     * "success": true,
     * "gemsAwarded": 20,
     * "newBalance": 145,
     * "day": 1,
     * "source": "daily_check_in_day1"
     * }
     */
    @PostMapping("/check-in")
    public ResponseEntity<Map<String, Object>> checkIn(@RequestBody Map<String, Object> request) {
        try {
            String userId = request.getOrDefault("userId", "default").toString();
            int day = Integer.parseInt(request.get("day").toString());
            int gemAmount = Integer.parseInt(request.get("gemAmount").toString());

            // Validate day (1-7)
            if (day < 1 || day > 7) {
                logger.warn("⚠️ Invalid check-in day: {}", day);
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "error", "Invalid day (must be 1-7)"));
            }

            // Validate gem amount matches expected reward for day
            int[] expectedRewards = {20, 10, 40, 20, 30, 50, 100};
            if (gemAmount != expectedRewards[day - 1]) {
                logger.warn("⚠️ Invalid gem amount {} for day {}", gemAmount, day);
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "error", "Invalid gem amount for day " + day));
            }

            // Award gems via CurrencyService
            String source = "daily_check_in_day" + day;
            currencyService.awardGems(userId, gemAmount, source, null);

            // Get updated balance
            int newBalance = currencyService.getGemBalance(userId);

            // Build success response
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("gemsAwarded", gemAmount);
            response.put("newBalance", newBalance);
            response.put("day", day);
            response.put("source", source);

            logger.info("✅ Daily check-in: User {} claimed Day {} (+{} gems, balance: {})",
                    userId, day, gemAmount, newBalance);

            return ResponseEntity.ok(response);

        } catch (NumberFormatException e) {
            logger.error("❌ Invalid number format in check-in request: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", "Invalid number format"));

        } catch (Exception e) {
            logger.error("❌ Check-in failed: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "error", "Check-in failed: " + e.getMessage()));
        }
    }

    /**
     * POST /api/tasks/claim-achievement
     * Claim achievement reward
     * <p>
     * Request body:
     * {
     * "userId": "default",
     * "achievementId": "scene_explorer",
     * "gemAmount": 50
     * }
     * <p>
     * Response:
     * {
     * "success": true,
     * "gemsAwarded": 50,
     * "newBalance": 195,
     * "achievementId": "scene_explorer",
     * "source": "achievement_scene_explorer"
     * }
     */
    @PostMapping("/claim-achievement")
    public ResponseEntity<Map<String, Object>> claimAchievement(@RequestBody Map<String, Object> request) {
        try {
            String userId = request.getOrDefault("userId", "default").toString();
            String achievementId = request.get("achievementId").toString();
            int gemAmount = Integer.parseInt(request.get("gemAmount").toString());

            // Validate achievement ID
            if (achievementId == null || achievementId.isEmpty()) {
                logger.warn("⚠️ Missing achievement ID");
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "error", "Achievement ID required"));
            }

            // Validate gem amount (reasonable bounds for achievements)
            if (gemAmount <= 0 || gemAmount > 500) {
                logger.warn("⚠️ Invalid achievement gem amount: {}", gemAmount);
                return ResponseEntity.badRequest()
                        .body(Map.of("success", false, "error", "Invalid gem amount"));
            }

            // Award gems via CurrencyService
            String source = "achievement_" + achievementId;
            currencyService.awardGems(userId, gemAmount, source, null);

            // Get updated balance
            int newBalance = currencyService.getGemBalance(userId);

            // Build success response
            Map<String, Object> response = new HashMap<>();
            response.put("success", true);
            response.put("gemsAwarded", gemAmount);
            response.put("newBalance", newBalance);
            response.put("achievementId", achievementId);
            response.put("source", source);

            logger.info("🏆 Achievement claimed: User {} unlocked {} (+{} gems, balance: {})",
                    userId, achievementId, gemAmount, newBalance);

            return ResponseEntity.ok(response);

        } catch (NumberFormatException e) {
            logger.error("❌ Invalid number format in claim request: {}", e.getMessage());
            return ResponseEntity.badRequest()
                    .body(Map.of("success", false, "error", "Invalid number format"));

        } catch (Exception e) {
            logger.error("❌ Claim achievement failed: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("success", false, "error", "Failed to claim achievement: " + e.getMessage()));
        }
    }

    /**
     * GET /api/tasks/status?userId=default
     * Get user's gem balance and stats
     * <p>
     * Response:
     * {
     * "userId": "default",
     * "gemBalance": 145,
     * "totalEarned": 320,
     * "totalSpent": 175
     * }
     */
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getTasksStatus(@RequestParam String userId) {
        try {
            // Get user currency data
            var userCurrency = currencyService.getUserCurrency(userId);

            if (userCurrency == null) {
                logger.warn("⚠️ User currency not found: {}", userId);
                return ResponseEntity.notFound().build();
            }

            // Build response
            Map<String, Object> response = new HashMap<>();
            response.put("userId", userId);
            response.put("gemBalance", userCurrency.getGemBalance());
            response.put("totalEarned", userCurrency.getTotalEarned());
            response.put("totalSpent", userCurrency.getTotalSpent());

            logger.debug("📊 Tasks status for {}: {} gems", userId, userCurrency.getGemBalance());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("❌ Failed to get tasks status: {}", e.getMessage());
            return ResponseEntity.internalServerError()
                    .body(Map.of("error", "Failed to get tasks status"));
        }
    }
}