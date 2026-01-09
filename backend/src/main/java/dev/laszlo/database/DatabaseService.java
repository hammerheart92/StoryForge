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