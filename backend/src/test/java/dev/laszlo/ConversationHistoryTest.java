package dev.laszlo;

import dev.laszlo.service.ConversationHistory;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.BeforeEach;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Unit tests for ConversationHistory JSON serialization.
 * ⭐ SESSION 26: Verify save/load functionality works correctly
 */
class ConversationHistoryTest {

    private ConversationHistory history;

    @BeforeEach
    void setUp() {
        history = new ConversationHistory();
    }

    @Test
    @DisplayName("Should serialize conversation to JSON")
    void testToJson() {
        // Arrange
        history.setSystemPrompt("You are Captain Blackwood, a weathered pirate captain.");
        history.addUserMessage("What do you see on the horizon?");
        history.addAssistantMessage("Storm clouds gathering, dark as betrayal.");
        history.addUserMessage("Should we change course?");
        history.addAssistantMessage("Never. A captain doesn't flee from challenges.");

        // Act
        String json = history.toJson();

        // Assert
        assertNotNull(json);
        assertTrue(json.contains("systemPrompt"));
        assertTrue(json.contains("messages"));
        assertTrue(json.contains("messageCount"));
        assertTrue(json.contains("version"));
        assertTrue(json.contains("Captain Blackwood"));
        assertTrue(json.contains("Storm clouds"));
    }

    @Test
    @DisplayName("Should deserialize conversation from JSON")
    void testFromJson() {
        // Arrange
        history.setSystemPrompt("You are Captain Blackwood, a weathered pirate captain.");
        history.addUserMessage("What do you see on the horizon?");
        history.addAssistantMessage("Storm clouds gathering, dark as betrayal.");
        String json = history.toJson();

        // Act
        ConversationHistory restored = ConversationHistory.fromJson(json);

        // Assert
        assertNotNull(restored);
        assertEquals(history.getSystemPrompt(), restored.getSystemPrompt());
        assertEquals(history.getMessageCount(), restored.getMessageCount());
    }

    @Test
    @DisplayName("Should preserve data integrity after serialization round-trip")
    void testDataIntegrity() {
        // Arrange
        history.setSystemPrompt("You are a test character.");
        history.addUserMessage("Test message 1");
        history.addAssistantMessage("Test response 1");
        history.addUserMessage("Test message 2");
        history.addAssistantMessage("Test response 2");

        // Act
        String json = history.toJson();
        ConversationHistory restored = ConversationHistory.fromJson(json);

        // Assert
        assertEquals(history.getSystemPrompt(), restored.getSystemPrompt());
        assertEquals(history.getMessageCount(), restored.getMessageCount());
        assertEquals(history.toJsonArray().toString(), restored.toJsonArray().toString());
    }

    @Test
    @DisplayName("Should handle empty conversation")
    void testEmptyConversation() {
        // Arrange
        ConversationHistory empty = ConversationHistory.createEmpty();

        // Act
        String json = empty.toJson();
        ConversationHistory restored = ConversationHistory.fromJson(json);

        // Assert
        assertTrue(restored.isEmpty());
        assertEquals(0, restored.getMessageCount());
    }

    @Test
    @DisplayName("Should handle conversation without system prompt")
    void testNoSystemPrompt() {
        // Arrange
        history.addUserMessage("Hello");
        history.addAssistantMessage("Hi there!");

        // Act
        String json = history.toJson();
        ConversationHistory restored = ConversationHistory.fromJson(json);

        // Assert
        assertNull(restored.getSystemPrompt());
        assertEquals(2, restored.getMessageCount());
    }

    @Test
    @DisplayName("Should handle long conversations")
    void testLongConversation() {
        // Arrange
        for (int i = 0; i < 50; i++) {
            history.addUserMessage("User message " + i);
            history.addAssistantMessage("Assistant response " + i);
        }

        // Act
        String json = history.toJson();
        ConversationHistory restored = ConversationHistory.fromJson(json);

        // Assert
        assertEquals(100, restored.getMessageCount());
        assertEquals(history.getMessageCount(), restored.getMessageCount());
    }

    @Test
    @DisplayName("Should throw exception for null JSON")
    void testNullJson() {
        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> {
            ConversationHistory.fromJson(null);
        });
    }

    @Test
    @DisplayName("Should throw exception for empty JSON")
    void testEmptyJson() {
        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> {
            ConversationHistory.fromJson("");
        });
    }

    @Test
    @DisplayName("Should throw exception for invalid JSON")
    void testInvalidJson() {
        // Act & Assert
        assertThrows(IllegalArgumentException.class, () -> {
            ConversationHistory.fromJson("{ invalid json");
        });
    }

    @Test
    @DisplayName("Should preserve message order")
    void testMessageOrder() {
        // Arrange
        history.addUserMessage("First");
        history.addAssistantMessage("Second");
        history.addUserMessage("Third");
        history.addAssistantMessage("Fourth");

        // Act
        String json = history.toJson();
        ConversationHistory restored = ConversationHistory.fromJson(json);

        // Assert
        String original = history.toJsonArray().toString();
        String restoredStr = restored.toJsonArray().toString();
        assertEquals(original, restoredStr);
        assertTrue(restoredStr.indexOf("First") < restoredStr.indexOf("Second"));
        assertTrue(restoredStr.indexOf("Second") < restoredStr.indexOf("Third"));
        assertTrue(restoredStr.indexOf("Third") < restoredStr.indexOf("Fourth"));
    }

    @Test
    @DisplayName("Should create empty conversation via factory method")
    void testCreateEmpty() {
        // Act
        ConversationHistory empty = ConversationHistory.createEmpty();

        // Assert
        assertNotNull(empty);
        assertTrue(empty.isEmpty());
        assertEquals(0, empty.getMessageCount());
        assertNull(empty.getSystemPrompt());
    }

    @Test
    @DisplayName("Should return copy of messages via getMessages()")
    void testGetMessagesCopy() {
        // Arrange
        history.addUserMessage("Test");
        history.addAssistantMessage("Response");

        // Act
        var messages = history.getMessages();
        int originalCount = history.getMessageCount();

        // Try to modify returned list
        messages.clear();

        // Assert - original should be unchanged
        assertEquals(originalCount, history.getMessageCount());
        assertFalse(history.isEmpty());
    }
}