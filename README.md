# 🎭 StoryForge

An AI-powered storytelling application built with Java Spring Boot backend and Flutter frontend, featuring session-based conversation management with Claude AI.

![Backend CI](https://github.com/hammerheart92/StoryForge/actions/workflows/backend-ci.yml/badge.svg)

## Features

- 🤖 **AI-Powered Storytelling** - Interactive conversations with Claude Sonnet 4
- 💬 **Multi-Session Management** - Create and switch between multiple chat sessions
- 💾 **Persistent Storage** - SQLite database for conversation history
- 🔄 **Session Switching** - Seamlessly switch between conversations with full history
- 🎨 **Modern UI** - Flutter web interface with responsive design
- ✅ **Automated Testing** - 21 comprehensive tests with CI/CD pipeline

## Tech Stack

### Backend
- **Java 21**
- **Spring Boot 3.2.1**
- **SQLite** - Embedded database
- **Claude API** - Anthropic's Claude Sonnet 4
- **Maven** - Build tool

### Frontend
- **Flutter** - Cross-platform framework
- **Dart** - Programming language
- **HTTP Client** - API communication

### Testing & CI/CD
- **JUnit 5** - Unit testing framework
- **Mockito** - Mocking framework
- **MockMvc** - API integration testing
- **GitHub Actions** - Automated CI/CD pipeline

## Project Structure
```
StoryForge/
├── backend/                  # Spring Boot backend
│   ├── src/
│   │   ├── main/java/dev/laszlo/
│   │   │   ├── Application.java
│   │   │   ├── ChatController.java
│   │   │   ├── ChatService.java
│   │   │   ├── DatabaseService.java
│   │   │   ├── ConversationHistory.java
│   │   │   ├── Session.java
│   │   │   └── AppConfig.java
│   │   └── test/java/dev/laszlo/
│   │       ├── DatabaseServiceTest.java    # 7 unit tests
│   │       └── ChatControllerTest.java     # 14 integration tests
│   └── pom.xml
├── frontend/                 # Flutter frontend
│   ├── lib/
│   │   ├── main.dart
│   │   ├── screens/
│   │   ├── services/
│   │   └── models/
│   └── pubspec.yaml
├── .github/
│   └── workflows/
│       └── backend-ci.yml    # CI/CD pipeline
└── docs/                     # Session summaries
```

## Getting Started

### Prerequisites

- **Java 21** - [Download](https://adoptium.net/)
- **Maven 3.x** - [Download](https://maven.apache.org/download.cgi)
- **Flutter** - [Install](https://flutter.dev/docs/get-started/install)
- **Anthropic API Key** - [Get one](https://console.anthropic.com/)

### Backend Setup

1. **Clone the repository**
```bash
   git clone https://github.com/YOUR-USERNAME/StoryForge.git
   cd StoryForge/backend
```

2. **Set environment variable**
```bash
   # Windows
   set ANTHROPIC_API_KEY=your_api_key_here
   
   # Linux/Mac
   export ANTHROPIC_API_KEY=your_api_key_here
```

3. **Run the backend**
```bash
   mvn spring-boot:run
```

Backend runs on: `http://localhost:8080`

### Frontend Setup

1. **Navigate to frontend**
```bash
   cd ../frontend
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Run the app**
```bash
   flutter run -d chrome
```

Frontend runs on: `http://localhost:52028` (or similar)

## Running Tests

### All Tests
```bash
cd backend
mvn test
```

### Specific Test Class
```bash
mvn test -Dtest=DatabaseServiceTest
mvn test -Dtest=ChatControllerTest
```

### With Coverage Report
```bash
mvn test jacoco:report
# Report: target/site/jacoco/index.html
```

### Test Results
```
Tests run: 21, Failures: 0, Errors: 0, Skipped: 0
- DatabaseServiceTest: 7 tests
- ChatControllerTest: 14 tests
Execution time: ~13 seconds
```

## API Endpoints

### Sessions
- `GET /api/chat/sessions` - Get all sessions
- `POST /api/chat/sessions` - Create new session
- `PUT /api/chat/sessions/{id}/switch` - Switch to session
- `DELETE /api/chat/sessions/{id}` - Delete session

### Messages
- `POST /api/chat/send` - Send message and get response
- `POST /api/chat/reset` - Clear current session messages

### Status
- `GET /api/chat/status` - Health check

## Development Journey

This project was built over multiple development sessions:

- **Session 1-8** - Initial development, basic features
- **Session 9** - Bug fixes, session persistence improvements
- **Session 10** - Comprehensive test suite (21 tests)
- **Session 11** - CI/CD pipeline with GitHub Actions

Full session summaries available in `/docs/` directory.

## Testing Strategy

### Unit Tests (7 tests)
- **DatabaseService** - CRUD operations, regression tests
- Fast execution without Spring context

### Integration Tests (14 tests)
- **ChatController** - REST API endpoints
- MockMvc for HTTP testing
- Mocked dependencies (ChatService, DatabaseService)

### Regression Tests
- `getAllSessions_shouldIncludeCreatedAtField()` - Prevents SELECT query bug
- `getSessions_shouldReturnSessionList_withCreatedAtField()` - API serialization

## CI/CD Pipeline

Automated testing runs on:
- ✅ Every push to any branch
- ✅ Pull requests to main
- ✅ Manual workflow dispatch

**Workflow:**
1. Checkout code
2. Set up Java 21
3. Run Maven tests
4. Upload test results
5. Publish test summary
6. Build verification

## Database Schema

### Sessions Table
```sql
CREATE TABLE sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    created_at TEXT NOT NULL
);
```

### Messages Table
```sql
CREATE TABLE messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    role TEXT NOT NULL,
    content TEXT NOT NULL,
    timestamp TEXT NOT NULL,
    FOREIGN KEY (session_id) REFERENCES sessions(id)
);
```

## Deployment

### Backend (Railway)
- Deployed to Railway.app
- Automatic environment detection (localhost vs production)
- SQLite database persists in Railway volume

### Frontend
- Flutter web build
- Can be deployed to any static hosting

## Contributing

This is a personal learning project. Feel free to fork and experiment!

## License

This project is for educational purposes.

## Acknowledgments

- **Anthropic** - Claude API
- **Spring Boot** - Backend framework
- **Flutter** - Frontend framework

---

**Built with ❤️ by Laszlo** - A journey in full-stack development and AI integration