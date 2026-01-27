package dev.laszlo;

import org.springframework.test.context.ActiveProfiles;
import dev.laszlo.service.ChatService;
import dev.laszlo.service.ConversationHistory;
import dev.laszlo.service.StorySaveService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.boot.test.web.server.LocalServerPort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
class NarrativeControllerSaveTest {

    @LocalServerPort
    private int port;

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private StorySaveService storySaveService;

    @MockBean
    private ChatService chatService;

    private String baseUrl;

    @BeforeEach
    void setUp() {
        baseUrl = "http://localhost:" + port + "/api/narrative/saves";

        // Delete all existing saves for clean slate
        List<StorySaveService.SaveInfo> allSaves = storySaveService.getAllSavesForUser("default");
        for (StorySaveService.SaveInfo save : allSaves) {
            storySaveService.deleteSave(save.storyId, save.saveSlot);
        }
    }

    @Test
    void testGetAllSaves_whenNoSaves_returnsEmptyList() {
        // Given: No saves exist (cleaned up in @BeforeEach)

        // When: Call GET /api/narrative/saves
        ResponseEntity<String> response = restTemplate.getForEntity(baseUrl, String.class);

        // Then: Should return 200 OK with empty array
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isEqualTo("[]");
    }

    @Test
    void testGetAllSaves_whenSavesExist_returnsSavesList() {
        // Given: Create a test save
        ConversationHistory testHistory = new ConversationHistory();
        testHistory.addUserMessage("Hello");
        testHistory.addAssistantMessage("Hi there!");

        storySaveService.saveStoryProgress(
                "test-story",
                1,
                testHistory,
                "narrator"
        );

        // When: Call GET /api/narrative/saves
        ResponseEntity<String> response = restTemplate.getForEntity(baseUrl, String.class);

        // Then: Should return 200 OK with saves array containing 1 save
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).contains("test-story");
        assertThat(response.getBody()).contains("narrator");
        assertThat(response.getBody()).contains("\"messageCount\":2");
    }

    @Test
    void testDeleteSave_whenSaveExists_returnsNoContent() {
        // Given: Create a test save
        ConversationHistory testHistory = new ConversationHistory();
        testHistory.addUserMessage("Test message");

        storySaveService.saveStoryProgress(
                "story-to-delete",
                1,
                testHistory,
                "narrator"
        );

        // When: Call DELETE /api/narrative/saves/story-to-delete
        restTemplate.delete(baseUrl + "/story-to-delete");

        // Then: Verify save is deleted by trying to GET it
        ResponseEntity<String> response = restTemplate.getForEntity(
                baseUrl + "/story-to-delete",
                String.class
        );

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
    }
}