// lib/models/narrative_message.dart
// Represents a single message in the conversation history

import 'narrative_response.dart';
import 'choice.dart';

class NarrativeMessage {
  final String speakerName;     // Display name ("Narrator", "Ilyra", "You")
  final String speaker;         // Character ID ("narrator", "ilyra", "user")
  final String dialogue;        // The message text
  final String? actionText;     // Action description (italic text)
  final String mood;            // Character's mood at this point
  final DateTime timestamp;     // When this message was created
  final List<Choice>? choices;  // Choices available after this message (null for user messages)

  NarrativeMessage({
    required this.speakerName,
    required this.speaker,
    required this.dialogue,
    this.actionText,
    required this.mood,
    required this.timestamp,
    this.choices,
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
      actionText: response.actionText,
      mood: response.mood,
      timestamp: DateTime.now(),
      choices: response.choices,  // CRITICAL: Capture choices from response
    );
  }

  /// Check if this is a user message
  bool get isUser => speaker == 'user';

  /// Check if this is the narrator
  bool get isNarrator => speaker == 'narrator';

  /// Check if action text is present
  bool get hasActionText => actionText != null && actionText!.isNotEmpty;

  /// Check if this message has choices available
  bool get hasChoices => choices != null && choices!.isNotEmpty;

  @override
  String toString() {
    return 'NarrativeMessage($speakerName: ${dialogue.substring(0, dialogue.length > 30 ? 30 : dialogue.length)}...)';
  }
}
