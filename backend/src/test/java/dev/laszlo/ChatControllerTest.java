package dev.laszlo;

import com.fasterxml.jackson.databind.ObjectMapper;
import dev.laszlo.controller.ChatController;
import dev.laszlo.database.DatabaseService;
import dev.laszlo.model.Session;
import dev.laszlo.service.ChatService;
import dev.laszlo.service.ConversationHistory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

/**
 * Integration tests for ChatController REST API endpoints.
 * Uses MockMvc to test HTTP requests/responses without starting full server.
 */
@WebMvcTest(ChatController.class)
class ChatControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private ChatService chatService;

    @MockBean
    private DatabaseService databaseService;

    @BeforeEach
    void setUp() {
        // Setup default mock behavior for DatabaseService
        // Return empty sessions list initially
        when(databaseService.getAllSessions()).thenReturn(Arrays.asList());
        when(databaseService.createSession(anyString())).thenReturn(1);
        when(databaseService.loadMessages(anyInt())).thenReturn(Arrays.asList());
    }

    // ==================== STATUS ENDPOINT ====================

    @Test
    void getStatus_shouldReturnRunningStatus() throws Exception {
        mockMvc.perform(get("/api/chat/status"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("running"))
                .andExpect(jsonPath("$.messageCount").exists());
    }

    // ==================== GET SESSIONS ENDPOINT ====================

    @Test
    void getSessions_shouldReturnEmptyList_whenNoSessions() throws Exception {
        // GIVEN: No sessions exist
        when(databaseService.getAllSessions()).thenReturn(Arrays.asList());

        // WHEN/THEN: Should return empty array
        mockMvc.perform(get("/api/chat/sessions"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$").isArray())
                .andExpect(jsonPath("$.length()").value(0));
    }

    @Test
    void getSessions_shouldReturnSessionList_withCreatedAtField() throws Exception {
        // GIVEN: Sessions exist in database
        List<Session> sessions = Arrays.asList(
                new Session(1, "First Session", 5, "2024-01-01T10:00:00"),
                new Session(2, "Second Session", 3, "2024-01-02T15:30:00")
        );
        when(databaseService.getAllSessions()).thenReturn(sessions);

        // WHEN/THEN: Should return sessions with all fields including createdAt
        mockMvc.perform(get("/api/chat/sessions"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].id").value(1))
                .andExpect(jsonPath("$[0].name").value("First Session"))
                .andExpect(jsonPath("$[0].messageCount").value(5))
                .andExpect(jsonPath("$[0].createdAt").value("2024-01-01T10:00:00"))
                .andExpect(jsonPath("$[1].id").value(2))
                .andExpect(jsonPath("$[1].name").value("Second Session"));
    }

    // ==================== CREATE SESSION ENDPOINT ====================

    @Test
    void createSession_shouldCreateNewSession_withValidName() throws Exception {
        // GIVEN: Valid session name
        Map<String, String> request = new HashMap<>();
        request.put("name", "My Adventure Story");

        when(databaseService.createSession("My Adventure Story")).thenReturn(42);

        // WHEN/THEN: Should create session and return details
        mockMvc.perform(post("/api/chat/sessions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(42))
                .andExpect(jsonPath("$.name").value("My Adventure Story"))
                .andExpect(jsonPath("$.messageCount").value(0))
                .andExpect(jsonPath("$.createdAt").exists());

        verify(databaseService).createSession("My Adventure Story");
    }

    @Test
    void createSession_shouldUseDefaultName_whenNameIsBlank() throws Exception {
        // GIVEN: Blank session name
        Map<String, String> request = new HashMap<>();
        request.put("name", "");

        when(databaseService.createSession("New Chat")).thenReturn(10);

        // WHEN/THEN: Should use "New Chat" as default
        mockMvc.perform(post("/api/chat/sessions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.id").value(10))
                .andExpect(jsonPath("$.name").value("New Chat"));

        verify(databaseService).createSession("New Chat");
    }

    @Test
    void createSession_shouldUseDefaultName_whenNameIsNull() throws Exception {
        // GIVEN: No name provided
        Map<String, String> request = new HashMap<>();

        when(databaseService.createSession("New Chat")).thenReturn(11);

        // WHEN/THEN: Should use "New Chat" as default
        mockMvc.perform(post("/api/chat/sessions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.name").value("New Chat"));
    }

    @Test
    void createSession_shouldReturnError_whenCreationFails() throws Exception {
        // GIVEN: Database fails to create session
        Map<String, String> request = new HashMap<>();
        request.put("name", "Failed Session");

        when(databaseService.createSession(anyString())).thenReturn(-1);

        // WHEN/THEN: Should return error response
        mockMvc.perform(post("/api/chat/sessions")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.error").value("Failed to create session"));
    }

    // ==================== SWITCH SESSION ENDPOINT ====================

    @Test
    void switchSession_shouldLoadMessagesFromSession() throws Exception {
        // GIVEN: Session with messages exists
        int sessionId = 5;
        List<String[]> messages = Arrays.asList(
                new String[]{"user", "Hello"},
                new String[]{"assistant", "Hi there!"},
                new String[]{"user", "How are you?"}
        );
        when(databaseService.loadMessages(sessionId)).thenReturn(messages);

        // WHEN/THEN: Should switch session and return messages
        mockMvc.perform(put("/api/chat/sessions/{id}/switch", sessionId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("switched"))
                .andExpect(jsonPath("$.sessionId").value(sessionId))
                .andExpect(jsonPath("$.messageCount").value(3))
                .andExpect(jsonPath("$.messages").isArray())
                .andExpect(jsonPath("$.messages.length()").value(3))
                .andExpect(jsonPath("$.messages[0].role").value("user"))
                .andExpect(jsonPath("$.messages[0].content").value("Hello"))
                .andExpect(jsonPath("$.messages[1].role").value("assistant"))
                .andExpect(jsonPath("$.messages[1].content").value("Hi there!"));

        verify(databaseService).loadMessages(sessionId);
    }

    @Test
    void switchSession_shouldHandleEmptySession() throws Exception {
        // GIVEN: Empty session
        int sessionId = 99;
        when(databaseService.loadMessages(sessionId)).thenReturn(Arrays.asList());

        // WHEN/THEN: Should switch to empty session
        mockMvc.perform(put("/api/chat/sessions/{id}/switch", sessionId))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("switched"))
                .andExpect(jsonPath("$.sessionId").value(sessionId))
                .andExpect(jsonPath("$.messageCount").value(0))
                .andExpect(jsonPath("$.messages.length()").value(0));
    }

    // ==================== SEND MESSAGE ENDPOINT ====================

    @Test
    void sendMessage_shouldReturnClaudeResponse() throws Exception {
        // GIVEN: Valid user message and Claude response
        Map<String, String> request = new HashMap<>();
        request.put("message", "Tell me a story");

        when(chatService.sendMessage(any(ConversationHistory.class)))
                .thenReturn("Once upon a time in a mystical forest...");

        // WHEN/THEN: Should send message and return response
        mockMvc.perform(post("/api/chat/send")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.response").value("Once upon a time in a mystical forest..."))
                .andExpect(jsonPath("$.messageCount").exists());

        // Verify message was saved to database
        verify(databaseService).saveMessage(anyInt(), eq("user"), eq("Tell me a story"));
        verify(databaseService).saveMessage(anyInt(), eq("assistant"), eq("Once upon a time in a mystical forest..."));
    }

    @Test
    void sendMessage_shouldReturnError_whenMessageIsEmpty() throws Exception {
        // GIVEN: Empty message
        Map<String, String> request = new HashMap<>();
        request.put("message", "");

        // WHEN/THEN: Should return bad request
        mockMvc.perform(post("/api/chat/send")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Message cannot be empty"));

        // Verify no API call was made
        verify(chatService, never()).sendMessage(any());
    }

    @Test
    void sendMessage_shouldReturnError_whenMessageIsNull() throws Exception {
        // GIVEN: Null message
        Map<String, String> request = new HashMap<>();

        // WHEN/THEN: Should return bad request
        mockMvc.perform(post("/api/chat/send")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.error").value("Message cannot be empty"));
    }

    @Test
    void sendMessage_shouldReturnError_whenClaudeApiFails() throws Exception {
        // GIVEN: Claude API returns null (failure)
        Map<String, String> request = new HashMap<>();
        request.put("message", "Hello");

        when(chatService.sendMessage(any(ConversationHistory.class))).thenReturn(null);

        // WHEN/THEN: Should return error
        mockMvc.perform(post("/api/chat/send")
                        .contentType(MediaType.APPLICATION_JSON)
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isInternalServerError())
                .andExpect(jsonPath("$.error").value("Failed to get response from Claude"));
    }

    // ==================== RESET ENDPOINT ====================

    @Test
    void resetChat_shouldClearConversationHistory() throws Exception {
        // WHEN/THEN: Should reset conversation
        mockMvc.perform(post("/api/chat/reset"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("Conversation reset"));

        // Verify database messages were cleared
        verify(databaseService).clearMessages(anyInt());
    }
}