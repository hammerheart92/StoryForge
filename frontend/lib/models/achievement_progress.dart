import 'dart:convert';
import 'achievement.dart';

/// Tracks progress for a specific achievement
///
/// Stores current count, status (locked/claimable/claimed), and claimed timestamp
class AchievementProgress {
  final int currentCount;
  final AchievementStatus status;
  final DateTime? claimedAt;

  const AchievementProgress({
    required this.currentCount,
    required this.status,
    this.claimedAt,
  });

  /// Create initial progress (locked, 0 count)
  factory AchievementProgress.initial() {
    return const AchievementProgress(
      currentCount: 0,
      status: AchievementStatus.locked,
      claimedAt: null,
    );
  }

  /// Create from JSON map
  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      currentCount: json['currentCount'] as int,
      status: AchievementStatus.values.firstWhere(
            (e) => e.toString() == 'AchievementStatus.${json['status']}',
        orElse: () => AchievementStatus.locked,
      ),
      claimedAt: json['claimedAt'] != null
          ? DateTime.parse(json['claimedAt'] as String)
          : null,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'currentCount': currentCount,
      'status': status.toString().split('.').last,
      'claimedAt': claimedAt?.toIso8601String(),
    };
  }

  /// Create copy with updated fields
  AchievementProgress copyWith({
    int? currentCount,
    AchievementStatus? status,
    DateTime? claimedAt,
  }) {
    return AchievementProgress(
      currentCount: currentCount ?? this.currentCount,
      status: status ?? this.status,
      claimedAt: claimedAt ?? this.claimedAt,
    );
  }

  /// Check if achievement target is reached
  bool hasReachedTarget(Achievement achievement) {
    return currentCount >= achievement.targetCount;
  }

  /// Get progress percentage (0.0 to 1.0)
  double getProgressPercentage(Achievement achievement) {
    if (achievement.targetCount == 0) return 1.0;
    return (currentCount / achievement.targetCount).clamp(0.0, 1.0);
  }

  /// Check if achievement is claimable (target reached and not claimed)
  bool isClaimable() {
    return status == AchievementStatus.claimable;
  }

  /// Check if achievement is already claimed
  bool isClaimed() {
    return status == AchievementStatus.claimed;
  }

  @override
  String toString() {
    return 'AchievementProgress(count: $currentCount, status: $status, claimedAt: $claimedAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AchievementProgress &&
        other.currentCount == currentCount &&
        other.status == status &&
        other.claimedAt == claimedAt;
  }

  @override
  int get hashCode => Object.hash(currentCount, status, claimedAt);
}

/// Helper function to serialize progress map to JSON string
String encodeProgressMap(Map<String, AchievementProgress> progressMap) {
  final jsonMap = progressMap.map(
        (key, value) => MapEntry(key, value.toJson()),
  );
  return jsonEncode(jsonMap);
}

/// Helper function to deserialize JSON string to progress map
Map<String, AchievementProgress> decodeProgressMap(String jsonString) {
  final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
  return jsonMap.map(
        (key, value) => MapEntry(
      key,
      AchievementProgress.fromJson(value as Map<String, dynamic>),
    ),
  );
}