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
  // Session 29: Added saveSlot for multi-slot support
  static String _storyKey(String storyId, String suffix) => 'story_${storyId}_$suffix';
  static String _slotKey(String storyId, int saveSlot, String suffix) => 'story_${storyId}_slot${saveSlot}_$suffix';

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
  /// Session 29: Added saveSlot for multi-slot support
  static Future<void> saveStateForStory({
    required String storyId,
    required List<NarrativeMessage> messages,
    required String lastCharacter,
    int saveSlot = 1,  // Session 29: Default to slot 1 for backward compatibility
  }) async {
    try {
      print('💾 StoryStateService.saveStateForStory($storyId, slot $saveSlot) with ${messages.length} messages');
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

      // Session 29: Save to slot-specific keys
      await prefs.setString(_slotKey(storyId, saveSlot, 'history'), jsonEncode(messagesJson));
      await prefs.setString(_slotKey(storyId, saveSlot, 'character'), lastCharacter);
      await prefs.setString(_slotKey(storyId, saveSlot, 'save_time'), DateTime.now().toIso8601String());

      // Also save to legacy story-specific keys for backward compatibility
      await prefs.setString(_storyKey(storyId, 'history'), jsonEncode(messagesJson));
      await prefs.setString(_storyKey(storyId, 'character'), lastCharacter);
      await prefs.setString(_storyKey(storyId, 'save_time'), DateTime.now().toIso8601String());

      // Also save to legacy global keys for backward compatibility
      await prefs.setString(_keyConversationHistory, jsonEncode(messagesJson));
      await prefs.setString(_keyLastCharacter, lastCharacter);
      await prefs.setString(_keyLastSaveTime, DateTime.now().toIso8601String());
      await prefs.setString(_keyStoryId, storyId);

      print('💾 Story state saved for $storyId slot $saveSlot: ${messages.length} messages');
    } catch (e) {
      print('❌ Error saving state for story $storyId slot $saveSlot: $e');
    }
  }

  /// Load state for a specific story (multi-story support)
  /// Session 29: Added saveSlot for multi-slot support
  static Future<Map<String, dynamic>?> loadStateForStory(String storyId, {int saveSlot = 1}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Session 29: First try slot-specific keys
      String? historyJson = prefs.getString(_slotKey(storyId, saveSlot, 'history'));
      String? lastCharacter = prefs.getString(_slotKey(storyId, saveSlot, 'character'));
      String? lastSaveTime = prefs.getString(_slotKey(storyId, saveSlot, 'save_time'));

      // Fallback to story-specific keys (pre-Session 29 saves)
      if (historyJson == null && saveSlot == 1) {
        historyJson = prefs.getString(_storyKey(storyId, 'history'));
        lastCharacter = prefs.getString(_storyKey(storyId, 'character'));
        lastSaveTime = prefs.getString(_storyKey(storyId, 'save_time'));

        // Migrate to slot-specific format if data exists
        if (historyJson != null && historyJson.isNotEmpty) {
          await prefs.setString(_slotKey(storyId, saveSlot, 'history'), historyJson);
          if (lastCharacter != null) {
            await prefs.setString(_slotKey(storyId, saveSlot, 'character'), lastCharacter);
          }
          if (lastSaveTime != null) {
            await prefs.setString(_slotKey(storyId, saveSlot, 'save_time'), lastSaveTime);
          }
          print('🔄 Migrated story-specific save to slot-specific keys for $storyId slot $saveSlot');
        }
      }

      // Fallback to legacy global keys if this is the current story (slot 1 only)
      if (historyJson == null && saveSlot == 1) {
        final legacyStoryId = prefs.getString(_keyStoryId);
        if (legacyStoryId == storyId) {
          historyJson = prefs.getString(_keyConversationHistory);
          lastCharacter = prefs.getString(_keyLastCharacter);
          lastSaveTime = prefs.getString(_keyLastSaveTime);

          // Migrate to slot-specific format if data exists
          if (historyJson != null && historyJson.isNotEmpty) {
            await prefs.setString(_slotKey(storyId, saveSlot, 'history'), historyJson);
            if (lastCharacter != null) {
              await prefs.setString(_slotKey(storyId, saveSlot, 'character'), lastCharacter);
            }
            if (lastSaveTime != null) {
              await prefs.setString(_slotKey(storyId, saveSlot, 'save_time'), lastSaveTime);
            }
            print('🔄 Migrated legacy save data to slot-specific keys for $storyId slot $saveSlot');
          }
        }
      }

      if (historyJson == null || historyJson.isEmpty) {
        print('📖 No saved state found for story $storyId slot $saveSlot');
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

      print('📖 Loaded state for story $storyId slot $saveSlot: ${messages.length} messages');

      return {
        'messages': messages,
        'lastCharacter': lastCharacter ?? 'narrator',
        'lastSaveTime': lastSaveTime,
        'storyId': storyId,
      };
    } catch (e) {
      print('❌ Error loading state for story $storyId slot $saveSlot: $e');
      return null;
    }
  }

  /// Clear state for a specific story
  /// Session 29: Added saveSlot for multi-slot support
  static Future<void> clearStateForStory(String storyId, {int? saveSlot}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (saveSlot != null) {
        // Clear specific slot
        await prefs.remove(_slotKey(storyId, saveSlot, 'history'));
        await prefs.remove(_slotKey(storyId, saveSlot, 'character'));
        await prefs.remove(_slotKey(storyId, saveSlot, 'save_time'));
        print('🗑️ Cleared state for story $storyId slot $saveSlot');
      } else {
        // Clear all slots for this story (1-5)
        for (int slot = 1; slot <= 5; slot++) {
          await prefs.remove(_slotKey(storyId, slot, 'history'));
          await prefs.remove(_slotKey(storyId, slot, 'character'));
          await prefs.remove(_slotKey(storyId, slot, 'save_time'));
        }

        // Also clear legacy story-specific keys
        await prefs.remove(_storyKey(storyId, 'history'));
        await prefs.remove(_storyKey(storyId, 'character'));
        await prefs.remove(_storyKey(storyId, 'save_time'));

        // Also clear legacy global keys if they match
        final legacyStoryId = prefs.getString(_keyStoryId);
        if (legacyStoryId == storyId) {
          await prefs.remove(_keyConversationHistory);
          await prefs.remove(_keyLastCharacter);
          await prefs.remove(_keyLastSaveTime);
          await prefs.remove(_keyStoryId);
        }

        print('🗑️ Cleared all state for story $storyId');
      }
    } catch (e) {
      print('❌ Error clearing state for story $storyId: $e');
    }
  }
}
