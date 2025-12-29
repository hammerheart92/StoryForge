# Phase 2.3-2.5: Enhanced Storytelling UI - Implementation Plan

**Date:** December 29, 2025  
**Status:** Ready to implement  
**Branch:** `feature/immersive-ui` (continue from Phase 2.1-2.2)  
**Estimated Time:** 6-8 hours total

---

## Overview

Transform StoryForge's text presentation from basic dialogue to immersive, cinematic storytelling with:
1. **Mixed typography** (italic actions + regular dialogue)
2. **Character-specific styling** (unique visual identity per character)
3. **Subtle animations** (optional polish)

---

## Phase 2.3: Mixed Typography - Foundation (2-3 hours)

### Goal
Implement Fantasia-style mixed typography where action descriptions appear in italics above dialogue.

### Visual Example

**Before:**
```
┌─────────────────────────────────┐
│ Ilyra                 [pleased] │
│ ┌───────────────────────────────┐│
│ │ The observatory remembers all ││
│ │ moments equally, and sometimes││
│ │ simultaneously.               ││
│ └───────────────────────────────┘│
└─────────────────────────────────┘
```

**After:**
```
┌─────────────────────────────────┐
│ Ilyra                 [pleased] │
│ ┌───────────────────────────────┐│
│ │ She gestures toward intricate ││ ← Italic, gray
│ │ mechanisms, eyes distant       ││
│ │                               ││
│ │ "The observatory remembers    ││ ← Regular, dark
│ │ all moments equally..."       ││
│ └───────────────────────────────┘│
└─────────────────────────────────┘
```

---

### Part A: Backend Changes (60-90 min)

#### File 1: Update Character Prompts

**Location:** `backend/src/main/java/dev/laszlo/service/NarrativeEngine.java`

**Current prompt structure:**
```java
"""
You are {characterName}, {personality description}.

Respond with JSON:
{
  "dialogue": "Your spoken words here"
}
"""
```

**Updated prompt structure:**
```java
"""
You are {characterName}, {personality description}.

CRITICAL: Respond with JSON in this EXACT format:
{
  "dialogue": "Your spoken words here",
  "actionText": "Brief action/gesture description (1-2 sentences)"
}

Guidelines for actionText:
- Describe physical actions, gestures, expressions, or movements
- Show emotion through body language
- Keep concise (1-2 sentences maximum)
- Use present tense
- Examples:
  * "She pauses, gazing at the stars, fingers tracing ancient symbols."
  * "He closes the ancient tome, his expression contemplative."
  * "Her eyes light up with recognition as she examines the mechanism."

Guidelines for dialogue:
- Your actual spoken words
- Keep character voice consistent
- Natural conversation flow

Example response:
{
  "dialogue": "The observatory remembers all moments equally, and sometimes... simultaneously.",
  "actionText": "She gestures toward the intricate mechanisms, her eyes growing distant."
}
"""
```

**Changes needed:**
1. Update `buildNarratorPrompt()` method
2. Update `buildIlyraPrompt()` method
3. Update any other character prompts

**Code location:**
```java
private String buildCharacterPrompt(String characterId) {
    String basePersonality = getCharacterPersonality(characterId);
    
    return """
        %s
        
        CRITICAL: Your response MUST be valid JSON in this EXACT format:
        {
          "dialogue": "Your spoken words",
          "actionText": "Brief action description (1-2 sentences)"
        }
        
        [Insert guidelines above]
        """.formatted(basePersonality);
}
```

---

#### File 2: Update Response Model

**Location:** `backend/src/main/java/dev/laszlo/models/NarrativeResponse.java`

**Add actionText field:**

```java
public class NarrativeResponse {
    private String speakerName;    // "Narrator", "Ilyra"
    private String speaker;        // "narrator", "ilyra"
    private String dialogue;       // Spoken words
    private String actionText;     // NEW! Action description
    private String mood;
    private List<Choice> choices;
    
    // Constructors
    public NarrativeResponse() {}
    
    public NarrativeResponse(String speakerName, String speaker, 
                            String dialogue, String actionText,  // NEW parameter
                            String mood, List<Choice> choices) {
        this.speakerName = speakerName;
        this.speaker = speaker;
        this.dialogue = dialogue;
        this.actionText = actionText;  // NEW
        this.mood = mood;
        this.choices = choices;
    }
    
    // Getters and Setters
    public String getActionText() {
        return actionText;
    }
    
    public void setActionText(String actionText) {
        this.actionText = actionText;
    }
    
    // ... existing getters/setters
}
```

---

#### File 3: Update JSON Parsing

**Location:** `backend/src/main/java/dev/laszlo/service/NarrativeEngine.java`

**Update parseAIResponse method:**

```java
private NarrativeResponse parseAIResponse(String aiResponseText, String speaker) {
    try {
        JsonNode responseJson = objectMapper.readTree(aiResponseText);
        
        String dialogue = responseJson.get("dialogue").asText();
        String actionText = responseJson.has("actionText") 
            ? responseJson.get("actionText").asText() 
            : null;  // Optional field for backward compatibility
        
        // ... rest of parsing
        
        return new NarrativeResponse(
            speakerName,
            speaker,
            dialogue,
            actionText,  // NEW
            mood,
            choices
        );
        
    } catch (Exception e) {
        logger.error("Failed to parse AI response", e);
        // Return fallback response
    }
}
```

---

#### File 4: Update Database Schema (Optional but Recommended)

**Location:** `backend/src/main/java/dev/laszlo/database/DatabaseService.java`

**Add actionText column to messages table:**

```sql
ALTER TABLE messages ADD COLUMN action_text TEXT;
```

**Update saveMessage method:**
```java
public void saveMessage(/* ... */) {
    String sql = """
        INSERT INTO messages (session_id, speaker, speaker_name, dialogue, 
                            action_text, mood, timestamp)
        VALUES (?, ?, ?, ?, ?, ?, ?)
        """;
    
    // ... implementation
}
```

---

### Part B: Frontend Changes (60-90 min)

#### File 1: Update NarrativeMessage Model

**Location:** `frontend/lib/models/narrative_message.dart`

**Add actionText field:**

```dart
class NarrativeMessage {
  final String speakerName;
  final String speaker;
  final String dialogue;
  final String? actionText;  // NEW! Optional for backward compatibility
  final String mood;
  final DateTime timestamp;

  NarrativeMessage({
    required this.speakerName,
    required this.speaker,
    required this.dialogue,
    this.actionText,  // NEW - optional
    required this.mood,
    required this.timestamp,
  });

  /// Create from NarrativeResponse (from API)
  factory NarrativeMessage.fromResponse(NarrativeResponse response) {
    return NarrativeMessage(
      speakerName: response.speakerName,
      speaker: response.speaker,
      dialogue: response.dialogue,
      actionText: response.actionText,  // NEW
      mood: response.mood,
      timestamp: DateTime.now(),
    );
  }

  /// Create from user choice
  factory NarrativeMessage.userChoice(String choiceLabel) {
    return NarrativeMessage(
      speakerName: 'You',
      speaker: 'user',
      dialogue: 'You chose: $choiceLabel',
      actionText: null,  // Users don't have action text
      mood: 'neutral',
      timestamp: DateTime.now(),
    );
  }

  bool get isUser => speaker == 'user';
  bool get isNarrator => speaker == 'narrator';
  bool get hasActionText => actionText != null && actionText!.isNotEmpty;
}
```

---

#### File 2: Update NarrativeResponse Model (Frontend)

**Location:** `frontend/lib/models/narrative_response.dart`

**Add actionText field:**

```dart
class NarrativeResponse {
  final String speakerName;
  final String speaker;
  final String dialogue;
  final String? actionText;  // NEW
  final String mood;
  final List<Choice> choices;

  NarrativeResponse({
    required this.speakerName,
    required this.speaker,
    required this.dialogue,
    this.actionText,  // NEW - optional
    required this.mood,
    required this.choices,
  });

  factory NarrativeResponse.fromJson(Map<String, dynamic> json) {
    return NarrativeResponse(
      speakerName: json['speakerName'] as String,
      speaker: json['speaker'] as String,
      dialogue: json['dialogue'] as String,
      actionText: json['actionText'] as String?,  // NEW - can be null
      mood: json['mood'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
```

---

#### File 3: Update CharacterMessageCard Widget

**Location:** `frontend/lib/widgets/character_message_card.dart`

**Add mixed typography display:**

```dart
// Inside the card Container, update child:
child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    // Action text (if present) - Italic, gray
    if (message.hasActionText)
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          message.actionText!,
          style: TextStyle(
            fontSize: 15,
            fontStyle: FontStyle.italic,
            color: const Color(0xFF6B6B6B),  // Gray
            height: 1.5,
          ),
        ),
      ),
    
    // Dialogue text - Regular
    Text(
      message.dialogue,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: const Color(0xFF2D2A26),  // Dark brown
        height: 1.6,
      ),
    ),
  ],
),
```

---

### Testing Phase 2.3

**Backend testing:**
```bash
cd backend
./mvnw spring-boot:run

# Test narrative endpoint
curl -X POST http://localhost:8080/api/narrative/send \
  -H "Content-Type: application/json" \
  -d '{"message":"I examine the ancient mechanisms","speaker":"narrator"}'

# Check response includes actionText field
```

**Frontend testing:**
```bash
cd frontend
flutter run --dart-define=API_URL=http://localhost:8080/api/narrative

# Verify:
# 1. Messages have italic action text above dialogue
# 2. Action text is gray and smaller
# 3. Dialogue is regular dark text
# 4. User messages (choices) don't show action text
```

---

## Phase 2.4: Character-Specific Styling (2-3 hours)

### Goal
Give each character unique visual identity through styling, decorations, and personality.

### Character Design Specifications

#### Narrator (Mysterious Sage)
**Color scheme:** Teal (#1A7F8A)  
**Font:** Serif (Lora, Merriweather, or similar)  
**Icon:** 📖 Book  
**Accent:** Teal glow around card  
**Texture:** Subtle parchment/old paper  
**Feel:** Wise, ancient, mysterious

#### Ilyra (Cosmic Astronomer)
**Color scheme:** Purple (#6B4A9E)  
**Font:** Elegant script (Dancing Script, or elegant sans-serif)  
**Icon:** ⭐ Star  
**Accent:** Purple glow around card  
**Texture:** Subtle starfield/cosmic  
**Feel:** Ethereal, melancholic, cosmic

#### User (You)
**Color scheme:** Blue (#4A90E2)  
**Font:** Clean sans-serif (default)  
**Icon:** None  
**Accent:** Simple blue border  
**Texture:** None (clean, modern)  
**Feel:** Clear, direct, present

---

### Implementation

#### File 1: Add Custom Fonts

**Location:** `frontend/pubspec.yaml`

```yaml
flutter:
  fonts:
    - family: Merriweather
      fonts:
        - asset: fonts/Merriweather-Regular.ttf
        - asset: fonts/Merriweather-Italic.ttf
          style: italic
    
    - family: DancingScript
      fonts:
        - asset: fonts/DancingScript-Regular.ttf
```

**Download fonts:**
- Merriweather: https://fonts.google.com/specimen/Merriweather
- Dancing Script: https://fonts.google.com/specimen/Dancing+Script

Place in: `frontend/assets/fonts/`

---

#### File 2: Update CharacterMessageCard

**Location:** `frontend/lib/widgets/character_message_card.dart`

**Add character-specific styling:**

```dart
class CharacterMessageCard extends StatelessWidget {
  final NarrativeMessage message;

  const CharacterMessageCard({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    final characterStyle = _getCharacterStyle();

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DesignSpacing.md,
        vertical: DesignSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with character-specific icon and styling
          _buildHeader(characterStyle),
          
          const SizedBox(height: DesignSpacing.sm),
          
          // Message card with character-specific decoration
          _buildMessageCard(characterStyle),
        ],
      ),
    );
  }

  Widget _buildHeader(CharacterStyle style) {
    return Row(
      children: [
        // Avatar with character-specific glow
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: style.accentColor.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 20,
            backgroundColor: style.accentColor,
            child: Text(
              style.icon,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),

        const SizedBox(width: DesignSpacing.sm),

        // Character name with custom font
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignSpacing.sm,
            vertical: DesignSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            message.speakerName,
            style: TextStyle(
              fontFamily: style.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),

        const Spacer(),

        // Mood indicator
        if (!message.isUser)
          _MoodIndicator(mood: message.mood, color: style.accentColor),
      ],
    );
  }

  Widget _buildMessageCard(CharacterStyle style) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DesignSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F1E8).withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: style.accentColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: style.accentColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        // Optional: Add subtle background texture
        image: style.backgroundTexture != null
            ? DecorationImage(
                image: AssetImage(style.backgroundTexture!),
                opacity: 0.03,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action text (if present)
          if (message.hasActionText)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                message.actionText!,
                style: TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  fontFamily: style.fontFamily,
                  color: const Color(0xFF6B6B6B),
                  height: 1.5,
                ),
              ),
            ),
          
          // Dialogue text with character-specific font
          Text(
            message.dialogue,
            style: TextStyle(
              fontSize: 16,
              fontFamily: style.fontFamily,
              fontWeight: FontWeight.normal,
              color: const Color(0xFF2D2A26),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  CharacterStyle _getCharacterStyle() {
    switch (message.speaker) {
      case 'narrator':
        return CharacterStyle(
          accentColor: const Color(0xFF1A7F8A),  // Teal
          fontFamily: 'Merriweather',
          icon: '📖',
          backgroundTexture: 'assets/textures/parchment.png',
        );
      
      case 'ilyra':
        return CharacterStyle(
          accentColor: const Color(0xFF6B4A9E),  // Purple
          fontFamily: 'DancingScript',
          icon: '⭐',
          backgroundTexture: 'assets/textures/starfield.png',
        );
      
      default:  // user
        return CharacterStyle(
          accentColor: const Color(0xFF4A90E2),  // Blue
          fontFamily: null,  // Use default
          icon: '👤',
          backgroundTexture: null,
        );
    }
  }
}

// Helper class for character styling
class CharacterStyle {
  final Color accentColor;
  final String? fontFamily;
  final String icon;
  final String? backgroundTexture;

  CharacterStyle({
    required this.accentColor,
    this.fontFamily,
    required this.icon,
    this.backgroundTexture,
  });
}
```

---

### Testing Phase 2.4

**Visual verification:**
```bash
flutter run --dart-define=ENV=production

# Check each character:
# Narrator:
#  - Teal glow around avatar and card
#  - Serif font for dialogue
#  - 📖 book icon
#  - Parchment texture (subtle)

# Ilyra:
#  - Purple glow around avatar and card
#  - Elegant script font for dialogue
#  - ⭐ star icon
#  - Starfield texture (subtle)

# User:
#  - Blue accent
#  - Clean sans-serif
#  - Simple styling
```

---

## Phase 2.5: Subtle Animations (Optional - 1-2 hours)

### Goal
Add polish with subtle fade-in animations for new messages.

### Implementation

#### File: Update CharacterMessageCard

**Add fade-in animation:**

```dart
class CharacterMessageCard extends StatefulWidget {
  final NarrativeMessage message;
  final bool animate;  // NEW parameter

  const CharacterMessageCard({
    super.key,
    required this.message,
    this.animate = true,  // Default: animate
  });

  @override
  State<CharacterMessageCard> createState() => _CharacterMessageCardState();
}

class _CharacterMessageCardState extends State<CharacterMessageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // Start animation if enabled
    if (widget.animate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    // ... existing card building logic
  }
}
```

---

## Git Commit Strategy

### Commit 1: Phase 2.3 Backend
```bash
git add backend/src/main/java/dev/laszlo/service/NarrativeEngine.java
git add backend/src/main/java/dev/laszlo/models/NarrativeResponse.java
git commit -m "feat(backend): Add actionText support for mixed typography

- Updated character prompts to generate action descriptions
- Extended NarrativeResponse model with actionText field
- Updated JSON parsing to handle action descriptions
- Maintains backward compatibility (actionText is optional)"
```

### Commit 2: Phase 2.3 Frontend
```bash
git add frontend/lib/models/narrative_message.dart
git add frontend/lib/models/narrative_response.dart
git add frontend/lib/widgets/character_message_card.dart
git commit -m "feat(ui): Implement mixed typography for immersive storytelling

- Added actionText field to message models
- Updated CharacterMessageCard to display italic action text
- Action text appears above dialogue in gray italic
- Dialogue remains regular dark text
- Fantasia-style presentation achieved"
```

### Commit 3: Phase 2.4
```bash
git add frontend/pubspec.yaml
git add frontend/assets/fonts/
git add frontend/lib/widgets/character_message_card.dart
git commit -m "feat(ui): Add character-specific styling and personality

- Added custom fonts (Merriweather for Narrator, DancingScript for Ilyra)
- Character-specific colors, icons, and glows
- Unique visual identity per character
- Subtle background textures
- Enhanced immersion and character memorability"
```

### Commit 4: Phase 2.5 (Optional)
```bash
git add frontend/lib/widgets/character_message_card.dart
git commit -m "feat(ui): Add subtle fade-in animations for new messages

- Messages fade in and slide up when appearing
- 400ms duration for smooth effect
- Skip flag for message history (no animation on scroll)
- Polish and professional feel"
```

---

## Timeline

| Phase | Tasks | Time | Dependencies |
|-------|-------|------|--------------|
| 2.3A | Backend (prompts, models, parsing) | 60-90 min | None |
| 2.3B | Frontend (models, message card) | 60-90 min | Phase 2.3A complete |
| 2.3 Test | End-to-end testing | 30 min | Phase 2.3B complete |
| 2.4 | Character styling + fonts | 2-3 hours | Phase 2.3 complete |
| 2.4 Test | Visual verification | 30 min | Phase 2.4 complete |
| 2.5 | Animations (optional) | 1-2 hours | Phase 2.4 complete |

**Total: 6-9 hours** (or 5-7 hours without Phase 2.5)

---

## Success Criteria

### Phase 2.3 Complete When:
- ✅ Backend generates actionText in responses
- ✅ Frontend displays italic action text above dialogue
- ✅ Action text is gray, smaller, italic
- ✅ Dialogue is regular dark text
- ✅ Looks like Fantasia reference

### Phase 2.4 Complete When:
- ✅ Narrator has teal glow, serif font, book icon
- ✅ Ilyra has purple glow, elegant font, star icon
- ✅ Each character feels visually distinct
- ✅ Professional, polished appearance

### Phase 2.5 Complete When:
- ✅ New messages fade in smoothly
- ✅ Animation doesn't slow down app
- ✅ Can skip animation if needed
- ✅ Feels professional, not gimmicky

---

## Next Session Preview

**After Phase 2.3-2.5 complete:**
- ✅ Deploy to Railway (backend)
- ✅ Build production APK (frontend)
- ✅ Show partner the Fantasia-style StoryForge!
- ✅ Celebrate! 🎉

---

**Ready to start with Phase 2.3 Backend!** 🚀

---

**END OF IMPLEMENTATION PLAN**