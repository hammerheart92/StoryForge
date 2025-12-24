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
     * Constructor - creates database table if it doesn't exist.
     */

    public DatabaseService() {
        initializeDatabase();
    }

    /**
     * Creates the messages table if it doesn't exist.
     */
    private void initializeDatabase() {
        String createTableSQL = """
                CREATE TABLE IF NOT EXISTS messages (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    role TEXT NOT NULL,
                    content TEXT NOT NULL,
                    timestamp TEXT NOT NULL
                )
                """;

        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement()) {

            stmt.execute(createTableSQL);
            logger.info("✅ Database initialized successfully");

        } catch (SQLException e) {
            logger.error("❌ Database initialization failed: {}", e.getMessage());
        }
    }

    /**
     * Saves a single message to the database.
     *
     * @param role    "user" or "assistant"
     * @param content The message text
     */

    public void saveMessage(String role, String content) {
        String insertSQL = "INSERT INTO messages (role, content, timestamp) VALUES (?, ?, ?)";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             PreparedStatement pstmt = conn.prepareStatement(insertSQL)) {

            pstmt.setString(1, role);
            pstmt.setString(2, content);
            pstmt.setString(3, java.time.LocalTime.now().toString());

            pstmt.executeUpdate();
            logger.debug("\uD83D\uDCBE Message saved: {} - {}", role, content.substring
                    (0, Math.min(50, content.length())));

        } catch (SQLException e) {
            logger.error("❌ Failed to save message: {}", e.getMessage());
        }
    }

    /**
     * Loads All messages from the database.
     *
     * @return List of messages, each as a String array [role, content]
     */
    public List<String[]> loadAllMessages() {
        List<String[]> messages = new ArrayList<>();
        String selectSQL = "SELECT role, content FROM messages ORDER BY id ASC";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(selectSQL)) {

            while (rs.next()) {
                String role = rs.getString("role");
                String content = rs.getString("content");
                messages.add(new String[]{role, content});
            }

            logger.info("📂 Loaded {} messages from database", messages.size());

        } catch (SQLException e) {
            logger.error("❌ Failed to load messages: {}", e.getMessage());
        }

        return messages;
    }

    /**
     * Clears all messages from the database.
     */
    public void clearMessages() {
        String deleteSQL = "DELETE FROM messages";

        try (Connection conn = DriverManager.getConnection(DB_URL);
             Statement stmt = conn.createStatement()) {

            stmt.executeUpdate(deleteSQL);
            logger.info("🗑️ All messages cleared from database");

        } catch (SQLException e) {
            logger.error("❌ Failed to clear messages: {}", e.getMessage());
        }
    }
}