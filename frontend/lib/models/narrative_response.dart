// lib/models/narrative_response.dart
// Complete response from the narrative API including dialogue and choices

import 'choice.dart';

class NarrativeResponse {
  final String dialogue;        // The character's response text
  final String speaker;         // Character ID ("narrator", "ilyra")
  final String speakerName;     // Display name ("Narrator", "Ilyra")
  final String mood;            // Character's current mood ("wary", "observant")
  final String? avatarUrl;      // Optional avatar image URL
  final List<Choice> choices;   // Available choices (2-3 options)

  NarrativeResponse({
    required this.dialogue,
    required this.speaker,
    required this.speakerName,
    required this.mood,
    this.avatarUrl,
    required this.choices,
  });

  /// Create NarrativeResponse from JSON (from backend API)
  factory NarrativeResponse.fromJson(Map<String, dynamic> json) {
    return NarrativeResponse(
      dialogue: json['dialogue'] as String,
      speaker: json['speaker'] as String,
      speakerName: json['speakerName'] as String,
      mood: json['mood'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      choices: (json['choices'] as List<dynamic>)
          .map((choiceJson) => Choice.fromJson(choiceJson as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Convert to JSON (if needed for local storage)
  Map<String, dynamic> toJson() {
    return {
      'dialogue': dialogue,
      'speaker': speaker,
      'speakerName': speakerName,
      'mood': mood,
      'avatarUrl': avatarUrl,
      'choices': choices.map((choice) => choice.toJson()).toList(),
    };
  }

  @override
  String toString() {
    return 'NarrativeResponse(speaker: $speakerName, mood: $mood, choices: ${choices.length})';
  }
}