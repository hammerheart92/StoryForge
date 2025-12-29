# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

StoryForge is an AI-powered interactive storytelling application with a Java Spring Boot backend and Flutter frontend. It features a narrative engine that generates character-driven dialogues with branching choices using Claude AI.

## Build and Run Commands

### Backend (Spring Boot)
```bash
cd backend

# Run the backend (requires ANTHROPIC_API_KEY environment variable)
mvn spring-boot:run

# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=DatabaseServiceTest
mvn test -Dtest=ChatControllerTest

# Run tests with coverage report (output: target/site/jacoco/index.html)
mvn test jacoco:report
```

### Frontend (Flutter)
```bash
cd frontend

# Install dependencies
flutter pub get

# Run in development mode (connects to localhost:8080)
flutter run -d chrome

# Run in production mode (connects to Railway deployment)
flutter run -d chrome --dart-define=ENV=production
```

## Architecture

### Two-API System
The backend exposes two REST API systems:
1. **Chat API** (`/api/chat/*`) - Basic session-based chat with Claude
2. **Narrative API** (`/api/narrative/*`) - Character-driven storytelling with choices

The frontend currently uses the Narrative API.

### Backend Structure (dev.laszlo.*)
- `controller/` - REST endpoints (ChatController, NarrativeController)
- `service/` - Business logic (ChatService for Claude API, NarrativeEngine for character responses)
- `database/` - SQLite persistence (DatabaseService, CharacterDatabase)
- `model/` - DTOs (Session, Character, Choice, NarrativeResponse)

### Frontend Structure (lib/)
- `providers/` - Riverpod state management (NarrativeNotifier, NarrativeState)
- `services/` - HTTP clients (NarrativeService)
- `screens/` - UI screens (NarrativeScreen)
- `widgets/` - Reusable components (ChoiceButton, CharacterMessageCard)
- `theme/` - Design tokens and theme (StoryForgeTheme)
- `config/` - Environment configuration (ApiConfig with dart-define)

### Key Patterns
- **Layered Prompts**: NarrativeEngine builds prompts by combining base narrative rules with character-specific personality traits
- **Choice Generation**: Uses a separate Claude call to generate contextual narrative choices, parsed via regex from `[CHOICE: label | nextSpeaker]` format
- **Environment Switching**: Flutter uses `--dart-define=ENV=production` to switch between localhost and Railway URLs

### Database Schema (SQLite)
- `sessions` - Chat sessions with name and created_at
- `messages` - User/assistant messages linked to sessions
- `characters` - Character definitions with personality, speech_style, mood
- `user_choices` - Tracks player choices for branching narrative

## API Endpoints

### Narrative API (primary)
- `GET /api/narrative/characters` - List all characters
- `POST /api/narrative/speak` - Send message, get response with choices
- `POST /api/narrative/choose` - Select a choice, continue narrative
- `GET /api/narrative/status` - Health check

### Chat API (legacy)
- `POST /api/chat/send` - Simple message/response
- `GET /api/chat/sessions` - List sessions
- `POST /api/chat/sessions` - Create session
- `PUT /api/chat/sessions/{id}/switch` - Switch active session
