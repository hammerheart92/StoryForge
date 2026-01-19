// lib/screens/narrative_screen.dart
// Main screen for the interactive branching narrative experience

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/narrative_message.dart';
import '../models/story_ending.dart';
import '../providers/narrative_provider.dart';
import '../services/story_completion_service.dart';
import '../services/unlock_tracker_service.dart';
import '../widgets/character_background.dart';
import '../widgets/character_message_card.dart';
import '../widgets/choices_section.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/story_completion_dialog.dart';
import '../theme/storyforge_theme.dart';
import '../theme/tokens/colors.dart';
import '../theme/tokens/spacing.dart';
import '../theme/tokens/typography.dart';
import 'debug_screen.dart';
import 'story_endings_screen.dart';
import 'story_library_screen.dart';

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

  /// Session 29: Save slot number (1-5) for multi-slot support
  final int saveSlot;

  const NarrativeScreen({
    super.key,
    this.restoredMessages,
    this.lastCharacter,
    this.startingCharacter,
    required this.storyId,
    this.saveSlot = 1,  // Default to slot 1 for backward compatibility
  });

  @override
  ConsumerState<NarrativeScreen> createState() => _NarrativeScreenState();
}

class _NarrativeScreenState extends ConsumerState<NarrativeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasStarted = false;

  /// Track how many messages were restored (don't animate these)
  int _restoredCount = 0;

  /// Character reveal animation state
  bool _isRevealActive = true;
  String? _lastSpeaker;
  Timer? _revealTimer;

  /// Session 34: Track if completion dialog was already shown
  bool _completionHandled = false;

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

        // Trigger reveal animation for restored story
        _triggerRevealAnimation();

        // FIX Issue 2: Scroll to bottom after restoration
        // Use SchedulerBinding to wait for ListView to be fully laid out
        SchedulerBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        // New story - Reset with initial speaker in one atomic operation
        // This prevents portrait flash from previous character
        final initialCharacter = widget.startingCharacter ?? 'narrator';
        ref.read(narrativeStateProvider.notifier).reset(initialSpeaker: initialCharacter);
        print('🔄 Reset provider state for fresh story with speaker: $initialCharacter');

        // Start with selected character (or default to Narrator)
        _startNarrative();

        // Trigger reveal animation for new story
        _triggerRevealAnimation();
      }
    });
  }

  /// Start the narrative with an initial message
  void _startNarrative() {
    if (_hasStarted) return;

    _hasStarted = true;

    // Use the selected character, default to 'narrator' if not specified
    final character = widget.startingCharacter ?? 'narrator';

    print('🎭 Starting narrative with character: $character (story: ${widget.storyId}, slot: ${widget.saveSlot})');

    // Send initial message to begin the story
    ref.read(narrativeStateProvider.notifier).sendMessage(
      'I approach the ancient observatory',
      character,
      widget.storyId,
      widget.saveSlot,  // Session 29: Multi-slot support
    );
  }

  /// Trigger the dramatic character reveal animation
  void _triggerRevealAnimation() {
    setState(() {
      _isRevealActive = true;
    });

    _revealTimer?.cancel();
    _revealTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isRevealActive = false;
        });
      }
    });
  }

  /// Scroll to bottom when new messages arrive
  /// FIX Issue 1: Scroll immediately to the bottom after content is rendered
  /// FIX Issue 2: Scroll continuously as typewriter animation expands content
  void _scrollToBottom() {
    if (!_scrollController.hasClients || !mounted) return;

    // Use SchedulerBinding to wait for the next frame after the ListView has updated
    // This ensures maxScrollExtent is accurate for the new content
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients && mounted) {
        // Jump immediately to bottom (no animation during typing looks smoother)
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  /// Scroll to bottom as typewriter animation expands content
  /// Called repeatedly during typewriter animation via onProgress callback
  void _scrollToBottomDuringAnimation() {
    if (!_scrollController.hasClients || !mounted) return;

    // Directly jump to max extent - called during animation so needs to be immediate
    if (_scrollController.hasClients && mounted) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(narrativeStateProvider);
    final currentSpeaker = ref.watch(currentSpeakerProvider);

    // Detect character switch and trigger reveal animation
    if (_lastSpeaker != null && _lastSpeaker != currentSpeaker && currentSpeaker.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _triggerRevealAnimation();
      });
    }
    _lastSpeaker = currentSpeaker;

    // Auto-scroll when new messages arrive AND detect story completion
    ref.listen(narrativeStateProvider, (previous, next) {
      if (previous?.history.length != next.history.length) {
        _scrollToBottom();
      }

      // Session 34: Detect story completion
// FIXED: Removed previous state check - _completionHandled flag is sufficient
      if (!_completionHandled && next.currentResponse?.isEnding == true) {
        _handleStoryCompletion(next.currentResponse!.endingId);
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
              final initialCharacter = widget.startingCharacter ?? 'narrator';
              ref.read(narrativeStateProvider.notifier).reset(initialSpeaker: initialCharacter);
              _hasStarted = false;
              _startNarrative();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ============================================================
          // Character portrait background (always visible, no animation)
          // ⭐ SESSION 24: Now includes mood for dynamic scene switching
          // ============================================================
          CharacterBackground(
            speaker: currentSpeaker,
            mood: state.currentResponse?.mood,  // ⭐ NEW: Pass mood from backend
          ),

          // ============================================================
          // Main content with slide-up animation
          // ============================================================
          Column(
            children: [
              // Conversation history (scrollable) with slide-up animation
              Expanded(
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  offset: _isRevealActive ? const Offset(0, 1) : Offset.zero,
                  child: state.hasHistory
                      ? ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(vertical: DesignSpacing.md),
                          itemCount: state.history.length,
                          itemBuilder: (context, index) {
                            final message = state.history[index];
                            // Restored messages don't animate, only new messages do
                            final isNewMessage = index >= _restoredCount;
                            final isLastMessage = index == state.history.length - 1;
                            return CharacterMessageCard(
                              message: message,
                              shouldAnimate: isNewMessage && isLastMessage,
                              // Only last message gets scroll callback during animation
                              onContentExpanding: (isNewMessage && isLastMessage)
                                  ? _scrollToBottomDuringAnimation
                                  : null,
                            );
                          },
                        )
                      : _EmptyState(),
                ),
              ),

              // Choices section (fixed at bottom) with slide-up animation
              if (state.hasCurrentResponse && !state.isLoading)
                AnimatedSlide(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  offset: _isRevealActive ? const Offset(0, 1) : Offset.zero,
                  child: ChoicesSection(
                    choices: state.currentResponse!.choices,
                    storyId: widget.storyId,
                    saveSlot: widget.saveSlot,  // Session 29: Multi-slot support
                  ),
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

  /// Session 34: Handle story completion - show dialog and track achievement
  Future<void> _handleStoryCompletion(String? endingId) async {
    if (_completionHandled) return;
    _completionHandled = true;

    print('🏆 Story completion detected! Ending: $endingId');

    // Fetch ending details
    final service = StoryCompletionService();
    final endings = await service.getStoryEndingsSafe(widget.storyId);

    // Find the specific ending, or use a fallback
    final ending = endings.isNotEmpty
        ? endings.firstWhere(
            (e) => e.id == endingId,
            orElse: () => StoryEnding(
              id: endingId ?? 'unknown',
              title: 'Story Complete',
              description: 'You have reached the end of this tale.',
              discovered: true,
            ),
          )
        : StoryEnding(
            id: endingId ?? 'unknown',
            title: 'Story Complete',
            description: 'You have reached the end of this tale.',
            discovered: true,
          );

    // Track completion for achievements
    final claimableAchievements = await UnlockTrackerService.trackStoryCompletion();
    final achievementUnlocked = claimableAchievements.isNotEmpty
        ? claimableAchievements.first
        : null;

    if (achievementUnlocked != null) {
      print('🎯 Achievement unlocked: $achievementUnlocked');
    }

    // Show completion dialog
    if (mounted) {
      final result = await StoryCompletionDialog.show(
        context: context,
        ending: ending,
        gemsAwarded: 100,
        achievementUnlocked: achievementUnlocked,
      );

      // Handle user choice
      if (mounted) {
        if (result == 'view_endings') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => StoryEndingsScreen(storyId: widget.storyId),
            ),
          );
        } else if (result == 'continue') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const StoryLibraryScreen(),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _revealTimer?.cancel();
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
            size: StoryForgeTheme.iconSizeXL,
            color: DesignColors.dSecondaryText,
          ),
          SizedBox(height: DesignSpacing.md),
          Text(
            'Starting your adventure...',
            style: TextStyle(
              fontSize: DesignTypography.bodyMedium.fontSize,
              color: DesignColors.dSecondaryText,
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
            padding: EdgeInsets.all(DesignSpacing.md),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: StoryForgeTheme.iconSizeMedium,
                ),
                SizedBox(width: DesignSpacing.sm + 4), // 12
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