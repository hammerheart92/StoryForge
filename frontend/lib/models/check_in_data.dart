import 'dart:convert';

/// Tracks daily check-in streak and rewards
///
/// Manages 7-day cycle with streak tracking and claimed days
class CheckInData {
  final int currentStreak;
  final int currentDay; // 1-7
  final DateTime? lastCheckInDate;
  final Set<int> claimedDaysInCycle; // Days claimed in current 7-day cycle

  /// Daily rewards array for 7-day cycle
  /// Day 1: 20 gems, Day 2: 10 gems, Day 3: 40 gems, Day 4: 20 gems,
  /// Day 5: 30 gems, Day 6: 50 gems, Day 7: 100 gems
  static const List<int> dailyRewards = [20, 10, 40, 20, 30, 50, 100];

  const CheckInData({
    required this.currentStreak,
    required this.currentDay,
    this.lastCheckInDate,
    required this.claimedDaysInCycle,
  });

  /// Create initial check-in data (no streak, ready for Day 1)
  factory CheckInData.initial() {
    return const CheckInData(
      currentStreak: 0,
      currentDay: 1,
      lastCheckInDate: null,
      claimedDaysInCycle: {},
    );
  }

  /// Create from JSON map
  factory CheckInData.fromJson(Map<String, dynamic> json) {
    return CheckInData(
      currentStreak: json['currentStreak'] as int,
      currentDay: json['currentDay'] as int,
      lastCheckInDate: json['lastCheckInDate'] != null
          ? DateTime.parse(json['lastCheckInDate'] as String)
          : null,
      claimedDaysInCycle: (json['claimedDaysInCycle'] as List<dynamic>)
          .map((e) => e as int)
          .toSet(),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'currentDay': currentDay,
      'lastCheckInDate': lastCheckInDate?.toIso8601String(),
      'claimedDaysInCycle': claimedDaysInCycle.toList(),
    };
  }

  /// Create copy with updated fields
  CheckInData copyWith({
    int? currentStreak,
    int? currentDay,
    DateTime? lastCheckInDate,
    Set<int>? claimedDaysInCycle,
  }) {
    return CheckInData(
      currentStreak: currentStreak ?? this.currentStreak,
      currentDay: currentDay ?? this.currentDay,
      lastCheckInDate: lastCheckInDate ?? this.lastCheckInDate,
      claimedDaysInCycle: claimedDaysInCycle ?? this.claimedDaysInCycle,
    );
  }

  /// Get reward for current day (1-indexed)
  int getCurrentDayReward() {
    if (currentDay < 1 || currentDay > dailyRewards.length) {
      return dailyRewards[0]; // Default to Day 1 reward
    }
    return dailyRewards[currentDay - 1]; // Convert to 0-indexed
  }

  /// Get reward for specific day (1-indexed)
  static int getRewardForDay(int day) {
    if (day < 1 || day > dailyRewards.length) {
      return dailyRewards[0]; // Default to Day 1 reward
    }
    return dailyRewards[day - 1]; // Convert to 0-indexed
  }

  /// Check if current day is already claimed in this cycle
  bool isCurrentDayClaimed() {
    return claimedDaysInCycle.contains(currentDay);
  }

  /// Check if specific day is claimed in this cycle
  bool isDayClaimed(int day) {
    return claimedDaysInCycle.contains(day);
  }

  /// Check if all 7 days are claimed (cycle complete)
  bool isCycleComplete() {
    return claimedDaysInCycle.length >= 7;
  }

  /// Get number of unclaimed days in current cycle
  int getUnclaimedDaysCount() {
    return 7 - claimedDaysInCycle.length;
  }

  @override
  String toString() {
    return 'CheckInData(streak: $currentStreak, day: $currentDay, claimed: ${claimedDaysInCycle.length}/7)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckInData &&
        other.currentStreak == currentStreak &&
        other.currentDay == currentDay &&
        other.lastCheckInDate == lastCheckInDate &&
        other.claimedDaysInCycle.length == claimedDaysInCycle.length &&
        other.claimedDaysInCycle
            .every((day) => claimedDaysInCycle.contains(day));
  }

  @override
  int get hashCode => Object.hash(
    currentStreak,
    currentDay,
    lastCheckInDate,
    claimedDaysInCycle.length,
  );
}

/// Helper function to serialize CheckInData to JSON string
String encodeCheckInData(CheckInData data) {
  return jsonEncode(data.toJson());
}

/// Helper function to deserialize JSON string to CheckInData
CheckInData decodeCheckInData(String jsonString) {
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  return CheckInData.fromJson(json);
}