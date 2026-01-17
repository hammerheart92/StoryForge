/// Model for story completion statistics
///
/// Maps to backend CompletionStats DTO from /api/narrative/{storyId}/completion-stats
class CompletionStats {
  final int totalSaves;
  final int completedSaves;
  final int endingsDiscovered;
  final int totalEndings;
  final double completionPercentage;

  CompletionStats({
    required this.totalSaves,
    required this.completedSaves,
    required this.endingsDiscovered,
    required this.totalEndings,
    required this.completionPercentage,
  });

  /// Whether all endings have been discovered
  bool get fullyCompleted => endingsDiscovered >= totalEndings;

  /// Whether the player has started this story
  bool get hasStarted => totalSaves > 0;

  /// Whether the player has completed the story at least once
  bool get hasCompletedOnce => completedSaves > 0;

  factory CompletionStats.fromJson(Map<String, dynamic> json) {
    return CompletionStats(
      totalSaves: json['totalSaves'] as int? ?? 0,
      completedSaves: json['completedSaves'] as int? ?? 0,
      endingsDiscovered: json['endingsDiscovered'] as int? ?? 0,
      totalEndings: json['totalEndings'] as int? ?? 0,
      completionPercentage: (json['completionPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalSaves': totalSaves,
      'completedSaves': completedSaves,
      'endingsDiscovered': endingsDiscovered,
      'totalEndings': totalEndings,
      'completionPercentage': completionPercentage,
    };
  }

  /// Empty stats for stories not yet started
  factory CompletionStats.empty({int totalEndings = 0}) {
    return CompletionStats(
      totalSaves: 0,
      completedSaves: 0,
      endingsDiscovered: 0,
      totalEndings: totalEndings,
      completionPercentage: 0.0,
    );
  }

  CompletionStats copyWith({
    int? totalSaves,
    int? completedSaves,
    int? endingsDiscovered,
    int? totalEndings,
    double? completionPercentage,
  }) {
    return CompletionStats(
      totalSaves: totalSaves ?? this.totalSaves,
      completedSaves: completedSaves ?? this.completedSaves,
      endingsDiscovered: endingsDiscovered ?? this.endingsDiscovered,
      totalEndings: totalEndings ?? this.totalEndings,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }

  @override
  String toString() {
    return 'CompletionStats{totalSaves: $totalSaves, completedSaves: $completedSaves, '
        'endings: $endingsDiscovered/$totalEndings, completion: $completionPercentage%}';
  }
}
