// lib/screens/narrative_screen.dart
// Main screen for the interactive branching narrative experience

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/narrative_message.dart';
import '../providers/narrative_provider.dart';
import '../widgets/character_background.dart';
import '../widgets/character_message_card.dart';
import '../widgets/choices_section.dart';
import '../widgets/loading_overlay.dart';
import '../theme/storyforge_theme.dart';
import 'debug_screen.dart';

class NarrativeScreen extends ConsumerStatefulWidget {
  /// Optional restored messages for "Continue Story" functionality
  /// When provided, these messages are loaded instantly without animation
  final List<NarrativeMessage>? restoredMessages;
  final String? lastCharacter;

  /// Character ID to start the story with ('narrator' or 'ilyra')
  /// Only used for new stories, ignored when restoring
  final String? startingCharacter;

  /// Story ID for the current narrative ('observatory' or 'illidan')
  final String storyId;

  const NarrativeScreen({
    super.key,
    this.restoredMessages,
    this.lastCharacter,
    this.startingCharacter,
    required this.storyId,
  });

  @override
  ConsumerState<NarrativeScreen> createState() => _NarrativeScreenState();
}

class _NarrativeScreenState extends ConsumerState<NarrativeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasStarted = false;

  /// Track how many messages were restored (don't animate these)
  int _restoredCount = 0;

  @override
  void initState() {
    super.initState();

    // Start the narrative after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Check if we're restoring a saved story
      if (widget.restoredMessages != null && widget.restoredMessages!.isNotEmpty) {
        // Restore conversation history instantly
        _restoredCount = widget.restoredMessages!.length;
        ref.read(narrativeStateProvider.notifier).restoreFromMessages(
          widget.restoredMessages!,
          widget.lastCharacter ?? 'narrator',
        );
        print('✅ Restored $_restoredCount messages - ready to continue');
      } else {
        // New story - CRITICAL: Reset provider state before starting
        // This clears any old conversation data from previous sessions
        ref.read(narrativeStateProvider.notifier).reset();
        print('🔄 Reset provider state for fresh story');

        // Start with selected character (or default to Narrator)
        _startNarrative();
      }
    });
  }

  /// Start the narrative with an initial message
  void _startNarrative() {
    if (_hasStarted) return;

    _hasStarted = true;

    // Use the selected character, default to 'narrator' if not specified
    final character = widget.startingCharacter ?? 'narrator';

    print('🎭 Starting narrative with character: $character (story: ${widget.storyId})');

    // Send initial message to begin the story
    ref.read(narrativeStateProvider.notifier).sendMessage(
      'I approach the ancient observatory',
      character,
      widget.storyId,
    );
  }

  /// Scroll to bottom when new messages arrive
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(narrativeStateProvider);

    // Auto-scroll when new messages arrive
    ref.listen(narrativeStateProvider, (previous, next) {
      if (previous?.history.length != next.history.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('StoryForge'),
        backgroundColor: StoryForgeTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Debug menu button
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Debug Info',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DebugScreen()),
              );
            },
          ),
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Start Over',
            onPressed: state.isLoading ? null : () {
              ref.read(narrativeStateProvider.notifier).reset();
              _hasStarted = false;
              _startNarrative();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ============================================================
          // ADDED: Character portrait background (immersive UI)
          // ============================================================
          CharacterBackground(
            speaker: ref.watch(currentSpeakerProvider),
          ),
          // Main content
          Column(
            children: [
              // Conversation history (scrollable)
              Expanded(
                child: state.hasHistory
                    ? ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(top: 16, bottom: 16),
                  itemCount: state.history.length,
                  itemBuilder: (context, index) {
                    final message = state.history[index];
                    // Restored messages don't animate, only new messages do
                    final isNewMessage = index >= _restoredCount;
                    final isLastMessage = index == state.history.length - 1;
                    return CharacterMessageCard(
                      message: message,
                      shouldAnimate: isNewMessage && isLastMessage,
                    );
                  },
                )
                    : _EmptyState(),
              ),

              // Choices section (fixed at bottom)
              if (state.hasCurrentResponse && !state.isLoading)
                ChoicesSection(
                  choices: state.currentResponse!.choices,
                  storyId: widget.storyId,
                ),
            ],
          ),

          // Loading overlay
          // if (state.isLoading)
          //   const LoadingOverlay(),

          // Error banner
          if (state.hasError)
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

/// Empty state shown before first message loads
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_stories,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Starting your adventure...',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error banner shown at top when errors occur
class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.error,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: StoryForgeTheme.errorColor,
        elevation: 4,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    error,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onDismiss,
                  tooltip: 'Dismiss',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}