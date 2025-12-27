package dev.laszlo.controller;

import dev.laszlo.database.CharacterDatabase;
import dev.laszlo.database.DatabaseService;
import dev.laszlo.model.Character;
import dev.laszlo.model.NarrativeResponse;
import dev.laszlo.model.Session;
import dev.laszlo.service.ConversationHistory;
import dev.laszlo.service.NarrativeEngine;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/narrative")
@CrossOrigin(origins = "*")
public class NarrativeController {

    private static final Logger logger = LoggerFactory.getLogger(NarrativeController.class);

    private final NarrativeEngine narrativeEngine;
    private final CharacterDatabase characterDb;
    private final DatabaseService databaseService;
    private final ConversationHistory history;

    private int currentSessionId;

    /**
     * Spring automatically injects these dependencies.
     */
    public NarrativeController(
            NarrativeEngine narrativeEngine,
            CharacterDatabase characterDb,
            DatabaseService databaseService
    ) {
        this.narrativeEngine = narrativeEngine;
        this.characterDb = characterDb;
        this.databaseService = databaseService;
        this.history = new ConversationHistory();

        // Initialize with a default session
        List<Session> sessions = databaseService.getAllSessions();
        if (sessions.isEmpty()) {
            this.currentSessionId = databaseService.createSession("Narrative Session");
        } else {
            this.currentSessionId = sessions.get(0).getId();
        }

        logger.info("🎭 NarrativeController initialized with session {}", currentSessionId);
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
     * UPDATED: Session 14 - Send a message and get a response WITH CHOICES.
     * POST /api/narrative/speak
     *
     * Request body:
     * {
     *   "message": "What are you studying?",
     *   "speaker": "ilyra"
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

        // Validate input
        if (userMessage == null || userMessage.isBlank()) {
            NarrativeResponse error = new NarrativeResponse();
            error.setDialogue("Error: Message cannot be empty");
            return ResponseEntity.badRequest().body(error);
        }

        if (speakerId == null || speakerId.isBlank()) {
            speakerId = "narrator";  // Default to narrator
        }

        logger.info("💬 User: '{}' | Speaker: {}", userMessage, speakerId);

        // Get the character
        Character speaker = characterDb.getCharacter(speakerId);
        if (speaker == null) {
            NarrativeResponse error = new NarrativeResponse();
            error.setDialogue("Error: Character not found: " + speakerId);
            return ResponseEntity.badRequest().body(error);
        }

        // UPDATED: Generate response WITH choices
        NarrativeResponse response = narrativeEngine.generateResponseWithChoices(
                userMessage,
                speakerId,
                history
        );

        // Save to database
        databaseService.saveMessage(currentSessionId, "user", userMessage);
        databaseService.saveMessage(currentSessionId, speakerId, response.getDialogue());

        logger.info("✅ {} responded with {} choices",
                response.getSpeakerName(),
                response.getChoices().size());

        return ResponseEntity.ok(response);
    }

    /**
     * NEW: Session 14 - Handle choice selection and continue the narrative.
     * POST /api/narrative/choose
     *
     * Request body:
     * {
     *   "choiceId": "choice_2",
     *   "label": "Ask about the constellation",
     *   "nextSpeaker": "ilyra"
     * }
     *
     * Response: NarrativeResponse with new dialogue and choices
     */
    @PostMapping("/choose")
    public ResponseEntity<NarrativeResponse> choose(@RequestBody Map<String, String> request) {
        String choiceId = request.get("choiceId");
        String choiceLabel = request.get("label");
        String nextSpeaker = request.get("nextSpeaker");

        // Validate input
        if (choiceId == null || nextSpeaker == null) {
            NarrativeResponse error = new NarrativeResponse();
            error.setDialogue("Error: Invalid choice (missing choiceId or nextSpeaker)");
            return ResponseEntity.badRequest().body(error);
        }

        if (choiceLabel == null) {
            choiceLabel = "Continue";  // Default label
        }

        logger.info("🎯 User chose: '{}' -> {}", choiceLabel, nextSpeaker);

        // Save the choice to database
        databaseService.saveUserChoice(currentSessionId, choiceId, choiceLabel, nextSpeaker);

        // Create transition message based on the choice
        String transitionMessage = "You chose: " + choiceLabel;

        // Generate response from the next speaker
        NarrativeResponse response = narrativeEngine.generateResponseWithChoices(
                transitionMessage,
                nextSpeaker,
                history
        );

        // Save messages to database
        databaseService.saveMessage(currentSessionId, "user", transitionMessage);
        databaseService.saveMessage(currentSessionId, nextSpeaker, response.getDialogue());

        logger.info("✅ {} responded after choice with {} new choices",
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