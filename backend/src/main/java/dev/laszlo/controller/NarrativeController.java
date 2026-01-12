package dev.laszlo.controller;

import dev.laszlo.database.CharacterDatabase;
import dev.laszlo.database.DatabaseService;
import dev.laszlo.model.Character;
import dev.laszlo.model.NarrativeResponse;
import dev.laszlo.model.Session;
import dev.laszlo.service.ConversationHistory;
import dev.laszlo.service.CurrencyService;
import dev.laszlo.service.NarrativeEngine;
import dev.laszlo.service.StorySaveService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import dev.laszlo.dto.SaveInfoDTO;
import java.time.LocalDateTime;
import java.util.stream.Collectors;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * REST controller for narrative interactions.
 * ⭐ SESSION 21: Added storyId support for multi-story system
 * ⭐ SESSION 26: Integrated StorySaveService for persistent multi-story saves
 * ⭐ SESSION 29: Added save slot management endpoints
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
    private final CurrencyService currencyService;

    private int currentSessionId;

    /**
     * Spring automatically injects these dependencies.
     * ⭐ SESSION 26: Added StorySaveService injection
     */
    public NarrativeController(
            NarrativeEngine narrativeEngine,
            CharacterDatabase characterDb,
            DatabaseService databaseService,
            StorySaveService storySaveService,  // ⭐ NEW
            CurrencyService currencyService
    ) {
        this.narrativeEngine = narrativeEngine;
        this.characterDb = characterDb;
        this.databaseService = databaseService;
        this.storySaveService = storySaveService;  // ⭐ NEW
        this.currencyService = currencyService;

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
    private ConversationHistory getHistoryForStory(String storyId, int saveSlot) {
        ConversationHistory history = storySaveService.loadStoryProgress(storyId, saveSlot);

        if (history != null) {
            logger.info("📂 Loaded existing save for story: {} slot: {} ({} messages)",
                    storyId, saveSlot, history.getMessageCount());
            return history;
        } else {
            logger.info("📖 Creating new conversation history for story: {} slot: {}", storyId, saveSlot);
            return new ConversationHistory();
        }
    }

    /**
     * ⭐ SESSION 26: NEW - Save conversation progress to database.
     * Called after each user interaction to persist state.
     */
    private void saveHistoryForStory(String storyId, int saveSlot, ConversationHistory history, String currentSpeaker) {
        boolean saved = storySaveService.saveStoryProgress(storyId, saveSlot, history, currentSpeaker);

        if (saved) {
            logger.debug("💾 Auto-saved progress for story: {} slot: {} ({} messages)",
                    storyId, saveSlot, history.getMessageCount());
        } else {
            logger.warn("⚠️ Failed to save progress for story: {} slot: {}", storyId, saveSlot);
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
        int saveSlot = Integer.parseInt(request.getOrDefault("saveSlot", "1"));

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
        ConversationHistory history = getHistoryForStory(storyId, saveSlot);

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
        saveHistoryForStory(storyId, saveSlot, history, response.getSpeaker());

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
        int saveSlot = Integer.parseInt(request.getOrDefault("saveSlot", "1"));

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
        ConversationHistory history = getHistoryForStory(storyId, saveSlot);

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
        saveHistoryForStory(storyId, saveSlot, history, response.getSpeaker());

        // ⭐ PHASE 1 GALLERY: Handle story completion and gem awards
        String userId = "default";

        if (response.getChoices().isEmpty()) {
            // Story completed - award completion bonus
            storySaveService.markStoryCompleted(storyId, saveSlot, userId);
            currencyService.awardGems(userId, 100, "story_completed", storyId);
            logger.info("🏆 Story {} completed! +100 gem bonus", storyId);
        } else {
            // Story continues - award per-choice gems
            currencyService.awardGems(userId, 5, "choice_made", storyId);
            logger.debug("💎 +5 gems for choice in {}", storyId);
        }

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

    // ═══════════════════════════════════════════════════════════════════════════
// SAVE MANAGEMENT ENDPOINTS (SESSION 28 + SESSION 29)
// ═══════════════════════════════════════════════════════════════════════════

    /**
     * Get all saves for the current user.
     * Used by Story Library screen to display all stories with progress.
     * ⭐ SESSION 29: UPDATED to include saveSlot
     */
    @GetMapping("/saves")
    public ResponseEntity<List<SaveInfoDTO>> getAllSaves() {
        try {
            String userId = "default";  // Future: get from authentication
            List<StorySaveService.SaveInfo> saves = storySaveService.getAllSavesForUser(userId);

            // Convert SaveInfo to SaveInfoDTO
            List<SaveInfoDTO> dtos = saves.stream()
                    .map(save -> new SaveInfoDTO(
                            save.storyId,
                            save.saveSlot,  // ⭐ NEW: Include slot number
                            save.currentSpeaker,
                            save.currentSpeaker,  // characterName = currentSpeaker for now
                            save.messageCount,
                            LocalDateTime.parse(save.lastPlayedAt),
                            save.isCompleted
                    ))
                    .collect(Collectors.toList());

            logger.info("📋 Returning {} saves", dtos.size());
            return ResponseEntity.ok(dtos);

        } catch (Exception e) {
            logger.error("❌ Error fetching saves: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Get a specific save by storyId (defaults to slot 1).
     * Used by Story Library to check if save exists for a story.
     * ⭐ SESSION 29: UPDATED to include saveSlot
     */
    @GetMapping("/saves/{storyId}")
    public ResponseEntity<SaveInfoDTO> getSaveByStory(@PathVariable String storyId) {
        try {
            String userId = "default";  // Future: get from authentication
            StorySaveService.SaveInfo save = storySaveService.getSaveByStoryId(userId, storyId);

            if (save == null) {
                return ResponseEntity.notFound().build();
            }

            SaveInfoDTO dto = new SaveInfoDTO(
                    save.storyId,
                    save.saveSlot,  // ⭐ NEW: Include slot number
                    save.currentSpeaker,
                    save.currentSpeaker,  // characterName = currentSpeaker for now
                    save.messageCount,
                    LocalDateTime.parse(save.lastPlayedAt),
                    save.isCompleted
            );

            logger.info("📂 Returning save for story: {}", storyId);
            return ResponseEntity.ok(dto);

        } catch (Exception e) {
            logger.error("❌ Error fetching save for {}: {}", storyId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * Delete a specific save by storyId (defaults to slot 1).
     * Used by Story Library when user long-presses to delete a save.
     */
    @DeleteMapping("/saves/{storyId}")
    public ResponseEntity<Void> deleteSave(@PathVariable String storyId) {
        try {
            String userId = "default";  // Future: get from authentication
            boolean deleted = storySaveService.deleteSaveByStoryId(userId, storyId);  // ⭐ FIXED

            if (deleted) {
                logger.info("🗑️ Deleted save for story: {}", storyId);
                return ResponseEntity.noContent().build();
            } else {
                logger.warn("⚠️ No save found to delete for story: {}", storyId);
                return ResponseEntity.notFound().build();
            }

        } catch (Exception e) {
            logger.error("❌ Error deleting save for {}: {}", storyId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * ⭐ NEW: SESSION 29 - Get all saves for a specific story (all slots 1-5).
     * Used by Story Slot Selection screen to show all available saves for one story.
     *
     * GET /api/narrative/saves/story/{storyId}
     *
     * Example: curl http://localhost:8080/api/narrative/saves/story/pirates
     * Returns: [
     *   {storyId: "pirates", saveSlot: 1, messageCount: 45, ...},
     *   {storyId: "pirates", saveSlot: 2, messageCount: 12, ...}
     * ]
     */
    @GetMapping("/saves/story/{storyId}")
    public ResponseEntity<List<SaveInfoDTO>> getSavesForStory(@PathVariable String storyId) {
        try {
            String userId = "default";  // Future: get from authentication
            List<StorySaveService.SaveInfo> saves = storySaveService.getAllSavesForStory(userId, storyId);

            // Convert SaveInfo to SaveInfoDTO
            List<SaveInfoDTO> dtos = saves.stream()
                    .map(save -> new SaveInfoDTO(
                            save.storyId,
                            save.saveSlot,  // Include slot number
                            save.currentSpeaker,
                            save.currentSpeaker,  // characterName = currentSpeaker for now
                            save.messageCount,
                            LocalDateTime.parse(save.lastPlayedAt),
                            save.isCompleted
                    ))
                    .collect(Collectors.toList());

            logger.info("📋 Returning {} saves for story: {}", dtos.size(), storyId);
            return ResponseEntity.ok(dtos);

        } catch (Exception e) {
            logger.error("❌ Error fetching saves for story {}: {}", storyId, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }

    /**
     * ⭐ NEW: SESSION 29 - Delete a specific save slot.
     * Used by Story Slot Selection screen when user deletes individual slot.
     *
     * DELETE /api/narrative/saves/{storyId}/{saveSlot}
     *
     * Example: curl -X DELETE http://localhost:8080/api/narrative/saves/pirates/2
     */
    @DeleteMapping("/saves/{storyId}/{saveSlot}")
    public ResponseEntity<Void> deleteSaveSlot(
            @PathVariable String storyId,
            @PathVariable int saveSlot
    ) {
        try {
            String userId = "default";  // Future: get from authentication
            boolean deleted = storySaveService.deleteSave(storyId, saveSlot);

            if (deleted) {
                logger.info("🗑️ Deleted save for story: {} slot: {}", storyId, saveSlot);
                return ResponseEntity.noContent().build();
            } else {
                logger.warn("⚠️ No save found to delete for story: {} slot: {}", storyId, saveSlot);
                return ResponseEntity.notFound().build();
            }

        } catch (Exception e) {
            logger.error("❌ Error deleting save for {} slot {}: {}", storyId, saveSlot, e.getMessage());
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();
        }
    }
}