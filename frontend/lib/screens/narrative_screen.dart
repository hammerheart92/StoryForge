// lib/screens/narrative_screen.dart
// Main screen for the interactive branching narrative experience

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/narrative_provider.dart';
import '../widgets/character_message_card.dart';
import '../widgets/choices_section.dart';
import '../widgets/loading_overlay.dart';
import '../theme/storyforge_theme.dart';
import 'debug_screen.dart';

class NarrativeScreen extends ConsumerStatefulWidget {
  const NarrativeScreen({super.key});

  @override
  ConsumerState<NarrativeScreen> createState() => _NarrativeScreenState();
}

class _NarrativeScreenState extends ConsumerState<NarrativeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasStarted = false;

  @override
  void initState() {
    super.initState();

    // Start the narrative after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNarrative();
    });
  }

  /// Start the narrative with an initial message
  void _startNarrative() {
    if (_hasStarted) return;

    _hasStarted = true;

    // Send initial message to begin the story
    ref.read(narrativeStateProvider.notifier).sendMessage(
      'I approach the ancient observatory',
      'narrator',
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
                    return CharacterMessageCard(message: message);
                  },
                )
                    : _EmptyState(),
              ),

              // Choices section (fixed at bottom)
              if (state.hasCurrentResponse && !state.isLoading)
                ChoicesSection(
                  choices: state.currentResponse!.choices,
                ),
            ],
          ),

          // Loading overlay
          if (state.isLoading)
            const LoadingOverlay(),

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