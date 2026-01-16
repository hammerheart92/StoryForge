// lib/services/check_in_service.dart
// Service for daily check-in streak logic via SharedPreferences

import 'package:shared_preferences/shared_preferences.dart';
import '../models/check_in_data.dart';

/// Service for managing daily check-in and streak tracking
class CheckInService {
  /// SharedPreferences key for check-in data
  static const String _checkInKey = 'check_in_data';

  /// Load check-in data from SharedPreferences
  static Future<CheckInData> loadCheckInData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_checkInKey);

      if (jsonString == null || jsonString.isEmpty) {
        print('📅 No check-in data found, returning initial state');
        return CheckInData.initial();
      }

      final data = decodeCheckInData(jsonString);
      print('✅ Loaded check-in data: Day ${data.currentDay}, Streak ${data.currentStreak}');
      return data;
    } catch (e) {
      print('❌ Error loading check-in data: $e');
      return CheckInData.initial();
    }
  }

  /// Save check-in data to SharedPreferences
  static Future<void> saveCheckInData(CheckInData data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = encodeCheckInData(data);
      await prefs.setString(_checkInKey, jsonString);
      print('✅ Saved check-in data: Day ${data.currentDay}, Streak ${data.currentStreak}');
    } catch (e) {
      print('❌ Error saving check-in data: $e');
    }
  }

  /// Process a check-in for today
  ///
  /// Returns the updated CheckInData after processing
  /// Returns current data unchanged if already claimed today
  static Future<CheckInData> processCheckIn() async {
    try {
      var data = await loadCheckInData();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      // Check if already claimed today
      if (!canClaimToday(data)) {
        print('⚠️ Already claimed today');
        return data;
      }

      // Check if streak should reset (missed a day)
      if (shouldResetStreak(data)) {
        print('🔄 Streak reset due to missed day(s)');
        data = CheckInData(
          currentStreak: 1,
          currentDay: 1,
          lastCheckInDate: today,
          claimedDaysInCycle: {1},
        );
        await saveCheckInData(data);
        return data;
      }

      // First ever check-in
      if (data.lastCheckInDate == null) {
        print('🎉 First check-in!');
        data = CheckInData(
          currentStreak: 1,
          currentDay: 1,
          lastCheckInDate: today,
          claimedDaysInCycle: {1},
        );
        await saveCheckInData(data);
        return data;
      }

      // Continue streak - next day
      final nextDay = data.currentDay >= 7 ? 1 : data.currentDay + 1;
      final newClaimedDays = nextDay == 1
          ? {1} // Start new cycle
          : {...data.claimedDaysInCycle, nextDay};

      data = CheckInData(
        currentStreak: data.currentStreak + 1,
        currentDay: nextDay,
        lastCheckInDate: today,
        claimedDaysInCycle: newClaimedDays,
      );

      print('✅ Check-in successful! Day $nextDay, Streak ${data.currentStreak}');
      await saveCheckInData(data);
      return data;
    } catch (e) {
      print('❌ Error processing check-in: $e');
      return CheckInData.initial();
    }
  }

  /// Check if user can claim today's reward
  ///
  /// Returns true if:
  /// - Never checked in before (lastCheckInDate is null)
  /// - Last check-in was on a previous day
  static bool canClaimToday(CheckInData data) {
    if (data.lastCheckInDate == null) {
      return true;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      data.lastCheckInDate!.year,
      data.lastCheckInDate!.month,
      data.lastCheckInDate!.day,
    );

    // Can claim if last check-in was before today
    return today.isAfter(lastDate);
  }

  /// Check if streak should be reset due to missed days
  ///
  /// Returns true if 2+ days have passed since last check-in
  static bool shouldResetStreak(CheckInData data) {
    if (data.lastCheckInDate == null) {
      return false; // First check-in, no reset needed
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      data.lastCheckInDate!.year,
      data.lastCheckInDate!.month,
      data.lastCheckInDate!.day,
    );

    final daysDiff = today.difference(lastDate).inDays;

    // Reset if more than 1 day has passed (missed a day)
    return daysDiff > 1;
  }

  /// Get the gem reward for the next claimable day
  ///
  /// Returns the reward amount for the current or next day
  static int getNextReward(CheckInData data) {
    if (data.lastCheckInDate == null) {
      // First check-in is always Day 1
      return CheckInData.getRewardForDay(1);
    }

    if (shouldResetStreak(data)) {
      // Reset to Day 1
      return CheckInData.getRewardForDay(1);
    }

    if (!canClaimToday(data)) {
      // Already claimed today, show next day's reward
      final nextDay = data.currentDay >= 7 ? 1 : data.currentDay + 1;
      return CheckInData.getRewardForDay(nextDay);
    }

    // Next day in streak
    final nextDay = data.currentDay >= 7 ? 1 : data.currentDay + 1;
    return CheckInData.getRewardForDay(nextDay);
  }
}
