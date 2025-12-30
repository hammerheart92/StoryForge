package dev.laszlo.service;

import dev.laszlo.database.CharacterDatabase;
import dev.laszlo.model.Character;
import dev.laszlo.model.Choice;
import dev.laszlo.model.NarrativeResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Service for generating narrative responses with character-specific voices and branching choices.
 * Uses layered prompts to give each character a distinct personality and speaking style.
 */
@Service
public class NarrativeEngine {
    private static final Logger logger = LoggerFactory.getLogger(NarrativeEngine.class);

    private final ChatService chatService;
    private final CharacterDatabase characterDb;

    // Base narrative prompt - shared by all characters
    private static final String BASE_PROMPT = """
        You are an interactive narrative engine for a fantasy roleplay experience.
        Your role is to create immersive, engaging story moments that respond to the player's choices.
        
        Guidelines:
        - Write in a natural, flowing style
        - Show, don't tell - use vivid sensory details
        - Let character personalities shine through dialogue and actions
        - Keep responses focused and meaningful (2-4 paragraphs)
        - Maintain consistency with established character traits
        - Create moments that invite player interaction
        """;

    public NarrativeEngine(ChatService chatService, CharacterDatabase characterDb) {
        this.chatService = chatService;
        this.characterDb = characterDb;
        logger.info("✨ NarrativeEngine initialized with choice generation");
    }

    /**
     * Generate a simple character response without choices (backward compatibility).
     * This is the original method from Session 13.
     */
    public String generateResponse(String userInput, String activeCharacterId, ConversationHistory history) {
        logger.info("🎭 Generating response for character: {}", activeCharacterId);

        // 1. Get the active character from database
        Character character = characterDb.getCharacter(activeCharacterId);

        if (character == null) {
            logger.error("❌ Character not found: {}", activeCharacterId);
            return "Error: Character not found.";
        }

        // 2. Build layered prompt (base + character)
        String layeredPrompt = buildLayeredPrompt(character);

        // 3. Set the system prompt with character context
        history.setSystemPrompt(layeredPrompt);

        // 4. Add user's message to history
        history.addUserMessage(userInput);

        // 5. Get Claude's response
        String response = chatService.sendMessage(history);

        // 6. Add response to history
        history.addAssistantMessage(response);

        logger.info("🎭 {} responded ({})", character.getName(), character.getDefaultMood());

        return response;
    }

    /**
     * Generate a complete narrative response WITH choices for branching.
     * This is the NEW method for Session 14's choice system.
     *
     * ⭐ UPDATED FOR PHASE 2.3: Now parses JSON to extract dialogue and actionText
     */
    public NarrativeResponse generateResponseWithChoices(
            String userInput,
            String activeCharacterId,
            ConversationHistory history
    ) {
        logger.info("🎭 Generating response WITH CHOICES for character: {}", activeCharacterId);

        // 1. Get character from database
        Character character = characterDb.getCharacter(activeCharacterId);
        if (character == null) {
            logger.error("❌ Character not found: {}", activeCharacterId);
            NarrativeResponse error = new NarrativeResponse();
            error.setDialogue("Error: Character not found");
            return error;
        }

        // 2. Generate character's response (now returns JSON)
        String rawResponse = generateResponse(userInput, activeCharacterId, history);

        // ⭐ DEBUG LOGGING: Track raw response for each character
        logger.info("🔍 [{}] Raw Response Length: {}", activeCharacterId, rawResponse.length());
        logger.info("🔍 [{}] Raw Response Preview (first 200 chars): {}",
                    activeCharacterId,
                    rawResponse.length() > 200 ? rawResponse.substring(0, 200) + "..." : rawResponse);
        logger.info("🔍 [{}] Raw Response Full: {}", activeCharacterId, rawResponse);

// ⭐ NEW: Extract and parse JSON more robustly
        String dialogue = rawResponse;  // Initialize with raw response as fallback
        String actionText = null;

        try {
            // ⭐ IMPROVED: Find valid JSON by trying to parse from each '{' position
            int jsonStart = rawResponse.indexOf('{');

            logger.info("🔍 [{}] JSON Start Index: {}", activeCharacterId, jsonStart);

            if (jsonStart >= 0) {
                boolean parsed = false;
                com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();

                // Try to parse JSON starting from each '{' until we find valid JSON
                for (int i = jsonStart; i < rawResponse.length() && !parsed; i++) {
                    if (rawResponse.charAt(i) == '{') {
                        // Try to parse from this position to the end
                        String candidate = rawResponse.substring(i);

                        try {
                            // Attempt to parse - Jackson will find the correct end of JSON
                            com.fasterxml.jackson.databind.JsonNode json = mapper.readTree(candidate);

                            // Check if this JSON has the expected structure
                            if (json.has("dialogue")) {
                                dialogue = json.get("dialogue").asText();

                                if (json.has("actionText")) {
                                    actionText = json.get("actionText").asText();
                                }

                                parsed = true;
                                logger.info("✅ [{}] Successfully parsed JSON at position {}", activeCharacterId, i);
                                logger.info("✅ [{}] Parsed dialogue: {}", activeCharacterId, dialogue);
                                logger.info("✅ [{}] Parsed actionText: {}", activeCharacterId, actionText);
                            }
                        } catch (com.fasterxml.jackson.core.JsonParseException jpe) {
                            // Not valid JSON at this position, try next '{'
                            continue;
                        }
                    }
                }

                if (!parsed) {
                    // No valid JSON found, use raw response
                    dialogue = rawResponse;
                    logger.warn("⚠️ [{}] No valid JSON with 'dialogue' field found, using raw text", activeCharacterId);
                }
            } else {
                // No JSON found at all, use raw response
                dialogue = rawResponse;
                logger.warn("⚠️ [{}] No JSON braces found in response, using raw text", activeCharacterId);
            }
        } catch (Exception e) {
            // If parsing fails, use raw response as dialogue
            dialogue = rawResponse;
            actionText = null;
            logger.error("❌ [{}] Failed to parse JSON response: {}", activeCharacterId, e.getMessage());
            logger.error("❌ [{}] Exception details: ", activeCharacterId, e);
        }

        // ═══════════════════════════════════════════════════════════════════════════
        // DEBUG LOGGING - CRITICAL FOR FINDING ILYRA BUG
        // ═══════════════════════════════════════════════════════════════════════════
        logger.info("═══════════════════════════════════════════════════════════════════");
        logger.info("CHARACTER: {}", activeCharacterId);
        logger.info("RAW AI RESPONSE: {}", rawResponse);
        logger.info("AFTER JSON PARSING:");
        logger.info("  - dialogue: {}", dialogue);
        logger.info("  - actionText: {}", actionText);
        logger.info("═══════════════════════════════════════════════════════════════════");

        // 3. Generate choices based on the dialogue and context
        List<Choice> choices = generateChoices(activeCharacterId, dialogue, history);

        // 4. Determine character's mood from the response
        String mood = determineMood(dialogue, character);

        // 5. Build complete narrative response
        NarrativeResponse response = new NarrativeResponse();
        response.setDialogue(dialogue);
        response.setActionText(actionText);  // ⭐ NEW: Set the action text
        response.setSpeaker(activeCharacterId);
        response.setSpeakerName(character.getName());
        response.setMood(mood);
        response.setAvatarUrl(character.getAvatarUrl());
        response.setChoices(choices);

        logger.info("✅ Generated narrative response: {} with {} choices",
                character.getName(), choices.size());

        // ⭐ DEBUG LOGGING: Verify final NarrativeResponse object
        logger.info("🔍 [{}] Final NarrativeResponse - dialogue: {}", activeCharacterId, response.getDialogue());
        logger.info("🔍 [{}] Final NarrativeResponse - actionText: {}", activeCharacterId, response.getActionText());
        logger.info("🔍 [{}] Final NarrativeResponse - speaker: {}", activeCharacterId, response.getSpeaker());
        logger.info("🔍 [{}] Final NarrativeResponse - speakerName: {}", activeCharacterId, response.getSpeakerName());

        return response;
    }

    /**
     * Generate narrative choices based on current context.
     * Uses a separate Claude call to generate contextually appropriate choices.
     */
    private List<Choice> generateChoices(
            String currentSpeaker,
            String lastDialogue,
            ConversationHistory history
    ) {
        logger.info("🎲 Generating choices for context...");

        try {
            // Build specialized prompt for choice generation
            String choicePrompt = buildChoicePrompt(currentSpeaker, lastDialogue);

            // Create temporary history for choice generation
            ConversationHistory tempHistory = new ConversationHistory();
            tempHistory.setSystemPrompt(choicePrompt);
            tempHistory.addUserMessage("Generate 2-3 narrative choices based on the context.");

            // Ask Claude to generate choices
            String choicesText = chatService.sendMessage(tempHistory);
            logger.debug("📝 Raw choice response: {}", choicesText);

            // Parse choices from Claude's response
            List<Choice> choices = parseChoices(choicesText, currentSpeaker);

            logger.info("✅ Generated {} choices", choices.size());
            return choices;

        } catch (Exception e) {
            logger.error("❌ Error generating choices: {}", e.getMessage());
            // Return fallback choices on error
            return createFallbackChoices(currentSpeaker);
        }
    }

    /**
     * Build the prompt for Claude to generate narrative choices.
     */
    private String buildChoicePrompt(String currentSpeaker, String lastDialogue) {
        return String.format("""
            You are a narrative choice generator for an interactive fantasy story.
            
            Current situation:
            - Active character: %s
            - Last dialogue: "%s"
            
            Your task: Generate 2-3 meaningful choices for the player.
            
            Requirements:
            - Make choices distinct and interesting
            - Include at least one choice that switches to a different character
            - Vary choice types: actions, questions, observations
            - Keep choices concise (3-8 words each)
            
            Available characters: narrator, ilyra
            
            Format each choice EXACTLY like this:
            [CHOICE: Ask about the constellation | ilyra]
            [CHOICE: Step back and observe | narrator]
            [CHOICE: Offer to help with research | ilyra]
            
            Generate the choices now:
            """, currentSpeaker,
                lastDialogue.length() > 200 ? lastDialogue.substring(0, 200) + "..." : lastDialogue);
    }

    /**
     * Parse choices from Claude's response using regex pattern matching.
     */
    private List<Choice> parseChoices(String response, String currentSpeaker) {
        List<Choice> choices = new ArrayList<>();

        // Pattern: [CHOICE: label text | nextSpeaker]
        Pattern pattern = Pattern.compile("\\[CHOICE:\\s*([^|]+?)\\s*\\|\\s*([^]]+?)\\]");
        Matcher matcher = pattern.matcher(response);

        int choiceId = 1;
        while (matcher.find()) {
            String label = matcher.group(1).trim();
            String nextSpeaker = matcher.group(2).trim().toLowerCase();

            // Validate nextSpeaker
            if (!isValidSpeaker(nextSpeaker)) {
                logger.warn("⚠️ Invalid speaker '{}', defaulting to narrator", nextSpeaker);
                nextSpeaker = "narrator";
            }

            Choice choice = new Choice(
                    "choice_" + choiceId++,
                    label,
                    nextSpeaker
            );
            choices.add(choice);

            logger.debug("📌 Parsed choice: {} -> {}", label, nextSpeaker);
        }

        // If parsing failed or no choices found, return fallback
        if (choices.isEmpty()) {
            logger.warn("⚠️ No choices parsed from response, using fallback");
            return createFallbackChoices(currentSpeaker);
        }

        // Limit to 3 choices maximum
        if (choices.size() > 3) {
            choices = choices.subList(0, 3);
        }

        return choices;
    }

    /**
     * Create fallback choices when parsing fails or as defaults.
     */
    private List<Choice> createFallbackChoices(String currentSpeaker) {
        List<Choice> fallback = new ArrayList<>();

        if ("narrator".equals(currentSpeaker)) {
            fallback.add(new Choice("continue", "Continue exploring", "narrator"));
            fallback.add(new Choice("talk_ilyra", "Approach Ilyra", "ilyra"));
        } else {
            // For any character
            fallback.add(new Choice("continue", "Continue the conversation", currentSpeaker));
            fallback.add(new Choice("step_back", "Step back", "narrator"));
        }

        logger.info("🔄 Using {} fallback choices", fallback.size());
        return fallback;
    }

    /**
     * Validate if a speaker ID is valid.
     */
    private boolean isValidSpeaker(String speakerId) {
        // Check if character exists in database
        try {
            Character character = characterDb.getCharacter(speakerId);
            return character != null;
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Build the complete prompt: Base + Character Context.
     * This is the magic that makes characters feel different!
     */
    private String buildLayeredPrompt(Character character) {
        // If it's the narrator, just use base prompt
        if ("narrator".equals(character.getId())) {
            logger.debug("Using narrator (base prompt only)");
            return BASE_PROMPT + """
        
        ## Current Character: Narrator
        You are the omniscient narrator. Describe scenes in third-person with rich detail.
        Set atmosphere, describe environments, and guide the story forward.
        Your voice is neutral, observant, and immersive.
        
        CRITICAL: You MUST respond with valid JSON in this EXACT format:
        {
          "dialogue": "Your spoken narration here",
          "actionText": "Brief scene description (1-2 sentences)"
        }
        
        Guidelines:
        - dialogue: Your narrative description (what you observe and describe)
        - actionText: Physical scene details, atmosphere, movements (1-2 sentences max)
        - ALWAYS include BOTH fields
        - Keep actionText concise and evocative
        
        Example:
        {
          "dialogue": "The ancient observatory stands before you, its mechanisms still turning after centuries.",
          "actionText": "Starlight filters through crystalline windows, casting patterns on the stone floor."
        }
        """;
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
                "personality, and speaking patterns. Show their current mood through subtle cues.\n\n" +

                // NEW: Add JSON format requirement
                "CRITICAL: You MUST respond with valid JSON in this EXACT format:\n" +
                "{\n" +
                "  \"dialogue\": \"Your spoken words here\",\n" +
                "  \"actionText\": \"Brief action/gesture description (1-2 sentences)\"\n" +
                "}\n\n" +

                "Guidelines for JSON response:\n" +
                "- dialogue: What " + character.getName() + " says (in their voice)\n" +
                "- actionText: What " + character.getName() + " does - gestures, expressions, movements (1-2 sentences max)\n" +
                "- ALWAYS include BOTH fields\n" +
                "- actionText shows emotion through body language\n" +
                "- Use present tense for actionText\n\n" +

                "Example response:\n" +
                "{\n" +
                "  \"dialogue\": \"The stars tell ancient stories, if you know how to listen.\",\n" +
                "  \"actionText\": \"She traces constellation patterns in the air, her eyes distant and contemplative.\"\n" +
                "}";

        logger.debug("Built layered prompt for {}", character.getName());

        return BASE_PROMPT + characterLayer;
    }

    /**
     * Determine character's mood from their response.
     * Simple keyword-based detection (can be enhanced later).
     */
    public String determineMood(String response, Character character) {
        if (response == null || response.isEmpty()) {
            return character.getDefaultMood();
        }

        String lowerResponse = response.toLowerCase();

        // Check for mood indicators
        if (lowerResponse.contains("smile") || lowerResponse.contains("laugh") ||
                lowerResponse.contains("grin")) {
            return "pleased";
        }
        if (lowerResponse.contains("frown") || lowerResponse.contains("scowl") ||
                lowerResponse.contains("glare")) {
            return "displeased";
        }
        if (lowerResponse.contains("sigh") || lowerResponse.contains("distant") ||
                lowerResponse.contains("wistful")) {
            return "melancholic";
        }
        if (lowerResponse.contains("exclaim") || lowerResponse.contains("excited") ||
                lowerResponse.contains("enthusiasm")) {
            return "excited";
        }
        if (lowerResponse.contains("narrow") || lowerResponse.contains("suspicious") ||
                lowerResponse.contains("cautious")) {
            return "wary";
        }

        // Default to character's default mood
        return character.getDefaultMood();
    }
}