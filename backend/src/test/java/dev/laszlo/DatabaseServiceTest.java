package dev.laszlo;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;

import java.io.File;
import java.nio.file.Path;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for DatabaseService - no Spring context needed!
 */
class DatabaseServiceTest {

    private DatabaseService databaseService;

    @TempDir
    Path tempDir;

    @BeforeEach
    void setUp() {
        // Create a fresh DatabaseService for each test
        // It will create its own storyforge.db in the working directory
        databaseService = new DatabaseService();

        // Clean up any existing test data
        cleanDatabase();
    }

    private void cleanDatabase() {
        // Clear all sessions and messages for clean tests
        try (Connection conn = DriverManager.getConnection("jdbc:sqlite:storyforge.db");
             Statement stmt = conn.createStatement()) {
            stmt.execute("DELETE FROM messages");
            stmt.execute("DELETE FROM sessions");
        } catch (Exception e) {
            // Ignore errors in cleanup
        }
    }

    /**
     * CRITICAL REGRESSION TEST
     * This test would have caught the created_at SELECT query bug!
     */
    @Test
    void getAllSessions_shouldIncludeCreatedAtField() {
        // GIVEN: A session exists in database
        int sessionId = databaseService.createSession("Test Session");

        // WHEN: Retrieving all sessions
        List<Session> sessions = databaseService.getAllSessions();

        // THEN: Session should include createdAt field
        assertNotNull(sessions, "Sessions list should not be null");
        assertFalse(sessions.isEmpty(), "Sessions list should not be empty");

        Session session = sessions.get(0);
        assertNotNull(session.getCreatedAt(),
                "Bug regression: created_at must be included in SELECT query");

        // Verify session data is correct
        assertEquals(sessionId, session.getId());
        assertEquals("Test Session", session.getName());
    }

    @Test
    void createSession_shouldReturnValidSessionId() {
        // GIVEN: A session name
        String sessionName = "My Story Session";

        // WHEN: Creating a session
        int sessionId = databaseService.createSession(sessionName);

        // THEN: Should return a valid positive ID
        assertTrue(sessionId > 0, "Session ID should be positive");

        // VERIFY: Session exists in database
        List<Session> sessions = databaseService.getAllSessions();
        assertTrue(sessions.stream()
                        .anyMatch(s -> s.getId() == sessionId && s.getName().equals(sessionName)),
                "Created session should be retrievable");
    }

    @Test
    void saveMessage_shouldPersistToDatabase() {
        // GIVEN: A session
        int sessionId = databaseService.createSession("Test Session");

        // WHEN: Saving a message
        databaseService.saveMessage(sessionId, "user", "Hello World");

        // THEN: Message should be retrievable
        List<String[]> messages = databaseService.loadMessages(sessionId);
        assertFalse(messages.isEmpty(), "Message should be saved");
        assertEquals("user", messages.get(0)[0], "Role should match");
        assertEquals("Hello World", messages.get(0)[1], "Content should match");
    }

    @Test
    void loadMessages_shouldReturnMessagesInOrder() {
        // GIVEN: A session with multiple messages
        int sessionId = databaseService.createSession("Multi-message Session");
        databaseService.saveMessage(sessionId, "user", "First");
        databaseService.saveMessage(sessionId, "assistant", "Second");
        databaseService.saveMessage(sessionId, "user", "Third");

        // WHEN: Loading messages
        List<String[]> messages = databaseService.loadMessages(sessionId);

        // THEN: Should return in correct order
        assertEquals(3, messages.size(), "Should have 3 messages");
        assertEquals("First", messages.get(0)[1]);
        assertEquals("Second", messages.get(1)[1]);
        assertEquals("Third", messages.get(2)[1]);
    }

    @Test
    void getAllSessions_shouldReturnCorrectMessageCount() {
        // GIVEN: A session with messages
        int sessionId = databaseService.createSession("Session with messages");
        databaseService.saveMessage(sessionId, "user", "Hello");
        databaseService.saveMessage(sessionId, "assistant", "Hi!");

        // WHEN: Getting all sessions
        List<Session> sessions = databaseService.getAllSessions();

        // THEN: Message count should be accurate
        Session session = sessions.stream()
                .filter(s -> s.getId() == sessionId)
                .findFirst()
                .orElseThrow();

        assertEquals(2, session.getMessageCount(),
                "Session should show correct message count");
    }

    @Test
    void clearMessages_shouldRemoveAllMessagesFromSession() {
        // GIVEN: A session with messages
        int sessionId = databaseService.createSession("Test Session");
        databaseService.saveMessage(sessionId, "user", "Message 1");
        databaseService.saveMessage(sessionId, "user", "Message 2");

        // WHEN: Clearing messages
        databaseService.clearMessages(sessionId);

        // THEN: No messages should remain
        List<String[]> messages = databaseService.loadMessages(sessionId);
        assertTrue(messages.isEmpty(), "All messages should be cleared");
    }

    @Test
    void deleteSession_shouldRemoveSessionAndMessages() {
        // GIVEN: A session with messages
        int sessionId = databaseService.createSession("To Be Deleted");
        databaseService.saveMessage(sessionId, "user", "Test message");

        // WHEN: Deleting the session
        databaseService.deleteSession(sessionId);

        // THEN: Session should not exist
        List<Session> sessions = databaseService.getAllSessions();
        assertTrue(sessions.stream().noneMatch(s -> s.getId() == sessionId),
                "Deleted session should not appear in list");

        // AND: Messages should be gone too
        List<String[]> messages = databaseService.loadMessages(sessionId);
        assertTrue(messages.isEmpty(), "Messages should be deleted with session");
    }
}