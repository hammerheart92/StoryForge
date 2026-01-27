# Changelog

All notable changes to StoryForge will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned
- Additional story content
- More achievements and challenges
- Enhanced character customization
- Multiplayer storytelling features

---

## [0.11.0] - 2026-01-27

### Added

#### Pirates Gallery - Lore & Extras Categories
- **5 Lore Items** - Historical pirate artifacts and documents:
  - **The Pirate Code** (COMMON, 25 gems) - Ancient rules of pirate conduct
  - **Captain's Logbook** (RARE, 50 gems) - Personal journal of legendary captain
  - **The Black Pearl Legend** (RARE, 55 gems) - Mythical tale of feared ship
  - **Ancient Sea Chart** (EPIC, 75 gems) - Navigation map with hidden routes
  - **The Kraken Chronicle** (EPIC, 80 gems) - Historical account of sea monster
- **5 Extras Items** - Museum-quality pirate artifacts:
  - **Ship's Bell** (COMMON, 30 gems) - Brass bell from famous vessel
  - **Pirate's Spyglass** (RARE, 50 gems) - Worn telescope for spotting prey
  - **Rum Bottles Collection** (RARE, 55 gems) - Aged Caribbean rum assortment
  - **Treasure Coins** (EPIC, 75 gems) - Gold doubloons and pieces of eight
  - **Captain's Pistol** (EPIC, 85 gems) - Ornate flintlock pistol
- **Gallery Progress**: 16/18 items complete (89%)

### Fixed
- **Achievement Progress Display Bug**: Progress text now capped at requirement value
  - "First Steps" achievement now correctly shows "1/1" instead of "7/1"
  - Added `dart:math` import and `min()` function to cap displayed progress
  - All achievements now display proper progress ratios

### Changed
- **Gallery Content Card**: Extended image loading to support Lore and Extras categories
- **Gallery Detail Screen**: Extended image loading to support Lore and Extras categories
- **Database Schema**: Cleaned duplicate sample data and added production Lore/Extras items

### Technical
- **Branch**: `feature/gallery-lore-extras`
- **Testing**: Chrome browser + Android physical device (production mode)
- **Production Ready**: All code deployed and tested on Railway

### Documentation
- SESSION_39_SUMMARY.md created with comprehensive implementation details

---

## [0.10.0] - 2026-01-23

### Added

#### Pirates Gallery Visual Upgrade
- **3 Scene Images** with professional Midjourney-generated artwork:
  - **The Storm** (RARE, 50 gems) - Dramatic lightning and turbulent seas (371 KB)
  - **The Kraken Attack** (EPIC, 80 gems) - Epic sunset kraken battle (607 KB)
  - **Treasure Island Discovery** (RARE, 50 gems) - Tropical paradise cove (671 KB)
- **Gallery Detail Screen** with full-screen content view
  - Tap-to-expand navigation from gallery cards
  - Full-screen image display with blur for locked content
  - Info overlay with gradient, rarity badge, title, description
  - Unlock button integration with existing gem economy
  - Support for both static images and animated video content
- **3 Character Portrait Images** (infrastructure added):
  - Captain Isla Portrait (EPIC, 75 gems) - Navigator with golden lighting
  - First Mate Rodriguez (RARE, 60 gems) - Experienced officer portrait
  - The Sea Witch (LEGENDARY, 120 gems) - Mystical sorceress with teal glow
- **Sea Witch Animation** - Midjourney-generated video (.mp4)
  - AnimatedCharacterBackground widget integration
  - Video playback support for legendary gallery content
  - Detail screen conditional video rendering

### Changed
- **Refactored Asset Management** to directory-based approach
  - Migrated from individual file declarations to folder declarations in `pubspec.yaml`
  - Scalable pattern supporting hundreds of assets
  - Cleaner, more maintainable configuration
- **Enhanced Gallery Card Widget** with conditional image loading
  - Dynamic background rendering based on content type
  - Image loading for scenes and characters via title mapping
  - Graceful fallback to placeholder for missing images
  - Preserved blur effects for locked content (sigmaX/Y: 4)

### Technical
- **Asset Organization**:
```
  frontend/assets/images/gallery/
  ├── scenes/          (3 images, ~1.6 MB total)
  ├── characters/      (3 images, ~2 MB total)
  ├── lore/            (prepared for future content)
  └── extras/          (prepared for future content)
  
  frontend/assets/videos/
  └── character_sea_witch_portrait.mp4
```
- **Image Optimization**: All images compressed with TinyPNG (60-70% size reduction)
- **Conditional Image Loading Pattern**:
```dart
  String? _getSceneImagePath() { ... }
  String? _getCharacterImagePath() { ... }
  final imagePath = _getSceneImagePath() ?? _getCharacterImagePath();
```
- **Video Detection Pattern** for Sea Witch:
```dart
  bool _isSeaWitch() {
    return content.title.toLowerCase() == 'the sea witch' &&
           content.contentType.toLowerCase() == 'character';
  }
```

### Infrastructure
- **Branch**: `feature/gallery-scene-images`
- **Testing**: Chrome browser + Android physical device
- **Performance**: 60fps maintained, smooth scrolling verified
- **Memory Usage**: ~2-3 MB additional assets (acceptable for mobile)
- **Production Ready**: Scenes category fully complete

### Known Issues
- Character images need cropping adjustment (full-body portraits don't fit card format)
- Sea Witch animation not yet tested (insufficient gems for unlock)
- Detail screen character image loading requires verification
- Lore and Extras categories not yet started

### Documentation
- SESSION_37_SUMMARY.md created with full implementation details
- SESSION_38_PLAN.md prepared for character polish completion

---

## [0.9.0] - 2026-01-21

### Added
- PostgreSQL database support for production deployment
- JDBC URL format conversion for Railway compatibility
- Persistent data storage across Railway container restarts
- Database schema initialization with 10 production tables

### Changed
- **BREAKING**: Migrated from SQLite to PostgreSQL
- Updated all database service classes to support environment-aware connections
- Modified `DatabaseService.java`, `CharacterDatabase.java`, `StorySaveService.java`, `CurrencyService.java`, and `GalleryService.java`
- Improved connection handling with automatic URL format detection

### Fixed
- Railway deployment connection failures (4-hour debugging session)
- PostgreSQL JDBC driver URL format incompatibility
- Timestamp data type handling for PostgreSQL
- Gallery unlock constraint violations
- Database connection string format conversion (libpq → JDBC)

### Technical
- Added `convertToJdbcUrl()` method to handle Railway's PostgreSQL connection string format
- Implemented proper timestamp writes with `setTimestamp()` instead of `setString()`
- Implemented proper timestamp reads with helper method using `getTimestamp()`
- Added SSL configuration for Railway PostgreSQL connections
- Fixed boolean handling (SQLite integer → PostgreSQL native boolean)

### Infrastructure
- Production deployment: https://storyforge-production.up.railway.app
- Database: Railway PostgreSQL (persistent storage)
- All data now survives container restarts and redeployments

## [0.8.0] - 2026-01-18

### Added

#### Story Completion & Endings System
- Story completion detection with ending markers (`[END:ending_id]`)
- StoryCompletionDialog celebration modal
  - Trophy icon with teal glow effect
  - Ending title and description display
  - +100 Chronicle Gems reward badge
  - Achievement unlocked notification
  - Navigation: "View Endings" or "Continue" to library
- StoryEndingsScreen gallery
  - Progress tracking (X/Y endings discovered)
  - Discovered endings with full details and discovery date
  - Undiscovered endings displayed as "???" with lock icon
  - Trophy button on story library cards for quick access
- Multiple endings per story:
  - **Pirates**: romantic_ending, treasure_ending, tragic_ending, redemption_ending
  - **Observatory**: enlightenment_ending, tragic_ending, neutral_ending
  - **Illidan**: redemption_ending, power_ending, neutral_ending

#### Backend Infrastructure
- Completion tracking columns in `story_saves` table:
  - `ending_id` (VARCHAR) - tracks which ending was discovered
  - `completed_at` (TIMESTAMP) - completion timestamp
  - `is_completed` (BOOLEAN) - already existed from Session 26
- `NarrativeEngine` ending detection with regex pattern `[END:ending_id]`
- `NarrativeResponse` fields: `isEnding`, `endingId`
- `StorySaveService.markStoryCompleted()` updated to accept `endingId` parameter
- New API endpoints:
  - `GET /api/narrative/{storyId}/endings` - List all endings (discovered/undiscovered)
  - `GET /api/narrative/{storyId}/completion-stats` - Completion statistics
- New DTOs: `EndingSummary`, `CompletionStats`

#### Frontend Services & Models
- `StoryEnding` model (id, title, description, discovered, discoveredAt)
- `CompletionStats` model with `fullyCompleted` computed property
- `StoryCompletionService` with API methods:
  - `getStoryEndings(storyId)` - Fetch endings for story
  - `getCompletionStats(storyId)` - Fetch completion statistics
- `UnlockTrackerService.trackStoryCompletion()` - Achievement tracking integration
- "First Story" achievement (10 gems, common rarity, target: 1 completion)

### Changed
- Completion detection now uses `[END:ending_id]` markers instead of empty choices
- 100 gems awarded on story completion (implementation formalized)
- Story Library "Completed" filter now functional with actual data
- Save slots display "Completed" badge when story is finished
- Completion tracking integrated with achievements system

### Fixed
- JSON field mapping: backend `ending` field → frontend `isEnding` property
- Completion dialog detection: removed overly-strict previous state check
- Achievement counter initialization: added `stories_completed` to default counters

---

## [0.7.0] - 2026-01-17

### Added

#### Tasks & Achievements System
- Daily check-in system with 7-day reward cycle
  - Day 1: 20 gems, Day 2: 10 gems, Day 3: 40 gems
  - Day 4: 20 gems, Day 5: 30 gems, Day 6: 50 gems, Day 7: 100 gems
- Streak tracking for consecutive daily check-ins
- 7 unlockable achievements with gem rewards:
  - **First Story** (10 gems) - Complete your first story
  - **Scene Explorer** (15 gems) - Unlock 3 gallery scenes
  - **Character Collector** (20 gems) - Unlock 5 character portraits
  - **Lore Master** (25 gems) - Unlock all lore entries
  - **Treasure Hunter** (30 gems) - Unlock 10 gallery items
  - **Dedicated Reader** (40 gems) - Read for 30 minutes
  - **Completionist** (50 gems) - Unlock all content for a story
- Achievement cards with progress bars and rarity colors
- Claimable rewards UI with gem animations
- Tasks icon button with badge count in app bar

#### Backend Infrastructure
- `TasksController` with check-in and claim endpoints
- Achievement progress tracking integration with gallery unlocks
- `UnlockTrackerService` for mapping gallery unlocks to achievements

---

## [0.6.0] - 2026-01-14

### Added

#### Gallery & Collection System
- Gallery screen with 4-tab filtering (All, Scenes, Characters, Lore, Extras)
- Content catalog with 10+ unlockable items per story
- 4 rarity levels with distinct visual styling:
  - **Common** (green border) - 20-30 gems
  - **Rare** (blue border) - 45-60 gems
  - **Epic** (purple border) - 75-85 gems
  - **Legendary** (gold border) - 100-120 gems
- Unlock confirmation dialog with gem cost display
- Blurred thumbnails for locked content
- Grid layout (2 columns) with rarity glow effects

#### Gem Currency Economy
- Starting balance: 100 gems for new users
- Earn gems through:
  - Story choices: 5 gems per choice made
  - Story completion: 100 gems bonus
  - Daily check-ins: 20-100 gems
  - Achievement claims: 10-50 gems
- Spend gems on gallery content unlocks
- Transaction history logging with source tracking
- `CurrencyService` for balance management
- `GalleryService` for content and unlock tracking

#### Sample Gallery Content (Pirates Story)
- The Pirate Code (common lore, 30 gems)
- The Storm (rare scene, 50 gems)
- Captain Isla Portrait (epic character, 75 gems)
- The Kraken Attack (epic scene, 80 gems)
- Treasure Island Discovery (rare scene, 45 gems)
- First Mate Rodriguez (rare character, 60 gems)
- The Sea Witch (legendary character, 120 gems)
- Tales of the Flying Dutchman (common lore, 25 gems)
- Ship Blueprint: The Black Pearl (epic extra, 85 gems)
- Soundtrack: Ocean's Embrace (common extra, 20 gems)

#### Design Token System
- Centralized color tokens (light theme, highlights, semantic colors)
- Typography tokens (heading, body, CTA, tags)
- Spacing tokens (xs through xxl)
- Shadow tokens (small, medium, large elevation)
- Rarity color mapping
- Character-specific color themes

---

## [0.5.0] - 2026-01-11

### Added

#### Story Library Screen
- Central hub for managing all story saves
- Story cards with save metadata display
- Progress percentage and completion status
- Last played timestamp
- Sort controls:
  - Last Played (default)
  - Alphabetical
  - Completion status
- Filter chips:
  - All stories
  - In Progress
  - Completed
- Pull-to-refresh capability
- Story count summary

#### Multi-Slot Save System
- 5 independent save slots per story
- Save slot selection screen with slot status
- Actions per slot: Continue, Start New, Delete
- `SaveSlotCard` widget with visual status indicators
- Backend save management endpoints:
  - `GET /api/narrative/saves` - All saves
  - `GET /api/narrative/saves/{storyId}` - Story saves
  - `GET /api/narrative/saves/story/{storyId}` - All slots for story
  - `DELETE /api/narrative/saves/{storyId}/{saveSlot}` - Delete slot

#### Auto-Save Functionality
- Automatic save after each story interaction
- Conversation history JSON serialization
- Save metadata tracking (message count, speaker, completion)
- `StorySaveService` with comprehensive save/load methods
- Database schema: `story_saves` table with slot support

### Changed
- Navigation flow updated for multi-slot support
- Story completion now awards 100 gems

---

## [0.4.0] - 2026-01-04

### Added

#### Home Screen
- Atmospheric gradient background
- "StoryForge" title with "Interactive Storytelling" subtitle
- Story Library button with teal glow effect
- Profile icon button for accessing user profile
- Responsive design for mobile and desktop

#### Profile Screen
- User profile header with avatar and username
- 3x2 statistics grid:
  - Total Messages sent
  - Choices Made count
  - Time Spent (minutes)
  - Narrator Messages count
  - Ilyra Messages count
  - Total Stories played
- Settings section:
  - Animation Speed slider (0-100ms per character)
  - Text Size options (Small/Medium/Large)
  - Language selection (English/Romanian)
  - Clear All Data (with confirmation)
  - About section (version info)
- `StatsService` for calculating gameplay statistics

#### Character Selection Screen
- Choose starting character for story
- Mobile/desktop responsive layouts
- Character info cards with traits and descriptions
- Story-specific character filtering
- Visual selection feedback

#### Story Selection System
- Browse available stories
- Story cards with icon, title, tagline
- Story-specific navigation
- Returns selected story ID to caller

#### New Stories & Characters

**Illidan Story (Warcraft-inspired)**
- **Illidan Stormrage** - The Betrayer
  - Moods: defiant, tormented, ruthless, arrogant, philosophical, intense
  - Complex anti-hero narrative
- **Tyrande Whisperwind** - High Priestess
  - Moods: concerned, hopeful, conflicted, compassionate, regretful, horrified
  - Moral compass character

**Pirates Story**
- **Captain Nathaniel Blackwood** - Legendary pirate captain
  - Moods: defiant, frustrated, angry, contemplative, longing, melancholic, charming, triumphant, confident
  - Romantically frustrated character arc
- **Isla Hartwell** - Ship's navigator
  - Moods: analytical, focused, firm, wary, concerned, anxious, uncomfortable, hopeful, optimistic, warm
  - Professional boundary maintainer

#### Animated Character Videos
- Mood-based video selection for Pirates story
- Video player integration (`video_player: ^2.8.0`)
- WebP format optimization for character portraits
- Character reveal animations with delayed UI

---

## [0.3.0] - 2025-12-30

### Added

#### Multi-Character Narrative Engine
- AI-powered narrative generation with Claude API
- Layered prompt system: base rules + character personality
- Character-specific system prompts
- JSON response parsing (dialogue, actionText, mood)
- Mood inference and extraction per character
- `NarrativeEngine` service with response generation

#### Branching Choice System
- Choice generation via separate Claude API call
- Regex parsing for `[CHOICE: label | nextSpeaker]` format
- 2-3 contextual choices per story turn
- `Choice` model with label, nextSpeaker, mood
- User choice tracking in database
- Fallback choices when generation fails
- `ChoicesSection` and `ChoiceButton` widgets

#### Character System Foundation
- **Narrator** (Observatory) - Omniscient storyteller
- **Ilyra** (Observatory) - Exiled astronomer
  - Personality: reserved, analytical, curious
  - Moods: wary, curious, melancholic, defensive, resigned, passionate, vulnerable
- Character-specific fonts and styling
- Character color mapping (Narrator=Navy, Ilyra=Purple, User=Blue)
- Character portraits with glow effects

#### Flutter Narrative UI
- `NarrativeScreen` with scrollable conversation history
- `CharacterMessageCard` for dialogue display
- `CharacterBackground` with mood-based scene switching
- `AnimatedCharacterBackground` for transitions
- Typewriter text animation (`TypewriterText` widget)
- Auto-scroll on new messages
- Debug menu for inspect/reset
- Error banner for API failures
- Loading overlay during API calls

#### State Management
- Riverpod providers for narrative state
- `NarrativeNotifier` and `NarrativeState`
- `narrativeServiceProvider` singleton
- Convenience providers for loading/error states
- `currentSpeakerProvider` for active character

---

## [0.2.0] - 2025-12-26

### Added

#### SQLite Database Persistence
- `DatabaseService` for SQLite initialization
- Tables created:
  - `sessions` - Chat sessions with metadata
  - `messages` - User/assistant messages with timestamps
  - `characters` - Character definitions
  - `user_choices` - Branching narrative tracking
- `CharacterDatabase` for character CRUD operations
- Conversation history persistence

#### Session Management
- Multi-session chat support
- Session creation and switching
- Session metadata (name, message count, created_at)
- Active session tracking
- Auto-session creation on first message

#### Testing Infrastructure
- 21 unit and integration tests
- 85% code coverage
- `DatabaseServiceTest` for database operations
- `ChatControllerTest` for API endpoints
- JaCoCo coverage reports (`target/site/jacoco/index.html`)

#### CI/CD Pipeline
- GitHub Actions workflow for automated testing
- Test summary reporting
- Workflow permissions configuration
- Railway.app cloud deployment support

#### Environment Configuration
- Development mode: `http://localhost:8080`
- Production mode: `https://storyforge-production.up.railway.app`
- `ApiConfig` with dart-define switching
- Usage: `flutter run --dart-define=ENV=production`
- `DebugScreen` for environment diagnostics

### Fixed
- Session persistence bug with `created_at` SELECT query
- Proper session retrieval on app restart

---

## [0.1.0] - 2025-12-21

### Added

#### Initial Claude API Integration
- Anthropic Claude API communication
- API key loading from environment variable (`ANTHROPIC_API_KEY`)
- HTTP client with proper headers (x-api-key, anthropic-version)
- Model: `claude-sonnet-4-20250514`
- Max tokens: 1024, API version: `2023-06-01`
- Request/response handling with Gson
- 30s connection timeout, 60s request timeout

#### Spring Boot REST API Framework
- `ChatController` with REST endpoints:
  - `GET /api/chat/status` - Health check
  - `GET /api/chat/sessions` - List sessions
  - `POST /api/chat/sessions` - Create session
  - `PUT /api/chat/sessions/{id}/switch` - Switch session
  - `POST /api/chat/send` - Send message
  - `POST /api/chat/reset` - Clear conversation
- `ChatService` for Claude API communication
- System prompt customization
- Conversation history management

#### Flutter Chat UI (Legacy)
- `ChatScreen` with message history
- Session management drawer
- Create new session button
- Session switching capability
- User/assistant message bubbles
- Manual reset conversation button

---

## Technical Architecture

### Backend Stack
- **Framework**: Java 17 + Spring Boot
- **Database**: SQLite (`storyforge.db`)
- **AI Model**: Claude Sonnet 4 via Anthropic API
- **Build Tool**: Maven

### Frontend Stack
- **Framework**: Flutter/Dart
- **State Management**: Riverpod
- **Local Storage**: SharedPreferences
- **HTTP Client**: Native Dart http package

### API Endpoints Summary

| Controller | Endpoints | Purpose |
|------------|-----------|---------|
| NarrativeController | 12 endpoints | Main storytelling API |
| ChatController | 6 endpoints | Legacy chat API |
| TasksController | 3 endpoints | Achievements system |
| GalleryController | 5 endpoints | Content unlock system |

### Database Schema

| Table | Purpose |
|-------|---------|
| sessions | Chat session metadata |
| messages | Conversation messages |
| characters | Character definitions |
| user_choices | Player choice tracking |
| story_saves | Multi-slot save data |
| user_currency | Gem balance tracking |
| gem_transactions | Transaction history |
| story_content | Gallery content catalog |
| user_unlocks | Unlocked content tracking |

---

## Development Statistics

- **Development Period**: December 19, 2025 - January 17, 2026 (29 days)
- **Development Sessions**: 32 documented sessions
- **Total Commits**: 100+ commits
- **Test Coverage**: 45+ tests, 85%+ coverage
- **Frontend Screens**: 11 screens
- **Frontend Widgets**: 19 reusable components
- **Backend Services**: 6 services
- **API Endpoints**: 25+ endpoints
- **Stories**: 3 (Observatory, Illidan, Pirates)
- **Characters**: 6 unique characters
- **Achievements**: 7 trackable achievements

---

## Contributors

- Development and design by the StoryForge team
- AI narrative generation powered by [Anthropic Claude](https://www.anthropic.com/)

---

## License

This project is proprietary software. All rights reserved.
