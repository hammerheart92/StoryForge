package dev.laszlo.controller;

import dev.laszlo.database.DatabaseService;
import dev.laszlo.model.Session;
import dev.laszlo.service.ChatService;
import dev.laszlo.service.ConversationHistory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST controller for Chat API
 * <p>
 * Endpoints:
 * - POST /api/chat/send    -> Send a message, get response
 * - POST /api/chat/reset   -> Clear conversation history
 * - GET  /api/chat/status  -> Check if API is running
 */
@RestController
@RequestMapping("/api/chat")
public class ChatController {

    private static final Logger logger = LoggerFactory.getLogger(ChatController.class);

    // Dependencies - injected by Spring
    private final ChatService chatService;
    private final ConversationHistory history;
    private final DatabaseService databaseService;
    private int currentSessionId;

    /**
     * Constructor - Spring automatically injects dependencies
     */
    public ChatController(ChatService chatService, DatabaseService databaseService) {
        this.chatService = chatService;
        this.databaseService = databaseService;
        this.history = new ConversationHistory();

        // Create a default session or use existing one
        List<Session> sessions = databaseService.getAllSessions();
        if (sessions.isEmpty()) {
            this.currentSessionId = databaseService.createSession("Default Session");
        } else {
            this.currentSessionId = sessions.get(0).getId();
        }

        // Load existing messages from database
        for (String[] msg : databaseService.loadMessages(currentSessionId)) {
            if (msg[0].equals("user")) {
                history.addUserMessage(msg[1]);
            } else {
                history.addAssistantMessage(msg[1]);
            }
        }
        logger.info("📂 Loaded {} messages from history", history.getMessageCount());

        // Set default system prompt
        this.history.setSystemPrompt("You are a creative storyteller who specializes in atmospheric, " +
                "immersive scenarios. You write vivid descriptions and engaging " +
                "dialogue. Keep responses concise but evocative."
        );

        logger.info("ChatController initialized...");
    }

    /**
     * Health check endpoint
     * GET /api/chat/status
     */
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getStatus() {
        Map<String, Object> status = new HashMap<>();
        status.put("status", "running");
        status.put("messageCount", history.getMessageCount());
        return ResponseEntity.ok(status);
    }

    /**
     * Get all sessions with message counts
     * GET /api/chat/sessions
     */
    @GetMapping("/sessions")
    public ResponseEntity<List<Session>> getSessions() {
        List<Session> sessions = databaseService.getAllSessions();
        logger.info("\uD83D\uDCCB Returning {} sessions", sessions.size());
        return ResponseEntity.ok(sessions);
    }

    /**
     * Create a new session
     * POST /api/chat/sessions
     * Body: { "name": "My New Chat" }
     */
    @PostMapping("/sessions")
    public ResponseEntity<Map<String, Object>> createSession(@RequestBody Map<String, String> request) {
        String sessionName = request.get("name");

        // Validate input
        if (sessionName == null || sessionName.isBlank()) {
            sessionName = "New Chat";
        }

        int newSessionId = databaseService.createSession(sessionName);

        if (newSessionId > 0) {

            this.currentSessionId = newSessionId;

            Map<String, Object> result = new HashMap<>();
            result.put("id", newSessionId);
            result.put("name", sessionName);
            result.put("createdAt", java.time.LocalDateTime.now().toString());
            result.put("messageCount", 0);

            logger.info("✨ Created new session: {} (ID: {})", sessionName, newSessionId);
            return ResponseEntity.ok(result);
        } else {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Failed to create session");
            return ResponseEntity.internalServerError().body(error);
        }
    }

    /**
     * Switch to a different session
     * PUT /api/chat/sessions/{id}/switch
     */
    @PutMapping("/sessions/{id}/switch")
    public ResponseEntity<Map<String, Object>> switchSession(@PathVariable int id) {
        // Clear current in-memory history
        history.clear();

        // Update current session ID
        this.currentSessionId = id;

        // Load messages from the new session
        List<String[]> messages = databaseService.loadMessages(id);
        List<Map<String, String>> messageList = new ArrayList<>();

        for (String[] msg : messages) {
            if (msg[0].equals("user")) {
                history.addUserMessage(msg[1]);
            } else {
                history.addAssistantMessage(msg[1]);
            }

            // Add to response list
            Map<String, String> msgMap = new HashMap<>();
            msgMap.put("role", msg[0]);
            msgMap.put("content", msg[1]);
            messageList.add(msgMap);
        }

        logger.info("🔄 Switched to session {} ({} messages loaded)", id, messages.size());

        Map<String, Object> result = new HashMap<>();
        result.put("status", "switched");
        result.put("sessionId", id);
        result.put("messageCount", history.getMessageCount());
        result.put("messages", messageList);  // ← Return the messages!

        return ResponseEntity.ok(result);
    }
    /**
     * Send a message and get Claude's response
     * POST /api/chat/send
     * Body: { "message": "Your message here" }
     */
    @PostMapping("/send")
    public ResponseEntity<Map<String, Object>> sendMessage(@RequestBody Map<String, String> request) {
        String userMessage = request.get("message");

        // Validate input
        if (userMessage == null || userMessage.isBlank()) {
            Map<String, Object> error = new HashMap<>();
            error.put("error", "Message cannot be empty");
            return ResponseEntity.badRequest().body(error);
        }

        logger.info("Received message: {}", userMessage);

        // Add to history and send
        history.addUserMessage(userMessage);
        databaseService.saveMessage(currentSessionId,"user", userMessage);
        String response = chatService.sendMessage(history);

        Map<String, Object> result = new HashMap<>();

        if (response != null) {
            // Save Claude's response to history
            history.addAssistantMessage(response);
            databaseService.saveMessage(currentSessionId,"assistant", response);

            result.put("response", response);
            result.put("messageCount", history.getMessageCount());
            return ResponseEntity.ok(result);
        } else {
            result.put("error", "Failed to get response from Claude");
            return ResponseEntity.internalServerError().body(result);
        }
    }

    /**
     * Reset conversation history
     * POST /api/chat/reset
     */
    @PostMapping("/reset")
    public ResponseEntity<Map<String, String>> resetChat() {
        history.clear();
        databaseService.clearMessages(currentSessionId);
        logger.info("Conversation history cleared");

        Map<String, String> result = new HashMap<>();
        result.put("status", "Conversation reset");
        return ResponseEntity.ok(result);
    }
}
