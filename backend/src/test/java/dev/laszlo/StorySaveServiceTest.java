package dev.laszlo;

import dev.laszlo.service.ConversationHistory;
import dev.laszlo.service.StorySaveService;
import org.junit.jupiter.api.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.TestPropertySource;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Integration tests for StorySaveService.
 * Tests save/load functionality with real database.
 *
 * ⭐ SESSION 26: Multi-story save system tests
 */
@SpringBootTest
@ActiveProfiles("test")  // ⭐ ADD THIS LINE
@TestMethodOrder(MethodOrderer.OrderAnnotation.class)
class StorySaveServiceTest {

    @Autowired
    private StorySaveService storySaveService;

    private ConversationHistory testHistory;

    @BeforeEach
    void setUp() {
        // Create test conversation
        testHistory = new ConversationHistory();
        testHistory.setSystemPrompt("You are Captain Blackwood, a pirate captain.");
        testHistory.addUserMessage("What do you see?");
        testHistory.addAssistantMessage("Storm clouds on the horizon.");
        testHistory.addUserMessage("Should we turn back?");
        testHistory.addAssistantMessage("Never! We sail forward!");
    }

    @AfterEach
    void tearDown() {
        // Clean up test data
        storySaveService.deleteSave("test_story", 1);
    }

    @Test
    @Order(1)
    @DisplayName("Should save story progress successfully")
    void testSaveStoryProgress() {
        // Act
        boolean saved = storySaveService.saveStoryProgress(
                "test_story",
                1,
                testHistory,
                "blackwood"
        );

        // Assert
        assertTrue(saved, "Save should succeed");
        assertTrue(storySaveService.hasSave("test_story", 1), "Save should exist");
    }

    @Test
    @Order(2)
    @DisplayName("Should load story progress successfully")
    void testLoadStoryProgress() {
        // Arrange
        storySaveService.saveStoryProgress("test_story", 1, testHistory, "blackwood");

        // Act
        ConversationHistory loaded = storySaveService.loadStoryProgress("test_story", 1);

        // Assert
        assertNotNull(loaded, "Loaded history should not be null");
        assertEquals(testHistory.getSystemPrompt(), loaded.getSystemPrompt());
        assertEquals(testHistory.getMessageCount(), loaded.getMessageCount());
    }

    @Test
    @Order(3)
    @DisplayName("Should update existing save")
    void testUpdateSave() {
        // Arrange - Save initial version
        storySaveService.saveStoryProgress("test_story", 1, testHistory, "blackwood");
        int initialCount = testHistory.getMessageCount();

        // Add more messages
        testHistory.addUserMessage("What about the crew?");
        testHistory.addAssistantMessage("They trust me.");

        // Act - Update save
        boolean updated = storySaveService.saveStoryProgress("test_story", 1, testHistory, "blackwood");

        // Assert
        assertTrue(updated, "Update should succeed");

        ConversationHistory loaded = storySaveService.loadStoryProgress("test_story", 1);
        assertNotNull(loaded);
        assertEquals(initialCount + 2, loaded.getMessageCount(), "Should have updated message count");
    }

    @Test
    @Order(4)
    @DisplayName("Should handle multiple stories independently")
    void testMultipleStories() {
        // Arrange
        ConversationHistory history1 = new ConversationHistory();
        history1.addUserMessage("Pirates story message");
        history1.addAssistantMessage("Pirates response");

        ConversationHistory history2 = new ConversationHistory();
        history2.addUserMessage("Observatory story message");
        history2.addAssistantMessage("Observatory response");

        // Act
        storySaveService.saveStoryProgress("pirates", 1, history1, "blackwood");
        storySaveService.saveStoryProgress("observatory", 1, history2, "ilyra");

        // Assert
        ConversationHistory loaded1 = storySaveService.loadStoryProgress("pirates", 1);
        ConversationHistory loaded2 = storySaveService.loadStoryProgress("observatory", 1);

        assertNotNull(loaded1);
        assertNotNull(loaded2);
        assertEquals(2, loaded1.getMessageCount());
        assertEquals(2, loaded2.getMessageCount());

        // Cleanup
        storySaveService.deleteSave("pirates", 1);
        storySaveService.deleteSave("observatory", 1);
    }

    @Test
    @Order(5)
    @DisplayName("Should return null for non-existent save")
    void testLoadNonExistentSave() {
        // Act
        ConversationHistory loaded = storySaveService.loadStoryProgress("nonexistent_story", 1);

        // Assert
        assertNull(loaded, "Non-existent save should return null");
    }

    @Test
    @Order(6)
    @DisplayName("Should check save existence correctly")
    void testHasSave() {
        // Arrange
        assertFalse(storySaveService.hasSave("test_story", 1), "Should not exist initially");

        // Act
        storySaveService.saveStoryProgress("test_story", 1, testHistory, "blackwood");

        // Assert
        assertTrue(storySaveService.hasSave("test_story", 1), "Should exist after save");
    }

    @Test
    @Order(7)
    @DisplayName("Should delete save successfully")
    void testDeleteSave() {
        // Arrange
        storySaveService.saveStoryProgress("test_story", 1, testHistory, "blackwood");
        assertTrue(storySaveService.hasSave("test_story", 1), "Save should exist");

        // Act
        boolean deleted = storySaveService.deleteSave("test_story", 1);

        // Assert
        assertTrue(deleted, "Delete should succeed");
        assertFalse(storySaveService.hasSave("test_story", 1), "Save should not exist after delete");
    }

    @Test
    @Order(8)
    @DisplayName("Should get save info without loading full conversation")
    void testGetSaveInfo() {
        // Arrange
        storySaveService.saveStoryProgress("test_story", 1, testHistory, "blackwood");

        // Act
        StorySaveService.SaveInfo info = storySaveService.getSaveInfo("test_story", 1);

        // Assert
        assertNotNull(info, "SaveInfo should not be null");
        assertEquals("test_story", info.storyId);
        assertEquals(1, info.saveSlot);
        assertEquals("blackwood", info.currentSpeaker);
        assertEquals(4, info.messageCount);
        assertFalse(info.isCompleted);
    }

    @Test
    @Order(9)
    @DisplayName("Should handle null story ID gracefully")
    void testNullStoryId() {
        // Act & Assert
        boolean saved = storySaveService.saveStoryProgress(null, 1, testHistory, "blackwood");
        assertFalse(saved, "Save with null storyId should fail");

        ConversationHistory loaded = storySaveService.loadStoryProgress(null, 1);
        assertNull(loaded, "Load with null storyId should return null");
    }

    @Test
    @Order(10)
    @DisplayName("Should handle null conversation history gracefully")
    void testNullHistory() {
        // Act & Assert
        boolean saved = storySaveService.saveStoryProgress("test_story", 1, null, "blackwood");
        assertFalse(saved, "Save with null history should fail");
    }

    @Test
    @Order(11)
    @DisplayName("Should handle empty story ID gracefully")
    void testEmptyStoryId() {
        // Act & Assert
        boolean saved = storySaveService.saveStoryProgress("", 1, testHistory, "blackwood");
        assertFalse(saved, "Save with empty storyId should fail");

        ConversationHistory loaded = storySaveService.loadStoryProgress("", 1);
        assertNull(loaded, "Load with empty storyId should return null");
    }

    @Test
    @Order(12)
    @DisplayName("Should preserve data integrity through save/load cycle")
    void testDataIntegrity() {
        // Arrange
        ConversationHistory original = new ConversationHistory();
        original.setSystemPrompt("Test system prompt with special characters: 你好 🏴‍☠️");
        original.addUserMessage("Message with quotes: \"Hello\" and 'World'");
        original.addAssistantMessage("Response with JSON: {\"key\": \"value\"}");

        // Act
        storySaveService.saveStoryProgress("test_story", 1, original, "test_speaker");
        ConversationHistory loaded = storySaveService.loadStoryProgress("test_story", 1);

        // Assert
        assertNotNull(loaded);
        assertEquals(original.getSystemPrompt(), loaded.getSystemPrompt());
        assertEquals(original.getMessageCount(), loaded.getMessageCount());
        assertEquals(original.toJsonArray().toString(), loaded.toJsonArray().toString());
    }
}