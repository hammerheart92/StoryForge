// lib/services/story_state_service.dart
// Service for persisting and restoring story state
// Uses SharedPreferences (works reliably on mobile, limited on web)

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/narrative_message.dart';
import '../models/choice.dart';

/// Service for persisting and restoring story state
/// Note: Web persistence is limited due to localStorage port-specific behavior
///
/// Session 27: Added multi-story support with story-specific keys
class StoryStateService {
  // Legacy single-story keys (for backward compatibility)
  static const String _keyConversationHistory = 'conversation_history';
  static const String _keyLastCharacter = 'last_character';
  static const String _keyLastSaveTime = 'last_save_time';
  static const String _keyStoryId = 'story_id';

  // Multi-story key prefixes (Session 27)
  static String _storyKey(String storyId, String suffix) => 'story_${storyId}_$suffix';

  /// Check if there is a saved story state
  static Future<bool> hasSavedState() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getString(_keyConversationHistory);
    final result = history != null && history.isNotEmpty;
    print('🔍 StoryStateService.hasSavedState() = $result');
    return result;
  }

  /// Save current conversation state
  static Future<void> saveState({
    required List<NarrativeMessage> messages,
    required String lastCharacter,
    String storyId = 'observatory',
  }) async {
    try {
      print('💾 StoryStateService.saveState() called with ${messages.length} messages (story: $storyId)');
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
      await prefs.setString(_keyStoryId, storyId);

      print('💾 Story state saved successfully: ${messages.length} messages');
    } catch (e) {
      print('❌ Error saving state: $e');
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
      final storyId = prefs.getString(_keyStoryId) ?? 'observatory';

      print('Story state loaded: ${messages.length} messages (story: $storyId)');

      return {
        'messages': messages,
        'lastCharacter': lastCharacter,
        'lastSaveTime': lastSaveTime,
        'storyId': storyId,
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
      await prefs.remove(_keyStoryId);
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

  // ==================== SESSION 27: Multi-Story Support ====================

  /// Save state for a specific story (multi-story support)
  static Future<void> saveStateForStory({
    required String storyId,
    required List<NarrativeMessage> messages,
    required String lastCharacter,
  }) async {
    try {
      print('💾 StoryStateService.saveStateForStory($storyId) with ${messages.length} messages');
      final prefs = await SharedPreferences.getInstance();

      final messagesJson = messages.map((msg) => {
        'speakerName': msg.speakerName,
        'speaker': msg.speaker,
        'dialogue': msg.dialogue,
        'actionText': msg.actionText,
        'mood': msg.mood,
        'timestamp': msg.timestamp.toIso8601String(),
        'choices': msg.choices?.map((choice) => choice.toStorageJson()).toList(),
      }).toList();

      // Save to story-specific keys
      await prefs.setString(_storyKey(storyId, 'history'), jsonEncode(messagesJson));
      await prefs.setString(_storyKey(storyId, 'character'), lastCharacter);
      await prefs.setString(_storyKey(storyId, 'save_time'), DateTime.now().toIso8601String());

      // Also save to legacy keys for backward compatibility
      await prefs.setString(_keyConversationHistory, jsonEncode(messagesJson));
      await prefs.setString(_keyLastCharacter, lastCharacter);
      await prefs.setString(_keyLastSaveTime, DateTime.now().toIso8601String());
      await prefs.setString(_keyStoryId, storyId);

      print('💾 Story state saved for $storyId: ${messages.length} messages');
    } catch (e) {
      print('❌ Error saving state for story $storyId: $e');
    }
  }

  /// Load state for a specific story (multi-story support)
  static Future<Map<String, dynamic>?> loadStateForStory(String storyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // First try story-specific keys
      String? historyJson = prefs.getString(_storyKey(storyId, 'history'));
      String? lastCharacter = prefs.getString(_storyKey(storyId, 'character'));
      String? lastSaveTime = prefs.getString(_storyKey(storyId, 'save_time'));

      // Fallback to legacy keys if this is the current story
      if (historyJson == null) {
        final legacyStoryId = prefs.getString(_keyStoryId);
        if (legacyStoryId == storyId) {
          historyJson = prefs.getString(_keyConversationHistory);
          lastCharacter = prefs.getString(_keyLastCharacter);
          lastSaveTime = prefs.getString(_keyLastSaveTime);

          // Migrate to new format if data exists
          if (historyJson != null && historyJson.isNotEmpty) {
            await prefs.setString(_storyKey(storyId, 'history'), historyJson);
            if (lastCharacter != null) {
              await prefs.setString(_storyKey(storyId, 'character'), lastCharacter);
            }
            if (lastSaveTime != null) {
              await prefs.setString(_storyKey(storyId, 'save_time'), lastSaveTime);
            }
            print('🔄 Migrated legacy save data to story-specific keys for $storyId');
          }
        }
      }

      if (historyJson == null || historyJson.isEmpty) {
        return null;
      }

      final List<dynamic> messagesData = jsonDecode(historyJson);
      final messages = messagesData.map((data) {
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
          choices: choices,
        );
      }).toList();

      print('📖 Loaded state for story $storyId: ${messages.length} messages');

      return {
        'messages': messages,
        'lastCharacter': lastCharacter ?? 'narrator',
        'lastSaveTime': lastSaveTime,
        'storyId': storyId,
      };
    } catch (e) {
      print('❌ Error loading state for story $storyId: $e');
      return null;
    }
  }

  /// Clear state for a specific story
  static Future<void> clearStateForStory(String storyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storyKey(storyId, 'history'));
      await prefs.remove(_storyKey(storyId, 'character'));
      await prefs.remove(_storyKey(storyId, 'save_time'));

      // Also clear legacy if it matches
      final legacyStoryId = prefs.getString(_keyStoryId);
      if (legacyStoryId == storyId) {
        await prefs.remove(_keyConversationHistory);
        await prefs.remove(_keyLastCharacter);
        await prefs.remove(_keyLastSaveTime);
        await prefs.remove(_keyStoryId);
      }

      print('🗑️ Cleared state for story $storyId');
    } catch (e) {
      print('❌ Error clearing state for story $storyId: $e');
    }
  }
}
