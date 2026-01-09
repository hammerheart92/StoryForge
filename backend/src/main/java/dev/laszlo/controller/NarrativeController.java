package dev.laszlo.controller;

import dev.laszlo.database.CharacterDatabase;
import dev.laszlo.database.DatabaseService;
import dev.laszlo.model.Character;
import dev.laszlo.model.NarrativeResponse;
import dev.laszlo.model.Session;
import dev.laszlo.service.ConversationHistory;
import dev.laszlo.service.NarrativeEngine;
import dev.laszlo.service.StorySaveService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST controller for narrative interactions.
 * ⭐ SESSION 21: Added storyId support for multi-story system
 * ⭐ SESSION 26: Integrated StorySaveService for persistent multi-story saves
 */
@RestController
@RequestMapping("/api/narrative")
@CrossOrigin(origins = "*")
public class NarrativeController {

    private static final Logger logger = LoggerFactory.getLogger(NarrativeController.class);

    private final NarrativeEngine narrativeEngine;
    private final CharacterDatabase characterDb;
    private final DatabaseService databaseService;
    private final StorySaveService storySaveService;  // ⭐ SESSION 26: Database save service

    private int currentSessionId;

    /**
     * Spring automatically injects these dependencies.
     * ⭐ SESSION 26: Added StorySaveService injection
     */
    public NarrativeController(
            NarrativeEngine narrativeEngine,
            CharacterDatabase characterDb,
            DatabaseService databaseService,
            StorySaveService storySaveService  // ⭐ NEW
    ) {
        this.narrativeEngine = narrativeEngine;
        this.characterDb = characterDb;
        this.databaseService = databaseService;
        this.storySaveService = storySaveService;  // ⭐ NEW

        // Initialize with a default session
        List<Session> sessions = databaseService.getAllSessions();
        if (sessions.isEmpty()) {
            this.currentSessionId = databaseService.createSession("Narrative Session");
        } else {
            this.currentSessionId = sessions.get(0).getId();
        }

        logger.info("🎭 NarrativeController initialized with session {} and persistent save system", currentSessionId);
    }

    /**
     * ⭐ SESSION 26: UPDATED - Get or create conversation history from DATABASE.
     * Each story maintains independent conversation context.
     * Now persists across server restarts!
     */
    private ConversationHistory getHistoryForStory(String storyId) {
        // Try to load existing save from database
        ConversationHistory history = storySaveService.loadStoryProgress(storyId, 1);

        if (history != null) {
            logger.info("📂 Loaded existing save for story: {} ({} messages)",
                    storyId, history.getMessageCount());
            return history;
        } else {
            // No save exists, create new history
            logger.info("📖 Creating new conversation history for story: {}", storyId);
            return new ConversationHistory();
        }
    }

    /**
     * ⭐ SESSION 26: NEW - Save conversation progress to database.
     * Called after each user interaction to persist state.
     */
    private void saveHistoryForStory(String storyId, ConversationHistory history, String currentSpeaker) {
        boolean saved = storySaveService.saveStoryProgress(storyId, 1, history, currentSpeaker);

        if (saved) {
            logger.debug("💾 Auto-saved progress for story: {} ({} messages)",
                    storyId, history.getMessageCount());
        } else {
            logger.warn("⚠️ Failed to save progress for story: {}", storyId);
        }
    }

    /**
     * Get all available characters.
     * GET /api/narrative/characters
     *
     * Example: curl http://localhost:8080/api/narrative/characters
     */
    @GetMapping("/characters")
    public ResponseEntity<List<Character>> getCharacters() {
        List<Character> characters = characterDb.getAllCharacters();
        logger.info("📂 Returning {} characters", characters.size());
        return ResponseEntity.ok(characters);
    }

    /**
     * Get a specific character by ID.
     * GET /api/narrative/characters/{id}
     *
     * Example: curl http://localhost:8080/api/narrative/characters/ilyra
     */
    @GetMapping("/characters/{id}")
    public ResponseEntity<Character> getCharacter(@PathVariable String id) {
        Character character = characterDb.getCharacter(id);

        if (character == null) {
            logger.warn("⚠️ Character not found: {}", id);
            return ResponseEntity.notFound().build();
        }

        return ResponseEntity.ok(character);
    }

    /**
     * UPDATED: Session 21 - Send a message and get a response WITH CHOICES.
     * ⭐ SESSION 26 - Auto-saves progress to database after response
     * POST /api/narrative/speak
     *
     * Request body:
     * {
     *   "message": "What are you studying?",
     *   "speaker": "ilyra",
     *   "storyId": "observatory"
     * }
     *
     * Response:
     * {
     *   "dialogue": "She pauses... 'The heavens speak...'",
     *   "speaker": "ilyra",
     *   "speakerName": "Ilyra",
     *   "mood": "wary",
     *   "avatarUrl": null,
     *   "choices": [
     *     {
     *       "id": "choice_1",
     *       "label": "Ask about the constellation",
     *       "nextSpeaker": "ilyra"
     *     },
     *     {
     *       "id": "choice_2",
     *       "label": "Step back and observe",
     *       "nextSpeaker": "narrator"
     *     }
     *   ]
     * }
     */
    @PostMapping("/speak")
    public ResponseEntity<NarrativeResponse> speak(@RequestBody Map<String, String> request) {
        String userMessage = request.get("message");
        String speakerId = request.get("speaker");
        String storyId = request.get("storyId");  // ⭐ NEW: Get storyId from request

        // Validate input
        if (userMessage == null || userMessage.isBlank()) {
            NarrativeResponse error = new NarrativeResponse();
            error.setDialogue("Error: Message cannot be empty");
            return ResponseEntity.badRequest().body(error);
        }

        if (speakerId == null || speakerId.isBlank()) {
            speakerId = "narrator";  // Default to narrator
        }

        // ⭐ NEW: Validate and default storyId
        if (storyId == null || storyId.isBlank()) {
            storyId = "observatory";  // Default to observatory story
            logger.debug("No storyId provided, defaulting to 'observatory'");
        }

        logger.info("💬 User: '{}' | Speaker: {} | Story: {}", userMessage, speakerId, storyId);

        // Get the character
        Character speaker = characterDb.getCharacter(speakerId);
        if (speaker == null) {
            NarrativeResponse error = new NarrativeResponse();
            error.setDialogue("Error: Character not found: " + speakerId);
            return ResponseEntity.badRequest().body(error);
        }

        // ⭐ SESSION 26: Load story-specific history from database
        ConversationHistory history = getHistoryForStory(storyId);

        NarrativeResponse response = narrativeEngine.generateResponseWithChoices(
                userMessage,
                speakerId,
                storyId,
                history  // ✅ NEW: story-scoped history (now from database)
        );

        // Save to old session database (backwards compatibility)
        databaseService.saveMessage(currentSessionId, "user", userMessage);
        databaseService.saveMessage(currentSessionId, speakerId, response.getDialogue());

        // ⭐ SESSION 26: Auto-save progress to database
        saveHistoryForStory(storyId, history, response.getSpeaker());

        logger.info("✅ {} responded with {} choices (progress auto-saved)",
                response.getSpeakerName(),
                response.getChoices().size());

        return ResponseEntity.ok(response);
    }

    /**
     * UPDATED: Session 21 - Handle choice selection and continue the narrative.
     * ⭐ SESSION 26 - Auto-saves progress to database after response
     * POST /api/narrative/choose
     *
     * Request body:
     * {
     *   "choiceId": "choice_2",
     *   "label": "Ask about the constellation",
     *   "nextSpeaker": "ilyra",
     *   "storyId": "observatory"
     * }
     *
     * Response: NarrativeResponse with new dialogue and choices
     */
    @PostMapping("/choose")
    public ResponseEntity<NarrativeResponse> choose(@RequestBody Map<String, String> request) {
        String choiceId = request.get("choiceId");
        String choiceLabel = request.get("label");
        String nextSpeaker = request.get("nextSpeaker");
        String storyId = request.get("storyId");  // ⭐ NEW: Get storyId from request

        // Validate input
        if (choiceId == null || nextSpeaker == null) {
            NarrativeResponse error = new NarrativeResponse();
            error.setDialogue("Error: Invalid choice (missing choiceId or nextSpeaker)");
            return ResponseEntity.badRequest().body(error);
        }

        if (choiceLabel == null) {
            choiceLabel = "Continue";  // Default label
        }

        // ⭐ NEW: Validate and default storyId
        if (storyId == null || storyId.isBlank()) {
            storyId = "observatory";  // Default to observatory story
            logger.debug("No storyId provided, defaulting to 'observatory'");
        }

        logger.info("🎯 User chose: '{}' -> {} | Story: {}", choiceLabel, nextSpeaker, storyId);

        // Save the choice to old database (backwards compatibility)
        databaseService.saveUserChoice(currentSessionId, choiceId, choiceLabel, nextSpeaker);

        // Create transition message based on the choice
        String transitionMessage = "You chose: " + choiceLabel;

        // ⭐ SESSION 26: Load story-specific history from database
        ConversationHistory history = getHistoryForStory(storyId);

        NarrativeResponse response = narrativeEngine.generateResponseWithChoices(
                transitionMessage,
                nextSpeaker,
                storyId,
                history  // ✅ NEW: story-scoped history (now from database)
        );

        // Save messages to old session database (backwards compatibility)
        databaseService.saveMessage(currentSessionId, "user", transitionMessage);
        databaseService.saveMessage(currentSessionId, nextSpeaker, response.getDialogue());

        // ⭐ SESSION 26: Auto-save progress to database
        saveHistoryForStory(storyId, history, response.getSpeaker());

        logger.info("✅ {} responded after choice with {} new choices (progress auto-saved)",
                response.getSpeakerName(),
                response.getChoices().size());

        return ResponseEntity.ok(response);
    }

    /**
     * Health check endpoint.
     * GET /api/narrative/status
     */
    @GetMapping("/status")
    public ResponseEntity<Map<String, Object>> getStatus() {
        Map<String, Object> status = new HashMap<>();
        status.put("status", "running");
        status.put("charactersAvailable", characterDb.getAllCharacters().size());
        status.put("currentSession", currentSessionId);
        status.put("choiceCount", databaseService.getChoiceCount(currentSessionId));
        return ResponseEntity.ok(status);
    }

    /**
     * NEW: Session 14 - Get choice history for current session.
     * GET /api/narrative/choices
     */
    @GetMapping("/choices")
    public ResponseEntity<List<String[]>> getChoiceHistory() {
        List<String[]> choices = databaseService.getChoiceHistory(currentSessionId);
        logger.info("📊 Returning {} choices from session {}", choices.size(), currentSessionId);
        return ResponseEntity.ok(choices);
    }
}