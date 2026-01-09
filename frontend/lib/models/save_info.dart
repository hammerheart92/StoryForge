// lib/models/save_info.dart
// Model representing a saved story state for the Story Library

class SaveInfo {
  final String storyId;
  final String characterId;
  final String characterName;
  final int messageCount;
  final DateTime lastPlayed;
  final bool isCompleted;

  const SaveInfo({
    required this.storyId,
    required this.characterId,
    required this.characterName,
    required this.messageCount,
    required this.lastPlayed,
    this.isCompleted = false,
  });

  factory SaveInfo.fromJson(Map<String, dynamic> json) {
    return SaveInfo(
      storyId: json['storyId'] as String,
      characterId: json['characterId'] as String,
      characterName: json['characterName'] as String,
      messageCount: json['messageCount'] as int,
      lastPlayed: DateTime.parse(json['lastPlayed'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
      'characterId': characterId,
      'characterName': characterName,
      'messageCount': messageCount,
      'lastPlayed': lastPlayed.toIso8601String(),
      'isCompleted': isCompleted,
    };
  }

  SaveInfo copyWith({
    String? storyId,
    String? characterId,
    String? characterName,
    int? messageCount,
    DateTime? lastPlayed,
    bool? isCompleted,
  }) {
    return SaveInfo(
      storyId: storyId ?? this.storyId,
      characterId: characterId ?? this.characterId,
      characterName: characterName ?? this.characterName,
      messageCount: messageCount ?? this.messageCount,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
