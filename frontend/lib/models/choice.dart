// lib/models/choice.dart
// Represents a single choice that the user can make in the narrative

class Choice {
  final String id;              // "choice_1", "choice_2"
  final String label;           // "Ask about the stars"
  final String nextSpeaker;     // "ilyra" or "narrator"
  final String? description;    // Optional tooltip/hint

  Choice({
    required this.id,
    required this.label,
    required this.nextSpeaker,
    this.description,
  });

  /// Create Choice from JSON (from backend API or storage)
  /// Handles both 'id' (storage format) and 'choiceId' (legacy format)
  factory Choice.fromJson(Map<String, dynamic> json) {
    return Choice(
      id: (json['id'] ?? json['choiceId']) as String,
      label: json['label'] as String,
      nextSpeaker: json['nextSpeaker'] as String,
      description: json['description'] as String?,
    );
  }

  /// Convert Choice to JSON (for sending to backend)
  Map<String, dynamic> toJson() {
    return {
      'choiceId': id,
      'label': label,
      'nextSpeaker': nextSpeaker,
    };
  }

  /// Convert Choice to JSON for local storage persistence
  Map<String, dynamic> toStorageJson() {
    return {
      'id': id,
      'label': label,
      'nextSpeaker': nextSpeaker,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'Choice(id: $id, label: $label, nextSpeaker: $nextSpeaker)';
  }
}