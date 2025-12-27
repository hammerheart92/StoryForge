# Session 14 Plan: Choice System & Branching Narratives 🌿

**Date:** December 27, 2025  
**Branch:** `feature/choice-system`  
**Prerequisites:** Session 13 complete (multi-character narrative engine working)  
**Goal:** Add branching narrative with user choices that lead to different story paths and character interactions

---

## Context from Session 13

### What We Built
- ✅ Character model (Narrator, Ilyra)
- ✅ CharacterDatabase (storage and retrieval)
- ✅ NarrativeEngine (layered prompts for distinct voices)
- ✅ NarrativeController API endpoints
- ✅ Characters respond with unique personalities

### What Works
- POST `/api/narrative/speak` - Send message, get character response
- GET `/api/narrative/characters` - List all characters
- Narrator gives rich scene descriptions
- Ilyra speaks with celestial metaphors

### Current Limitation
**One-way conversation:** User sends message → Character responds → User sends another message

**No branching:** User can't choose between multiple story options

---

## Session 14 Objectives

### Primary Goal
Add a choice system that allows users to make decisions that branch the narrative in different directions.

### Success Criteria
- ✅ Claude generates 2-3 choices after each response
- ✅ Choices stored and returned in API response
- ✅ User can select a choice to continue the story
- ✅ Different choices lead to different outcomes
- ✅ Choice can switch active character
- ✅ Choices tracked in database

---

## The Vision

### What Your Partner Wants

**From the original concept:**
```json
{
  "dialogue": "She studies the stars, pretending not to notice you.",
  "speaker": "Ilyra",
  "choices": [
    {
      "id": "ask_ilyra",
      "label": "Ask Ilyra about the constellation",
      "nextSpeaker": "Ilyra"
    },
    {
      "id": "talk_guard",
      "label": "Approach the observatory guard",
      "nextSpeaker": "Kael"
    },
    {
      "id": "observe",
      "label": "Remain silent",
      "nextSpeaker": "Narrator"
    }
  ]
}
```

**Key Features:**
- Each response includes 2-3 choices
- Choices can switch between characters
- User taps a choice → story branches
- Creates illusion of interactive narrative

---

## Architecture Design

### New Data Models

#### Choice.java
```java
package dev.laszlo.model;

public class Choice {
    private String id;              // "ask_about_stars"
    private String label;           // "Ask about the constellation"
    private String nextSpeaker;     // "ilyra" or "narrator"
    private String description;     // Optional tooltip
    
    // Constructor, getters, setters
}
```

#### NarrativeResponse.java
```java
package dev.laszlo.model;

import java.util.List;

public class NarrativeResponse {
    private String dialogue;        // Character's response
    private String speaker;         // "ilyra"
    private String speakerName;     // "Ilyra"
    private String mood;            // "wary"
    private String avatarUrl;       // Character avatar
    private List<Choice> choices;   // Available choices
    
    // Constructor, getters, setters
}
```

---

### Database Changes

#### New Table: user_choices
```sql
CREATE TABLE user_choices (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    choice_id TEXT NOT NULL,
    choice_label TEXT NOT NULL,
    next_speaker TEXT NOT NULL,
    chosen_at TEXT NOT NULL,
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);
```

**Purpose:** Track which choices users make for analytics and continuity.

---

## Implementation Strategy

### Approach: Two-Step Process

**Why not one API call?**
- Asking Claude to generate both dialogue AND structured choices in one response is complex
- Parsing mixed content (narrative + JSON) is error-prone
- Two calls = simpler, more reliable

**Step 1:** Generate character's narrative response
```
User: "What are you studying?"
Claude (as Ilyra): "The stars speak of upheaval..."
```

**Step 2:** Generate choices based on that response
```
Prompt: "Given Ilyra's response about stars, suggest 3 narrative choices"
Claude: Returns structured choices
```

### Alternative: Prompt Engineering (Simpler)

**Single API call with careful prompting:**
```
System prompt addition:
"After your response, suggest 2-3 choices in this format:
[CHOICE: Ask about the stars | ilyra]
[CHOICE: Leave quietly | narrator]"
```

**Then parse the markers from Claude's response.**

**Recommendation:** Start with parsing approach (simpler), can enhance to two-step later.

---

## Implementation Plan

### Phase 1: Create Data Models (15 min)

**Files to create:**
1. `backend/src/main/java/dev/laszlo/model/Choice.java`
2. `backend/src/main/java/dev/laszlo/model/NarrativeResponse.java`

**Simple POJOs with constructors, getters, setters.**

---

### Phase 2: Update NarrativeEngine (30 min)

**Modify:** `backend/src/main/java/dev/laszlo/service/NarrativeEngine.java`

**Add method:**
```java
public NarrativeResponse generateResponseWithChoices(
    String userInput,
    String activeCharacterId,
    ConversationHistory history
) {
    // 1. Generate character's response (existing logic)
    String dialogue = generateResponse(userInput, activeCharacterId, history);
    
    // 2. Generate choices based on context
    List<Choice> choices = generateChoices(activeCharacterId, dialogue, history);
    
    // 3. Build complete response
    Character character = characterDb.getCharacter(activeCharacterId);
    String mood = determineMood(dialogue, character);
    
    NarrativeResponse response = new NarrativeResponse();
    response.setDialogue(dialogue);
    response.setSpeaker(activeCharacterId);
    response.setSpeakerName(character.getName());
    response.setMood(mood);
    response.setAvatarUrl(character.getAvatarUrl());
    response.setChoices(choices);
    
    return response;
}
```

**Add choice generation method:**
```java
private List<Choice> generateChoices(
    String currentSpeaker,
    String lastDialogue,
    ConversationHistory history
) {
    // Build prompt for choice generation
    String choicePrompt = buildChoicePrompt(currentSpeaker, lastDialogue);
    
    // Ask Claude for choices
    ConversationHistory tempHistory = new ConversationHistory();
    tempHistory.setSystemPrompt(choicePrompt);
    String choicesText = chatService.sendMessage(tempHistory);
    
    // Parse choices from response
    return parseChoices(choicesText, currentSpeaker);
}
```

**Add choice parsing:**
```java
private List<Choice> parseChoices(String response, String currentSpeaker) {
    List<Choice> choices = new ArrayList<>();
    
    // Look for [CHOICE: label | nextSpeaker] patterns
    Pattern pattern = Pattern.compile("\\[CHOICE: ([^|]+) \\| ([^]]+)\\]");
    Matcher matcher = pattern.matcher(response);
    
    int id = 1;
    while (matcher.find()) {
        String label = matcher.group(1).trim();
        String nextSpeaker = matcher.group(2).trim();
        
        Choice choice = new Choice();
        choice.setId("choice_" + id++);
        choice.setLabel(label);
        choice.setNextSpeaker(nextSpeaker);
        choices.add(choice);
    }
    
    // Fallback: if no choices parsed, provide defaults
    if (choices.isEmpty()) {
        choices.add(new Choice("continue", "Continue", currentSpeaker));
        choices.add(new Choice("narrator", "Step back", "narrator"));
    }
    
    return choices;
}
```

**Add choice prompt builder:**
```java
private String buildChoicePrompt(String currentSpeaker, String lastDialogue) {
    return "You are a narrative choice generator. Based on the following dialogue, " +
           "suggest 2-3 interesting choices for the player.\n\n" +
           "Current speaker: " + currentSpeaker + "\n" +
           "Last dialogue: " + lastDialogue + "\n\n" +
           "Format each choice as:\n" +
           "[CHOICE: descriptive label | next_speaker_id]\n\n" +
           "Available speakers: narrator, ilyra\n" +
           "Make choices meaningful and varied. Include at least one that changes the speaker.";
}
```

---

### Phase 3: Update Database Service (20 min)

**Modify:** `backend/src/main/java/dev/laszlo/database/DatabaseService.java`

**Add table creation:**
```java
private void createUserChoicesTable() {
    String sql = """
        CREATE TABLE IF NOT EXISTS user_choices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_id INTEGER NOT NULL,
            choice_id TEXT NOT NULL,
            choice_label TEXT NOT NULL,
            next_speaker TEXT NOT NULL,
            chosen_at TEXT NOT NULL,
            FOREIGN KEY (session_id) REFERENCES sessions(id)
        )
        """;
    
    try (Connection conn = DriverManager.getConnection(DB_URL);
         Statement stmt = conn.createStatement()) {
        stmt.execute(sql);
        logger.debug("User choices table created");
    } catch (SQLException e) {
        logger.error("Failed to create user_choices table", e);
    }
}
```

**Add to initialization:**
```java
public DatabaseService() {
    createSessionsTable();
    createMessagesTable();
    createUserChoicesTable();  // NEW
    logger.info("✅ Database initialized successfully");
}
```

**Add save method:**
```java
public void saveUserChoice(int sessionId, String choiceId, String label, String nextSpeaker) {
    String sql = """
        INSERT INTO user_choices (session_id, choice_id, choice_label, next_speaker, chosen_at)
        VALUES (?, ?, ?, ?, ?)
        """;
    
    try (Connection conn = DriverManager.getConnection(DB_URL);
         PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setInt(1, sessionId);
        pstmt.setString(2, choiceId);
        pstmt.setString(3, label);
        pstmt.setString(4, nextSpeaker);
        pstmt.setString(5, LocalDateTime.now().toString());
        pstmt.executeUpdate();
        
        logger.debug("Saved user choice: {}", label);
    } catch (SQLException e) {
        logger.error("Failed to save user choice", e);
    }
}
```

---

### Phase 4: Update NarrativeController (25 min)

**Modify:** `backend/src/main/java/dev/laszlo/controller/NarrativeController.java`

**Update `/speak` endpoint to return NarrativeResponse:**
```java
@PostMapping("/speak")
public ResponseEntity<NarrativeResponse> speak(@RequestBody Map<String, String> request) {
    String userMessage = request.get("message");
    String speakerId = request.get("speaker");
    
    if (userMessage == null || userMessage.isBlank()) {
        // Return error as NarrativeResponse
        NarrativeResponse error = new NarrativeResponse();
        error.setDialogue("Error: Message cannot be empty");
        return ResponseEntity.badRequest().body(error);
    }
    
    if (speakerId == null || speakerId.isBlank()) {
        speakerId = "narrator";
    }
    
    logger.info("💬 User: '{}' | Speaker: {}", userMessage, speakerId);
    
    // Generate response with choices
    NarrativeResponse response = narrativeEngine.generateResponseWithChoices(
        userMessage, 
        speakerId, 
        history
    );
    
    // Save to database
    databaseService.saveMessage(currentSessionId, "user", userMessage);
    databaseService.saveMessage(currentSessionId, speakerId, response.getDialogue());
    
    logger.info("✅ {} responded with {} choices", 
        response.getSpeakerName(), response.getChoices().size());
    
    return ResponseEntity.ok(response);
}
```

**Add new endpoint for choice selection:**
```java
@PostMapping("/choose")
public ResponseEntity<NarrativeResponse> choose(@RequestBody Map<String, String> request) {
    String choiceId = request.get("choiceId");
    String choiceLabel = request.get("label");
    String nextSpeaker = request.get("nextSpeaker");
    
    if (choiceId == null || nextSpeaker == null) {
        NarrativeResponse error = new NarrativeResponse();
        error.setDialogue("Error: Invalid choice");
        return ResponseEntity.badRequest().body(error);
    }
    
    logger.info("🎯 User chose: '{}' -> {}", choiceLabel, nextSpeaker);
    
    // Save the choice
    databaseService.saveUserChoice(currentSessionId, choiceId, choiceLabel, nextSpeaker);
    
    // Generate response based on choice
    String transitionMessage = "You chose: " + choiceLabel;
    NarrativeResponse response = narrativeEngine.generateResponseWithChoices(
        transitionMessage,
        nextSpeaker,
        history
    );
    
    // Save messages
    databaseService.saveMessage(currentSessionId, "user", transitionMessage);
    databaseService.saveMessage(currentSessionId, nextSpeaker, response.getDialogue());
    
    return ResponseEntity.ok(response);
}
```

---

## Testing Strategy

### Manual Testing with curl

**Test 1: Get response with choices**
```bash
curl -X POST http://localhost:8080/api/narrative/speak \
  -H "Content-Type: application/json" \
  -d '{"message": "I approach the observatory", "speaker": "narrator"}'
```

**Expected Response:**
```json
{
  "dialogue": "The wind howls...",
  "speaker": "narrator",
  "speakerName": "Narrator",
  "mood": "observant",
  "choices": [
    {
      "id": "choice_1",
      "label": "Enter the observatory",
      "nextSpeaker": "narrator"
    },
    {
      "id": "choice_2",
      "label": "Call out to the figure inside",
      "nextSpeaker": "ilyra"
    }
  ]
}
```

**Test 2: Make a choice**
```bash
curl -X POST http://localhost:8080/api/narrative/choose \
  -H "Content-Type: application/json" \
  -d '{
    "choiceId": "choice_2",
    "label": "Call out to the figure inside",
    "nextSpeaker": "ilyra"
  }'
```

**Expected:** Ilyra's response with new choices

**Test 3: Verify choice tracking**
```bash
# Check database
sqlite3 storyforge.db "SELECT * FROM user_choices"
```

**Expected:** Choice records saved

---

## Success Validation

### Must-Have Features ✅
1. API returns choices with each response
2. Choices include label and nextSpeaker
3. User can select a choice
4. Story branches based on choice
5. Character switches based on nextSpeaker
6. Choices saved to database

### Quality Checks ✅
1. Choices are contextually relevant
2. At least one choice switches speaker
3. No duplicate choices
4. Fallback choices if parsing fails
5. Error handling for invalid choices

---

## Example Flow

**User:** "I approach the observatory"  
**Narrator:** "The wind howls across the clifftop..."  
**Choices:**
- Enter the observatory [narrator]
- Call out to Ilyra [ilyra]
- Examine the door [narrator]

**User chooses:** "Call out to Ilyra"  
**Ilyra:** "A figure emerges from shadows..."  
**Choices:**
- Ask about the stars [ilyra]
- Leave quickly [narrator]
- Offer help [ilyra]

**Branching narrative working!** 🌿

---

## Potential Challenges

### Challenge 1: Choice Parsing Reliability
**Issue:** Claude might not always format choices correctly

**Solutions:**
- Clear, specific formatting instructions
- Pattern matching with regex
- Fallback default choices
- Validation before returning

### Challenge 2: Context Management
**Issue:** Generating choices requires context about story state

**Solutions:**
- Include recent dialogue in choice prompt
- Track narrative state in history
- Limit choice generation to 2-3 options (simpler)

### Challenge 3: Choice Quality
**Issue:** Choices might be boring or repetitive

**Solutions:**
- Vary choice types (action, dialogue, observation)
- Always include speaker-switching option
- Test with multiple scenarios
- Iterate on prompts

---

## Optional Enhancements

### If Time Permits

**Enhancement 1: Choice Categories**
```java
private String choiceType;  // "action", "dialogue", "investigation"
```

**Enhancement 2: Conditional Choices**
```java
private String requirement;  // "has_key", "ilyra_friendly"
```

**Enhancement 3: Choice History**
```java
public List<Choice> getChoiceHistory(int sessionId)
```

**Enhancement 4: Rich Descriptions**
```java
private String hoverText;   // Tooltip on hover
```

**Note:** These are extras - focus on core functionality first!

---

## Files to Create/Modify

### New Files
```
backend/src/main/java/dev/laszlo/model/
├── Choice.java                  (Choice data model)
└── NarrativeResponse.java       (Response with choices)
```

### Modified Files
```
backend/src/main/java/dev/laszlo/
├── service/
│   └── NarrativeEngine.java     (Add choice generation)
├── controller/
│   └── NarrativeController.java (Update /speak, add /choose)
└── database/
    └── DatabaseService.java     (Add user_choices table)
```

---

## Time Estimates

- **Phase 1:** Data Models - 15 minutes
- **Phase 2:** NarrativeEngine - 30 minutes
- **Phase 3:** Database - 20 minutes
- **Phase 4:** Controller - 25 minutes
- **Testing:** 20 minutes
- **Debugging:** 15 minutes

**Total:** ~2 hours

---

## Success Metrics

### Functional
- ✅ Choices returned with responses
- ✅ User can select choices
- ✅ Story branches correctly
- ✅ Character switching works
- ✅ Choices tracked in database

### Quality
- ✅ Choices are contextually relevant
- ✅ No parsing errors
- ✅ Smooth user experience
- ✅ All tests still passing

---

## What Comes After Session 14

**Session 15:** Flutter UI for choices
- Display choice buttons in app
- Visual character switching
- Choice selection UI

**Session 16:** Polish & animations
- Character transition effects
- Mood indicators
- The "illusion"

---

## Quick Start Commands
```bash
# Create feature branch
git checkout -b feature/choice-system

# Run backend
# (via IntelliJ: Run Application.java)

# Test
curl -X POST http://localhost:8080/api/narrative/speak \
  -H "Content-Type: application/json" \
  -d '{"message": "Hello", "speaker": "narrator"}'

# Commit
git add .
git commit -m "feat: Add choice system for branching narratives"
git push origin feature/choice-system
```

---

## Important Notes

1. **Build incrementally** - Test each phase before moving to next
2. **Start simple** - Basic choice parsing first, enhance later
3. **Fallback gracefully** - Always provide default choices if parsing fails
4. **Log everything** - Debug with clear logging
5. **Test thoroughly** - Try different characters and scenarios

---

**Ready to build branching narratives!** 🌿🚀

This plan assumes Session 13 is complete and working. If you encounter issues, review SESSION_13_SUMMARY.md for context.