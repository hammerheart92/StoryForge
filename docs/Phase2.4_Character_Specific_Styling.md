# Phase 2.4: Character-Specific Styling - Task Breakdown

## Overview

**Goal:** Give each character a unique visual personality through fonts, colors, and styling.

**Time Estimate:** 2-3 hours total (broken into 30-45 min tasks)

---

## Character Designs

### Narrator
- **Font:** Merriweather (serif, bookish)
- **Color:** Teal (#1A7F8A)
- **Icon:** 📖 Book
- **Feel:** Ancient storyteller, observant, wise

### Ilyra
- **Font:** Dancing Script (elegant, flowing)
- **Color:** Purple (#6B4A9E)
- **Icon:** ⭐ Star
- **Feel:** Mystical, stargazer, ethereal

### User (You)
- **Font:** Roboto (clean sans-serif)
- **Color:** Blue (#2196F3)
- **Icon:** None (simple, modern)
- **Feel:** Clean, modern, straightforward

---

## Task 1: Download Custom Fonts (15 minutes)

### What You'll Do:
Download the font files we need from Google Fonts.

### Steps:

1. **Open your browser**

2. **Go to Google Fonts:**
    - Visit: https://fonts.google.com

3. **Download Merriweather (for Narrator):**
    - Search for "Merriweather"
    - Click on it
    - Click "Download family" button (top right)
    - Save the ZIP file
    - Extract the ZIP file
    - Find these files inside:
        - `Merriweather-Regular.ttf`
        - `Merriweather-Italic.ttf`

4. **Download Dancing Script (for Ilyra):**
    - Search for "Dancing Script"
    - Click on it
    - Click "Download family" button
    - Save the ZIP file
    - Extract the ZIP file
    - Find this file inside:
        - `DancingScript-Regular.ttf`

5. **Create fonts folder in your project:**
    - Navigate to: `frontend/`
    - Create a new folder called: `fonts`
    - Inside `fonts/`, create two folders:
        - `merriweather/`
        - `dancing_script/`

6. **Copy font files:**
    - Copy `Merriweather-Regular.ttf` → `frontend/fonts/merriweather/`
    - Copy `Merriweather-Italic.ttf` → `frontend/fonts/merriweather/`
    - Copy `DancingScript-Regular.ttf` → `frontend/fonts/dancing_script/`

### Success Check:
Your structure should look like:
```
frontend/
├── fonts/
│   ├── merriweather/
│   │   ├── Merriweather-Regular.ttf
│   │   └── Merriweather-Italic.ttf
│   └── dancing_script/
│       └── DancingScript-Regular.ttf
```

**When done, tell me: "Task 1 complete - fonts downloaded!"**

---

## Task 2: Add Fonts to pubspec.yaml (10 minutes)

### What You'll Do:
Tell Flutter about the new fonts so it can use them.

### Steps:

1. **Open:** `frontend/pubspec.yaml`

2. **Find the `flutter:` section** (around line 50-60)

3. **Look for the `fonts:` section**
    - If it doesn't exist, add it after the `assets:` section

4. **Add this code:**

```yaml
  fonts:
    # Narrator font - Bookish serif
    - family: Merriweather
      fonts:
        - asset: fonts/merriweather/Merriweather-Regular.ttf
        - asset: fonts/merriweather/Merriweather-Italic.ttf
          style: italic
    
    # Ilyra font - Elegant script
    - family: DancingScript
      fonts:
        - asset: fonts/dancing_script/DancingScript-Regular.ttf
```

5. **Save the file**

6. **Stop your Flutter app** (if running)

7. **In terminal, run:**
    - Navigate to frontend folder
    - Just close and reopen your IDE
    - Or if you want to be sure: Stop app, then start it again

### Success Check:
- No errors when app restarts
- Fonts are registered

**When done, tell me: "Task 2 complete - fonts registered!"**

---

## Task 3: Create Character Style Helper (20 minutes)

### What You'll Do:
Create a helper class that defines the style for each character.

### Steps:

1. **Create a new file:**
    - Navigate to: `frontend/lib/widgets/`
    - Create new file: `character_style_helper.dart`

2. **Copy this entire code into the file:**

```dart
// lib/widgets/character_style_helper.dart
// Helper class for character-specific styling

import 'package:flutter/material.dart';

class CharacterStyle {
  final Color accentColor;      // Character's theme color
  final String fontFamily;      // Custom font
  final String icon;            // Emoji icon
  final Color glowColor;        // Glow effect color

  CharacterStyle({
    required this.accentColor,
    required this.fontFamily,
    required this.icon,
    required this.glowColor,
  });

  /// Get the style for a specific character
  static CharacterStyle forSpeaker(String speaker) {
    switch (speaker.toLowerCase()) {
      case 'narrator':
        return CharacterStyle(
          accentColor: const Color(0xFF1A7F8A),  // Teal
          fontFamily: 'Merriweather',
          icon: '📖',
          glowColor: const Color(0xFF1A7F8A).withOpacity(0.3),
        );

      case 'ilyra':
        return CharacterStyle(
          accentColor: const Color(0xFF6B4A9E),  // Purple
          fontFamily: 'DancingScript',
          icon: '⭐',
          glowColor: const Color(0xFF6B4A9E).withOpacity(0.3),
        );

      case 'user':
      default:
        return CharacterStyle(
          accentColor: const Color(0xFF2196F3),  // Blue
          fontFamily: 'Roboto',  // Default Flutter font
          icon: '',  // No icon for user
          glowColor: const Color(0xFF2196F3).withOpacity(0.2),
        );
    }
  }
}
```

3. **Save the file**

### Success Check:
- File created at `frontend/lib/widgets/character_style_helper.dart`
- No syntax errors

**When done, tell me: "Task 3 complete - style helper created!"**

---

## Task 4: Update Message Card Widget (30 minutes)

### What You'll Do:
Update the message card to use character-specific styling.

### Steps:

1. **Open:** `frontend/lib/widgets/character_message_card.dart`

2. **Add import at the top** (after other imports):

```dart
import 'character_style_helper.dart';
```

3. **In the `build()` method, add this line** right after the `final speakerColor` line:

```dart
final characterStyle = CharacterStyle.forSpeaker(message.speaker);
```

So it looks like:
```dart
@override
Widget build(BuildContext context) {
  final isUser = message.isUser;
  final speakerColor = StoryForgeTheme.getCharacterColor(message.speaker);
  final characterStyle = CharacterStyle.forSpeaker(message.speaker);  // NEW LINE
```

4. **Update the message card Container decoration** (around line 120):

Find the Container that wraps the message content. Update its decoration to include a glow:

```dart
decoration: BoxDecoration(
  // Light cream/beige - 90% opacity (semi-opaque)
  color: isUser
      ? _userCardBackground.withOpacity(0.92)
      : _creamBackground.withOpacity(0.90),
  borderRadius: BorderRadius.circular(
    StoryForgeTheme.cardRadius,
  ),
  // Warm border for definition
  border: Border.all(
    color: isUser
        ? const Color(0xFFD0D8E8)
        : _cardBorder,
    width: 1,
  ),
  // Soft shadow for depth + character glow
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
    // NEW: Character-specific glow
    if (!isUser)
      BoxShadow(
        color: characterStyle.glowColor,
        blurRadius: 20,
        offset: const Offset(0, 0),
      ),
  ],
),
```

5. **Update the dialogue text style** to use custom font:

Find where the dialogue Text widget is (around line 150). Update its style:

```dart
// Dialogue text - Regular
Text(
  message.dialogue,
  style: StoryForgeTheme.dialogueText.copyWith(
    color: _textPrimary,
    fontSize: 16,
    height: 1.6,
    fontWeight: FontWeight.w400,
    fontFamily: characterStyle.fontFamily,  // NEW: Custom font
  ),
),
```

6. **Update the action text style** to use custom font:

Find where the action text is (around line 135). Update its style:

```dart
if (message.hasActionText)
  Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(
      message.actionText!,
      style: TextStyle(
        fontSize: 15,
        fontStyle: FontStyle.italic,
        color: _actionTextGray,
        height: 1.5,
        fontWeight: FontWeight.w400,
        fontFamily: characterStyle.fontFamily,  // NEW: Custom font
      ),
    ),
  ),
```

7. **Save the file**

### Success Check:
- No compilation errors
- File saved successfully

**When done, tell me: "Task 4 complete - message card updated!"**

---

## Task 5: Test Each Character (15 minutes)

### What You'll Do:
Run the app and verify each character has their unique style.

### Steps:

1. **Run the Flutter app:**
    - Start the app in Chrome
    - Wait for it to load

2. **Test Narrator:**
    - Start a conversation
    - Look at Narrator's messages
    - Check for:
        - ✅ Serif font (bookish, traditional)
        - ✅ Teal glow around the card
        - ✅ Clean, readable text

3. **Test Ilyra:**
    - Make a choice to switch to Ilyra
    - Look at Ilyra's messages
    - Check for:
        - ✅ Elegant script font (flowing, mystical)
        - ✅ Purple glow around the card
        - ✅ Text is still readable

4. **Test User messages:**
    - Your choice messages should look:
        - ✅ Clean sans-serif (default)
        - ✅ Blue accent
        - ✅ No special glow

### Success Check:
- ✅ Each character has distinct font
- ✅ Each character has distinct glow color
- ✅ Text is readable for all characters
- ✅ Narrator feels bookish/wise
- ✅ Ilyra feels mystical/elegant
- ✅ User feels clean/modern

**When done, take screenshots and tell me: "Task 5 complete - all characters tested!"**

---

## Task 6: Optional Polish (15 minutes) - SKIP IF TIRED

### What You'll Do:
Add character icon next to the name badge.

### Steps:

1. **Open:** `frontend/lib/widgets/character_message_card.dart`

2. **Find the character name Container** (around line 70)

3. **Update it to include the icon:**

```dart
// Character name - cream background pill
Container(
  padding: const EdgeInsets.symmetric(
    horizontal: DesignSpacing.sm,
    vertical: DesignSpacing.xs,
  ),
  decoration: BoxDecoration(
    color: _creamBackground.withOpacity(0.95),
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: _cardBorder,
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  ),
  child: Row(  // CHANGED: Wrap in Row
    mainAxisSize: MainAxisSize.min,
    children: [
      // NEW: Character icon
      if (characterStyle.icon.isNotEmpty) ...[
        Text(
          characterStyle.icon,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(width: 4),
      ],
      // Character name
      Text(
        message.speakerName,
        style: StoryForgeTheme.characterName.copyWith(
          color: _textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  ),
),
```

4. **Save and test**

### Success Check:
- ✅ Narrator shows 📖 book icon
- ✅ Ilyra shows ⭐ star icon
- ✅ User shows no icon

**When done, tell me: "Task 6 complete - icons added!"**

---

## Summary

**Total Tasks:** 6 tasks (Task 6 is optional)

**Time Estimate:**
- Task 1: 15 min (download fonts)
- Task 2: 10 min (add to pubspec)
- Task 3: 20 min (create helper)
- Task 4: 30 min (update widget)
- Task 5: 15 min (test)
- Task 6: 15 min (optional icons)

**Total:** ~90-105 minutes

---

## Work Strategy

**Do tasks in order:**
1. → 2 → 3 → 4 → 5 → (optional 6)

**Take breaks between tasks!**

**Report after each task** so I can guide you to the next one.

---

## Success Criteria for Phase 2.4

Phase 2.4 is complete when:
- ✅ Each character has unique font
- ✅ Each character has unique glow color
- ✅ Text remains readable
- ✅ Visual personality matches character role
- ✅ Professional, polished appearance

---

**Ready to start Task 1? Let me know!** 🚀