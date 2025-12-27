package dev.laszlo.service;

import dev.laszlo.database.CharacterDatabase;
import dev.laszlo.model.Character;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * The brain of the narrative system.
 * Builds layered prompts (base + character) and generates responses.
 */
public class NarrativeEngine {

    private static final Logger logger = LoggerFactory.getLogger(NarrativeEngine.class);

    private final ChatService chatService;
    private final CharacterDatabase characterDb;

    // Base system prompt - NEVER changes
    private static final String BASE_PROMPT =
            "You are an interactive narrative engine. You maintain continuity, " +
                    "tone, and world state. You respond in-character when a character is " +
                    "active, and as a narrator when none is active. You never break immersion.";

    public NarrativeEngine(ChatService chatService, CharacterDatabase characterDb) {
        this.chatService = chatService;
        this.characterDb = characterDb;
        logger.info("🎭 NarrativeEngine initialized");
    }

    /**
     * Generate a response with character context.
     *
     * @param userInput What the user said
     * @param activeCharacterId Which character should respond (e.g., "ilyra", "narrator")
     * @param history The conversation history
     * @return The character's response
     */
    public String generateResponse(
            String userInput,
            String activeCharacterId,
            ConversationHistory history
    ) {
        // 1. Get the active character from database
        Character activeCharacter = characterDb.getCharacter(activeCharacterId);

        if (activeCharacter == null) {
            logger.error("❌ Character not found: {}", activeCharacterId);
            return "Error: Character not found.";
        }

        // 2. Build layered prompt (base + character)
        String layeredPrompt = buildLayeredPrompt(activeCharacter);

        // 3. Set the system prompt with character context
        history.setSystemPrompt(layeredPrompt);

        // 4. Add user's message to history
        history.addUserMessage(userInput);

        // 5. Get Claude's response
        String response = chatService.sendMessage(history);

        // 6. Add response to history
        history.addAssistantMessage(response);

        logger.info("🎭 {} responded ({})", activeCharacter.getName(), activeCharacter.getDefaultMood());

        return response;
    }

    /**
     * Build the complete prompt: Base + Character Context.
     * This is the magic that makes characters feel different!
     */
    private String buildLayeredPrompt(Character character) {
        // If it's the narrator, just use base prompt
        if ("narrator".equals(character.getId())) {
            logger.debug("Using narrator (base prompt only)");
            return BASE_PROMPT;
        }

        // For other characters, add their personality layer
        String characterLayer = "\n\n" +
                "## Current Character\n" +
                "You are currently embodying: **" + character.getName() + "**\n\n" +
                "**Role:** " + character.getRole() + "\n" +
                "**Personality Traits:** " + String.join(", ", character.getPersonality()) + "\n" +
                "**Speech Style:** " + character.getSpeechStyle() + "\n" +
                "**Current Mood:** " + character.getDefaultMood() + "\n" +
                "**Relationship to User:** " + character.getRelationshipToUser() + "\n\n" +
                "**Background:** " + character.getDescription() + "\n\n" +
                "Respond in character. Maintain " + character.getName() + "'s distinct voice, " +
                "personality, and speaking patterns. Show their current mood through subtle cues.";

        logger.debug("Built layered prompt for {}", character.getName());

        return BASE_PROMPT + characterLayer;
    }

    /**
     * Determine character's mood from their response.
     * Simple keyword-based detection (can be enhanced later).
     */
    public String determineMood(String response, Character character) {
        String lowerResponse = response.toLowerCase();

        // Simple mood detection based on keywords
        if (lowerResponse.contains("smile") || lowerResponse.contains("laugh") ||
                lowerResponse.contains("grin")) {
            return "pleased";
        } else if (lowerResponse.contains("frown") || lowerResponse.contains("narrow") ||
                lowerResponse.contains("glare")) {
            return "wary";
        } else if (lowerResponse.contains("sigh") || lowerResponse.contains("distant")) {
            return "melancholic";
        } else if (lowerResponse.contains("excited") || lowerResponse.contains("eager")) {
            return "enthusiastic";
        }

        // Default to character's default mood
        return character.getDefaultMood();
    }
}
