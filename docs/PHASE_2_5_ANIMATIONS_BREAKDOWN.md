# Phase 2.5: Message Animations - Task Breakdown

## Overview

**Goal:** Add subtle fade-in animations when new messages appear for professional polish.

**Time Estimate:** 1-2 hours total (broken into 30-45 min tasks)

**Style:** Subtle and professional - not distracting from the story!

---

## Animation Design

### What We're Adding:
- **Fade-in effect:** Messages appear with 400ms fade (0% → 100% opacity)
- **Slide-up effect:** Messages slide up 20px as they fade in
- **Skip for history:** Old messages (when scrolling) appear instantly - no animation

### Example:
```
New message appears:
  Frame 1 (0ms):   Opacity 0%, Position +20px (invisible, below)
  Frame 2 (200ms): Opacity 50%, Position +10px (fading in, moving up)
  Frame 3 (400ms): Opacity 100%, Position 0px (fully visible, in place)
```

**Feel:** Smooth, professional, like a message gracefully appearing on screen.

---

## Task 1: Make Message Card Animated (30 minutes)

### What You'll Do:
Turn the static CharacterMessageCard into an animated widget.

### Steps:

1. **Open:** `frontend/lib/widgets/character_message_card.dart`

2. **Change from StatelessWidget to StatefulWidget:**

**Find this** (around line 11):
```dart
class CharacterMessageCard extends StatelessWidget {
  final NarrativeMessage message;

  const CharacterMessageCard({
    super.key,
    required this.message,
  });
```

**Replace with:**
```dart
class CharacterMessageCard extends StatefulWidget {
  final NarrativeMessage message;
  final bool shouldAnimate;  // NEW: Control animation

  const CharacterMessageCard({
    super.key,
    required this.message,
    this.shouldAnimate = true,  // NEW: Default to true
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

    // Create animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),  // 400ms animation
      vsync: this,
    );

    // Fade animation (0.0 to 1.0)
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Slide animation (20px up)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),  // Start 5% down
      end: Offset.zero,              // End at normal position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Start animation if shouldAnimate is true
    if (widget.shouldAnimate) {
      _controller.forward();
    } else {
      _controller.value = 1.0;  // Skip animation, show immediately
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
```

3. **Update the build method:**

**Find:**
```dart
@override
Widget build(BuildContext context) {
  final isUser = message.speaker == 'user';
```

**Replace with:**
```dart
@override
Widget build(BuildContext context) {
  final isUser = widget.message.speaker == 'user';  // CHANGED: widget.message
```

**And wrap the entire return Container with animations:**

**Find:**
```dart
return Container(
  margin: const EdgeInsets.symmetric(
```

**Replace with:**
```dart
return FadeTransition(
  opacity: _fadeAnimation,
  child: SlideTransition(
    position: _slideAnimation,
    child: Container(
      margin: const EdgeInsets.symmetric(
```

**And at the very end of the build method, close the new widgets:**

**Find the closing of the outermost Container** (last line before the closing brace):
```dart
        ],
      ),
    );  // Container closing
  }   // build() closing
}     // Class closing
```

**Replace with:**
```dart
        ],
      ),
    ),  // Container closing
  ),    // SlideTransition closing
);      // FadeTransition closing
```

4. **Update all references to `message` to `widget.message`:**

Use Find & Replace in your IDE:
- Find: `message.`
- Replace: `widget.message.`
- Replace all in this file

5. **Save the file**

### Success Check:
- File compiles without errors
- CharacterMessageCard is now a StatefulWidget
- Has animation controller and animations defined

**When done, tell me: "Task 1 complete - widget is animated!"**

---

## Task 2: Update Screen to Control Animations (20 minutes)

### What You'll Do:
Tell the widget when to animate (new messages) vs when not to (scrolling history).

### Steps:

1. **Open:** `frontend/lib/screens/narrative_screen.dart`

2. **Find where CharacterMessageCard is created:**

Look for something like:
```dart
CharacterMessageCard(
  message: message,
),
```

3. **Update to pass shouldAnimate flag:**

```dart
CharacterMessageCard(
  message: message,
  shouldAnimate: index == state.history.length - 1,  // Only animate last message
),
```

**Explanation:**
- `index == state.history.length - 1` means "only animate if this is the newest message"
- Old messages (when scrolling) won't animate

4. **Save the file**

### Success Check:
- File compiles without errors
- shouldAnimate flag is passed to widget

**When done, tell me: "Task 2 complete - screen updated!"**

---

## Task 3: Test Animations (15 minutes)

### What You'll Do:
Run the app and verify animations work correctly.

### Steps:

1. **Run the Flutter app:**
    - Start the app in Chrome
    - Wait for it to load

2. **Test new messages:**
    - Start a conversation
    - Make a choice
    - **Watch the new message appear**

**What to check:**
- ✅ New message fades in smoothly (400ms)
- ✅ New message slides up slightly
- ✅ Animation feels smooth, not jerky
- ✅ Not too fast, not too slow

3. **Test scrolling through history:**
    - Scroll up to see old messages
    - Scroll down to see old messages

**What to check:**
- ✅ Old messages appear instantly (no animation)
- ✅ Scrolling feels smooth
- ✅ No performance issues

4. **Test rapid messages:**
    - Make several choices quickly
    - Watch multiple messages appear

**What to check:**
- ✅ Each message animates independently
- ✅ No lag or stuttering
- ✅ Smooth experience

### Success Criteria:

Phase 2.5 is complete when:
- ✅ New messages fade in with 400ms duration
- ✅ Messages slide up 20px as they fade
- ✅ Old messages (history) appear instantly
- ✅ Animation is smooth and professional
- ✅ No performance impact
- ✅ Feels polished, not gimmicky

**When done, take screenshots/video and tell me: "Task 3 complete - animations working!"**

---

## Optional Task 4: Fine-Tune Animation (15 minutes - SKIP IF SATISFIED)

### What You'll Do:
Adjust timing and curves if animation feels off.

### If animation feels too fast:
```dart
duration: const Duration(milliseconds: 500),  // Slower: 400 → 500
```

### If animation feels too slow:
```dart
duration: const Duration(milliseconds: 300),  // Faster: 400 → 300
```

### If slide feels too much:
```dart
begin: const Offset(0, 0.03),  // Less: 0.05 → 0.03
```

### If slide feels too little:
```dart
begin: const Offset(0, 0.08),  // More: 0.05 → 0.08
```

### If animation feels "bouncy":
```dart
curve: Curves.easeOut,  // Keep this - smooth and professional
```

### If you want slower start, faster end:
```dart
curve: Curves.easeInOut,  // Different curve
```

---

## Summary

**Total Tasks:** 3 tasks (Task 4 is optional tuning)

**Time Estimate:**
- Task 1: 30 min (make widget animated)
- Task 2: 20 min (control animation)
- Task 3: 15 min (test)
- Task 4: 15 min (optional fine-tuning)

**Total:** ~65-80 minutes

---

## Work Strategy

**Do tasks in order:**
1 → 2 → 3 → (optional 4)

**Report after each task** so I can guide you to the next one.

---

## Success Criteria for Phase 2.5

Phase 2.5 is complete when:
- ✅ New messages fade in smoothly
- ✅ Messages slide up as they appear
- ✅ History messages appear instantly (no delay)
- ✅ Professional, subtle polish
- ✅ No performance issues

---

## Notes

**Animation philosophy:**
- Subtle, not flashy
- Enhances, doesn't distract
- Professional polish
- Complements the Fantasia aesthetic

**Common issues:**
- Animation too fast → Increase duration
- Animation too slow → Decrease duration
- Feels "bouncy" → Use Curves.easeOut
- Performance issues → Reduce animation complexity

---

**Ready to start Task 1? Let me know!** 🎬