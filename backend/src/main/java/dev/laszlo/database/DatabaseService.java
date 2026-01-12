package dev.laszlo.database;

import dev.laszlo.model.Session;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Handles SQLite database operations for chat persistence.
 * ⭐ SESSION 26: Added story_saves table for multi-story save system
 */
public class DatabaseService {

    private static final Logger logger = LoggerFactory.getLogger(DatabaseService.class);

    // Database file location
    private static final String DB_URL = "jdbc:sqlite:storyforge.db";

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
        createUserChoicesTable();  // NEW: Session 14 addition
        createStorySavesTable();   // ⭐ SESSION 26: Multi-story save system

        // ⭐ PHASE 1 GALLERY: Gallery system tables
        createUserCurrencyTable();
        createGemTransactionsTable();
        createStoryContentTable();
        createUserUnlocksTable();

        logger.info("✅ Database initialized successfully");
    }

    private void createSessionsTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS sessions (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    created_at TEXT NOT NULL
                )
                """;
        executeSQL(sql);
    }

    private void createMessagesTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS messages (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    session_id INTEGER NOT NULL,
                    role TEXT NOT NULL,
                    content TEXT NOT NULL,
                    timestamp TEXT NOT NULL,
                    FOREIGN KEY (session_id) REFERENCES sessions(id)
                )
                """;
        executeSQL(sql);
    }

    /**
     * NEW: Session 14 - Create table to track user choices for branching narratives.
     */
    private void createUserChoicesTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS user_choices (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    session_id INTEGER NOT NULL,
                    choice_id TEXT NOT NULL,
                    choice_label TEXT NOT NULL,
                    next_speaker TEXT NOT NULL,
                    chosen_at TEXT NOT NULL,
                    FOREIGN KEY (session_id) REFERENCES sessions(id)
                )
                """;
        executeSQL(sql);
        logger.debug("📊 user_choices table ready");
    }

    /**
     * ⭐ SESSION 26: Create table to store conversation saves for each story.
     * This enables users to maintain progress across multiple stories simultaneously.
     */
    private void createStorySavesTable() {
        String sql = """
                CREATE TABLE IF NOT EXISTS story_saves (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    story_id TEXT NOT NULL,
                    save_slot INTEGER DEFAULT 1,
                    user_id TEXT DEFAULT 'default',
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    last_played_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    current_speaker TEXT,
                    message_count INTEGER DEFAULT 0,
                    choice_count INTEGER DEFAULT 0,
                    conversation_json TEXT NOT NULL,
                    progress_metadata TEXT,
                    is_completed BOOLEAN DEFAULT 0,
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

        logger.debug("💾 story_saves table ready");
    }

    /**
     * ⭐ PHASE 1 GALLERY: Create table to track user's gem balance
     */
    private void createUserCurrencyTable() {
        String sql = """
            CREATE TABLE IF NOT EXISTS user_currency (
                user_id TEXT PRIMARY KEY,
                gem_balance INTEGER DEFAULT 0 NOT NULL,
                total_earned INTEGER DEFAULT 0 NOT NULL,
                total_spent INTEGER DEFAULT 0 NOT NULL,
                last_updated TEXT DEFAULT CURRENT_TIMESTAMP,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
            """;

        executeSQL(sql);
        logger.debug("💰 user_currency table ready");

        // Initialize default user with 100 starting gems
        String initSql = """
            INSERT OR IGNORE INTO user_currency (user_id, gem_balance, total_earned, total_spent)
            VALUES ('default', 100, 0, 0)
            """;
        executeSQL(initSql);
    }

    /**
     * ⭐ PHASE 1 GALLERY: Create table to log all gem transactions
     */
    private void createGemTransactionsTable() {
        String sql = """
            CREATE TABLE IF NOT EXISTS gem_transactions (
                transaction_id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT NOT NULL,
                amount INTEGER NOT NULL,
                transaction_type TEXT NOT NULL CHECK(transaction_type IN ('earn', 'spend')),
                source TEXT,
                story_id TEXT,
                content_id INTEGER,
                timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
                FOREIGN KEY (user_id) REFERENCES user_currency(user_id)
            )
            """;

        executeSQL(sql);
        logger.debug("💎 gem_transactions table ready");
    }

    /**
     * ⭐ PHASE 1 GALLERY: Create catalog of unlockable content
     */
    private void createStoryContentTable() {
        String sql = """
            CREATE TABLE IF NOT EXISTS story_content (
                content_id INTEGER PRIMARY KEY AUTOINCREMENT,
                story_id TEXT NOT NULL,
                content_type TEXT NOT NULL CHECK(content_type IN ('scene', 'character', 'lore', 'extra')),
                content_category TEXT,
                title TEXT NOT NULL,
                description TEXT,
                unlock_cost INTEGER NOT NULL,
                rarity TEXT DEFAULT 'common' CHECK(rarity IN ('common', 'rare', 'epic', 'legendary')),
                unlock_condition TEXT,
                content_url TEXT,
                thumbnail_url TEXT,
                display_order INTEGER DEFAULT 0,
                created_at TEXT DEFAULT CURRENT_TIMESTAMP
            )
            """;

        executeSQL(sql);
        logger.debug("🖼️ story_content table ready");

        // Insert 3 sample content items for pirates story
        String sampleContent = """
            INSERT OR IGNORE INTO story_content 
            (content_id, story_id, content_type, title, description, unlock_cost, rarity, content_url, thumbnail_url, display_order)
            VALUES 
            (1, 'pirates', 'lore', 'The Pirate Code', 'Ancient rules that govern the seas', 30, 'common', 
             'https://placeholder.com/code.jpg', 'https://placeholder.com/code_blur.jpg', 1),
            (2, 'pirates', 'scene', 'The Storm', 'The ship battles against nature''s fury', 50, 'rare',
             'https://placeholder.com/storm.jpg', 'https://placeholder.com/storm_blur.jpg', 2),
            (3, 'pirates', 'character', 'Captain Isla Portrait', 'Full portrait of Captain Isla Blackwater', 75, 'epic',
             'https://placeholder.com/isla.jpg', 'https://placeholder.com/isla_blur.jpg', 3)
            """;
        executeSQL(sampleContent);
        logger.info("📦 Inserted 3 sample gallery items for pirates story");
    }

    /**
     * ⭐ PHASE 1 GALLERY: Track which content each user has unlocked
     */
    private void createUserUnlocksTable() {
        String sql = """
            CREATE TABLE IF NOT EXISTS user_unlocks (
                user_id TEXT NOT NULL,
                content_id INTEGER NOT NULL,
                unlocked_at TEXT DEFAULT CURRENT_TIMESTAMP,
                PRIMARY KEY (user_id, content_id),
                FOREIGN KEY (content_id) REFERENCES story_content(content_id)
            )
            """;

        executeSQL(sql);
        logger.debug("🔓 user_unlocks table ready");
    }

    private void executeSQL(String sql) {
        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement()) {
            stmt.execute(sql);
        } catch (SQLException e) {
            logger.error("❌ SQL execution failed: {}", e.getMessage());
        }
    }

    // ==================== MESSAGE OPERATIONS ====================

    /**
     * Saves a message to a specific session.
     */
    public void saveMessage(int sessionId, String role, String content) {
        String insertSQL = "INSERT INTO messages (session_id, role, content, timestamp) VALUES (?, ?, ?, ?)";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            pstmt.setInt(1, sessionId);
            pstmt.setString(2, role);
            pstmt.setString(3, content);
            pstmt.setString(4, java.time.LocalDateTime.now().toString());

            pstmt.executeUpdate();
            logger.debug("💾 Message saved to session {}: {}", sessionId, role);

        } catch (SQLException e) {
            logger.error("❌ Failed to save message: {}", e.getMessage());
        }
    }

    /**
     * Loads all messages for a specific session.
     */
    public List<String[]> loadMessages(int sessionId) {
        List<String[]> messages = new ArrayList<>();
        String selectSQL = "SELECT role, content FROM messages WHERE session_id = ? ORDER BY id ASC";

        try (Connection conn = DriverManager.getConnection(DB_URL);
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
     * Clears all messages from a specific session.
     */
    public void clearMessages(int sessionId) {
        String deleteSQL = "DELETE FROM messages WHERE session_id = ?";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(deleteSQL)) {

            pstmt.setInt(1, sessionId);
            pstmt.executeUpdate();
            logger.info("🗑️ Messages cleared from session {}", sessionId);

        } catch (SQLException e) {
            logger.error("❌ Failed to clear messages: {}", e.getMessage());
        }
    }

    // ==================== CHOICE OPERATIONS (NEW: Session 14) ====================

    /**
     * NEW: Save a user's choice to the database for tracking narrative branches.
     */
    public void saveUserChoice(int sessionId, String choiceId, String choiceLabel, String nextSpeaker) {
        String insertSQL = "INSERT INTO user_choices (session_id, choice_id, choice_label, next_speaker, chosen_at) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            pstmt.setInt(1, sessionId);
            pstmt.setString(2, choiceId);
            pstmt.setString(3, choiceLabel);
            pstmt.setString(4, nextSpeaker);
            pstmt.setString(5, java.time.LocalDateTime.now().toString());

            pstmt.executeUpdate();
            logger.debug("🎯 Choice saved: '{}' -> {}", choiceLabel, nextSpeaker);

        } catch (SQLException e) {
            logger.error("❌ Failed to save choice: {}", e.getMessage());
        }
    }

    /**
     * NEW: Get all choices made in a specific session (for analytics or debugging).
     */
    public List<String[]> getChoiceHistory(int sessionId) {
        List<String[]> choices = new ArrayList<>();
        String selectSQL = "SELECT choice_id, choice_label, next_speaker, chosen_at FROM user_choices WHERE session_id = ? ORDER BY id ASC";

        try (Connection conn = DriverManager.getConnection(DB_URL);
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

    /**
     * NEW: Get count of choices made in a session.
     */
    public int getChoiceCount(int sessionId) {
        String countSQL = "SELECT COUNT(*) as count FROM user_choices WHERE session_id = ?";

        try (Connection conn = DriverManager.getConnection(DB_URL);
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

    /**
     * Create a new session and returns its ID.
     */
    public int createSession(String name) {
        String insertSQL = "INSERT INTO sessions (name, created_at) VALUES (?, ?)";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            pstmt.setString(1, name);
            pstmt.setString(2, java.time.LocalDateTime.now().toString());
            pstmt.executeUpdate();

            // SQLite way to get last inserted ID
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT last_insert_rowid()");
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

    /**
     * Get All sessions with message counts.
     */
    public List<Session> getAllSessions() {
        List<Session> sessions = new ArrayList<>();
        String selectSQL = """
                SELECT s.id, s.name, s.created_at, COUNT(m.id) as msg_count
                FROM sessions s
                LEFT JOIN messages m ON s.id = m.session_id
                GROUP BY s.id
                ORDER BY s.id DESC
                """;

        try (Connection conn = DriverManager.getConnection(DB_URL);
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

    /**
     * Deletes a session and all its messages.
     * UPDATED: Now also deletes user choices.
     */
    public void deleteSession(int sessionId) {
        String deleteMessagesSQL = "DELETE FROM messages WHERE session_id = ?";
        String deleteChoicesSQL = "DELETE FROM user_choices WHERE session_id = ?";  // NEW
        String deleteSessionSQL = "DELETE FROM sessions WHERE id = ?";

        try (Connection conn = DriverManager.getConnection(DB_URL)) {

            // Delete messages
            try (PreparedStatement pstmt = conn.prepareStatement(deleteMessagesSQL)) {
                pstmt.setInt(1, sessionId);
                pstmt.executeUpdate();
            }

            // NEW: Delete choices
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