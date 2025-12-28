// lib/models/narrative_message.dart
// Represents a single message in the conversation history

import 'narrative_response.dart';

class NarrativeMessage {
  final String speakerName;     // Display name ("Narrator", "Ilyra", "You")
  final String speaker;         // Character ID ("narrator", "ilyra", "user")
  final String dialogue;        // The message text
  final String mood;            // Character's mood at this point
  final DateTime timestamp;     // When this message was created

  NarrativeMessage({
    required this.speakerName,
    required this.speaker,
    required this.dialogue,
    required this.mood,
    required this.timestamp,
  });

  /// Create a user choice message (for history)
  factory NarrativeMessage.userChoice(String choiceLabel) {
    return NarrativeMessage(
      speakerName: 'You',
      speaker: 'user',
      dialogue: 'You chose: $choiceLabel',
      mood: 'neutral',
      timestamp: DateTime.now(),
    );
  }

  /// Create a character response message (from NarrativeResponse)
  factory NarrativeMessage.fromResponse(NarrativeResponse response) {
    return NarrativeMessage(
      speakerName: response.speakerName,
      speaker: response.speaker,
      dialogue: response.dialogue,
      mood: response.mood,
      timestamp: DateTime.now(),
    );
  }

  /// Check if this is a user message
  bool get isUser => speaker == 'user';

  /// Check if this is the narrator
  bool get isNarrator => speaker == 'narrator';

  @override
  String toString() {
    return 'NarrativeMessage($speakerName: ${dialogue.substring(0, 30)}...)';
  }
}