// lib/services/stats_service.dart
// Service for calculating user statistics from saved story data

import '../models/narrative_message.dart';
import 'story_state_service.dart';

/// User statistics calculated from story history
class UserStats {
  final int totalMessages;
  final int choicesMade;
  final int timeSpentMinutes;
  final int narratorMessages;
  final int ilyraMessages;
  final int totalStories;

  const UserStats({
    required this.totalMessages,
    required this.choicesMade,
    required this.timeSpentMinutes,
    required this.narratorMessages,
    required this.ilyraMessages,
    required this.totalStories,
  });

  /// Empty stats for new users
  factory UserStats.empty() {
    return const UserStats(
      totalMessages: 0,
      choicesMade: 0,
      timeSpentMinutes: 0,
      narratorMessages: 0,
      ilyraMessages: 0,
      totalStories: 0,
    );
  }

  @override
  String toString() {
    return 'UserStats(messages: $totalMessages, choices: $choicesMade, '
        'minutes: $timeSpentMinutes, narrator: $narratorMessages, '
        'ilyra: $ilyraMessages, stories: $totalStories)';
  }
}

/// Service for calculating user statistics
class StatsService {
  /// Calculate all user statistics from saved story data
  static Future<UserStats> calculateStats() async {
    final savedState = await StoryStateService.loadState();

    // No saved state - return empty stats
    if (savedState == null) {
      return UserStats.empty();
    }

    final messages = savedState['messages'] as List<NarrativeMessage>;

    // No messages - return empty stats
    if (messages.isEmpty) {
      return UserStats.empty();
    }

    // Count messages by type
    final totalMessages = messages.length;
    final choicesMade = messages.where((m) => m.isUser).length;
    final narratorMessages = messages.where((m) => m.speaker == 'narrator').length;
    final ilyraMessages = messages.where((m) => m.speaker == 'ilyra').length;

    // Estimate reading time based on word count
    final timeSpentMinutes = _estimateReadingTime(messages);

    // For MVP: 1 story if there are messages, 0 otherwise
    final totalStories = messages.isNotEmpty ? 1 : 0;

    return UserStats(
      totalMessages: totalMessages,
      choicesMade: choicesMade,
      timeSpentMinutes: timeSpentMinutes,
      narratorMessages: narratorMessages,
      ilyraMessages: ilyraMessages,
      totalStories: totalStories,
    );
  }

  /// Estimate reading time based on word count
  /// Assumes average reading speed of 200 words per minute
  static int _estimateReadingTime(List<NarrativeMessage> messages) {
    int totalWords = 0;

    for (final msg in messages) {
      // Count words in main dialogue
      totalWords += _countWords(msg.dialogue);

      // Count words in action text if present
      if (msg.actionText != null && msg.actionText!.isNotEmpty) {
        totalWords += _countWords(msg.actionText!);
      }
    }

    // Calculate minutes at 200 words per minute
    // Minimum 1 minute if there's any content
    if (totalWords == 0) return 0;
    return (totalWords / 200).ceil();
  }

  /// Count words in a string
  static int _countWords(String text) {
    if (text.isEmpty) return 0;
    return text.trim().split(RegExp(r'\s+')).length;
  }
}
