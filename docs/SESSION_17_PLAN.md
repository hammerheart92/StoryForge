# Session 17 Plan: Home Screen & Navigation System

**Date:** December 30, 2025  
**Branch:** `feature/home-screen` (to be created)  
**Status:** PLANNING  
**Previous Session:** Session 16 - Immersive UI (COMPLETE, merged to main)

---

## Session Goal

Build a Home/Landing screen and navigation system to prevent automatic Narrator API calls on app launch, giving users control over when stories begin.

---

## Current Problem

**Issue:** Every app launch automatically triggers Narrator
```
App starts → NarrativeScreen loads → _startNarrative() called → API token consumed
```

**Impact:**
- Wastes API tokens on every app launch
- User has no control over story start
- No way to manage multiple sessions or settings
- Poor user experience

**Required Solution:**
- App opens to Home screen (no API calls)
- User explicitly chooses when to start story
- Proper navigation structure for future features
- Preserve existing immersive UI features

---

## Architecture Overview

### Current Flow
```
main.dart
  └─> NarrativeScreen (IMMEDIATE API CALL)
```

### Target Flow
```
main.dart
  └─> HomeScreen
       ├─> "Begin Story" → NarrativeScreen → Start Narrator
       ├─> "Continue Story" → NarrativeScreen (restore state) [Phase 3]
       └─> "Settings" → SettingsScreen [Future]
```

---

## Session Phases

### Phase 1: Home Screen Foundation
**Goal:** Create landing screen that prevents auto-start  
**Duration:** ~90 minutes (3 tasks)  
**Outcome:** App opens to Home screen, user starts story manually

### Phase 2: Navigation Structure
**Goal:** Implement proper routing and navigation  
**Duration:** ~90 minutes (3 tasks)  
**Outcome:** Clean navigation flow, proper back button handling

### Phase 3: State Preservation
**Goal:** Save/restore story state, enable "Continue"  
**Duration:** ~90 minutes (3 tasks)  
**Outcome:** Users can resume stories, state persists across launches

---

## Phase 1: Home Screen Foundation

### Task 1.1: Create HomeScreen Widget (30 min)
**File:** `frontend/lib/screens/home_screen.dart`

**Requirements:**
- StatelessWidget (for now, StatefulWidget if needed later)
- Centered vertical layout
- App title/logo area
- "Begin Your Story" primary button
- Match StoryForge theme (dark, immersive, teal/purple)
- Responsive design (works on mobile + desktop)

**Design Inspiration:**
- Reference from Fantasia app (user will provide)
- Dark background matching narrative screen aesthetic
- Character portraits or thematic imagery (optional)
- Minimalist, elegant approach

**Success Criteria:**
- Screen displays correctly on Chrome
- Screen displays correctly on Android mobile
- Button is clearly visible and styled
- No console errors

**Testing:**
- Hot reload in Chrome
- Test on Android device
- Verify theme consistency

---

### Task 1.2: Update App Entry Point (15 min)
**File:** `frontend/lib/main.dart`

**Changes:**
- Import HomeScreen
- Change `home:` from `NarrativeScreen()` to `HomeScreen()`
- Verify no other entry points trigger NarrativeScreen

**Success Criteria:**
- App launches to Home screen
- No Narrator API call on launch
- No console errors
- Existing theme applied correctly

**Testing:**
- Close and reopen app multiple times
- Verify backend logs show no Narrator calls
- Check Chrome DevTools network tab (no API requests)

---

### Task 1.3: Wire Navigation to NarrativeScreen (30 min)
**File:** `frontend/lib/screens/home_screen.dart`

**Changes:**
- Implement button onPressed handler
- Use Navigator.push to NarrativeScreen
- Ensure NarrativeScreen starts normally (Narrator triggers)
- Add proper back button handling

**Success Criteria:**
- Clicking "Begin Story" navigates to NarrativeScreen
- Narrator starts automatically after navigation
- All immersive UI features work (typewriter, styling, portraits)
- Back button returns to Home screen
- Re-entering story restarts from beginning (for now)

**Testing:**
- Click button, verify Narrator appears
- Test back navigation
- Verify typewriter animation works
- Test on both Chrome and mobile
- Verify portrait backgrounds visible
- Test multiple start → back → start cycles

---

## Phase 2: Navigation Structure

### Task 2.1: Implement Routing Package (45 min)
**Decision:** Use `go_router` package for proper routing

**Files:**
- `frontend/pubspec.yaml` - Add go_router dependency
- `frontend/lib/router/app_router.dart` - Define routes

**Routes:**
- `/` - HomeScreen
- `/story` - NarrativeScreen
- `/settings` - SettingsScreen (placeholder for now)

**Success Criteria:**
- Routes defined and working
- Deep linking structure in place
- Navigation via route names (not widget instances)
- Proper route transitions

---

### Task 2.2: Convert Screens to Use Router (30 min)
**Files:**
- `frontend/lib/main.dart` - Update to use router
- `frontend/lib/screens/home_screen.dart` - Use context.go() instead of Navigator
- `frontend/lib/screens/narrative_screen.dart` - Add route awareness

**Success Criteria:**
- All navigation uses router
- Clean back button behavior
- No widget rebuild issues
- State preserved during navigation (where appropriate)

---

### Task 2.3: Add Navigation Guards (15 min)
**File:** `frontend/lib/router/app_router.dart`

**Requirements:**
- Prevent direct navigation to /story without starting from home
- Handle deep links appropriately
- Error handling for invalid routes

**Success Criteria:**
- Cannot bypass home screen
- 404 handling (redirect to home)
- Clean URL structure

---

## Phase 3: State Preservation

### Task 3.1: Implement Story State Persistence (45 min)
**Package:** Use Hive or shared_preferences for local storage

**Data to Store:**
- Current session ID
- Conversation history
- Last active character
- User choices made
- Timestamp of last activity

**Files:**
- `frontend/lib/services/story_state_service.dart` - New file
- `frontend/lib/models/story_state.dart` - New model

**Success Criteria:**
- State saves after each message
- State loads on app restart
- Handles null/empty state gracefully

---

### Task 3.2: Add "Continue Story" Button (30 min)
**File:** `frontend/lib/screens/home_screen.dart`

**Requirements:**
- "Continue Story" button (only visible if saved state exists)
- Loads last session when clicked
- Navigates to NarrativeScreen with restored state

**Success Criteria:**
- Button appears only when story in progress
- Clicking button restores conversation history
- All messages display correctly (with instant rendering, no animation)
- Current character state preserved

---

### Task 3.3: Implement Session Management (15 min)
**File:** `frontend/lib/screens/home_screen.dart`

**Requirements:**
- Clear logic for "new story" (clears state)
- "Continue" loads existing state
- Handle edge cases (corrupted state, version mismatches)

**Success Criteria:**
- New story always starts fresh
- Continue always restores previous state
- No crashes on edge cases
- User can abandon and restart stories

---

## Files to Create

### New Files
```
frontend/lib/screens/home_screen.dart
frontend/lib/router/app_router.dart
frontend/lib/services/story_state_service.dart
frontend/lib/models/story_state.dart
```

### Optional New Files (if needed)
```
frontend/lib/screens/settings_screen.dart (placeholder)
frontend/assets/images/logo.png (if we add app logo)
```

---

## Files to Modify

### Phase 1
```
frontend/lib/main.dart
  - Change home to HomeScreen
  - Import new screen

frontend/lib/screens/narrative_screen.dart
  - Verify _startNarrative() logic
  - Ensure works when navigated to (not just initial load)
```

### Phase 2
```
frontend/pubspec.yaml
  - Add go_router dependency

frontend/lib/main.dart
  - Replace MaterialApp with MaterialApp.router
  - Configure router

frontend/lib/screens/home_screen.dart
  - Use router navigation methods

frontend/lib/screens/narrative_screen.dart
  - Add route awareness
  - Handle navigation parameters
```

### Phase 3
```
frontend/pubspec.yaml
  - Add hive/hive_flutter or shared_preferences

frontend/lib/screens/narrative_screen.dart
  - Save state after each message
  - Load state on screen init (if provided)

frontend/lib/screens/home_screen.dart
  - Check for saved state
  - Show/hide Continue button
  - Handle state loading
```

---

## Design Specifications

### Color Scheme
- Background: Dark (matching narrative screen)
- Primary accent: Teal (Narrator color)
- Secondary accent: Purple (Ilyra color)
- Text: Light (matching immersive UI)

### Layout (To be refined after Fantasia reference)
```
┌─────────────────────────────────┐
│                                 │
│         [APP LOGO/TITLE]        │
│                                 │
│                                 │
│    [Background imagery?]        │
│                                 │
│                                 │
│     ┌───────────────────┐      │
│     │  Begin Your Story │      │
│     └───────────────────┘      │
│                                 │
│     ┌───────────────────┐      │
│     │  Continue Story   │      │ (Phase 3)
│     └───────────────────┘      │
│                                 │
│           [Settings]            │ (Future)
│                                 │
└─────────────────────────────────┘
```

### Typography
- Title: Large, serif font (Merriweather?)
- Buttons: Clear, sans-serif (Roboto)
- Subtitle/tagline: Italic (if included)

### Button Design
- Primary button: Prominent, teal glow
- Secondary button: Subtle, purple glow (Continue)
- Hover effects: Increase glow intensity
- Mobile: Touch feedback

---

## Technical Decisions

### Routing Package Choice
**Option 1: go_router** ✅ RECOMMENDED
- Declarative routing
- Deep linking support
- Type-safe routes
- Active maintenance
- Good Flutter community adoption

**Option 2: Navigator 2.0**
- Built-in Flutter
- More complex API
- More control but more code

**Option 3: Basic Navigator** (Current)
- Simple but limited
- No URL routing
- Harder to scale

**Decision:** Use go_router for Phase 2

---

### State Management Choice
**Option 1: Hive** ✅ RECOMMENDED
- Fast, lightweight
- No native dependencies
- Type-safe
- Good for structured data
- Already familiar from FurFriendDiary?

**Option 2: shared_preferences**
- Simple key-value storage
- Good for small amounts of data
- Less structure

**Option 3: SQLite**
- Overkill for this use case
- More complex setup

**Decision:** Use Hive for Phase 3 (if you're familiar) or shared_preferences (simpler)

---

## Testing Strategy

### After Each Task
- Hot reload changes
- Test on Chrome (desktop)
- Test on Android mobile
- Verify no console errors
- Check functionality works as expected

### After Each Phase
- Full app restart testing
- Navigate through all screens
- Test back button behavior
- Verify immersive UI still works
- Check API token usage (no unwanted calls)

### Final Testing (After Phase 3)
- Complete user flow: Launch → Home → New Story → Play → Back → Continue
- Multiple session tests
- State persistence across app restarts
- Edge cases (corrupted data, etc.)
- Performance (no lag on navigation)

---

## Success Criteria

### Phase 1 Complete When:
- ✅ App opens to Home screen (not Narrator)
- ✅ No API calls on app launch
- ✅ User can click button to start story
- ✅ Narrator starts normally after navigation
- ✅ All immersive UI features still work
- ✅ Back button returns to Home

### Phase 2 Complete When:
- ✅ Proper routing structure implemented
- ✅ Clean URL/route structure
- ✅ Navigation via named routes
- ✅ No navigation bugs
- ✅ All Phase 1 features still work

### Phase 3 Complete When:
- ✅ Story state persists across app restarts
- ✅ "Continue Story" button appears when appropriate
- ✅ Continuing story restores full conversation
- ✅ New story clears old state
- ✅ No data corruption issues

### Session 17 Complete When:
- ✅ All three phases complete
- ✅ App never auto-starts Narrator
- ✅ User controls when story begins
- ✅ State preservation works reliably
- ✅ Professional home screen design
- ✅ Clean navigation experience
- ✅ All existing features functional
- ✅ Tested on Chrome and mobile
- ✅ Merged to main branch

---

## Risks & Mitigation

### Risk 1: Navigation Breaks Existing Features
**Mitigation:** Test thoroughly after each change, keep git commits small

### Risk 2: State Serialization Issues
**Mitigation:** Use proven packages (Hive/shared_preferences), handle errors gracefully

### Risk 3: Performance Impact from State Saving
**Mitigation:** Save asynchronously, test on mobile, optimize if needed

### Risk 4: Complex Routing Bugs
**Mitigation:** Start simple, add complexity gradually, test each addition

---

## Dependencies to Add

### Phase 2
```yaml
dependencies:
  go_router: ^14.0.0  # Check for latest stable version
```

### Phase 3
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.8
```

**OR**

```yaml
dependencies:
  shared_preferences: ^2.2.2
```

---

## Git Workflow

### Branch Strategy
```bash
# Create feature branch from main
git checkout main
git pull origin main
git checkout -b feature/home-screen

# Commit after each task
git add .
git commit -m "Phase 1.1: Create basic HomeScreen widget"

# Push regularly
git push -u origin feature/home-screen
```

### Commit Message Pattern
- `Phase 1.1: Create basic HomeScreen widget`
- `Phase 1.2: Update main.dart to route to HomeScreen`
- `Phase 1.3: Wire navigation to NarrativeScreen`
- `Phase 2.1: Add go_router package and define routes`
- etc.

### Final Merge
```bash
# After all phases complete and tested
git checkout main
git merge feature/home-screen
git push origin main
git branch -d feature/home-screen
git push origin --delete feature/home-screen
```

---

## Future Enhancements (Post-Session 17)

### Session 18+ Ideas
- Settings screen (animation speed, text size)
- Character selection screen
- Multiple story slots/save files
- Story history/timeline view
- Export/share story feature
- Achievements/progress tracking
- Dark/light theme toggle
- Accessibility features

---

## Questions for Laszlo

### Before Phase 1 Starts
1. Show Fantasia reference for home screen design
2. Any specific branding elements? (logo, tagline)
3. Character selection on home screen or always start with Narrator?
4. Any specific button text preferences?

### Before Phase 2 Starts
1. Confirm go_router package choice?
2. Any specific route names preferred?

### Before Phase 3 Starts
1. Hive or shared_preferences for state storage?
2. What should "new story" do if story in progress? (warning, auto-clear, save slots?)

---

## Session Timeline Estimate

### Phase 1: ~90 minutes
- Task 1.1: 30 min
- Task 1.2: 15 min
- Task 1.3: 30 min
- Testing: 15 min

### Phase 2: ~90 minutes
- Task 2.1: 45 min
- Task 2.2: 30 min
- Task 2.3: 15 min

### Phase 3: ~90 minutes
- Task 3.1: 45 min
- Task 3.2: 30 min
- Task 3.3: 15 min

### Total: ~4.5 hours
- Could span multiple work sessions
- Break points: After each phase
- Each phase is independently testable

---

## Reference Materials

### To Review Before Starting
- [✓] SESSION_16_SUMMARY.md - Current implementation
- [✓] NEXT_SESSION_CONTEXT.md - Previous planning
- [ ] Fantasia home screen reference (Laszlo will provide)
- [ ] go_router documentation (if needed)
- [ ] Hive documentation (if needed)

### Documentation to Update
- Update NEXT_SESSION_CONTEXT.md after completion
- Create SESSION_17_SUMMARY.md at end
- Update README if navigation changes affect setup

---

## Notes

- Keep each task small and testable
- Test on both Chrome and mobile after each task
- Commit frequently with descriptive messages
- Don't move to next phase until current phase fully working
- If any task takes >45 minutes, consider breaking it down further
- User prefers manual instructions over shell scripts
- Use VS Code for Flutter development
- Hot reload frequently during development

---

## Ready to Start!

**First Step:** Review Fantasia reference and discuss home screen design  
**Then:** Create feature branch and begin Phase 1, Task 1.1  
**Status:** Waiting for user input 🚀

---

**Session 17 Goal:** Never again waste tokens on accidental Narrator launches! 🎯