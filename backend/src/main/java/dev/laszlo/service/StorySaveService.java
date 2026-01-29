package dev.laszlo.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.ArrayList;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import javax.sql.DataSource;
import org.springframework.stereotype.Service;

import java.sql.*;
import java.time.LocalDateTime;

/**
 * Service for managing story save/load operations.
 * Handles persistence of conversation history across multiple stories.
 * <p>
 * ⭐ SESSION 26: Multi-story save system
 * ⭐ SESSION 35: Migrated from SQLite to PostgreSQL
 */
@Service
public class StorySaveService extends BaseService {

    private static final Logger logger = LoggerFactory.getLogger(StorySaveService.class);
    private final DataSource dataSource;

    /**
     * Constructor - creates database tables if they don't exist.
     */
    public StorySaveService(DataSource dataSource) {
        this.dataSource = dataSource;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // SAVE OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /**
     * Save or update story progress to database.
     *
     * @param storyId        Story identifier (e.g., "pirates", "observatory")
     * @param saveSlot       Save slot number (default: 1)
     * @param history        Complete conversation history
     * @param currentSpeaker Last active character
     * @return true if save successful, false otherwise
     */
    public boolean saveStoryProgress(
            String storyId,
            int saveSlot,
            ConversationHistory history,
            String currentSpeaker
    ) {
        if (storyId == null || storyId.isBlank()) {
            logger.error("❌ Cannot save: storyId is null or empty");
            return false;
        }

        if (history == null) {
            logger.error("❌ Cannot save: conversation history is null");
            return false;
        }

        try {
            // Serialize conversation to JSON
            String conversationJson = history.toJson();
            int messageCount = history.getMessageCount();
            String userId = "default";  // Future: get from authentication

            // Check if save already exists
            if (saveExists(storyId, saveSlot, userId)) {
                return updateSave(storyId, saveSlot, userId, conversationJson, messageCount, currentSpeaker);
            } else {
                return insertSave(storyId, saveSlot, userId, conversationJson, messageCount, currentSpeaker);
            }

        } catch (Exception e) {
            logger.error("❌ Failed to save story progress for {}: {}", storyId, e.getMessage(), e);
            return false;
        }
    }

    /**
     * Insert new save record.
     */
    private boolean insertSave(
            String storyId,
            int saveSlot,
            String userId,
            String conversationJson,
            int messageCount,
            String currentSpeaker
    ) {
        String sql = """
                INSERT INTO story_saves (
                    story_id, save_slot, user_id, current_speaker, 
                    message_count, choice_count, conversation_json,
                    created_at, last_played_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            Timestamp now = Timestamp.valueOf(LocalDateTime.now());

            pstmt.setString(1, storyId);
            pstmt.setInt(2, saveSlot);
            pstmt.setString(3, userId);
            pstmt.setString(4, currentSpeaker);
            pstmt.setInt(5, messageCount);
            pstmt.setInt(6, 0);  // choice_count: will track later
            pstmt.setString(7, conversationJson);
            pstmt.setTimestamp(8, now);
            pstmt.setTimestamp(9, now);

            pstmt.executeUpdate();
            logger.info("💾 Created new save: {} (slot {}, {} messages)", storyId, saveSlot, messageCount);
            return true;

        } catch (SQLException e) {
            logger.error("❌ Failed to insert save: {}", e.getMessage());
            return false;
        }
    }

    /**
     * Update existing save record.
     */
    private boolean updateSave(
            String storyId,
            int saveSlot,
            String userId,
            String conversationJson,
            int messageCount,
            String currentSpeaker
    ) {
        String sql = """
                UPDATE story_saves 
                SET conversation_json = ?,
                    message_count = ?,
                    current_speaker = ?,
                    last_played_at = ?
                WHERE story_id = ? AND save_slot = ? AND user_id = ?
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, conversationJson);
            pstmt.setInt(2, messageCount);
            pstmt.setString(3, currentSpeaker);
            pstmt.setTimestamp(4, Timestamp.valueOf(LocalDateTime.now()));
            pstmt.setString(5, storyId);
            pstmt.setInt(6, saveSlot);
            pstmt.setString(7, userId);

            int updated = pstmt.executeUpdate();

            if (updated > 0) {
                logger.info("💾 Updated save: {} (slot {}, {} messages)", storyId, saveSlot, messageCount);
                return true;
            } else {
                logger.warn("⚠️ No save found to update: {} slot {}", storyId, saveSlot);
                return false;
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to update save: {}", e.getMessage());
            return false;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // LOAD OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /**
     * Load story progress from database.
     *
     * @param storyId  Story identifier
     * @param saveSlot Save slot number (default: 1)
     * @return ConversationHistory if found, null otherwise
     */
    public ConversationHistory loadStoryProgress(String storyId, int saveSlot) {
        if (storyId == null || storyId.isBlank()) {
            logger.error("❌ Cannot load: storyId is null or empty");
            return null;
        }

        String userId = "default";  // Future: get from authentication
        String sql = """
                SELECT conversation_json, message_count, current_speaker
                FROM story_saves
                WHERE story_id = ? AND save_slot = ? AND user_id = ?
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, storyId);
            pstmt.setInt(2, saveSlot);
            pstmt.setString(3, userId);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                String conversationJson = rs.getString("conversation_json");
                int messageCount = rs.getInt("message_count");
                String currentSpeaker = rs.getString("current_speaker");

                // Deserialize JSON back to ConversationHistory
                ConversationHistory history = ConversationHistory.fromJson(conversationJson);

                logger.info("📂 Loaded save: {} (slot {}, {} messages, speaker: {})",
                        storyId, saveSlot, messageCount, currentSpeaker);

                return history;
            } else {
                logger.debug("📂 No save found for: {} slot {}", storyId, saveSlot);
                return null;
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to load save: {}", e.getMessage());
            return null;
        } catch (IllegalArgumentException e) {
            logger.error("❌ Failed to deserialize save data: {}", e.getMessage());
            return null;
        }
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // QUERY OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /**
     * Check if a save exists for the given story and slot.
     *
     * @param storyId  Story identifier
     * @param saveSlot Save slot number
     * @return true if save exists, false otherwise
     */
    public boolean hasSave(String storyId, int saveSlot) {
        return hasSave(storyId, saveSlot, "default");
    }

    /**
     * Check if a save exists (with user_id).
     */
    private boolean saveExists(String storyId, int saveSlot, String userId) {
        return hasSave(storyId, saveSlot, userId);
    }

    /**
     * Internal method to check save existence.
     */
    private boolean hasSave(String storyId, int saveSlot, String userId) {
        String sql = """
                SELECT COUNT(*) as count 
                FROM story_saves 
                WHERE story_id = ? AND save_slot = ? AND user_id = ?
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, storyId);
            pstmt.setInt(2, saveSlot);
            pstmt.setString(3, userId);

            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("count") > 0;
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to check save existence: {}", e.getMessage());
        }

        return false;
    }

    /**
     * Get save information (metadata only, no conversation data).
     *
     * @param storyId  Story identifier
     * @param saveSlot Save slot number
     * @return SaveInfo object with metadata, or null if not found
     */
    public SaveInfo getSaveInfo(String storyId, int saveSlot) {
        String userId = "default";
        String sql = """
                SELECT story_id, save_slot, created_at, last_played_at,
                       current_speaker, message_count, choice_count, is_completed,
                       ending_id, completed_at
                FROM story_saves
                WHERE story_id = ? AND save_slot = ? AND user_id = ?
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, storyId);
            pstmt.setInt(2, saveSlot);
            pstmt.setString(3, userId);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return new SaveInfo(
                        rs.getString("story_id"),
                        rs.getInt("save_slot"),
                        getTimestampAsString(rs, "created_at"),
                        getTimestampAsString(rs, "last_played_at"),
                        rs.getString("current_speaker"),
                        rs.getInt("message_count"),
                        rs.getInt("choice_count"),
                        rs.getBoolean("is_completed"),
                        rs.getString("ending_id"),
                        getTimestampAsString(rs, "completed_at")
                );
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to get save info: {}", e.getMessage());
        }

        return null;
    }

    // ═══════════════════════════════════════════════════════════════════════════
    // DELETE OPERATIONS
    // ═══════════════════════════════════════════════════════════════════════════

    /**
     * Delete a story save.
     *
     * @param storyId  Story identifier
     * @param saveSlot Save slot number
     * @return true if deleted, false otherwise
     */
    public boolean deleteSave(String storyId, int saveSlot) {
        String userId = "default";
        String sql = "DELETE FROM story_saves WHERE story_id = ? AND save_slot = ? AND user_id = ?";

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, storyId);
            pstmt.setInt(2, saveSlot);
            pstmt.setString(3, userId);

            int deleted = pstmt.executeUpdate();

            if (deleted > 0) {
                logger.info("🗑️ Deleted save: {} slot {}", storyId, saveSlot);
                return true;
            } else {
                logger.warn("⚠️ No save found to delete: {} slot {}", storyId, saveSlot);
                return false;
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to delete save: {}", e.getMessage());
            return false;
        }
    }

    /**
     * 🏆 Mark a story as completed with ending information.
     * ⭐ SESSION 34: Updated to accept endingId and set completed_at timestamp.
     *
     * @param storyId  Story identifier
     * @param saveSlot Slot number
     * @param userId   User identifier
     * @param endingId The ending that was reached (e.g., "good_ending", "tragic_ending")
     * @return true if successful
     */
    public boolean markStoryCompleted(String storyId, int saveSlot, String userId, String endingId) {
        Timestamp now = Timestamp.valueOf(LocalDateTime.now());
        String sql = """
                UPDATE story_saves
                SET is_completed = true,
                    ending_id = ?,
                    completed_at = ?,
                    last_played_at = ?
                WHERE story_id = ? AND save_slot = ? AND user_id = ?
                """;

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, endingId);
            pstmt.setTimestamp(2, now);
            pstmt.setTimestamp(3, now);
            pstmt.setString(4, storyId);
            pstmt.setInt(5, saveSlot);
            pstmt.setString(6, userId);

            int updated = pstmt.executeUpdate();
            if (updated > 0) {
                logger.info("🏆 Story marked as completed: {} slot {} (ending: {})", storyId, saveSlot, endingId);
                return true;
            }
        } catch (SQLException e) {
            logger.error("❌ Failed to mark story completed: {}", e.getMessage());
        }
        return false;
    }

    // ═══════════════════════════════════════════════════════════════════════════
// REST API METHODS (SESSION 28)
// ═══════════════════════════════════════════════════════════════════════════

    /**
     * Get all saves for a specific user (for Story Library screen).
     * Returns list of SaveInfo for all stories.
     */
    public List<SaveInfo> getAllSavesForUser(String userId) {
        String sql = """
                SELECT story_id, save_slot, created_at, last_played_at,
                       current_speaker, message_count, choice_count, is_completed,
                       ending_id, completed_at
                FROM story_saves
                WHERE user_id = ?
                ORDER BY last_played_at DESC
                """;

        List<SaveInfo> saves = new ArrayList<>();

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                saves.add(new SaveInfo(
                        rs.getString("story_id"),
                        rs.getInt("save_slot"),
                        getTimestampAsString(rs, "created_at"),
                        getTimestampAsString(rs, "last_played_at"),
                        rs.getString("current_speaker"),
                        rs.getInt("message_count"),
                        rs.getInt("choice_count"),
                        rs.getBoolean("is_completed"),
                        rs.getString("ending_id"),
                        getTimestampAsString(rs, "completed_at")
                ));
            }

            logger.info("📋 Retrieved {} saves for user: {}", saves.size(), userId);

        } catch (SQLException e) {
            logger.error("❌ Failed to get all saves: {}", e.getMessage());
        }

        return saves;
    }

    /**
     * Get save for a specific story (without specifying slot - assumes slot 1).
     * Used by REST API for simpler frontend integration.
     */
    public SaveInfo getSaveByStoryId(String userId, String storyId) {
        return getSaveInfo(storyId, 1);  // Default to slot 1
    }

    /**
     * Delete save by storyId (without specifying slot - assumes slot 1).
     * Used by REST API for simpler frontend integration.
     */
    public boolean deleteSaveByStoryId(String userId, String storyId) {
        return deleteSave(storyId, 1);  // Defaults to slot 1
    }

    /**
     * Get all saves for a specific story across all slots (1-5).
     * Used by REST API for save slot management UI.
     */
    public List<SaveInfo> getAllSavesForStory(String userId, String storyId) {
        String sql = """
                SELECT story_id, save_slot, created_at, last_played_at,
                       current_speaker, message_count, choice_count, is_completed,
                       ending_id, completed_at
                FROM story_saves
                WHERE user_id = ? AND story_id = ?
                ORDER BY save_slot ASC
                """;

        List<SaveInfo> saves = new ArrayList<>();

        try (Connection conn = dataSource.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, userId);
            pstmt.setString(2, storyId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                saves.add(new SaveInfo(
                        rs.getString("story_id"),
                        rs.getInt("save_slot"),
                        getTimestampAsString(rs, "created_at"),
                        getTimestampAsString(rs, "last_played_at"),
                        rs.getString("current_speaker"),
                        rs.getInt("message_count"),
                        rs.getInt("choice_count"),
                        rs.getBoolean("is_completed"),
                        rs.getString("ending_id"),
                        getTimestampAsString(rs, "completed_at")
                ));
            }

            logger.info("📋 Retrieved {} saves for story {} (user: {})", saves.size(), storyId, userId);

        } catch (SQLException e) {
            logger.error("❌ Failed to get saves for story {}: {}", storyId, e.getMessage());
        }

        return saves;
    }

/**
 * Delete save by storyId and specific slot.
 * Used by REST API for slot-specific deletion.
 */

    // ═══════════════════════════════════════════════════════════════════════════
    // INNER CLASSES
    // ═══════════════════════════════════════════════════════════════════════════

    /**
     * Save metadata (without full conversation data).
     * Used for displaying save lists in UI.
     * ⭐ SESSION 34: Added endingId and completedAt for story completion tracking.
     */
    public static class SaveInfo {
        public final String storyId;
        public final int saveSlot;
        public final String createdAt;
        public final String lastPlayedAt;
        public final String currentSpeaker;
        public final int messageCount;
        public final int choiceCount;
        public final boolean isCompleted;
        public final String endingId;      // ⭐ SESSION 34
        public final String completedAt;   // ⭐ SESSION 34

        public SaveInfo(
                String storyId,
                int saveSlot,
                String createdAt,
                String lastPlayedAt,
                String currentSpeaker,
                int messageCount,
                int choiceCount,
                boolean isCompleted,
                String endingId,
                String completedAt
        ) {
            this.storyId = storyId;
            this.saveSlot = saveSlot;
            this.createdAt = createdAt;
            this.lastPlayedAt = lastPlayedAt;
            this.currentSpeaker = currentSpeaker;
            this.messageCount = messageCount;
            this.choiceCount = choiceCount;
            this.isCompleted = isCompleted;
            this.endingId = endingId;
            this.completedAt = completedAt;
        }

        @Override
        public String toString() {
            return String.format("SaveInfo{story=%s, slot=%d, messages=%d, speaker=%s, completed=%s, ending=%s}",
                    storyId, saveSlot, messageCount, currentSpeaker, isCompleted, endingId);
        }
    }
}