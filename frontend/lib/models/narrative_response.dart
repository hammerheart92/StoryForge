import 'choice.dart';

class NarrativeResponse {
  final String speakerName;
  final String speaker;
  final String dialogue;
  final String? actionText;  // Action description
  final String mood;
  final List<Choice> choices;
  final List<String> suggestions; // SESSION_45: AI-generated suggestions
  final bool? isEnding;      // True when story reaches an ending
  final String? endingId;    // ID of the ending reached

  NarrativeResponse({
    required this.speakerName,
    required this.speaker,
    required this.dialogue,
    this.actionText,
    required this.mood,
    required this.choices,
    this.suggestions = const [],
    this.isEnding,
    this.endingId,
  });

  factory NarrativeResponse.fromJson(Map<String, dynamic> json) {
    return NarrativeResponse(
      speakerName: json['speakerName'] as String,
      speaker: json['speaker'] as String,
      dialogue: json['dialogue'] as String,
      actionText: json['actionText'] as String?,
      mood: json['mood'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
      suggestions: (json['suggestions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      isEnding: json['ending'] as bool?,
      endingId: json['endingId'] as String?,
    );
  }
}