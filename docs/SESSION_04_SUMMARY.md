# Session 4 Summary: Flutter Frontend

**Date:** December 21, 2024  
**Project:** StoryForge (formerly ScenarioChat)  
**Goal:** Build Flutter UI that connects to Java backend

---

## What We Built

A cross-platform chat UI that:
1. Runs on Web (Chrome) and Android
2. Connects to Java backend via HTTP
3. Displays chat messages with styled bubbles
4. Supports send message and reset conversation

---

## Architecture (Full Stack)

```
┌─────────────────────────────────────┐
│         Flutter Frontend            │
│   (Web / Android / Desktop)         │
│         localhost:54580             │
└─────────────────────────────────────┘
                  ↕ HTTP
┌─────────────────────────────────────┐
│        Java Spring Boot             │
│          localhost:8080             │
│   /api/chat/send, /reset, /status   │
└─────────────────────────────────────┘
                  ↕ HTTP
┌─────────────────────────────────────┐
│        Anthropic Claude API         │
└─────────────────────────────────────┘
```

---

## Project Structure (Monorepo)

```
StoryForge/
├── backend/                    # Java Spring Boot
│   ├── src/main/java/dev/laszlo/
│   │   ├── Application.java
│   │   ├── ChatController.java   # Added @CrossOrigin
│   │   ├── ChatService.java
│   │   ├── ConversationHistory.java
│   │   └── Main.java
│   └── pom.xml
├── frontend/                   # Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── models/
│   │   │   └── chat_message.dart
│   │   ├── screens/
│   │   │   └── chat_screen.dart
│   │   └── services/
│   │       └── chat_service.dart
│   └── pubspec.yaml
├── prompts/                    # For teammate's prompt templates
└── docs/                       # Session summaries
```

---

## Key Concepts Learned

### 1. Flutter Project Creation

```powershell
flutter create scenario_chat_app
```

Creates a new Flutter project with all platform folders (android, ios, web, windows, etc.)

---

### 2. Dart Constructor vs Java Constructor

**Java:**
```java
public ChatMessage(String content, boolean isUser) {
    this.content = content;
    this.isUser = isUser;
    this.timestamp = LocalDateTime.now();
}
```

**Dart:**
```dart
ChatMessage({
  required this.content,
  required this.isUser,
  DateTime? timestamp,
}) : timestamp = timestamp ?? DateTime.now();
```

| Dart | Java | Meaning |
|------|------|---------|
| `required this.content` | `this.content = content` | Auto-assigns parameter |
| `{ }` around params | No braces | Named parameters |
| `DateTime?` | `@Nullable` | Nullable type |
| `??` | `!= null ? x : y` | Null coalescing |

---

### 3. HTTP Package for API Calls

**pubspec.yaml:**
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
```

**Making requests:**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

final response = await http.post(
  Uri.parse('http://localhost:8080/api/chat/send'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({'message': message}),
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  return data['response'];
}
```

---

### 4. CORS Error and Fix

**Problem:** Browser blocks requests between different ports (security)
- Flutter: `localhost:54580`
- Java: `localhost:8080`

**Fix:** Add `@CrossOrigin` annotation in Java:

```java
@RestController
@RequestMapping("/api/chat")
@CrossOrigin(origins = "*")  // ← This fixes CORS
public class ChatController {
```

---

### 5. Flutter Widget Structure

```dart
class ChatScreen extends StatefulWidget {
  // StatefulWidget = has mutable state (messages change)
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];  // State
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(...),
      body: Column(
        children: [
          Expanded(child: ListView.builder(...)),  // Messages
          Container(child: Row(...)),              // Input area
        ],
      ),
    );
  }
}
```

---

### 6. Running on Different Platforms

```powershell
# Check available devices
flutter devices

# Run on Chrome
flutter run -d chrome

# Run on Android device
flutter run -d <device_id>

# Run on Windows (requires Visual Studio C++)
flutter run -d windows
```

---

## Files Created This Session

### lib/models/chat_message.dart
Simple data class to hold message content, sender, and timestamp.

### lib/services/chat_service.dart
HTTP client that calls Java backend:
- `sendMessage()` → POST /api/chat/send
- `resetChat()` → POST /api/chat/reset
- `checkStatus()` → GET /api/chat/status

### lib/screens/chat_screen.dart
Main UI with:
- AppBar with reset button
- Message list (purple = user, grey = Claude)
- Loading indicator
- Text input with send button

### lib/main.dart
App entry point with theme configuration.

---

## Testing Results

**Web (Chrome):** ✅ Working
- Wizard scenario generated successfully
- Alucard from Hellsing scenario worked
- Conversation memory maintained

**Android (Phone):** ✅ App runs
- UI displays correctly
- Backend connection fails (expected - localhost issue)
- Would need computer's IP address for real mobile testing

---

## Questions & Answers

### Q1: Why build UI with Flutter instead of Java?

| Flutter | Java (JavaFX) |
|---------|---------------|
| Modern, beautiful UI | "Windows 98" look 😅 |
| One codebase → all platforms | Desktop only |
| Hot reload | Rebuild each time |
| Growing community | Shrinking |

---

### Q2: Mobile can't connect to localhost?

`localhost` on phone = the phone itself, not your computer.

**Fix:** Use computer's IP address:
```dart
static const String baseUrl = 'http://192.168.1.100:8080/api/chat';
```

---

## Monorepo Reorganization

Reorganized two separate projects into one repository:

**Before:**
```
D:\java-projects\
├── ScenarioChat\        (separate repo)
└── scenario_chat_app\   (no repo)
```

**After:**
```
D:\java-projects\StoryForge\
├── backend/
├── frontend/
├── prompts/
└── docs/
```

**Why monorepo?**
- Solo developer (+ 1 teammate)
- Frontend tightly coupled to backend
- One `git push` updates everything
- Easier collaboration

---

## Team Structure

| Role | Person | Responsibility |
|------|--------|----------------|
| Developer | Laszlo | Java backend, Flutter frontend |
| Prompt Engineer | Colleague | GenAI prompts, financing, business idea |

---

## Commands Reference

**Run backend (IntelliJ):**
- Select `Application` config → Run ▶️

**Run frontend (Terminal):**
```powershell
cd D:\java-projects\StoryForge\frontend
flutter run -d chrome
```

**Test API (PowerShell):**
```powershell
Invoke-WebRequest -Uri "http://localhost:8080/api/chat/send" -Method POST -ContentType "application/json" -Body '{"message":"Hello"}'
```

---

## Project Progress

| Session | Achievement |
|---------|-------------|
| 1 | First API call to Claude |
| 2 | Interactive chat with memory |
| 3 | REST API with Spring Boot |
| 4 | Flutter frontend + monorepo ✅ |

---

## Next Steps

- Add more prompt templates (teammate's job)
- Persist conversations to database
- Deploy backend to cloud
- Build release APK for Android
- Add user authentication

---

*Session 4 completed successfully! 🎉*

*Full stack AI chatbot: Flutter → Java → Claude*