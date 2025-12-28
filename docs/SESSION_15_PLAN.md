# Session 15 Plan: Flutter UI for Choice System 📱

**Date:** December 28, 2025  
**Branch:** `feature/choice-ui`  
**Prerequisites:** Sessions 13 & 14 complete (backend choice system working)  
**Goal:** Create a beautiful, intuitive Flutter UI for the branching narrative system with character switching and choice selection

---

## Context from Previous Sessions

### Session 13: Multi-Character Narrative Engine ✅
- Character database (Narrator, Ilyra)
- Layered prompts for distinct voices
- NarrativeEngine service
- API endpoints for character interaction

### Session 14: Choice System ✅
- Choice generation (2-3 per response)
- POST `/choose` endpoint
- Character switching based on choices
- Database tracking of decisions
- NarrativeResponse model with choices

### What Works (Backend)
```bash
POST /api/narrative/speak
Response:
{
  "dialogue": "The wind howls...",
  "speaker": "narrator",
  "speakerName": "Narrator",
  "mood": "observant",
  "choices": [
    {"id": "choice_1", "label": "Enter", "nextSpeaker": "narrator"},
    {"id": "choice_2", "label": "Call out", "nextSpeaker": "ilyra"}
  ]
}
```

---

## Session 15 Objectives

### Primary Goal
Create an immersive Flutter UI that makes the branching narrative feel magical and interactive.

### Success Criteria
- ✅ Display character dialogue with proper styling
- ✅ Show 2-3 choice buttons per response
- ✅ Handle choice selection smoothly
- ✅ Visual indication of character switching
- ✅ Loading states during API calls
- ✅ Error handling with user-friendly messages
- ✅ Character avatars (placeholders initially)
- ✅ Smooth animations and transitions
- ✅ Conversation history display

---

## The Vision

### UI Mockup

```
┌─────────────────────────────────────┐
│  ← Back              StoryForge     │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────────────────────┐   │
│  │ 👤 Narrator                 │   │
│  │ Mood: Observant             │   │
│  ├─────────────────────────────┤   │
│  │                             │   │
│  │ "The wind howls across the  │   │
│  │ clifftop as you make your   │   │
│  │ way up the weathered stone  │   │
│  │ path..."                    │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  💭 What do you do?                 │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  🚪 Enter the observatory   │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  👋 Call out to Ilyra       │   │
│  └─────────────────────────────┘   │
│                                     │
│  ┌─────────────────────────────┐   │
│  │  🔍 Examine the door        │   │
│  └─────────────────────────────┘   │
│                                     │
└─────────────────────────────────────┘
```

### Character Switch Animation

```
Narrator card fades out ↓
Character indicator changes color
Ilyra card fades in ↑
New choices appear
```

---

## Architecture Design

### Widget Structure

```
NarrativeScreen (StatefulWidget)
├── AppBar (StoryForge title)
├── Body
│   ├── ConversationHistory (ListView)
│   │   ├── CharacterMessageCard (Narrator)
│   │   ├── CharacterMessageCard (Ilyra)
│   │   └── CharacterMessageCard (Narrator)
│   │
│   ├── CurrentResponseCard
│   │   ├── CharacterHeader (avatar, name, mood)
│   │   ├── DialogueText (formatted text)
│   │   └── CharacterIndicator (visual separator)
│   │
│   └── ChoicesSection
│       ├── ChoicePrompt ("What do you do?")
│       └── ChoiceButtons (2-3 buttons)
│           ├── ChoiceButton (choice_1)
│           ├── ChoiceButton (choice_2)
│           └── ChoiceButton (choice_3)
│
└── LoadingOverlay (when making API calls)
```

### State Management (Riverpod)

```dart
// Providers
final narrativeServiceProvider = Provider<NarrativeService>((ref) => NarrativeService());

final narrativeStateProvider = StateNotifierProvider<NarrativeNotifier, NarrativeState>(
  (ref) => NarrativeNotifier(ref.read(narrativeServiceProvider))
);

// State
class NarrativeState {
  final List<NarrativeMessage> history;
  final NarrativeResponse? currentResponse;
  final bool isLoading;
  final String? error;
  final String currentSpeaker;
}

// Notifier
class NarrativeNotifier extends StateNotifier<NarrativeState> {
  Future<void> sendMessage(String message, String speaker);
  Future<void> selectChoice(Choice choice);
  void clearError();
}
```

---

## Data Models (Flutter)

### 1. NarrativeResponse (mirrors backend)

```dart
class NarrativeResponse {
  final String dialogue;
  final String speaker;
  final String speakerName;
  final String mood;
  final String? avatarUrl;
  final List<Choice> choices;

  NarrativeResponse({
    required this.dialogue,
    required this.speaker,
    required this.speakerName,
    required this.mood,
    this.avatarUrl,
    required this.choices,
  });

  factory NarrativeResponse.fromJson(Map<String, dynamic> json) {
    return NarrativeResponse(
      dialogue: json['dialogue'] as String,
      speaker: json['speaker'] as String,
      speakerName: json['speakerName'] as String,
      mood: json['mood'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      choices: (json['choices'] as List)
          .map((c) => Choice.fromJson(c))
          .toList(),
    );
  }
}
```

### 2. Choice

```dart
class Choice {
  final String id;
  final String label;
  final String nextSpeaker;
  final String? description;

  Choice({
    required this.id,
    required this.label,
    required this.nextSpeaker,
    this.description,
  });

  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: json['id'] as String,
      label: json['label'] as String,
      nextSpeaker: json['nextSpeaker'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'choiceId': id,
      'label': label,
      'nextSpeaker': nextSpeaker,
    };
  }
}
```

### 3. NarrativeMessage (for history)

```dart
class NarrativeMessage {
  final String speakerName;
  final String speaker;
  final String dialogue;
  final String mood;
  final DateTime timestamp;

  NarrativeMessage({
    required this.speakerName,
    required this.speaker,
    required this.dialogue,
    required this.mood,
    required this.timestamp,
  });
}
```

---

## API Service Layer

### NarrativeService

```dart
class NarrativeService {
  final String baseUrl = 'http://localhost:8080/api/narrative';
  final http.Client client;

  NarrativeService({http.Client? client}) 
    : client = client ?? http.Client();

  // Send message and get response with choices
  Future<NarrativeResponse> speak(String message, String speaker) async {
    final response = await client.post(
      Uri.parse('$baseUrl/speak'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'message': message,
        'speaker': speaker,
      }),
    );

    if (response.statusCode == 200) {
      return NarrativeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get response: ${response.statusCode}');
    }
  }

  // Select a choice and get next response
  Future<NarrativeResponse> choose(Choice choice) async {
    final response = await client.post(
      Uri.parse('$baseUrl/choose'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(choice.toJson()),
    );

    if (response.statusCode == 200) {
      return NarrativeResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to process choice: ${response.statusCode}');
    }
  }

  // Get available characters
  Future<List<Character>> getCharacters() async {
    final response = await client.get(
      Uri.parse('$baseUrl/characters'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((c) => Character.fromJson(c)).toList();
    } else {
      throw Exception('Failed to get characters');
    }
  }
}
```

---

## Implementation Plan

### Phase 1: Data Models & Service (30 min)

**Files to create:**
1. `lib/models/narrative_response.dart`
2. `lib/models/choice.dart`
3. `lib/models/narrative_message.dart`
4. `lib/services/narrative_service.dart`

**Dependencies to add:**
```yaml
dependencies:
  http: ^1.1.0
  flutter_riverpod: ^2.4.0  # (already have)
```

**Tasks:**
- Create all model classes with fromJson/toJson
- Implement NarrativeService with all methods
- Add error handling
- Test API calls manually

---

### Phase 2: State Management (30 min)

**Files to create:**
1. `lib/providers/narrative_provider.dart`
2. `lib/providers/narrative_state.dart`
3. `lib/providers/narrative_notifier.dart`

**State Structure:**
```dart
@freezed
class NarrativeState with _$NarrativeState {
  const factory NarrativeState({
    @Default([]) List<NarrativeMessage> history,
    NarrativeResponse? currentResponse,
    @Default(false) bool isLoading,
    String? error,
    @Default('narrator') String currentSpeaker,
  }) = _NarrativeState;
}
```

**Notifier Methods:**
```dart
class NarrativeNotifier extends StateNotifier<NarrativeState> {
  final NarrativeService _service;

  Future<void> sendMessage(String message, String speaker) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.speak(message, speaker);
      
      // Add to history
      final historyMessage = NarrativeMessage(
        speakerName: response.speakerName,
        speaker: response.speaker,
        dialogue: response.dialogue,
        mood: response.mood,
        timestamp: DateTime.now(),
      );
      
      state = state.copyWith(
        currentResponse: response,
        history: [...state.history, historyMessage],
        currentSpeaker: response.speaker,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  Future<void> selectChoice(Choice choice) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _service.choose(choice);
      
      // Add choice to history as user message
      final choiceMessage = NarrativeMessage(
        speakerName: 'You',
        speaker: 'user',
        dialogue: 'You chose: ${choice.label}',
        mood: 'neutral',
        timestamp: DateTime.now(),
      );
      
      // Add response to history
      final responseMessage = NarrativeMessage(
        speakerName: response.speakerName,
        speaker: response.speaker,
        dialogue: response.dialogue,
        mood: response.mood,
        timestamp: DateTime.now(),
      );
      
      state = state.copyWith(
        currentResponse: response,
        history: [...state.history, choiceMessage, responseMessage],
        currentSpeaker: response.speaker,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
```

---

### Phase 3: UI Widgets (45 min)

**Files to create:**
1. `lib/widgets/character_message_card.dart`
2. `lib/widgets/choice_button.dart`
3. `lib/widgets/choices_section.dart`
4. `lib/widgets/character_header.dart`
5. `lib/widgets/loading_overlay.dart`

#### CharacterMessageCard

```dart
class CharacterMessageCard extends StatelessWidget {
  final NarrativeMessage message;

  const CharacterMessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final isNarrator = message.speaker == 'narrator';
    final isUser = message.speaker == 'user';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Character header
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _getColorForSpeaker(message.speaker),
                child: Text(
                  message.speakerName[0],
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(width: 8),
              Text(
                message.speakerName,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Spacer(),
              _MoodIndicator(mood: message.mood),
            ],
          ),
          SizedBox(height: 8),
          // Dialogue
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser 
                ? Colors.blue.shade50 
                : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              message.dialogue,
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForSpeaker(String speaker) {
    switch (speaker) {
      case 'narrator':
        return Colors.grey.shade700;
      case 'ilyra':
        return Colors.purple.shade400;
      case 'user':
        return Colors.blue.shade400;
      default:
        return Colors.teal.shade400;
    }
  }
}
```

#### ChoiceButton

```dart
class ChoiceButton extends StatelessWidget {
  final Choice choice;
  final VoidCallback onPressed;
  final bool isLoading;

  const ChoiceButton({
    required this.choice,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          backgroundColor: _getColorForSpeaker(choice.nextSpeaker),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: Row(
          children: [
            _getIconForSpeaker(choice.nextSpeaker),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                choice.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }

  Color _getColorForSpeaker(String speaker) {
    switch (speaker) {
      case 'narrator':
        return Colors.grey.shade600;
      case 'ilyra':
        return Colors.purple.shade400;
      default:
        return Colors.teal.shade400;
    }
  }

  Icon _getIconForSpeaker(String speaker) {
    switch (speaker) {
      case 'narrator':
        return Icon(Icons.auto_stories, size: 20);
      case 'ilyra':
        return Icon(Icons.stars, size: 20);
      default:
        return Icon(Icons.chat, size: 20);
    }
  }
}
```

#### ChoicesSection

```dart
class ChoicesSection extends ConsumerWidget {
  final List<Choice> choices;

  const ChoicesSection({required this.choices});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(
      narrativeStateProvider.select((s) => s.isLoading)
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Text(
            '💭 What do you do?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        ...choices.map((choice) => ChoiceButton(
          choice: choice,
          isLoading: isLoading,
          onPressed: () {
            ref.read(narrativeStateProvider.notifier).selectChoice(choice);
          },
        )),
        SizedBox(height: 16),
      ],
    );
  }
}
```

---

### Phase 4: Main Screen (30 min)

**File:** `lib/screens/narrative_screen.dart`

```dart
class NarrativeScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<NarrativeScreen> createState() => _NarrativeScreenState();
}

class _NarrativeScreenState extends ConsumerState<NarrativeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start the narrative
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(narrativeStateProvider.notifier).sendMessage(
        'I approach the ancient observatory',
        'narrator',
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(narrativeStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('StoryForge'),
        backgroundColor: Colors.teal.shade700,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Conversation history
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: state.history.length,
                  itemBuilder: (context, index) {
                    return CharacterMessageCard(
                      message: state.history[index],
                    );
                  },
                ),
              ),
              
              // Current response with choices
              if (state.currentResponse != null) ...[
                Divider(height: 1),
                ChoicesSection(
                  choices: state.currentResponse!.choices,
                ),
              ],
            ],
          ),
          
          // Loading overlay
          if (state.isLoading)
            LoadingOverlay(),
          
          // Error snackbar
          if (state.error != null)
            _ErrorBanner(
              error: state.error!,
              onDismiss: () {
                ref.read(narrativeStateProvider.notifier).clearError();
              },
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
```

---

### Phase 5: Animations & Polish (25 min)

#### Character Switch Animation

```dart
class CharacterMessageCard extends StatefulWidget {
  // ... (convert to StatefulWidget)
  
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
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: CharacterMessageCard(...),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

#### Loading Overlay

```dart
class LoadingOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  'Weaving the narrative...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Color Scheme

### Character Colors
- **Narrator:** Grey (#616161) - Neutral, observant
- **Ilyra:** Purple (#AB47BC) - Mystical, celestial
- **User:** Blue (#42A5F5) - Interactive, engaging

### UI Colors
- **Primary:** Teal (#00897B) - StoryForge brand
- **Background:** White (#FFFFFF)
- **Cards:** Light Grey (#F5F5F5)
- **Text:** Dark Grey (#212121)
- **Accent:** Amber (#FFA726) - Mood indicators

---

## Error Handling

### Connection Errors
```dart
try {
  final response = await _service.speak(message, speaker);
  // ...
} catch (e) {
  if (e is SocketException) {
    state = state.copyWith(
      error: 'Cannot connect to server. Is the backend running?',
      isLoading: false,
    );
  } else if (e is TimeoutException) {
    state = state.copyWith(
      error: 'Request timed out. Please try again.',
      isLoading: false,
    );
  } else {
    state = state.copyWith(
      error: 'An error occurred: $e',
      isLoading: false,
    );
  }
}
```

### Error Banner
```dart
class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.red.shade400,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  error,
                  style: TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: onDismiss,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## Testing Strategy

### Manual Testing Checklist

**Scenario 1: Initial Load**
- [ ] App starts
- [ ] Loading overlay appears
- [ ] First narrative message loads from Narrator
- [ ] 2-3 choices appear
- [ ] No errors

**Scenario 2: Select Choice (Same Speaker)**
- [ ] Tap choice that stays with Narrator
- [ ] Loading overlay appears
- [ ] Choice added to history ("You chose: ...")
- [ ] New response appears
- [ ] New choices appear
- [ ] Scroll position updates

**Scenario 3: Select Choice (Character Switch)**
- [ ] Tap choice that switches to Ilyra
- [ ] Loading overlay appears
- [ ] Character switches visually
- [ ] Ilyra's response appears
- [ ] Color scheme changes to purple
- [ ] New choices appear

**Scenario 4: Error Handling**
- [ ] Stop backend
- [ ] Tap a choice
- [ ] Error banner appears
- [ ] Error message is clear
- [ ] Can dismiss error
- [ ] Can retry after backend restarts

**Scenario 5: Multiple Choices**
- [ ] Make 5+ choices in sequence
- [ ] History scrolls correctly
- [ ] All messages appear in order
- [ ] No performance issues
- [ ] Memory usage stable

---

## File Structure

```
lib/
├── models/
│   ├── narrative_response.dart
│   ├── choice.dart
│   ├── narrative_message.dart
│   └── character.dart (optional)
│
├── services/
│   └── narrative_service.dart
│
├── providers/
│   ├── narrative_state.dart
│   ├── narrative_notifier.dart
│   └── narrative_provider.dart
│
├── screens/
│   └── narrative_screen.dart
│
├── widgets/
│   ├── character_message_card.dart
│   ├── choice_button.dart
│   ├── choices_section.dart
│   ├── character_header.dart
│   └── loading_overlay.dart
│
└── main.dart (updated to include NarrativeScreen)
```

---

## Dependencies to Add

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.0  # Already have
  http: ^1.1.0  # NEW - for API calls
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0  # If using freezed
  freezed: ^2.4.0  # If using freezed
```

---

## Optional Enhancements

### If Time Permits

**Enhancement 1: Character Avatars**
```dart
// Use cached_network_image for avatars
CachedNetworkImage(
  imageUrl: character.avatarUrl ?? '',
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.person),
)
```

**Enhancement 2: Mood Animations**
```dart
// Animate mood indicator color
AnimatedContainer(
  duration: Duration(milliseconds: 300),
  color: _getMoodColor(mood),
)
```

**Enhancement 3: Sound Effects**
```dart
// Add subtle sound when making choices
AudioPlayer().play('assets/sounds/choice_select.mp3');
```

**Enhancement 4: Typing Animation**
```dart
// Simulate character typing
AnimatedTextKit(
  animatedTexts: [
    TypewriterAnimatedText(
      dialogue,
      speed: Duration(milliseconds: 50),
    ),
  ],
)
```

---

## Time Estimates

- **Phase 1:** Data Models & Service - 30 minutes
- **Phase 2:** State Management - 30 minutes
- **Phase 3:** UI Widgets - 45 minutes
- **Phase 4:** Main Screen - 30 minutes
- **Phase 5:** Animations & Polish - 25 minutes
- **Testing:** 20 minutes
- **Debugging:** 20 minutes

**Total:** ~3 hours

---

## Success Metrics

### Functional
- ✅ Display narrative responses
- ✅ Show choice buttons
- ✅ Handle choice selection
- ✅ Character switching works
- ✅ History displays correctly
- ✅ Loading states work
- ✅ Errors handled gracefully

### Quality
- ✅ Smooth animations
- ✅ Responsive UI
- ✅ Clear visual hierarchy
- ✅ Intuitive interaction
- ✅ Professional appearance
- ✅ No performance issues

---

## What Comes After Session 15

**Session 16:** Polish & Advanced Features
- Character-specific themes
- Advanced animations
- Sound effects
- Persistence (save/load stories)
- Settings screen
- The complete "illusion"

---

## Important Notes

1. **Backend must be running** - Test connection first
2. **Start simple** - Basic UI first, polish later
3. **Test frequently** - After each widget
4. **Use hot reload** - Flutter's superpower
5. **Commit often** - Small, working increments

---

## Quick Start Commands

```bash
# Create feature branch
git checkout -b feature/choice-ui

# Add dependencies
flutter pub add http

# Run app
flutter run

# Hot reload (while running)
# Press 'r' in terminal

# Commit
git add .
git commit -m "feat: Add Flutter UI for choice system"
git push origin feature/choice-ui
```

---

## Backend Checklist

Before starting Flutter work:

- [ ] Backend is running (Application.java)
- [ ] Test endpoint: `curl http://localhost:8080/api/narrative/status`
- [ ] Response includes `choiceCount`
- [ ] Session 14 code is working

---

## Tips for Success

### Development Flow
1. **Build one widget at a time**
2. **Test in isolation** (create test screens)
3. **Add to main screen** when working
4. **Iterate on styling** after functionality works

### Debugging
- Use Flutter DevTools
- Check network tab for API calls
- Add print statements liberally
- Test on both Android and iOS if possible

### Performance
- Use `const` constructors where possible
- Avoid rebuilding entire tree
- Profile with Flutter Performance overlay
- Keep widget tree shallow

---

**Ready to make the narrative come alive!** 📱✨

This plan builds on Sessions 13 & 14 to create the complete user experience. The choice system will feel magical when users see it working in the app!

---

*Let me know when you're ready to start implementing!* 🚀