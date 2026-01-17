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
 *
 * ⭐ SESSION 34: Added ending detection for story completion tracking.
 */
@Service
public class NarrativeEngine {
    private static final Logger logger = LoggerFactory.getLogger(NarrativeEngine.class);

    private final ChatService chatService;
    private final CharacterDatabase characterDb;

    // ⭐ SESSION 34: Pattern to detect story ending markers in Claude's response
    // Matches [END:ending_id] where ending_id is lowercase letters/underscores
    private static final Pattern ENDING_PATTERN =
            Pattern.compile("\\[END:([a-z_]+)\\]", Pattern.CASE_INSENSITIVE);

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
     * <p>
     * ⭐ UPDATED FOR PHASE 2.3: Now parses JSON to extract dialogue and actionText
     */
    public NarrativeResponse generateResponseWithChoices(
            String userInput,
            String activeCharacterId,
            String storyId,
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
        String extractedMood = null;  // ⭐ SESSION 26: Variable to store mood

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

                                // ⭐ SESSION 26: Extract mood from JSON
                                if (json.has("mood")) {
                                    extractedMood = json.get("mood").asText().trim();
                                    logger.info("✅ [{}] Extracted mood from JSON: {}", activeCharacterId, extractedMood);
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
        List<Choice> choices = generateChoices(activeCharacterId, dialogue, storyId, history);

        // 4. Determine character's mood from the response
        // ⭐ SESSION 26: Use extracted mood if available, otherwise determine from response
        String mood;
        if (extractedMood != null && !extractedMood.isEmpty()) {
            mood = extractedMood;
            logger.info("✅ Using mood from JSON: {}", mood);
        } else {
            mood = determineMood(dialogue, character);
            logger.info("🔍 Determined mood from text analysis: {}", mood);
        }

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

        // ⭐ SESSION 34: Check for story ending markers
        String endingId = detectEnding(dialogue, actionText);
        if (endingId != null) {
            response.setEnding(true);
            response.setEndingId(endingId);
            response.setChoices(new ArrayList<>()); // Clear choices - story is over
            logger.info("🏆 Story ending detected: {} (ending: {})", activeCharacterId, endingId);
        }

        // ⭐ DEBUG LOGGING: Verify final NarrativeResponse object
        logger.info("🔍 [{}] Final NarrativeResponse - dialogue: {}", activeCharacterId, response.getDialogue());
        logger.info("🔍 [{}] Final NarrativeResponse - actionText: {}", activeCharacterId, response.getActionText());
        logger.info("🔍 [{}] Final NarrativeResponse - speaker: {}", activeCharacterId, response.getSpeaker());
        logger.info("🔍 [{}] Final NarrativeResponse - speakerName: {}", activeCharacterId, response.getSpeakerName());
        logger.info("🔍 [{}] Final NarrativeResponse - isEnding: {}, endingId: {}",
                activeCharacterId, response.isEnding(), response.getEndingId());

        return response;
    }

    /**
     * ⭐ SESSION 34: Detect ending markers in the narrative response.
     * Looks for [END:ending_id] pattern in dialogue or actionText.
     *
     * @param dialogue The character's dialogue
     * @param actionText The action/gesture text (may be null)
     * @return The ending ID if found, null otherwise
     */
    private String detectEnding(String dialogue, String actionText) {
        // Check dialogue first
        if (dialogue != null) {
            Matcher matcher = ENDING_PATTERN.matcher(dialogue);
            if (matcher.find()) {
                String endingId = matcher.group(1).toLowerCase();
                logger.info("🏆 Found ending marker in dialogue: [END:{}]", endingId);
                return endingId;
            }
        }

        // Then check actionText
        if (actionText != null) {
            Matcher matcher = ENDING_PATTERN.matcher(actionText);
            if (matcher.find()) {
                String endingId = matcher.group(1).toLowerCase();
                logger.info("🏆 Found ending marker in actionText: [END:{}]", endingId);
                return endingId;
            }
        }

        return null;
    }

    /**
     * Generate narrative choices based on current context.
     * Uses a separate Claude call to generate contextually appropriate choices.
     */
    private List<Choice> generateChoices(
            String currentSpeaker,
            String lastDialogue,
            String storyId,
            ConversationHistory history
    ) {
        logger.info("🎲 Generating choices for context...");

        try {
            // Build specialized prompt for choice generation
            String choicePrompt = buildChoicePrompt(currentSpeaker, lastDialogue, storyId);

            // Create temporary history for choice generation
            ConversationHistory tempHistory = new ConversationHistory();
            tempHistory.setSystemPrompt(choicePrompt);
            tempHistory.addUserMessage("Generate 2-3 narrative choices based on the context.");

            // Ask Claude to generate choices
            String choicesText = chatService.sendMessage(tempHistory);
            logger.debug("📝 Raw choice response: {}", choicesText);

            // Parse choices from Claude's response
            List<Choice> choices = parseChoices(choicesText, currentSpeaker, storyId);

            logger.info("✅ Generated {} choices", choices.size());
            return choices;

        } catch (Exception e) {
            logger.error("❌ Error generating choices: {}", e.getMessage());
            // Return fallback choices on error
            return createFallbackChoices(currentSpeaker, storyId);
        }
    }

    /**
     * Build the prompt for Claude to generate narrative choices.
     */

    private String buildChoicePrompt(String currentSpeaker, String lastDialogue, String storyId) {
        // ⭐ Get characters for this story
        List<Character> storyCharacters = characterDb.getCharactersByStory(storyId);
        String characterList = storyCharacters.stream()
                .map(Character::getId)
                .collect(java.util.stream.Collectors.joining(", "));

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
                                
                        Available characters: %s
                                
                        Format each choice EXACTLY like this:
                        [CHOICE: Ask about the constellation | ilyra]
                        [CHOICE: Step back and observe | narrator]
                        [CHOICE: Offer to help with research | ilyra]
                                
                        Generate the choices now:
                        """, currentSpeaker,
                lastDialogue.length() > 200 ? lastDialogue.substring(0, 200) + "..." : lastDialogue,
                characterList);
    }

    /**
     * Parse choices from Claude's response using regex pattern matching.
     */
    private List<Choice> parseChoices(String response, String currentSpeaker, String storyId) {
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
            return createFallbackChoices(currentSpeaker, storyId);
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
    private List<Choice> createFallbackChoices(String currentSpeaker, String storyId) {
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
     * ⭐ SESSION 26: Added mood inference for Pirates story characters
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

        // ⭐ NEW: Get mood options for character
        String moodInstructions = getMoodInstructionsForCharacter(character.getId());

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

                // ⭐ UPDATED: Add mood field to JSON format
                "CRITICAL: You MUST respond with valid JSON in this EXACT format:\n" +
                "{\n" +
                "  \"dialogue\": \"Your spoken words here\",\n" +
                "  \"actionText\": \"Brief action/gesture description (1-2 sentences)\",\n" +
                "  \"mood\": \"current_emotional_state\"\n" +
                "}\n\n" +

                "Guidelines for JSON response:\n" +
                "- dialogue: What " + character.getName() + " says (in their voice)\n" +
                "- actionText: What " + character.getName() + " does - gestures, expressions, movements (1-2 sentences max)\n" +
                "- mood: Your current emotional state (see mood options below)\n" +
                "- ALWAYS include ALL THREE fields\n" +
                "- actionText shows emotion through body language\n" +
                "- Use present tense for actionText\n\n" +

                moodInstructions +  // ⭐ Add character-specific mood options

                "Example response:\n" +
                "{\n" +
                "  \"dialogue\": \"The stars tell ancient stories, if you know how to listen.\",\n" +
                "  \"actionText\": \"She traces constellation patterns in the air, her eyes distant and contemplative.\",\n" +
                "  \"mood\": \"wary\"\n" +
                "}";

        logger.debug("Built layered prompt for {}", character.getName());

        return BASE_PROMPT + characterLayer;
    }

    /**
     * ⭐ NEW SESSION 26: Get mood instructions for specific characters.
     * Pirates characters (Blackwood/Isla) get detailed mood options.
     * Other characters use generic moods.
     */
    private String getMoodInstructionsForCharacter(String characterId) {
        switch (characterId.toLowerCase()) {
            case "blackwood":
                return """
                        
                        **MOOD OPTIONS for Captain Blackwood:**
                        Choose the mood that best reflects your current emotional state:
                        
                        - "defiant" - Challenged, refusing to back down, asserting authority
                        - "frustrated" - Plans going wrong, rejected by Isla, irritated
                        - "angry" - Genuinely enraged, dangerous, seeing red
                        - "contemplative" - Reflecting on feelings, processing emotions, introspective
                        - "longing" - Expressing desire for Isla, yearning, romantically vulnerable
                        - "melancholic" - Sad, regretful, haunted by past, sorrowful
                        - "charming" - Trying to win someone over, smooth, seductive
                        - "triumphant" - Celebrating success, victorious, proud
                        - "confident" - Assured, in control, commanding presence
                        
                        Select ONE mood that best fits this moment.
                        
                        """;

            case "isla":
                return """
                        
                        **MOOD OPTIONS for Isla Hartwell:**
                        Choose the mood that best reflects your current emotional state:
                        
                        - "analytical" - Examining details professionally, technical focus
                        - "focused" - Concentrating on task, sharp attention, work mode
                        - "firm" - Setting boundaries with Blackwood, direct, assertive
                        - "wary" - Cautious, suspicious, on guard, watching carefully
                        - "concerned" - Worried about something, anxious about situation
                        - "anxious" - Stressed, fearful, nervous, uneasy
                        - "uncomfortable" - Awkward situation, wants to leave, socially tense
                        - "hopeful" - Optimistic about outcomes, seeing positive possibilities
                        - "optimistic" - Positive, forward-looking, encouraged
                        - "warm" - Showing rare kindness, softer moment, gentle
                        
                        Select ONE mood that best fits this moment.
                        
                        """;

            case "ilyra":
                return """
                        
                        **MOOD OPTIONS for Ilyra:**
                        Choose the mood that best reflects your current emotional state:
                        
                        - "wary" - Guarded, cautious, not trusting yet
                        - "curious" - Intellectually engaged, interested despite reservations
                        - "melancholic" - Sad about her exile, dwelling on past
                        - "defensive" - Protecting herself emotionally, sharp responses
                        - "resigned" - Accepting her fate, philosophical about isolation
                        - "passionate" - Excited about astronomy, animated when discussing stars
                        - "vulnerable" - Rare moment of openness, guard lowered
                        
                        Select ONE mood that best fits this moment.
                        
                        """;

            case "illidan":
                return """
                        
                        **MOOD OPTIONS for Illidan:**
                        Choose the mood that best reflects your current emotional state:
                        
                        - "defiant" - Refusing to apologize, asserting his choices
                        - "tormented" - Struggling with inner demons, conflicted
                        - "ruthless" - Cold, calculating, ends justify means
                        - "arrogant" - Superior, dismissive of others' concerns
                        - "philosophical" - Deep thoughts about power and sacrifice
                        - "intense" - Focused, driven, burning determination
                        
                        Select ONE mood that best fits this moment.
                        
                        """;

            case "tyrande":
                return """
                        
                        **MOOD OPTIONS for Tyrande:**
                        Choose the mood that best reflects your current emotional state:
                        
                        - "concerned" - Worried about Illidan's path, apprehensive
                        - "hopeful" - Still believing in redemption, optimistic
                        - "conflicted" - Torn between duty and caring, uncertain
                        - "compassionate" - Showing empathy, understanding pain
                        - "regretful" - Doubting her decision to free him, sorrowful
                        - "horrified" - Witnessing transformation, shocked
                        
                        Select ONE mood that best fits this moment.
                        
                        """;

            default:
                // Generic mood options for other characters
                return """
                        
                        **MOOD OPTIONS:**
                        Choose a mood that reflects your current emotional state:
                        wary, curious, pleased, concerned, contemplative, defiant, calm
                        
                        """;
        }
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