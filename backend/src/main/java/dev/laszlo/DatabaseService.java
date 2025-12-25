package dev.laszlo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Handles SQLite database operations for chat persistence.
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
                SELECT s.id, s.name, COUNT(m.id) as msg_count 
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
     */
    public void deleteSession(int sessionId) {
        String deleteMessagesSQL = "DELETE FROM messages WHERE session_id = ?";
        String deleteSessionSQL = "DELETE FROM sessions WHERE id = ?";

        try (Connection conn = DriverManager.getConnection(DB_URL)) {

            // First delete messages
            try (PreparedStatement pstmt = conn.prepareStatement(deleteMessagesSQL)) {
                pstmt.setInt(1, sessionId);
                pstmt.executeUpdate();
            }

            // Then delete session
            try (PreparedStatement pstmt = conn.prepareStatement(deleteSessionSQL)) {
                pstmt.setInt(1, sessionId);
                pstmt.executeUpdate();
            }

            logger.info("🗑️ Deleted session {}", sessionId);

        } catch (SQLException e) {
            logger.error("❌ Failed to delete session: {}", e.getMessage());
        }
    }
}