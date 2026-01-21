package dev.laszlo.database;

import dev.laszlo.model.Session;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Handles PostgreSQL database operations for chat persistence.
 * ⭐ SESSION 35: Migrated from SQLite to PostgreSQL for production persistence
 */
public class DatabaseService {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseService.class);

    /**
     * Get database connection URL.
     * - Production (Railway): Uses DATABASE_URL environment variable
     * - Local development: Uses localhost PostgreSQL
     */
    private String getDatabaseUrl() {
        String railwayUrl = System.getenv("DATABASE_URL");
        if (railwayUrl != null && !railwayUrl.isEmpty()) {
            logger.info("🚂 Using Railway DATABASE_URL");
            return convertToJdbcUrl(railwayUrl);
        }
        // Local development fallback
        String localUrl = "jdbc:postgresql://localhost:5432/storyforge?user=postgres&password=postgres";
        logger.debug("🏠 Using local PostgreSQL: localhost:5432/storyforge");
        return localUrl;
    }

    /**
     * Convert DATABASE_URL to JDBC-compatible format.
     * Railway provides: postgresql://user:password@host:port/database
     * JDBC requires:    jdbc:postgresql://host:port/database?user=xxx&password=xxx
     */
    private String convertToJdbcUrl(String url) {
        // Add jdbc: prefix if missing
        if (!url.startsWith("jdbc:")) {
            url = "jdbc:" + url;
        }

        // Check if URL contains credentials in the host part (user:pass@host format)
        // Pattern: jdbc:postgresql://user:password@host:port/database
        if (url.contains("@")) {
            try {
                // Extract parts: jdbc:postgresql://user:password@host:port/database
                String withoutPrefix = url.substring("jdbc:postgresql://".length());
                int atIndex = withoutPrefix.indexOf("@");

                if (atIndex > 0) {
                    String credentials = withoutPrefix.substring(0, atIndex);
                    String hostAndDb = withoutPrefix.substring(atIndex + 1);

                    // Parse user:password
                    int colonIndex = credentials.indexOf(":");
                    if (colonIndex > 0) {
                        String user = credentials.substring(0, colonIndex);
                        String password = credentials.substring(colonIndex + 1);

                        // Build JDBC URL: jdbc:postgresql://host:port/database?user=xxx&password=xxx
                        String jdbcUrl = "jdbc:postgresql://" + hostAndDb;
                        if (jdbcUrl.contains("?")) {
                            jdbcUrl += "&user=" + user + "&password=" + password;
                        } else {
                            jdbcUrl += "?user=" + user + "&password=" + password;
                        }

                        logger.info("🔧 Converted URL format for JDBC compatibility");
                        return jdbcUrl;
                    }
                }
            } catch (Exception e) {
                logger.warn("⚠️ Could not parse DATABASE_URL, using as-is: {}", e.getMessage());
            }
        }

        return url;
    }

    /**
     * Get database connection.
     */
    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection(getDatabaseUrl());
    }

    /**
     * Constructor - creates database tables if they don't exist.
     */
    public DatabaseService() {
        initializeDatabase();
    }

    // ==================== INITIALIZATION ====================

    private void initializeDatabase() {
        createSessionsTable();
        createMessagesTable();
        createUserChoicesTable();
        createStorySavesTable();

        // Gallery system tables
        createUserCurrencyTable();
        createGemTransactionsTable();
        createStoryContentTable();
        createUserUnlocksTable();

        // Session 33: Tasks & Achievements
        createUserTasksTable();
        createUserAchievementsTable();

        logger.info("✅ Database initialized successfully");
    }

    private void createSessionsTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS sessions (
                    id SERIAL PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
                """;
        executeSQL(sql);
    }

    private void createMessagesTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS messages (
                    id SERIAL PRIMARY KEY,
                    session_id INTEGER NOT NULL,
                    role VARCHAR(50) NOT NULL,
                    content TEXT NOT NULL,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (session_id) REFERENCES sessions(id)
                )
                """;
        executeSQL(sql);
    }

    private void createUserChoicesTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS user_choices (
                    id SERIAL PRIMARY KEY,
                    session_id INTEGER NOT NULL,
                    choice_id VARCHAR(100) NOT NULL,
                    choice_label TEXT NOT NULL,
                    next_speaker VARCHAR(50) NOT NULL,
                    chosen_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (session_id) REFERENCES sessions(id)
                )
                """;
        executeSQL(sql);
        logger.debug("📊 user_choices table ready");
    }

    /**
     * ⭐ SESSION 34: Story saves with completion tracking
     */
    private void createStorySavesTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS story_saves (
                    id SERIAL PRIMARY KEY,
                    story_id VARCHAR(50) NOT NULL,
                    save_slot INTEGER DEFAULT 1,
                    user_id VARCHAR(50) DEFAULT 'default',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    last_played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    current_speaker VARCHAR(50),
                    message_count INTEGER DEFAULT 0,
                    choice_count INTEGER DEFAULT 0,
                    conversation_json TEXT NOT NULL,
                    progress_metadata TEXT,
                    is_completed BOOLEAN DEFAULT FALSE,
                    ending_id VARCHAR(100),
                    completed_at TIMESTAMP,
                    UNIQUE(story_id, save_slot, user_id)
                )
                """;
        executeSQL(sql);

        // Create indexes for fast lookups
        String indexLookup = """
                CREATE INDEX IF NOT EXISTS idx_story_saves_lookup 
                ON story_saves(story_id, save_slot, user_id)
                """;
        executeSQL(indexLookup);

        String indexRecent = """
                CREATE INDEX IF NOT EXISTS idx_story_saves_recent 
                ON story_saves(last_played_at DESC)
                """;
        executeSQL(indexRecent);

        String indexUser = """
                CREATE INDEX IF NOT EXISTS idx_story_saves_user 
                ON story_saves(user_id, last_played_at DESC)
                """;
        executeSQL(indexUser);

        String indexCompleted = """
                CREATE INDEX IF NOT EXISTS idx_story_saves_completed 
                ON story_saves(is_completed)
                """;
        executeSQL(indexCompleted);

        logger.debug("💾 story_saves table ready");
    }

    /**
     * ⭐ PHASE 1 GALLERY: User gem balance
     */
    private void createUserCurrencyTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS user_currency (
                    user_id VARCHAR(50) PRIMARY KEY,
                    gem_balance INTEGER DEFAULT 0 NOT NULL,
                    total_earned INTEGER DEFAULT 0 NOT NULL,
                    total_spent INTEGER DEFAULT 0 NOT NULL,
                    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
                """;

        executeSQL(sql);
        logger.debug("💰 user_currency table ready");

        // Initialize default user with 100 starting gems
        String initSql = """
                INSERT INTO user_currency (user_id, gem_balance, total_earned, total_spent)
                VALUES ('default', 100, 100, 0)
                ON CONFLICT (user_id) DO NOTHING
                """;
        executeSQL(initSql);
    }

    /**
     * ⭐ PHASE 1 GALLERY: Gem transaction log
     */
    private void createGemTransactionsTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS gem_transactions (
                    transaction_id SERIAL PRIMARY KEY,
                    user_id VARCHAR(50) NOT NULL,
                    amount INTEGER NOT NULL,
                    transaction_type VARCHAR(10) NOT NULL CHECK(transaction_type IN ('earn', 'spend')),
                    source VARCHAR(100),
                    story_id VARCHAR(50),
                    content_id INTEGER,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES user_currency(user_id)
                )
                """;

        executeSQL(sql);

        // Create index for user lookups
        String indexUser = """
                CREATE INDEX IF NOT EXISTS idx_gem_transactions_user 
                ON gem_transactions(user_id, timestamp DESC)
                """;
        executeSQL(indexUser);

        logger.debug("💎 gem_transactions table ready");
    }

    /**
     * ⭐ PHASE 1 GALLERY: Story content catalog
     */
    private void createStoryContentTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS story_content (
                    content_id SERIAL PRIMARY KEY,
                    story_id VARCHAR(50) NOT NULL,
                    content_type VARCHAR(20) NOT NULL CHECK(content_type IN ('scene', 'character', 'lore', 'extra')),
                    content_category VARCHAR(50),
                    title VARCHAR(255) NOT NULL,
                    description TEXT,
                    unlock_cost INTEGER NOT NULL,
                    rarity VARCHAR(20) DEFAULT 'common' CHECK(rarity IN ('common', 'rare', 'epic', 'legendary')),
                    unlock_condition VARCHAR(255),
                    content_url TEXT,
                    thumbnail_url TEXT,
                    display_order INTEGER DEFAULT 0,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
                """;

        executeSQL(sql);
        logger.debug("🖼️ story_content table ready");

        // Insert sample content for pirates story (using ON CONFLICT for idempotency)
        String sampleContent = """
                INSERT INTO story_content 
                (content_id, story_id, content_type, title, description, unlock_cost, rarity, content_url, thumbnail_url, display_order)
                VALUES 
                (1, 'pirates', 'lore', 'The Pirate Code', 'Ancient rules of the sea that govern all pirates', 30, 'common', 'lore/pirate_code.md', 'thumbnails/pirate_code.jpg', 1),
                (2, 'pirates', 'scene', 'The Storm', 'A devastating storm that tests your crew', 50, 'rare', 'scenes/storm.jpg', 'thumbnails/storm_thumb.jpg', 2),
                (3, 'pirates', 'character', 'Captain Isla Portrait', 'Official portrait of Captain Isla Hartwell', 75, 'epic', 'characters/isla_portrait.jpg', 'thumbnails/isla_thumb.jpg', 3),
                (4, 'pirates', 'scene', 'The Kraken Attack', 'Face the legendary beast of the deep', 80, 'epic', 'scenes/kraken.jpg', 'thumbnails/kraken_thumb.jpg', 4),
                (5, 'pirates', 'scene', 'Treasure Island Discovery', 'Finding the legendary treasure island', 45, 'rare', 'scenes/treasure_island.jpg', 'thumbnails/island_thumb.jpg', 5),
                (6, 'pirates', 'character', 'First Mate Rodriguez', 'Your loyal first mate', 60, 'rare', 'characters/rodriguez.jpg', 'thumbnails/rodriguez_thumb.jpg', 6),
                (7, 'pirates', 'character', 'The Sea Witch', 'Mysterious enchantress of the ocean', 120, 'legendary', 'characters/sea_witch.jpg', 'thumbnails/witch_thumb.jpg', 7),
                (8, 'pirates', 'lore', 'Tales of the Flying Dutchman', 'Ghost ship legends', 25, 'common', 'lore/dutchman.md', 'thumbnails/dutchman_thumb.jpg', 8),
                (9, 'pirates', 'extra', 'Ship Blueprint: The Black Pearl', 'Detailed schematics', 85, 'epic', 'extras/blueprint.pdf', 'thumbnails/blueprint_thumb.jpg', 9),
                (10, 'pirates', 'extra', 'Soundtrack: Ocean''s Embrace', 'Ambient sea music', 20, 'common', 'audio/ocean_embrace.mp3', 'thumbnails/music_thumb.jpg', 10)
                ON CONFLICT (content_id) DO NOTHING
                """;

        executeSQL(sampleContent);
        logger.info("📦 Inserted 10 sample gallery items for pirates story");
    }

    /**
     * ⭐ PHASE 1 GALLERY: User unlocks tracking
     */
    private void createUserUnlocksTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS user_unlocks (
                    unlock_id SERIAL PRIMARY KEY,
                    user_id VARCHAR(50) NOT NULL,
                    story_id VARCHAR(50) NOT NULL,
                    content_id INTEGER NOT NULL,
                    unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(user_id, story_id, content_id),
                    FOREIGN KEY (content_id) REFERENCES story_content(content_id)
                )
                """;

        executeSQL(sql);

        // Create indexes
        String indexUser = """
                CREATE INDEX IF NOT EXISTS idx_user_unlocks_user 
                ON user_unlocks(user_id)
                """;
        executeSQL(indexUser);

        String indexStory = """
                CREATE INDEX IF NOT EXISTS idx_user_unlocks_story 
                ON user_unlocks(story_id)
                """;
        executeSQL(indexStory);

        logger.debug("🔓 user_unlocks table ready");
    }

    /**
     * ⭐ SESSION 33: Daily check-in tasks
     */
    private void createUserTasksTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS user_tasks (
                    user_id VARCHAR(50) PRIMARY KEY,
                    streak INTEGER DEFAULT 0,
                    last_checkin_date DATE,
                    checkin_day INTEGER DEFAULT 0,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
                """;
        executeSQL(sql);
        logger.debug("✅ user_tasks table ready");
    }

    /**
     * ⭐ SESSION 33: Achievement progress tracking
     */
    private void createUserAchievementsTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS user_achievements (
                    id SERIAL PRIMARY KEY,
                    user_id VARCHAR(50) NOT NULL,
                    achievement_id VARCHAR(50) NOT NULL,
                    current_count INTEGER DEFAULT 0,
                    target_count INTEGER NOT NULL,
                    claimed BOOLEAN DEFAULT FALSE,
                    claimed_at TIMESTAMP,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    UNIQUE(user_id, achievement_id)
                )
                """;
        executeSQL(sql);
        logger.debug("🏆 user_achievements table ready");
    }

    /**
     * Execute SQL statement with error handling.
     */
    private void executeSQL(String sql) {
        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        } catch (SQLException e) {
            logger.error("❌ SQL execution failed: {}", e.getMessage());
        }
    }

    // ==================== MESSAGE OPERATIONS ====================

    public void saveMessage(int sessionId, String role, String content) {
        String insertSQL = "INSERT INTO messages (session_id, role, content) VALUES (?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            pstmt.setInt(1, sessionId);
            pstmt.setString(2, role);
            pstmt.setString(3, content);
            pstmt.executeUpdate();

            logger.debug("💬 Message saved: {} -> {}", role, content.substring(0, Math.min(50, content.length())));

        } catch (SQLException e) {
            logger.error("❌ Failed to save message: {}", e.getMessage());
        }
    }

    public List<String[]> getMessages(int sessionId) {
        List<String[]> messages = new ArrayList<>();
        String selectSQL = "SELECT role, content FROM messages WHERE session_id = ? ORDER BY id ASC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(selectSQL)) {

            pstmt.setInt(1, sessionId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                String role = rs.getString("role");
                String content = rs.getString("content");
                messages.add(new String[]{role, content});
            }

            logger.info("📂 Loaded {} messages from session {}", messages.size(), sessionId);

        } catch (SQLException e) {
            logger.error("❌ Failed to load messages: {}", e.getMessage());
        }

        return messages;
    }

    /**
     * Compatibility wrapper for legacy code.
     * @deprecated Use getMessages() instead
     */
    public List<String[]> loadMessages(int sessionId) {
        return getMessages(sessionId);
    }

    public void clearMessages(int sessionId) {
        String deleteSQL = "DELETE FROM messages WHERE session_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(deleteSQL)) {

            pstmt.setInt(1, sessionId);
            pstmt.executeUpdate();
            logger.info("🗑️ Messages cleared from session {}", sessionId);

        } catch (SQLException e) {
            logger.error("❌ Failed to clear messages: {}", e.getMessage());
        }
    }

    // ==================== CHOICE OPERATIONS ====================

    public void saveUserChoice(int sessionId, String choiceId, String choiceLabel, String nextSpeaker) {
        String insertSQL = "INSERT INTO user_choices (session_id, choice_id, choice_label, next_speaker) VALUES (?, ?, ?, ?)";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            pstmt.setInt(1, sessionId);
            pstmt.setString(2, choiceId);
            pstmt.setString(3, choiceLabel);
            pstmt.setString(4, nextSpeaker);

            pstmt.executeUpdate();
            logger.debug("🎯 Choice saved: '{}' -> {}", choiceLabel, nextSpeaker);

        } catch (SQLException e) {
            logger.error("❌ Failed to save choice: {}", e.getMessage());
        }
    }

    public List<String[]> getChoiceHistory(int sessionId) {
        List<String[]> choices = new ArrayList<>();
        String selectSQL = "SELECT choice_id, choice_label, next_speaker, chosen_at FROM user_choices WHERE session_id = ? ORDER BY id ASC";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(selectSQL)) {

            pstmt.setInt(1, sessionId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                String choiceId = rs.getString("choice_id");
                String label = rs.getString("choice_label");
                String nextSpeaker = rs.getString("next_speaker");
                String chosenAt = rs.getString("chosen_at");
                choices.add(new String[]{choiceId, label, nextSpeaker, chosenAt});
            }

            logger.debug("📊 Loaded {} choices from session {}", choices.size(), sessionId);

        } catch (SQLException e) {
            logger.error("❌ Failed to load choice history: {}", e.getMessage());
        }

        return choices;
    }

    public int getChoiceCount(int sessionId) {
        String countSQL = "SELECT COUNT(*) as count FROM user_choices WHERE session_id = ?";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(countSQL)) {

            pstmt.setInt(1, sessionId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("count");
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to count choices: {}", e.getMessage());
        }

        return 0;
    }

    // ==================== SESSION OPERATIONS ====================

    public int createSession(String name) {
        String insertSQL = "INSERT INTO sessions (name) VALUES (?) RETURNING id";

        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            pstmt.setString(1, name);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                int sessionId = rs.getInt(1);
                logger.info("📝 Created session: {} (ID: {})", name, sessionId);
                return sessionId;
            }

        } catch (SQLException e) {
            logger.error("❌ Failed to create session: {}", e.getMessage());
        }

        return -1;
    }

    public List<Session> getAllSessions() {
        List<Session> sessions = new ArrayList<>();
        String selectSQL = """
                SELECT s.id, s.name, s.created_at, COUNT(m.id) as msg_count
                FROM sessions s
                LEFT JOIN messages m ON s.id = m.session_id
                GROUP BY s.id, s.name, s.created_at
                ORDER BY s.id DESC
                """;

        try (Connection conn = getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(selectSQL)) {

            while (rs.next()) {
                int id = rs.getInt("id");
                String name = rs.getString("name");
                String createdAt = rs.getString("created_at");
                int msgCount = rs.getInt("msg_count");
                sessions.add(new Session(id, name, msgCount, createdAt));
            }

            logger.info("📂 Loaded {} sessions", sessions.size());

        } catch (SQLException e) {
            logger.error("❌ Failed to load sessions: {}", e.getMessage());
        }

        return sessions;
    }

    public void deleteSession(int sessionId) {
        String deleteMessagesSQL = "DELETE FROM messages WHERE session_id = ?";
        String deleteChoicesSQL = "DELETE FROM user_choices WHERE session_id = ?";
        String deleteSessionSQL = "DELETE FROM sessions WHERE id = ?";

        try (Connection conn = getConnection()) {

            // Delete messages
            try (PreparedStatement pstmt = conn.prepareStatement(deleteMessagesSQL)) {
                pstmt.setInt(1, sessionId);
                pstmt.executeUpdate();
            }

            // Delete choices
            try (PreparedStatement pstmt = conn.prepareStatement(deleteChoicesSQL)) {
                pstmt.setInt(1, sessionId);
                pstmt.executeUpdate();
            }

            // Delete session
            try (PreparedStatement pstmt = conn.prepareStatement(deleteSessionSQL)) {
                pstmt.setInt(1, sessionId);
                pstmt.executeUpdate();
            }

            logger.info("🗑️ Deleted session {} (including choices)", sessionId);

        } catch (SQLException e) {
            logger.error("❌ Failed to delete session: {}", e.getMessage());
        }
    }
}