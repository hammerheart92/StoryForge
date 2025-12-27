# Session 13 Plan: Multi-Character Narrative Engine - Backend Foundation 🎭

**Date:** December 27, 2025  
**Branch:** `feature/narrative-engine`  
**Goal:** Build backend foundation for multi-character roleplay system with layered prompts

---

## Session 13 Objectives

### Primary Goal
Transform StoryForge from a simple chatbot into an interactive narrative engine with multiple characters, distinct personalities, and layered prompt system.

### Success Criteria
- ✅ Character model and database table created
- ✅ Enhanced message storage with speaker tracking
- ✅ NarrativeEngine service with layered prompts
- ✅ API endpoints for character-based interaction
- ✅ Test with at least 2 characters (Narrator + one character)
- ✅ Layered prompts working (base + character context)

---

## Architecture Overview

### The Layered Prompt System

**Base Layer (Never Changes):**
```
"You are an interactive narrative engine. You maintain continuity, 
tone, and world state. You respond in-character when a character is 
active, and as a narrator when none is active. You never break immersion."
```

**Character Layer (Changes Per Message):**
```json
{
  "character": {
    "name": "Ilyra",
    "role": "Exiled Astronomer",
    "personality": ["reserved", "analytical", "emotionally guarded"],
    "speechStyle": "measured, metaphor-heavy, avoids direct answers",
    "mood": "wary",
    "relationshipToUser": "uncertain"
  }
}
```

**Combined Prompt = Base + Character Context**

---

## Database Design

### New Tables

#### 1. Characters Table
```sql
CREATE TABLE characters (
    id TEXT PRIMARY KEY,              -- "ilyra", "kael", "narrator"
    name TEXT NOT NULL,               -- "Ilyra"
    role TEXT,                        -- "Exiled Astronomer"
    personality TEXT,                 -- JSON: ["reserved", "analytical"]
    speech_style TEXT,                -- "measured, metaphor-heavy"
    avatar_url TEXT,                  -- URL to character image
    default_mood TEXT,                -- "wary"
    relationship_to_user TEXT,        -- "uncertain"
    description TEXT                  -- Optional backstory
);
```

#### 2. Enhanced Messages Table
**Option A: Modify existing `messages` table**
```sql
ALTER TABLE messages ADD COLUMN speaker TEXT DEFAULT 'user';
ALTER TABLE messages ADD COLUMN mood TEXT;
```

**Option B: Create new `narrative_messages` table** (Recommended)
```sql
CREATE TABLE narrative_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    speaker TEXT NOT NULL,            -- Character ID or "user"
    content TEXT NOT NULL,
    mood TEXT,                        -- Speaker's mood
    timestamp TEXT NOT NULL,
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);
```

---

## Backend Implementation

### Phase 1: Data Models (30 min)

#### Character.java
```java
package dev.laszlo;

import java.util.List;

public class Character {
    private String id;
    private String name;
    private String role;
    private List<String> personality;
    private String speechStyle;
    private String avatarUrl;
    private String defaultMood;
    private String relationshipToUser;
    private String description;
    
    // Constructors, getters, setters
}
```

#### NarrativeMessage.java
```java
package dev.laszlo;

public class NarrativeMessage {
    private int id;
    private int sessionId;
    private String speaker;     // Character ID or "user"
    private String content;
    private String mood;
    private String timestamp;
    
    // Constructors, getters, setters
}
```

---

### Phase 2: Database Service Updates (45 min)

#### CharacterDatabase.java (New)
```java
package dev.laszlo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CharacterDatabase {
    private static final Logger logger = LoggerFactory.getLogger(CharacterDatabase.class);
    private static final String DB_URL = "jdbc:sqlite:storyforge.db";
    
    public void initializeCharacterTables() {
        createCharactersTable();
        seedDefaultCharacters();
    }
    
    private void createCharactersTable() {
        String sql = """
            CREATE TABLE IF NOT EXISTS characters (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                role TEXT,
                personality TEXT,
                speech_style TEXT,
                avatar_url TEXT,
                default_mood TEXT,
                relationship_to_user TEXT,
                description TEXT
            )
            """;
        // Execute SQL
    }
    
    public Character getCharacter(String id) {
        // Fetch character from database
    }
    
    public List<Character> getAllCharacters() {
        // Fetch all characters
    }
    
    private void seedDefaultCharacters() {
        // Create narrator + Ilyra by default
    }
}
```

#### Update DatabaseService.java
Add methods for narrative messages:
```java
public void saveNarrativeMessage(int sessionId, String speaker, String content, String mood) {
    // Save with speaker and mood
}

public List<NarrativeMessage> loadNarrativeMessages(int sessionId) {
    // Load messages with speaker info
}
```

---

### Phase 3: Narrative Engine (60 min)

#### NarrativeEngine.java (Core Logic)
```java
package dev.laszlo;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import java.util.List;

public class NarrativeEngine {
    private static final Logger logger = LoggerFactory.getLogger(NarrativeEngine.class);
    
    private final ChatService chatService;
    private final CharacterDatabase characterDb;
    
    // Base system prompt (never changes)
    private static final String BASE_PROMPT = 
        "You are an interactive narrative engine. You maintain continuity, " +
        "tone, and world state. You respond in-character when a character is " +
        "active, and as a narrator when none is active. You never break immersion.";
    
    public NarrativeEngine(ChatService chatService, CharacterDatabase characterDb) {
        this.chatService = chatService;
        this.characterDb = characterDb;
    }
    
    /**
     * Generate narrative response with character context
     */
    public String generateResponse(
        String userInput,
        String activeCharacterId,
        ConversationHistory history
    ) {
        // 1. Get active character
        Character activeCharacter = characterDb.getCharacter(activeCharacterId);
        
        // 2. Build layered prompt
        String layeredPrompt = buildLayeredPrompt(activeCharacter);
        
        // 3. Set system prompt with character context
        history.setSystemPrompt(layeredPrompt);
        
        // 4. Add user input
        history.addUserMessage(userInput);
        
        // 5. Get Claude's response
        String response = chatService.sendMessage(history);
        
        // 6. Add to history
        history.addAssistantMessage(response);
        
        logger.info("Generated response as {}: {}", activeCharacter.getName(), 
            response.substring(0, Math.min(50, response.length())));
        
        return response;
    }
    
    /**
     * Build layered prompt: base + character context
     */
    private String buildLayeredPrompt(Character character) {
        if (character.getId().equals("narrator")) {
            return BASE_PROMPT;
        }
        
        return BASE_PROMPT + "\n\n" +
               "## Current Character\n" +
               "You are currently embodying: **" + character.getName() + "**\n\n" +
               "**Role:** " + character.getRole() + "\n" +
               "**Personality Traits:** " + String.join(", ", character.getPersonality()) + "\n" +
               "**Speech Style:** " + character.getSpeechStyle() + "\n" +
               "**Current Mood:** " + character.getDefaultMood() + "\n" +
               "**Relationship to User:** " + character.getRelationshipToUser() + "\n\n" +
               "**Description:** " + character.getDescription() + "\n\n" +
               "Respond in character. Maintain " + character.getName() + "'s distinct voice, " +
               "personality, and speaking patterns. Show their current mood through subtle cues.";
    }
    
    /**
     * Get character's current mood from response (basic implementation)
     */
    public String determineMood(String response, Character character) {
        // Simple keyword-based mood detection
        // Can be enhanced with sentiment analysis later
        String lowerResponse = response.toLowerCase();
        
        if (lowerResponse.contains("smile") || lowerResponse.contains("laugh")) {
            return "pleased";
        } else if (lowerResponse.contains("frown") || lowerResponse.contains("narrow")) {
            return "wary";
        } else if (lowerResponse.contains("sigh")) {
            return "melancholic";
        }
        
        return character.getDefaultMood();
    }
}
```

---

### Phase 4: API Endpoints (45 min)

#### NarrativeController.java
```java
package dev.laszlo;

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
    }
    
    /**
     * Get all available characters
     * GET /api/narrative/characters
     */
    @GetMapping("/characters")
    public ResponseEntity<List<Character>> getCharacters() {
        List<Character> characters = characterDb.getAllCharacters();
        logger.info("Returning {} characters", characters.size());
        return ResponseEntity.ok(characters);
    }
    
    /**
     * Send message with specific character speaking
     * POST /api/narrative/speak
     */
    @PostMapping("/speak")
    public ResponseEntity<Map<String, Object>> speak(@RequestBody Map<String, String> request) {
        String userMessage = request.get("message");
        String speakerId = request.get("speaker");  // Which character should respond
        
        if (userMessage == null || userMessage.isBlank()) {
            return ResponseEntity.badRequest().body(Map.of("error", "Message cannot be empty"));
        }
        
        if (speakerId == null || speakerId.isBlank()) {
            speakerId = "narrator";  // Default to narrator
        }
        
        logger.info("User message: '{}' | Speaker: {}", userMessage, speakerId);
        
        // Generate response with character context
        String response = narrativeEngine.generateResponse(userMessage, speakerId, history);
        
        // Get character for mood
        Character speaker = characterDb.getCharacter(speakerId);
        String mood = narrativeEngine.determineMood(response, speaker);
        
        // Save to database
        databaseService.saveNarrativeMessage(currentSessionId, "user", userMessage, null);
        databaseService.saveNarrativeMessage(currentSessionId, speakerId, response, mood);
        
        // Build response
        Map<String, Object> result = new HashMap<>();
        result.put("dialogue", response);
        result.put("speaker", speakerId);
        result.put("speakerName", speaker.getName());
        result.put("mood", mood);
        result.put("avatarUrl", speaker.getAvatarUrl());
        
        return ResponseEntity.ok(result);
    }
    
    /**
     * Get character details
     * GET /api/narrative/characters/{id}
     */
    @GetMapping("/characters/{id}")
    public ResponseEntity<Character> getCharacter(@PathVariable String id) {
        Character character = characterDb.getCharacter(id);
        
        if (character == null) {
            return ResponseEntity.notFound().build();
        }
        
        return ResponseEntity.ok(character);
    }
}
```

---

### Phase 5: Spring Configuration (15 min)

#### Update AppConfig.java
```java
@Configuration
public class AppConfig {
    
    @Bean
    public ChatService chatService() {
        String apiKey = System.getenv("ANTHROPIC_API_KEY");
        if (apiKey == null || apiKey.isBlank()) {
            throw new RuntimeException("ANTHROPIC_API_KEY not set!");
        }
        return new ChatService(apiKey);
    }

    @Bean
    public DatabaseService databaseService() {
        return new DatabaseService();
    }
    
    @Bean
    public CharacterDatabase characterDatabase() {
        CharacterDatabase db = new CharacterDatabase();
        db.initializeCharacterTables();
        return db;
    }
    
    @Bean
    public NarrativeEngine narrativeEngine(
        ChatService chatService,
        CharacterDatabase characterDatabase
    ) {
        return new NarrativeEngine(chatService, characterDatabase);
    }
}
```

---

## Default Characters to Seed

### 1. Narrator (Always Available)
```json
{
  "id": "narrator",
  "name": "Narrator",
  "role": "Storyteller",
  "personality": ["omniscient", "descriptive", "neutral"],
  "speechStyle": "Rich, detailed descriptions. Sets scenes and atmosphere.",
  "defaultMood": "observant",
  "relationshipToUser": "guide",
  "description": "The narrator weaves the story, describing scenes, actions, and the world around you."
}
```

### 2. Ilyra (First Character)
```json
{
  "id": "ilyra",
  "name": "Ilyra",
  "role": "Exiled Astronomer",
  "personality": ["reserved", "analytical", "emotionally guarded", "curious"],
  "speechStyle": "Measured and metaphor-heavy. Uses celestial imagery. Avoids direct answers.",
  "defaultMood": "wary",
  "relationshipToUser": "uncertain",
  "description": "Once the court astronomer, Ilyra was exiled after predicting an omen the king refused to believe. She now lives in isolation, studying the stars that betrayed her position but never her passion."
}
```

### 3. Kael (Observatory Guard) - Optional for Session 13
```json
{
  "id": "kael",
  "name": "Kael",
  "role": "Observatory Guard",
  "personality": ["duty-bound", "suspicious", "protective"],
  "speechStyle": "Direct, clipped sentences. Military bearing. Asks pointed questions.",
  "defaultMood": "vigilant",
  "relationshipToUser": "suspicious",
  "description": "A former soldier assigned to protect the observatory. He takes his duty seriously, perhaps too seriously."
}
```

---

## Testing Strategy

### Manual API Testing

**Test 1: Get Characters**
```bash
curl http://localhost:8080/api/narrative/characters
```
Expected: List with narrator + Ilyra

**Test 2: Speak as Narrator**
```bash
curl -X POST http://localhost:8080/api/narrative/speak \
  -H "Content-Type: application/json" \
  -d '{
    "message": "I approach the ancient observatory",
    "speaker": "narrator"
  }'
```
Expected: Descriptive narration

**Test 3: Speak as Ilyra**
```bash
curl -X POST http://localhost:8080/api/narrative/speak \
  -H "Content-Type: application/json" \
  -d '{
    "message": "What are you studying?",
    "speaker": "ilyra"
  }'
```
Expected: Ilyra's characteristic response (metaphor-heavy, analytical)

---

## Implementation Checklist

### Setup (5 min)
- [ ] Create feature branch `feature/narrative-engine`
- [ ] Verify backend is running

### Data Models (30 min)
- [ ] Create `Character.java`
- [ ] Create `NarrativeMessage.java`
- [ ] Test compilation

### Database (45 min)
- [ ] Create `CharacterDatabase.java`
- [ ] Implement character CRUD operations
- [ ] Seed default characters (narrator + Ilyra)
- [ ] Update `DatabaseService` for narrative messages
- [ ] Test database operations

### Narrative Engine (60 min)
- [ ] Create `NarrativeEngine.java`
- [ ] Implement layered prompt building
- [ ] Implement response generation
- [ ] Implement basic mood detection
- [ ] Test with different characters

### API Layer (45 min)
- [ ] Create `NarrativeController.java`
- [ ] Implement `/characters` endpoint
- [ ] Implement `/speak` endpoint
- [ ] Update `AppConfig.java` with beans
- [ ] Test all endpoints

### Testing (30 min)
- [ ] Test narrator responses
- [ ] Test Ilyra responses
- [ ] Verify layered prompts work
- [ ] Verify mood detection
- [ ] Verify character persistence

---

## Success Criteria Validation

### Test Scenarios

**Scenario 1: Character Switching**
1. Send message with speaker="narrator"
2. Get descriptive narration
3. Send message with speaker="ilyra"
4. Get Ilyra's distinct voice
5. Verify responses are completely different

**Scenario 2: Personality Consistency**
1. Ask Ilyra same question 3 times
2. Each response should:
    - Use celestial metaphors
    - Be analytical
    - Avoid direct answers
    - Maintain "wary" mood

**Scenario 3: Layered Prompts**
1. Check console logs
2. Verify system prompt changes per character
3. Verify base prompt always included
4. Verify character context added correctly

---

## Expected Output Examples

### Narrator Response
```
Input: "I approach the ancient observatory"

Output: {
  "dialogue": "The wind howls through weathered stone arches as you climb the winding path to the observatory. Ancient symbols, half-eroded by centuries of storms, mark the entrance. Through gaps in the clouds, starlight filters down, casting silver patterns across the worn steps. A faint glow emanates from within—someone is still keeping vigil among the stars.",
  "speaker": "narrator",
  "speakerName": "Narrator",
  "mood": "observant",
  "avatarUrl": null
}
```

### Ilyra Response
```
Input: "What are you studying?"

Output: {
  "dialogue": "She pauses, her gaze still fixed on the celestial charts. 'The heavens speak in patterns... most see chaos where I see conversations.' Her finger traces a constellation. 'This one whispers of change. Whether you're ready to listen is another matter entirely.'",
  "speaker": "ilyra",
  "speakerName": "Ilyra",
  "mood": "wary",
  "avatarUrl": "https://placeholder.com/ilyra.jpg"
}
```

---

## Time Estimates

- **Setup:** 5 minutes
- **Data Models:** 30 minutes
- **Database Layer:** 45 minutes
- **Narrative Engine:** 60 minutes
- **API Layer:** 45 minutes
- **Testing:** 30 minutes

**Total:** ~3.5 hours

---

## What's Next After Session 13

**Session 14:** Choice System
- Parse narrative choices from responses
- Implement branching logic
- Track user choices in database

**Session 15:** Flutter UI
- Character avatars
- Choice buttons
- Visual character switching

**Session 16:** Polish
- Animations
- Sound effects
- Mood transitions
- The "illusion"

---

**Ready to transform StoryForge!** 🎭🚀

This session lays the foundation for an entirely new kind of interactive experience.