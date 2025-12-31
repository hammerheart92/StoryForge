// lib/services/story_state_service.dart
// Service for persisting and restoring story state
// Uses SharedPreferences (works reliably on mobile, limited on web)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/narrative_message.dart';
import '../models/choice.dart';

/// Service for persisting and restoring story state
/// Note: Web persistence is limited due to localStorage port-specific behavior
class StoryStateService {
  static const String _keyConversationHistory = 'conversation_history';
  static const String _keyLastCharacter = 'last_character';
  static const String _keyLastSaveTime = 'last_save_time';

  /// Check if there is a saved story state
  static Future<bool> hasSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getString(_keyConversationHistory);
    return history != null && history.isNotEmpty;
  }

  /// Save current conversation state
  static Future<void> saveState({
    required List<NarrativeMessage> messages,
    required String lastCharacter,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final messagesJson = messages.map((msg) => {
        'speakerName': msg.speakerName,
        'speaker': msg.speaker,
        'dialogue': msg.dialogue,
        'actionText': msg.actionText,
        'mood': msg.mood,
        'timestamp': msg.timestamp.toIso8601String(),
        'choices': msg.choices?.map((choice) => choice.toStorageJson()).toList(),  // Save choices with correct field names
      }).toList();

      await prefs.setString(_keyConversationHistory, jsonEncode(messagesJson));
      await prefs.setString(_keyLastCharacter, lastCharacter);
      await prefs.setString(_keyLastSaveTime, DateTime.now().toIso8601String());

      print('Story state saved: ${messages.length} messages');
    } catch (e) {
      print('Error saving state: $e');
    }
  }

  /// Load saved conversation state
  static Future<Map<String, dynamic>?> loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_keyConversationHistory);

      if (historyJson == null || historyJson.isEmpty) {
        return null;
      }

      final List<dynamic> messagesData = jsonDecode(historyJson);
      final messages = messagesData.map((data) {
        // Parse choices if they exist
        List<Choice>? choices;
        if (data['choices'] != null) {
          choices = (data['choices'] as List<dynamic>)
              .map((choiceJson) => Choice.fromJson(choiceJson as Map<String, dynamic>))
              .toList();
        }

        return NarrativeMessage(
          speakerName: data['speakerName'] as String,
          speaker: data['speaker'] as String,
          dialogue: data['dialogue'] as String,
          actionText: data['actionText'] as String?,
          mood: data['mood'] as String,
          timestamp: DateTime.parse(data['timestamp'] as String),
          choices: choices,  // Restore choices
        );
      }).toList();

      final lastCharacter = prefs.getString(_keyLastCharacter) ?? 'narrator';
      final lastSaveTime = prefs.getString(_keyLastSaveTime);

      print('Story state loaded: ${messages.length} messages');

      return {
        'messages': messages,
        'lastCharacter': lastCharacter,
        'lastSaveTime': lastSaveTime,
      };
    } catch (e) {
      print('Error loading state: $e');
      await clearState();
      return null;
    }
  }

  /// Clear all saved state
  static Future<void> clearState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyConversationHistory);
      await prefs.remove(_keyLastCharacter);
      await prefs.remove(_keyLastSaveTime);
      print('Story state cleared');
    } catch (e) {
      print('Error clearing state: $e');
    }
  }

  /// Get timestamp of last save
  static Future<DateTime?> getLastSaveTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timeString = prefs.getString(_keyLastSaveTime);
      if (timeString == null) return null;
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }
}
