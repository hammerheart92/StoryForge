import 'choice.dart';

class NarrativeResponse {
  final String speakerName;
  final String speaker;
  final String dialogue;
  final String? actionText;  // NEW! Action description
  final String mood;
  final List<Choice> choices;

  NarrativeResponse({
    required this.speakerName,
    required this.speaker,
    required this.dialogue,
    this.actionText,  // NEW - optional
    required this.mood,
    required this.choices,
  });

  factory NarrativeResponse.fromJson(Map<String, dynamic> json) {
    return NarrativeResponse(
      speakerName: json['speakerName'] as String,
      speaker: json['speaker'] as String,
      dialogue: json['dialogue'] as String,
      actionText: json['actionText'] as String?,  // NEW - can be null
      mood: json['mood'] as String,
      choices: (json['choices'] as List<dynamic>)
          .map((e) => Choice.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}