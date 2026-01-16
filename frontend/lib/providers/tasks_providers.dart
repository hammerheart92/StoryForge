// lib/providers/tasks_providers.dart
// State management for Tasks/Achievements system

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../models/achievement_progress.dart';
import '../models/check_in_data.dart';
import '../services/tasks_service.dart';
import '../services/achievement_service.dart';
import '../services/check_in_service.dart';

/// Immutable state for the Tasks screen
class TasksState {
  final CheckInData checkInData;
  final List<(Achievement, AchievementProgress)> achievements;
  final bool isLoading;
  final String? error;

  const TasksState({
    required this.checkInData,
    required this.achievements,
    required this.isLoading,
    this.error,
  });

  /// Initial state with loading flag
  factory TasksState.initial() {
    return TasksState(
      checkInData: CheckInData.initial(),
      achievements: const [],
      isLoading: true,
      error: null,
    );
  }

  /// Create copy with updated fields
  TasksState copyWith({
    CheckInData? checkInData,
    List<(Achievement, AchievementProgress)>? achievements,
    bool? isLoading,
    String? error,
  }) {
    return TasksState(
      checkInData: checkInData ?? this.checkInData,
      achievements: achievements ?? this.achievements,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Get count of claimable achievements
  int get unclaimedAchievementCount {
    return achievements
        .where((tuple) => tuple.$2.status == AchievementStatus.claimable)
        .length;
  }

  /// Check if daily check-in is available
  bool get canClaimCheckIn {
    return CheckInService.canClaimToday(checkInData);
  }

  /// Total badge count (unclaimed achievements + check-in if available)
  int get badgeCount {
    return unclaimedAchievementCount + (canClaimCheckIn ? 1 : 0);
  }

  @override
  String toString() {
    return 'TasksState(loading: $isLoading, achievements: ${achievements.length}, '
        'checkIn: Day ${checkInData.currentDay}, badge: $badgeCount)';
  }
}

/// StateNotifier for managing Tasks/Achievements state
class TasksNotifier extends StateNotifier<TasksState> {
  final TasksService _tasksService;

  TasksNotifier(this._tasksService) : super(TasksState.initial());

  /// Load all tasks data (check-in + achievements)
  Future<void> loadData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Load check-in data
      final checkInData = await CheckInService.loadCheckInData();

      // Load achievements with progress
      final achievements = await AchievementService.getAllWithProgress();

      state = state.copyWith(
        checkInData: checkInData,
        achievements: achievements,
        isLoading: false,
      );

      print('✅ TasksNotifier: Loaded ${achievements.length} achievements, '
          'Day ${checkInData.currentDay}, Streak ${checkInData.currentStreak}');
    } catch (e) {
      print('❌ TasksNotifier: Error loading data: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tasks data: $e',
      );
    }
  }

  /// Perform daily check-in
  ///
  /// Returns true if successful, false otherwise
  Future<bool> performCheckIn() async {
    try {
      // Check if can claim today
      if (!CheckInService.canClaimToday(state.checkInData)) {
        print('⚠️ TasksNotifier: Already claimed today');
        return false;
      }

      // Get reward for current day (before processing)
      final day = state.checkInData.lastCheckInDate == null
          ? 1
          : (state.checkInData.currentDay >= 7 ? 1 : state.checkInData.currentDay + 1);
      final gemAmount = CheckInData.getRewardForDay(day);

      // Process check-in locally
      await CheckInService.processCheckIn();

      // Call backend API to award gems
      final success = await _tasksService.performCheckIn(
        day: day,
        gemAmount: gemAmount,
      );

      if (success) {
        print('✅ TasksNotifier: Check-in successful! Day $day, +$gemAmount gems');
        // Reload to get fresh state
        await loadData();
        return true;
      } else {
        print('❌ TasksNotifier: Backend API failed for check-in');
        // Still reload to show updated local state
        await loadData();
        return false;
      }
    } catch (e) {
      print('❌ TasksNotifier: Error performing check-in: $e');
      state = state.copyWith(error: 'Check-in failed: $e');
      return false;
    }
  }

  /// Claim an achievement reward
  ///
  /// Returns true if successful, false otherwise
  Future<bool> claimAchievement(String achievementId) async {
    try {
      // Find the achievement
      final achievement = Achievement.getById(achievementId);
      if (achievement == null) {
        print('⚠️ TasksNotifier: Achievement not found: $achievementId');
        return false;
      }

      // Find progress for this achievement
      final tuple = state.achievements
          .where((t) => t.$1.id == achievementId)
          .firstOrNull;

      if (tuple == null) {
        print('⚠️ TasksNotifier: Progress not found for: $achievementId');
        return false;
      }

      // Check if claimable
      if (tuple.$2.status != AchievementStatus.claimable) {
        print('⚠️ TasksNotifier: Achievement not claimable: $achievementId');
        return false;
      }

      // Mark as claimed locally
      await AchievementService.markClaimed(achievementId);

      // Call backend API to award gems
      final success = await _tasksService.claimAchievement(
        achievementId: achievementId,
        gemAmount: achievement.gemReward,
      );

      if (success) {
        print('✅ TasksNotifier: Achievement claimed! $achievementId, +${achievement.gemReward} gems');
        // Reload to get fresh state
        await loadData();
        return true;
      } else {
        print('❌ TasksNotifier: Backend API failed for achievement claim');
        // Still reload to show updated local state
        await loadData();
        return false;
      }
    } catch (e) {
      print('❌ TasksNotifier: Error claiming achievement: $e');
      state = state.copyWith(error: 'Claim failed: $e');
      return false;
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for Tasks state with auto-loading
final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  final tasksService = TasksService();
  return TasksNotifier(tasksService)..loadData();
});

/// Provider for badge count (unclaimed achievements + check-in availability)
///
/// Use this for the TasksIconButton badge in Gallery AppBar
final tasksBadgeCountProvider = FutureProvider<int>((ref) async {
  // Get unclaimed achievement count
  final unclaimedCount = await AchievementService.getUnclaimedCount();

  // Check if check-in is available
  final checkInData = await CheckInService.loadCheckInData();
  final canCheckIn = CheckInService.canClaimToday(checkInData);

  final total = unclaimedCount + (canCheckIn ? 1 : 0);
  print('🔔 Badge count: $total (achievements: $unclaimedCount, checkIn: $canCheckIn)');

  return total;
});
