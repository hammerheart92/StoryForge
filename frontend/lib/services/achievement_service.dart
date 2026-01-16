// lib/services/achievement_service.dart
// Service for local achievement progress tracking via SharedPreferences

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../models/achievement_progress.dart';

/// Service for managing achievement progress locally
class AchievementService {
  /// SharedPreferences key for achievement progress
  static const String _progressKey = 'achievement_progress';

  /// SharedPreferences key for unlock counters
  static const String _countersKey = 'unlock_counters';

  /// Load all achievement progress from SharedPreferences
  ///
  /// Returns a map of achievementId -> AchievementProgress
  /// Missing achievements are initialized with AchievementProgress.initial()
  static Future<Map<String, AchievementProgress>> loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_progressKey);

      if (jsonString == null || jsonString.isEmpty) {
        print('🎯 No achievement progress found, returning initial state');
        return _initializeProgress();
      }

      final progress = decodeProgressMap(jsonString);
      print('✅ Loaded achievement progress for ${progress.length} achievements');

      // Ensure all achievements have progress entries
      final complete = _ensureAllAchievements(progress);
      return complete;
    } catch (e) {
      print('❌ Error loading achievement progress: $e');
      return _initializeProgress();
    }
  }

  /// Save achievement progress to SharedPreferences
  static Future<void> saveProgress(Map<String, AchievementProgress> progress) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = encodeProgressMap(progress);
      await prefs.setString(_progressKey, jsonString);
      print('✅ Saved achievement progress');
    } catch (e) {
      print('❌ Error saving achievement progress: $e');
    }
  }

  /// Load unlock counters from SharedPreferences
  static Future<Map<String, int>> loadCounters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_countersKey);

      if (jsonString == null || jsonString.isEmpty) {
        print('🎯 No unlock counters found, returning initial state');
        return _initializeCounters();
      }

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final counters = json.map((key, value) => MapEntry(key, value as int));
      print('✅ Loaded unlock counters: $counters');
      return counters;
    } catch (e) {
      print('❌ Error loading unlock counters: $e');
      return _initializeCounters();
    }
  }

  /// Save unlock counters to SharedPreferences
  static Future<void> saveCounters(Map<String, int> counters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(counters);
      await prefs.setString(_countersKey, jsonString);
      print('✅ Saved unlock counters');
    } catch (e) {
      print('❌ Error saving unlock counters: $e');
    }
  }

  /// Increment a tracking counter and check for newly claimable achievements
  ///
  /// Returns list of achievement IDs that became claimable
  static Future<List<String>> incrementCounter(String trackingKey) async {
    try {
      // Load current counters and increment
      final counters = await loadCounters();
      counters[trackingKey] = (counters[trackingKey] ?? 0) + 1;
      await saveCounters(counters);
      print('🎯 Incremented $trackingKey to ${counters[trackingKey]}');

      // Load current progress
      final progress = await loadProgress();
      final newlyClaimable = <String>[];

      // Check all achievements with this tracking key
      final achievements = Achievement.getByTrackingKey(trackingKey);
      for (final achievement in achievements) {
        final currentProgress = progress[achievement.id]!;
        final newCount = counters[trackingKey]!;

        // If locked and target reached, mark as claimable
        if (currentProgress.status == AchievementStatus.locked &&
            newCount >= achievement.targetCount) {
          progress[achievement.id] = currentProgress.copyWith(
            currentCount: newCount,
            status: AchievementStatus.claimable,
          );
          newlyClaimable.add(achievement.id);
          print('🏆 Achievement unlocked: ${achievement.title}');
        } else if (currentProgress.status == AchievementStatus.locked) {
          // Just update the count
          progress[achievement.id] = currentProgress.copyWith(
            currentCount: newCount,
          );
        }
      }

      // Save updated progress
      await saveProgress(progress);

      return newlyClaimable;
    } catch (e) {
      print('❌ Error incrementing counter: $e');
      return [];
    }
  }

  /// Mark an achievement as claimed
  static Future<void> markClaimed(String achievementId) async {
    try {
      final progress = await loadProgress();

      if (!progress.containsKey(achievementId)) {
        print('⚠️ Achievement not found: $achievementId');
        return;
      }

      final currentProgress = progress[achievementId]!;
      if (currentProgress.status != AchievementStatus.claimable) {
        print('⚠️ Achievement $achievementId is not claimable');
        return;
      }

      progress[achievementId] = currentProgress.copyWith(
        status: AchievementStatus.claimed,
        claimedAt: DateTime.now(),
      );

      await saveProgress(progress);
      print('✅ Marked $achievementId as claimed');
    } catch (e) {
      print('❌ Error marking achievement claimed: $e');
    }
  }

  /// Get count of claimable (unclaimed) achievements
  static Future<int> getUnclaimedCount() async {
    try {
      final progress = await loadProgress();
      final count = progress.values
          .where((p) => p.status == AchievementStatus.claimable)
          .length;
      print('🎯 Unclaimed achievements: $count');
      return count;
    } catch (e) {
      print('❌ Error getting unclaimed count: $e');
      return 0;
    }
  }

  /// Get all achievements with their progress
  ///
  /// Returns list of tuples (Achievement, AchievementProgress)
  static Future<List<(Achievement, AchievementProgress)>> getAllWithProgress() async {
    try {
      final progress = await loadProgress();
      final counters = await loadCounters();
      final result = <(Achievement, AchievementProgress)>[];

      for (final achievement in Achievement.all) {
        var p = progress[achievement.id] ?? AchievementProgress.initial();

        // Update count from counters
        final currentCount = counters[achievement.trackingKey] ?? 0;
        if (p.currentCount != currentCount) {
          p = p.copyWith(currentCount: currentCount);
        }

        result.add((achievement, p));
      }

      return result;
    } catch (e) {
      print('❌ Error getting all achievements with progress: $e');
      return [];
    }
  }

  /// Initialize progress for all achievements
  static Map<String, AchievementProgress> _initializeProgress() {
    final progress = <String, AchievementProgress>{};
    for (final achievement in Achievement.all) {
      progress[achievement.id] = AchievementProgress.initial();
    }
    return progress;
  }

  /// Ensure all achievements have progress entries
  static Map<String, AchievementProgress> _ensureAllAchievements(
    Map<String, AchievementProgress> progress,
  ) {
    for (final achievement in Achievement.all) {
      if (!progress.containsKey(achievement.id)) {
        progress[achievement.id] = AchievementProgress.initial();
      }
    }
    return progress;
  }

  /// Initialize counters with default values
  static Map<String, int> _initializeCounters() {
    return {
      'total_unlocked': 0,
      'scenes_unlocked': 0,
      'characters_unlocked': 0,
      'lore_unlocked': 0,
      'legendary_unlocked': 0,
      'stories_started': 0,
    };
  }
}
