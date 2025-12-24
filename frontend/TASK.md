# Task: Add Session Management UI to Flutter Frontend

## Context
StoryForge is a full-stack AI chatbot (Java Spring Boot backend + Flutter frontend).
The backend already has SQLite database with sessions table and can handle multiple conversations.
The Flutter UI currently only shows one conversation - we need to add session management UI.

## Current State
- Backend: `D:\java-projects\StoryForge\backend\` (Java Spring Boot on port 8080)
- Frontend: `D:\java-projects\StoryForge\frontend\` (Flutter)
- Database: SQLite with sessions and messages tables
- Working: Single conversation chat UI in `frontend/lib/screens/chat_screen.dart`

## What Needs to Be Done

### 1. Create Session Model
**File:** `frontend/lib/models/session.dart`

Create a Session data class with:
- `int id`
- `String name`
- `DateTime createdAt`
- `int messageCount`
- `fromJson` factory constructor
- `toJson` method

### 2. Update ChatService
**File:** `frontend/lib/services/chat_service.dart`

Add these three new methods:
- `Future<List<Session>> getSessions()` - GET `/api/chat/sessions`
- `Future<Session> createNewSession(String name)` - POST `/api/chat/sessions` with body `{"name": "..."}`
- `Future<void> switchSession(int sessionId)` - PUT `/api/chat/sessions/{id}/switch`

Import the Session model.

### 3. Update ChatScreen UI
**File:** `frontend/lib/screens/chat_screen.dart`

Add session management to existing chat screen:

**State variables to add:**
- `List<Session> _sessions = []`
- `Session? _currentSession`
- `bool _isLoadingSessions = false`

**Methods to add:**
- `initState()` - call `_loadSessions()`
- `_loadSessions()` - fetch sessions from backend
- `_createNewSession()` - create new session with name "Chat {count}"
- `_switchToSession(Session session)` - switch to different session and clear messages
- `_buildDrawer()` - build drawer UI with session list
- `_formatDate(DateTime date)` - format dates nicely (Today, Yesterday, Xd ago)

**UI changes:**
- Add `drawer: _buildDrawer()` to Scaffold
- Drawer should have:
  - Header showing "🎭 StoryForge" and conversation count
  - "New Chat" button (green accent, white text)
  - Scrollable list of sessions
  - Visual indicator for active session (purple highlight)
  - Show message count per session
  - Tap session to switch

**Design matching existing style:**
- Use existing colors: `Colors.deepPurple`, `Colors.greenAccent`
- Keep existing message bubble design
- Match existing AppBar style

### 4. Important Notes
- Backend endpoints don't exist yet - they will be created in next step
- For now, just add the UI and service methods
- The API calls will fail until backend is updated (that's expected)
- Keep existing chat functionality working
- Import Session model where needed

## Testing After Completion
Run: `flutter run -d chrome` from `frontend/` directory
- Drawer should open (but session list will be empty/error until backend is ready)
- UI should render without crashes
- Existing chat should still work

## Files to Modify
1. `frontend/lib/models/session.dart` - CREATE NEW
2. `frontend/lib/services/chat_service.dart` - ADD 3 METHODS
3. `frontend/lib/screens/chat_screen.dart` - ADD SESSION UI

## Code Style
- Use const constructors where possible
- Follow existing Dart/Flutter conventions
- Match the coding style in existing files
- Add comments for clarity