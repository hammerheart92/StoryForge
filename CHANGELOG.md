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

## [1.0.0] - 2026-02-12

### 🎉 Major Milestone: Complete Admin Panel (SESSION_44)

**Breaking Change:** This release introduces a complete content management system for creators. The admin panel enables non-technical users to manage all StoryForge content through the UI without backend or database access.

### Added

#### Backend - Admin APIs (Phases 1-3)
- ✨ **Creator Ownership System**: Database migrations adding `created_by_user_id` to `stories` and `story_content` tables with proper foreign keys and indexes
- 🔐 **Story Management API**: Complete CRUD endpoints (`/api/admin/stories`) with JWT authentication and role-based authorization
  - Create, read, update, delete stories
  - Toggle publish status (`PATCH /api/admin/stories/{id}/publish`)
  - Creator ownership verification on all mutations
  - Auto-generated URL-friendly story slugs
  - 6 production endpoints
- 🎨 **Gallery Management API**: Complete CRUD endpoints (`/api/admin/gallery`) for managing gallery items
  - Create, read, update, delete gallery items
  - Filter by story (`GET /api/admin/gallery/story/{storyId}`)
  - Indirect ownership verification (creator → story → gallery item)
  - Support for scenes, characters, lore, and extra content types
  - 5 production endpoints
- 🛡️ **Security**: JWT token authentication with CREATOR role enforcement, ownership verification, 401/403 error handling

#### Frontend - Admin UI (Phases 4-6)
- 🎛️ **Admin Layout Screen**: Navigation drawer with Stories Management and Gallery Items sections
  - Restricted to CREATOR role users only
  - Beautiful teal-themed design matching app aesthetics
  - Drawer with user email display
  - "Back to App" navigation option
- 📚 **Story Management UI**: Complete CRUD interface for stories
  - Stories list screen with empty/loading/error states
  - Create/edit story form (title, description, cover image URL)
  - Delete confirmation dialogs
  - Publish/unpublish toggle with status badges (green "Published" / amber "Draft")
  - Pull-to-refresh support
  - Character counters (title: 255, description: 2000)
  - Floating Action Button (+) for creating new stories
- 🖼️ **Gallery Management UI**: Complete CRUD interface for gallery items
  - Gallery items list with rarity badges and content type indicators
  - 10-field create/edit form:
    - **Story selector dropdown** - Populated with creator's stories
    - **Content type dropdown** - Scene/Character/Lore/Extra
    - **Title** - Required, max 255 characters
    - **Description** - Optional, max 2000 characters, multiline
    - **Unlock cost (gems)** - Required, integer validation
    - **Rarity dropdown** - Common/Rare/Epic/Legendary
    - **Content URL** - Optional, URL format validation
    - **Thumbnail URL** - Optional, URL format validation
    - **Display order** - Optional, integer for sorting
    - **Content category** - Optional, free text field
  - Delete confirmation dialogs
  - Real-time sync with Railway PostgreSQL
  - Floating Action Button (+) for creating new items
- 🎨 **Design System Integration**:
  - Rarity color badges using `DesignColors.rarityCommon/Rare/Epic/Legendary`
  - Blue badge for Rare items
  - Purple/gold badge for Epic items
  - Purple badge for Legendary items
  - Content type badges color-coded by type
- 🔓 **Logout Feature**: Red logout button on profile screen for role testing and security

#### Data Models
- `StoryDto` - Response model with 9 fields (id, storyId, title, description, coverImageUrl, createdByUserId, createdAt, updatedAt, published)
- `CreateStoryRequest` / `UpdateStoryRequest` - Request models with validation
- `GalleryItemDto` - Response model with 14 fields (contentId, storyId, contentType, contentCategory, title, description, unlockCost, rarity, unlockCondition, contentUrl, thumbnailUrl, displayOrder, createdByUserId, createdAt)
- `CreateGalleryItemRequest` / `UpdateGalleryItemRequest` - Request models with validation

#### Services
- `StoryAdminService` - HTTP service for Story Admin API with JWT auth
- `GalleryAdminService` - HTTP service for Gallery Admin API with JWT auth
- Both services use `http` package (not Dio) matching existing codebase patterns
- Manual JWT token injection from `FlutterSecureStorage`
- Custom exception hierarchy for each service

#### State Management
- `stories_provider.dart` - Riverpod providers for stories (FutureProvider + helper functions)
- `gallery_items_provider.dart` - Riverpod providers for gallery items
- Automatic list refresh after mutations (create/update/delete)
- Loading state providers for UI feedback

### Changed
- 🔐 **Authentication Flow**: Enhanced to support CREATOR role alongside existing USER role
- 🎨 **Profile Screen**: Added Creator Tools button (visible only to CREATOR role users)
- 🗂️ **Admin Navigation**: Updated admin layout to show real screens instead of placeholders for both Stories and Gallery sections
- 📱 **FAB Logic**: Context-aware floating action button shows "+" for Stories or Gallery sections based on selected admin section
- 🧹 **Code Cleanup**: Removed unused `_PlaceholderContent` class from admin layout (both sections now have real implementations)

### Fixed
- 🔧 **Railway Database Sequence**: Resolved duplicate key constraint issues with `story_content_content_id_seq` after seeded pirates data
- 🐛 **Token Refresh**: Fixed JWT token caching issue requiring logout/login after role changes in database
- 📋 **Form Validation**: Proper validation for required fields (story selector, content type, unlock cost must be integers >= 0)
- 🔐 **Role Verification**: Backend properly validates CREATOR role before allowing admin operations

### Security
- 🔒 **JWT Token Management**: Secure token storage using `FlutterSecureStorage` with automatic injection in API requests
- 🛡️ **Role-Based Access Control**: CREATOR role required for all admin endpoints, enforced both in UI and backend
- ✋ **Permission Checks**: 403 Forbidden responses handled gracefully with "Access denied" messages
- 🚪 **Session Management**: Auto-logout on 401 Unauthorized responses with navigation to login screen
- ⚠️ **Delete Protection**: Confirmation dialogs prevent accidental deletions of stories and gallery items
- 🔐 **Ownership Verification**: Backend verifies creator owns resources before allowing mutations
  - Direct ownership for stories (creator → story)
  - Indirect ownership for gallery items (creator → story → gallery item)
- 🔍 **Input Sanitization**: All user inputs validated before sending to API (title length, URL format, integer validation)

### Testing
- ✅ **Create/Edit/Delete Stories**: Verified on Railway production environment
- ✅ **Create/Edit/Delete Gallery Items**: Verified on Railway production environment with multiple items
- ✅ **Story Dropdown Population**: Confirmed creator's stories populate gallery item form selector
- ✅ **JWT Authentication**: Token-based auth working correctly with CREATOR role verification
- ✅ **Mobile Testing**: All features tested on physical Android device (Samsung/Xiaomi)
- ✅ **Network Error Handling**: Graceful error messages for connection failures
- ✅ **Permission Errors**: 403 responses properly handled with user-friendly messages
- ✅ **Pull-to-Refresh**: List refresh working correctly after mutations
- ✅ **Empty States**: Proper messaging when no stories or gallery items exist
- ✅ **Loading States**: Skeleton screens and progress indicators during async operations

### Documentation
- 📝 **SESSION_44 Checkpoints**: Complete documentation for all 6 phases in `/outputs` directory
  - `SESSION_44_CHECKPOINT_PHASE1.md` - Database migration details
  - `SESSION_44_CHECKPOINT_PHASE2.md` - Story API implementation
  - `SESSION_44_CHECKPOINT_PHASE3.md` - Gallery API implementation
  - `SESSION_44_CHECKPOINT_PHASE4.md` - Admin layout UI with navigation
  - `SESSION_44_CHECKPOINT_PHASE5.md` - Story CRUD UI with testing results
  - `SESSION_44_CHECKPOINT_PHASE6.md` - Gallery CRUD UI and session completion
- 📋 **API Documentation**: Endpoint specifications for Story and Gallery Admin APIs
- 🎨 **Design System**: Rarity colors and content type badges documented

### Technical Details
- **Backend**: Java Spring Boot 3.2.1, PostgreSQL, JWT authentication, Railway deployment
- **Frontend**: Flutter 3.x, Riverpod state management, `http` package (0.13.x) for API calls
- **Database**: PostgreSQL on Railway with proper indexes and foreign key constraints
- **Security**: JWT tokens, role-based authorization (USER/CREATOR), ownership verification
- **Architecture**: Clean Architecture with separation of concerns
  - Models: `/lib/models/admin/`
  - Services: `/lib/services/admin/`
  - Providers: `/lib/providers/admin/`
  - Screens: `/lib/screens/admin/`
- **Error Handling**:
  - Custom exception hierarchy per service
  - User-friendly error messages (no technical details exposed)
  - Network timeout handling (30 seconds)
  - Retry mechanisms with pull-to-refresh
- **Logging**:
  - debugPrint with prefixes (📤 request, 📥 response, ✅ success, ❌ error)
  - No sensitive data logged (tokens, passwords excluded)
  - API call metadata logged (endpoint, method, status code)

### Migration Notes
- **Database**: Run migrations in Phase 1 to add `created_by_user_id` columns to `stories` and `story_content` tables
- **User Roles**: Existing users have USER role by default. Change role to CREATOR in database for admin access:
  ```sql
  UPDATE users SET role = 'CREATOR' WHERE email = 'your-email@example.com';
  ```
- **JWT Tokens**: Users must logout and login again after role changes for new tokens to include updated role
- **Railway Sequence**: If encountering duplicate key errors on `story_content`, sequence may need reset:
  ```sql
  SELECT MAX(content_id) FROM story_content;
  ALTER SEQUENCE story_content_content_id_seq RESTART WITH <max_id + 1>;
  ```
- **API Base URL**: Admin endpoints use same base URL as existing APIs (`ApiConfig.authBaseUrl`)

### Performance
- **API Response Times**: Average 200-500ms for CRUD operations on Railway
- **UI Responsiveness**: All screens maintain 60fps with smooth scrolling
- **List Rendering**: Optimized with `ListView.builder` for efficient memory usage
- **Image Loading**: Graceful handling of network images with placeholders
- **State Management**: Efficient state updates with Riverpod (no unnecessary rebuilds)

### Contributors
- Laszlo (@hammerheart92) - Lead Developer, Backend & Frontend Implementation
- Partner - Project Financing, Prompt Engineering, Content Strategy
- Claude (Anthropic) - AI Development Assistant, Architecture Guidance
- Claude Code (Anthropic) - Implementation Assistant, Code Generation

### Notes
- 🎯 **Partner Enablement**: Non-technical partner can now create stories and populate them with gallery items entirely through the UI without any technical knowledge
- 🚀 **Production Ready**: All features tested and deployed on Railway with real PostgreSQL database
- 🔮 **Future Vision**: Foundation laid for VR integration and multi-device testing (10+ physical devices planned for quality assurance)
- 💪 **Development Environment**: Successfully migrated to new Acer Nitro V 15 AI laptop with complete development setup
- 📈 **Scalability**: Architecture supports hundreds of stories and thousands of gallery items per creator
- 🎨 **Design Quality**: Professional UI with consistent design system, proper spacing, and beautiful color schemes
- 🔒 **Security First**: All admin operations protected by JWT authentication, role verification, and ownership checks

---

## [0.12.0] - 2026-02-03

### Added
- **Theme System**: Complete Light/Dark/System mode support across entire app
- **Settings Screen**: Dedicated settings screen with 4 sections (Appearance, Preferences, Data & Privacy, About)
- Theme toggle dialog in Settings with Light/Dark/System options
- Theme persistence via SharedPreferences
- Theme provider (Riverpod) for runtime state management

### Changed
- **Profile Screen**: Refactored to show only user stats and achievements (removed settings)
- Settings moved to dedicated screen accessible via Settings button
- All 8 screens now theme-aware using design tokens (60+ color replacements)
- "Clear All Data" now shows confirmation dialog with warning styling

### Fixed
- DialogTheme type error (changed to DialogThemeData)
- Hardcoded dark colors across 8 screens and 4 widgets
- Theme-aware color selection now consistent throughout app

### Improved
- Visual hierarchy in Settings with section headers
- Dangerous actions styled with warning colors
- Consistent Material 3 design across both themes
- Professional UI with 100% design token compliance

## [0.11.1] - 2026-01-29

### Fixed
- **CI/CD Test Failures**: All 48 backend tests now pass in GitHub Actions
  - Implemented H2 in-memory database for automated testing with PostgreSQL compatibility mode
  - Added Spring DataSource injection to `DatabaseService` and `StorySaveService`
  - Replaced hardcoded PostgreSQL connections from `BaseService` with Spring-managed DataSource
  - Fixed PostgreSQL-specific SQL (`RETURNING` clause) to use standard JDBC `getGeneratedKeys()`
  - Added `spring-boot-starter-jdbc` dependency for proper DataSource auto-configuration
  - Tests now use H2 in test profile while production continues using PostgreSQL

### Technical
- **Database Service Architecture**: Refactored database services to use Spring Boot's DataSource injection
  - `DatabaseService`: Added DataSource constructor injection, replaced 11 hardcoded connection calls
  - `StorySaveService`: Added DataSource constructor injection, replaced all hardcoded connection calls
  - `AppConfig`: Updated bean definitions to inject DataSource
  - Enhanced error logging in `createTables()` for better CI/CD debugging
- **Test Configuration**: Updated `application-test.properties` with H2 PostgreSQL mode and auto-DDL
- **Test Classes**: Added `@SpringBootTest` and `@ActiveProfiles("test")` annotations where missing

### Performance
- **Test Execution**: CI/CD test suite completes in ~26 seconds (down from failing indefinitely)
- **Local Testing**: All tests pass with H2 in-memory database (2-3x faster than PostgreSQL)

### Development Workflow
- ✅ Green CI/CD pipeline enables confident merging and collaboration
- ✅ Automated testing catches bugs before production deployment
- ✅ Professional development workflow with passing status checks

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
- Railway app configured for production deployment
- `application.properties` configured with database URL, username, password

### Fixed
- JDBC URL format for Railway PostgreSQL connection
- Table creation queries for PostgreSQL syntax
- Session and message persistence across restarts
- Gallery content and user unlocks persistence

### Technical
- Environment: Production on Railway
- Database: PostgreSQL 13
- Connection pooling enabled
- Auto-reconnect configured

---

## [0.8.0] - 2026-01-17

### Added

#### Gem-Based Gallery Unlock System
- **Gem Economy**:
  - Starting balance: 350 gems
  - Story completion rewards: 15 gems per completion
  - Transaction history tracking in `gem_transactions` table
- **Unlock System**:
  - Gallery items with unlock costs (25-120 gems)
  - `user_unlocks` table for permanent unlock tracking
  - Real-time gem balance updates
- **Gallery UI**:
  - Locked content overlay with blur effect
  - Unlock button with gem cost display
  - Insufficient funds error handling
  - Success feedback after unlock

#### Refactored Gallery System
- **3-Tier Architecture**:
  1. `GalleryService` - HTTP API integration
  2. `GalleryProvider` - Riverpod state management
  3. `GalleryScreen` - Flutter UI with categories
- **RESTful Backend**:
  - `GET /api/gallery` - Fetch all content
  - `GET /api/gallery/{contentId}` - Fetch single item
  - `GET /api/gallery/unlocks` - User's unlocked items
  - `POST /api/gallery/unlock/{contentId}` - Unlock content
  - `POST /api/currency/reward` - Award gems
- **Category Filtering**:
  - Scenes, Characters, Lore, Extras tabs
  - "All" category for overview
  - Category-specific content counts

#### Design & UX Improvements
- **Gallery Cards**:
  - Rarity-colored borders (COMMON, RARE, EPIC, LEGENDARY)
  - Rarity badges in top-left corner
  - Lock icons for locked content
  - Unlock button prominently placed
- **Gallery Screen**:
  - Material 3 TabBar with category tabs
  - Gem balance indicator in app bar
  - Responsive grid layout (2 columns on mobile)
  - Pull-to-refresh support

---

## [0.7.0] - 2026-01-15

### Added

#### Story Gallery System
- **Database Schema**:
  - `story_content` table for gallery items
  - Fields: story_id, content_type, title, description, unlock_cost, rarity, content_url, thumbnail_url, display_order
  - Support for 4 content types: scene, character, lore, extra
  - Rarity tiers: COMMON, RARE, EPIC, LEGENDARY
- **Gallery Screen**:
  - Grid layout (2 columns) with content cards
  - Rarity-colored borders (gray, blue, purple, gold)
  - Lock icons for locked content
  - Unlock cost display (gems)
  - Tap to view full-screen content
- **Sample Content**:
  - 10 Pirates story gallery items
  - Mix of scenes, characters, and lore
  - Rarity distribution: 4 COMMON, 3 RARE, 2 EPIC, 1 LEGENDARY

#### Backend Gallery Endpoints
- `GET /api/story/{storyId}/gallery` - Fetch gallery items
- `POST /api/story/{storyId}/unlock/{contentId}` - Unlock content (placeholder)

---

## [0.6.0] - 2026-01-10

### Added

#### Achievements & Tasks System
- **7 Achievements**:
  - First Steps (1 message)
  - Conversationalist (10 messages)
  - Chatterbox (50 messages)
  - Story Explorer (1 story)
  - Completionist (3 stories)
  - Dedicated Reader (100 messages)
  - Master Storyteller (10 stories)
- **Task Tracking**:
  - Message count per user
  - Story completion count
  - Progress percentage calculation
  - Completion status tracking
- **Tasks Screen**:
  - Achievement cards with progress bars
  - Trophy icons for completed achievements
  - Real-time progress updates
  - Bottom navigation integration

#### Backend Tasks Endpoints
- `GET /api/tasks/user` - Fetch user tasks
- `POST /api/tasks/track` - Track task progress
- `GET /api/tasks/achievements` - List achievements

---

## [0.5.0] - 2026-01-08

### Added

#### Pirates Story (Third Interactive Story)
- **Captain Isla Hartwell**:
  - Legendary pirate captain
  - Personality: charismatic, daring, strategic, ruthless
  - Moods: confident, amused, serious, dangerous, calculating, defiant, reflective
- **Narrator (Pirates)**:
  - Adventurous, descriptive storytelling
  - Caribbean pirate atmosphere
- **Story Metadata**:
  - Title: "Tales of the Flying Dutchman"
  - Description: "A Caribbean pirate adventure"
  - Difficulty: MEDIUM
  - Estimated duration: 20-30 minutes

#### Flutter Story Selection Screen
- **Story Cards**:
  - Story title, description
  - Difficulty badge (EASY, MEDIUM, HARD)
  - Duration estimate
  - Play button navigation
- **3 Stories Available**:
  - Ilyra - The Observatory (EASY, 15-20 min)
  - Illidan Stormrage (HARD, 30-40 min)
  - Captain Isla - Pirates (MEDIUM, 20-30 min)

---

## [0.4.0] - 2026-01-05

### Added

#### Illidan Stormrage Story (Second Interactive Story)
- **Illidan Stormrage**:
  - The Betrayer, demon hunter
  - Personality: arrogant, tormented, determined, cynical
  - Moods: defiant, brooding, intense, sarcastic, menacing, contemplative, resigned
- **Narrator (Illidan)**:
  - Dark, ominous, epic tone
  - Warcraft universe lore integration
- **Story Saves System**:
  - Multi-slot save support (3 save slots per story)
  - Save metadata: story_id, save_slot, character, timestamp
  - Load/delete save functionality
- **Save UI**:
  - Save screen with slot selection
  - Load screen with save preview
  - Delete confirmation dialogs

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
- **Framework**: Java 17 + Spring Boot 3.2.1
- **Database**: PostgreSQL 13 (Railway production), H2 (testing)
- **AI Model**: Claude Sonnet 4 via Anthropic API
- **Build Tool**: Maven
- **Security**: JWT authentication with role-based authorization

### Frontend Stack
- **Framework**: Flutter 3.x / Dart
- **State Management**: Riverpod
- **Local Storage**: SharedPreferences, FlutterSecureStorage
- **HTTP Client**: Native Dart http package (0.13.x)
- **Design**: Material 3 with custom design tokens

### API Endpoints Summary

| Controller | Endpoints | Purpose |
|------------|-----------|---------|
| NarrativeController | 12 endpoints | Main storytelling API |
| ChatController | 6 endpoints | Legacy chat API |
| TasksController | 3 endpoints | Achievements system |
| GalleryController | 5 endpoints | Content unlock system |
| **StoryAdminController** | **6 endpoints** | **Story management (v1.0.0)** |
| **GalleryAdminController** | **5 endpoints** | **Gallery management (v1.0.0)** |

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
| **stories** | **Story metadata (v1.0.0)** |
| **users** | **User authentication with roles (v1.0.0)** |

---

## Development Statistics

- **Development Period**: December 19, 2025 - February 12, 2026 (55 days)
- **Development Sessions**: 44+ documented sessions
- **Total Commits**: 150+ commits
- **Test Coverage**: 48+ tests, 85%+ coverage
- **Frontend Screens**: 17 screens (11 original + 6 admin)
- **Frontend Widgets**: 25+ reusable components
- **Backend Services**: 8 services
- **API Endpoints**: 37+ endpoints (25 original + 11 admin + 1 auth)
- **Stories**: 3 (Observatory, Illidan, Pirates)
- **Characters**: 6 unique characters
- **Achievements**: 7 trackable achievements
- **Admin Features**: Complete CRUD for stories and gallery items

---

## Contributors

- **Laszlo** (@hammerheart92) - Lead Developer, Backend & Frontend Implementation
- **Partner** - Project Financing, Prompt Engineering, Content Strategy, VR Vision
- **Claude** (Anthropic) - AI Development Assistant, Architecture Guidance, Documentation
- **Claude Code** (Anthropic) - Implementation Assistant, Code Generation, Testing Support

---

## License

This project is proprietary software. All rights reserved.