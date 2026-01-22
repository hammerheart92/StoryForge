package dev.laszlo.service;

import dev.laszlo.model.StoryContent;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Service for managing story gallery content and unlocks.
 * ⭐ SESSION 35: Migrated from SQLite to PostgreSQL
 */
@Service
public class GalleryService extends BaseService {
    private static final Logger logger = LoggerFactory.getLogger(GalleryService.class);

    private final CurrencyService currencyService;

    // Constructor injection
    public GalleryService(CurrencyService currencyService) {
        this.currencyService = currencyService;
    }

    /**
     * 🖼️ Get all content for a story, optionally filtered by type
     *
     * @param storyId Story identifier
     * @param contentType Optional filter (scene, character, lore, extra)
     * @return List of story content
     */
    public List<StoryContent> getStoryContent(String storyId, String contentType) {
        List<StoryContent> contentList = new ArrayList<>();

        String sql = contentType == null || contentType.isEmpty()
                ? "SELECT * FROM story_content WHERE story_id = ? ORDER BY display_order, content_id"
                : "SELECT * FROM story_content WHERE story_id = ? AND content_type = ? ORDER BY display_order, content_id";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, storyId);
            if (contentType != null && !contentType.isEmpty()) {
                pstmt.setString(2, contentType);
            }

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                StoryContent content = new StoryContent(
                        rs.getInt("content_id"),
                        rs.getString("story_id"),
                        rs.getString("content_type"),
                        rs.getString("content_category"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getInt("unlock_cost"),
                        rs.getString("rarity"),
                        rs.getString("unlock_condition"),
                        rs.getString("content_url"),
                        rs.getString("thumbnail_url"),
                        rs.getInt("display_order"),
                        rs.getString("created_at")
                );
                contentList.add(content);
            }

            logger.debug("🖼️ Retrieved {} content items for story: {}", contentList.size(), storyId);

        } catch (SQLException e) {
            logger.error("❌ Failed to get story content: {}", e.getMessage());
        }

        return contentList;
    }

    /**
     * 🔓 Unlock content by spending gems
     *
     * @param userId User identifier
     * @param contentId Content to unlock
     * @return true if successful, false otherwise
     */
    public boolean unlockContent(String userId, int contentId) {
        // Check if already unlocked
        if (isContentUnlocked(userId, contentId)) {
            logger.warn("⚠️ Content {} already unlocked for user {}", contentId, userId);
            return false;
        }

        // Get content details to check unlock cost
        StoryContent content = getContentById(contentId);
        if (content == null) {
            logger.error("❌ Content {} not found", contentId);
            return false;
        }

        // Spend gems (handles balance check internally)
        boolean gemsSpent = currencyService.spendGems(userId, content.getUnlockCost(), contentId);
        if (!gemsSpent) {
            return false;
        }

        // Add to user_unlocks (story_id is required by schema)
        String sql = "INSERT INTO user_unlocks (user_id, story_id, content_id) VALUES (?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setString(2, content.getStoryId());
            pstmt.setInt(3, contentId);
            pstmt.executeUpdate();

            logger.info("🔓 User {} unlocked content: {} ({}) for story {}", userId, content.getTitle(), contentId, content.getStoryId());
            return true;

        } catch (SQLException e) {
            logger.error("❌ Failed to unlock content: {}", e.getMessage());
            // TODO: Rollback gem transaction if unlock fails
            return false;
        }
    }

    /**
     * 📋 Get list of content IDs unlocked by user
     *
     * @param userId User identifier
     * @param storyId Optional filter by story
     * @return List of unlocked content IDs
     */
    public List<Integer> getUserUnlocks(String userId, String storyId) {
        List<Integer> unlockedIds = new ArrayList<>();

        String sql = storyId == null || storyId.isEmpty()
                ? "SELECT content_id FROM user_unlocks WHERE user_id = ?"
                : """
                  SELECT u.content_id FROM user_unlocks u
                  JOIN story_content c ON u.content_id = c.content_id
                  WHERE u.user_id = ? AND c.story_id = ?
                  """;

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            if (storyId != null && !storyId.isEmpty()) {
                pstmt.setString(2, storyId);
            }

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                unlockedIds.add(rs.getInt("content_id"));
            }

            logger.debug("🔓 User {} has {} unlocked items", userId, unlockedIds.size());

        } catch (SQLException e) {
            logger.error("❌ Failed to get user unlocks: {}", e.getMessage());
        }

        return unlockedIds;
    }

    /**
     * ✅ Check if specific content is unlocked for user
     *
     * @param userId User identifier
     * @param contentId Content to check
     * @return true if unlocked, false otherwise
     */
    public boolean isContentUnlocked(String userId, int contentId) {
        String sql = "SELECT 1 FROM user_unlocks WHERE user_id = ? AND content_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setInt(2, contentId);
            ResultSet rs = pstmt.executeQuery();

            return rs.next();

        } catch (SQLException e) {
            logger.error("❌ Failed to check unlock status: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 🔍 Get content by ID
     *
     * @param contentId Content identifier
     * @return StoryContent object or null if not found
     */
    private StoryContent getContentById(int contentId) {
        String sql = "SELECT * FROM story_content WHERE content_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, contentId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return new StoryContent(
                        rs.getInt("content_id"),
                        rs.getString("story_id"),
                        rs.getString("content_type"),
                        rs.getString("content_category"),
                        rs.getString("title"),
                        rs.getString("description"),
                        rs.getInt("unlock_cost"),
                        rs.getString("rarity"),
                        rs.getString("unlock_condition"),
                        rs.getString("content_url"),
                        rs.getString("thumbnail_url"),
                        rs.getInt("display_order"),
                        rs.getString("created_at")
                );
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to get content by ID: {}", e.getMessage());
        }

        return null;
    }
}