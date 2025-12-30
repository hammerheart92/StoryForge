# Phase 2.3 Part A: Backend - Mixed Typography Implementation

**Goal:** Update backend to generate action descriptions alongside dialogue  
**Time:** 60-90 minutes  
**Branch:** `feature/immersive-ui` (current)

---

## Overview

We're adding `actionText` field to character responses so the AI generates:
- **Dialogue:** What the character says
- **ActionText:** What the character does (gestures, expressions, movements)

**Example response:**
```json
{
  "dialogue": "The observatory remembers all moments equally, and sometimes... simultaneously.",
  "actionText": "She gestures toward the intricate mechanisms, her eyes growing distant."
}
```

---

## Step 1: Update Character Prompts (30-40 min)

### File: `backend/src/main/java/dev/laszlo/service/NarrativeEngine.java`

Find your character prompt building methods. They might be named:
- `buildNarratorPrompt()`
- `buildIlyraPrompt()`
- Or a generic `buildCharacterPrompt(String characterId)`

### Current Structure (Probably):
```java
private String buildCharacterPrompt(String characterId) {
    String personality = getCharacterPersonality(characterId);
    
    return """
        You are %s.
        
        Respond with JSON:
        {
          "dialogue": "Your spoken words here"
        }
        """.formatted(personality);
}
```

### Updated Structure:
```java
private String buildCharacterPrompt(String characterId) {
    String personality = getCharacterPersonality(characterId);
    
    return """
        You are %s.
        
        CRITICAL: Respond with JSON in this EXACT format:
        {
          "dialogue": "Your spoken words here",
          "actionText": "Brief action/gesture description"
        }
        
        Guidelines for actionText (1-2 sentences max):
        - Describe physical gestures, expressions, or movements
        - Show emotion through body language
        - Use present tense
        - Keep it concise and evocative
        
        Examples of good actionText:
        - "She pauses, her gaze drifting to the stars, fingers tracing ancient symbols."
        - "He closes the ancient tome, his expression contemplative."
        - "Her eyes light up with recognition as she examines the mechanism."
        
        Guidelines for dialogue:
        - Your actual spoken words
        - Maintain character voice
        - Natural conversation flow
        
        IMPORTANT: Always include BOTH fields in your JSON response.
        """.formatted(personality);
}
```

### Action: Update Your Prompt Methods

**Locate and update:**
1. Narrator prompt method
2. Ilyra prompt method
3. Any other character prompt methods

**Tip:** Search for `"dialogue"` in NarrativeEngine.java to find prompt strings

---

## Step 2: Update NarrativeResponse Model (10-15 min)

### File: `backend/src/main/java/dev/laszlo/models/NarrativeResponse.java`

### Add the actionText field:

```java
package dev.laszlo.models;

import java.util.List;

public class NarrativeResponse {
    private String speakerName;    // "Narrator", "Ilyra"
    private String speaker;        // "narrator", "ilyra"
    private String dialogue;       // Spoken words
    private String actionText;     // NEW! Action description
    private String mood;
    private List<Choice> choices;

    // Default constructor (required for JSON parsing)
    public NarrativeResponse() {}

    // Full constructor
    public NarrativeResponse(String speakerName, String speaker, 
                            String dialogue, String actionText,
                            String mood, List<Choice> choices) {
        this.speakerName = speakerName;
        this.speaker = speaker;
        this.dialogue = dialogue;
        this.actionText = actionText;  // NEW
        this.mood = mood;
        this.choices = choices;
    }

    // Getters and Setters
    public String getSpeakerName() {
        return speakerName;
    }

    public void setSpeakerName(String speakerName) {
        this.speakerName = speakerName;
    }

    public String getSpeaker() {
        return speaker;
    }

    public void setSpeaker(String speaker) {
        this.speaker = speaker;
    }

    public String getDialogue() {
        return dialogue;
    }

    public void setDialogue(String dialogue) {
        this.dialogue = dialogue;
    }

    // NEW: actionText getter/setter
    public String getActionText() {
        return actionText;
    }

    public void setActionText(String actionText) {
        this.actionText = actionText;
    }

    public String getMood() {
        return mood;
    }

    public void setMood(String mood) {
        this.mood = mood;
    }

    public List<Choice> getChoices() {
        return choices;
    }

    public void setChoices(List<Choice> choices) {
        this.choices = choices;
    }
}
```

**Action:** Add the `actionText` field, getter, and setter to your NarrativeResponse class.

---

## Step 3: Update JSON Parsing (20-30 min)

### File: `backend/src/main/java/dev/laszlo/service/NarrativeEngine.java`

Find your AI response parsing method. It might be named:
- `parseAIResponse()`
- `extractResponseFromAI()`
- Or similar

### Current Parsing (Probably):
```java
private NarrativeResponse parseAIResponse(String aiResponseText, String speaker) {
    try {
        JsonNode responseJson = objectMapper.readTree(aiResponseText);
        
        String dialogue = responseJson.get("dialogue").asText();
        // ... parse other fields
        
        return new NarrativeResponse(
            speakerName,
            speaker,
            dialogue,
            mood,
            choices
        );
        
    } catch (Exception e) {
        logger.error("Failed to parse AI response", e);
        return createFallbackResponse();
    }
}
```

### Updated Parsing:
```java
private NarrativeResponse parseAIResponse(String aiResponseText, String speaker) {
    try {
        JsonNode responseJson = objectMapper.readTree(aiResponseText);
        
        String dialogue = responseJson.get("dialogue").asText();
        
        // NEW: Parse actionText (optional for backward compatibility)
        String actionText = null;
        if (responseJson.has("actionText")) {
            actionText = responseJson.get("actionText").asText();
        }
        
        // ... parse mood, choices, etc.
        
        return new NarrativeResponse(
            speakerName,
            speaker,
            dialogue,
            actionText,  // NEW parameter
            mood,
            choices
        );
        
    } catch (Exception e) {
        logger.error("Failed to parse AI response", e);
        return createFallbackResponse();
    }
}
```

**Important:** Make `actionText` optional (`null` if not present) for backward compatibility with old responses.

### Also Update: createFallbackResponse()

If you have a fallback response method, update it too:

```java
private NarrativeResponse createFallbackResponse() {
    return new NarrativeResponse(
        "Narrator",
        "narrator",
        "The path ahead seems unclear. Perhaps a different approach?",
        null,  // NEW: actionText can be null for fallback
        "confused",
        List.of(/* default choices */)
    );
}
```

---

## Step 4: Test Backend Locally (10-15 min)

### Start the backend:
```bash
cd ~/code/storyforge/backend
./mvnw spring-boot:run
```

### Test with curl:
```bash
# Send a test narrative request
curl -X POST http://localhost:8080/api/narrative/send \
  -H "Content-Type: application/json" \
  -d '{
    "message": "I examine the ancient mechanisms",
    "speaker": "narrator"
  }'
```

### Expected Response:
```json
{
  "speakerName": "Narrator",
  "speaker": "narrator",
  "dialogue": "These mechanisms have tracked celestial movements for centuries...",
  "actionText": "He gestures toward the intricate brass gears, his expression contemplative.",
  "mood": "contemplative",
  "choices": [
    {"label": "Ask about the construction", "speaker": "narrator"},
    {"label": "Look for unusual patterns", "speaker": "narrator"}
  ]
}
```

### Verify:
- ✅ Response includes `actionText` field
- ✅ `actionText` is 1-2 sentences
- ✅ `actionText` describes action/gesture/expression
- ✅ `dialogue` contains spoken words
- ✅ No JSON parsing errors in backend logs

### Debugging Tips:

**If actionText is missing:**
- Check AI response in logs (search for the raw JSON)
- Verify prompt includes actionText in format
- Try regenerating with different message

**If parsing fails:**
- Check JsonNode field access
- Verify constructor parameter order matches
- Add more logging around parsing

---

## Step 5: Commit Backend Changes

```bash
cd ~/code/storyforge

git add backend/src/main/java/dev/laszlo/service/NarrativeEngine.java
git add backend/src/main/java/dev/laszlo/models/NarrativeResponse.java

git commit -m "feat(backend): Add actionText support for mixed typography

- Updated character prompts to generate action descriptions
- Extended NarrativeResponse model with actionText field
- Updated JSON parsing to handle actionText (optional)
- Maintains backward compatibility with existing responses
- Action descriptions enhance storytelling immersion

Part of Phase 2.3: Mixed Typography implementation"

git status
```

---

## Troubleshooting

### Problem: AI doesn't generate actionText

**Solution 1:** Make prompt more explicit
```java
"""
YOU MUST include BOTH fields:
- dialogue: what you say
- actionText: what you do

Do NOT respond with just dialogue. Always include actionText.
"""
```

**Solution 2:** Add examples in prompt
```java
"""
Example response:
{
  "dialogue": "The stars tell stories if you know how to read them.",
  "actionText": "She traces constellation patterns in the air, eyes distant."
}
"""
```

### Problem: actionText is too long

**Solution:** Be more explicit in prompt
```java
"""
actionText must be SHORT (maximum 2 sentences, ideally 1 sentence).
Focus on ONE key action or gesture, not multiple actions.

Good: "She gazes at the stars, fingers tracing ancient symbols."
Bad: "She walks to the window, looks up, sees the stars, traces symbols, then turns back to face you."
"""
```

### Problem: JSON parsing fails

**Solution:** Add validation and logging
```java
logger.info("Raw AI response: {}", aiResponseText);

if (!responseJson.has("dialogue")) {
    logger.error("Missing dialogue field in response");
    return createFallbackResponse();
}

if (!responseJson.has("actionText")) {
    logger.warn("Missing actionText field, using null");
}
```

---

## Next Steps

After backend is working:
1. ✅ Backend generates actionText in responses
2. ✅ JSON parsing handles actionText correctly
3. ✅ Testing shows actionText in API responses
4. → **Move to Phase 2.3 Part B: Frontend Implementation**

---

## Summary Checklist

- [ ] Character prompts updated to request actionText
- [ ] NarrativeResponse model includes actionText field
- [ ] JSON parsing extracts actionText from AI response
- [ ] Backward compatibility maintained (actionText optional)
- [ ] Local testing confirms actionText appears in responses
- [ ] Backend changes committed to git
- [ ] Backend still running for frontend integration

---

**Once backend is working, let me know and we'll move to frontend!** 🚀

**Estimated time to complete:** 60-90 minutes

---

**END OF PHASE 2.3 PART A**