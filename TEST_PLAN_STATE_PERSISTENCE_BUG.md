# Test Plan: State Persistence Bug Fix

## Bug Description
After clearing data in ProfileScreen, the "Begin Your Story" button continues the old story instead of starting fresh.

## Root Cause
The Riverpod `narrativeStateProvider` is a singleton that persists across navigation. When starting a new story, the provider still retained old conversation state in memory even though SharedPreferences was cleared.

## Fix Implementation
Added `reset()` call in NarrativeScreen's `initState()` when starting a fresh story (when `restoredMessages` is null).

**File Modified:** `frontend/lib/screens/narrative_screen.dart` (lines 54-57)

```dart
// New story - CRITICAL: Reset provider state before starting
// This clears any old conversation data from previous sessions
ref.read(narrativeStateProvider.notifier).reset();
print('🔄 Reset provider state for fresh story');
```

## Test Scenarios

### Test 1: Clear Data → Begin Fresh Story
**Steps:**
1. Start app, tap "Begin Your Story"
2. Wait for first message from Narrator (e.g., "I approach the ancient observatory")
3. Make 2-3 choices to build conversation history
4. Navigate back to Home
5. Tap Profile icon
6. Tap "Clear All Data" → Confirm
7. Verify stats show all zeros
8. Navigate back to Home
9. Tap "Begin Your Story"

**Expected Result:**
- Story starts fresh with the initial message ("I approach the ancient observatory")
- No old conversation history appears
- Profile stats show only new session data

**Actual Result Before Fix:**
- Story continued from message 10+ (old data in memory)
- Profile stats showed old data reappearing

---

### Test 2: Clear Data → Continue Story Disabled
**Steps:**
1. Start app, tap "Begin Your Story"
2. Make 1-2 choices
3. Navigate back to Home
4. Tap Profile icon
5. Tap "Clear All Data" → Confirm
6. Navigate back to Home

**Expected Result:**
- "Continue Story" button is disabled (grayed out)
- "Begin Your Story" button is enabled

**Actual Result:** ✓ Already working (this part was not broken)

---

### Test 3: Normal Flow - Continue Story (Regression Test)
**Steps:**
1. Start app, tap "Begin Your Story"
2. Make 2-3 choices to build conversation
3. Navigate back to Home
4. Tap "Continue Story"

**Expected Result:**
- Story resumes from where it left off
- All previous messages are displayed
- Choice buttons from last message are available

**Actual Result:** ✓ Should continue working (verify no regression)

---

### Test 4: Multiple Fresh Stories Without Clearing
**Steps:**
1. Start app, tap "Begin Your Story"
2. Make 1 choice
3. Navigate back to Home
4. Tap "Begin Your Story" again (without clearing data)

**Expected Result:**
- SharedPreferences is cleared by HomeScreen (line 120)
- Story starts fresh each time

**Actual Result:** ✓ Already working correctly

---

### Test 5: Provider State Isolation
**Steps:**
1. Start app, tap "Begin Your Story"
2. Make 3 choices (story has ~6 messages)
3. Tap "Start Over" button in NarrativeScreen (refresh icon)

**Expected Result:**
- Story resets and starts fresh with initial message
- Old conversation is cleared from UI

**Actual Result:** ✓ Should work (uses same reset() method)

---

## Verification Checklist

- [ ] Fix compiles without errors
- [ ] Test 1 passes (Clear Data → Fresh Story)
- [ ] Test 2 passes (Continue button disabled after clear)
- [ ] Test 3 passes (Continue Story still works)
- [ ] Test 4 passes (Multiple fresh stories)
- [ ] Test 5 passes (Start Over button works)
- [ ] No console errors or warnings
- [ ] Profile stats accurately reflect only current session

---

## Technical Validation

### Before Fix:
```dart
// NarrativeScreen.initState() - OLD CODE
} else {
  // New story - start with Narrator as usual
  _startNarrative();  // ❌ Never resets provider state!
}
```

### After Fix:
```dart
// NarrativeScreen.initState() - NEW CODE
} else {
  // New story - CRITICAL: Reset provider state before starting
  ref.read(narrativeStateProvider.notifier).reset();  // ✅ Clears old data!
  print('🔄 Reset provider state for fresh story');
  _startNarrative();
}
```

### Reset Method (already existed, just wasn't being called):
```dart
// narrative_notifier.dart (line 108-111)
void reset() {
  print('🔄 Resetting narrative state');
  state = NarrativeState.initial();  // Empty history, no response, clean state
}
```

---

## Console Output Expected

When starting a fresh story, you should see:
```
🔄 Reset provider state for fresh story
🔄 Resetting narrative state
📤 Sending message: "I approach the ancient observatory" to narrator
✅ Message sent successfully. Speaker: Narrator, Choices: 3
```

When continuing a saved story, you should see:
```
✅ Restored 9 messages - ready to continue
```

---

## Prevention Measures

1. **Code Comment Added:** Clear explanation of why reset() is critical
2. **Architectural Pattern:** Always reset singleton state when starting fresh sessions
3. **Future Enhancement:** Consider adding integration tests for state management flows

---

## Related Files
- `frontend/lib/screens/narrative_screen.dart` (FIX APPLIED)
- `frontend/lib/providers/narrative_notifier.dart` (reset() method)
- `frontend/lib/screens/home_screen.dart` (Begin Your Story button)
- `frontend/lib/screens/profile_screen.dart` (Clear Data functionality)
- `frontend/lib/services/story_state_service.dart` (SharedPreferences clearing)
