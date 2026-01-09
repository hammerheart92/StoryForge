// lib/services/save_service.dart
// Service for managing multi-story save metadata
// Full conversation data is handled by StoryStateService

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/save_info.dart';
import '../models/character_info.dart';

class SaveService {
  static const String _keySaveMetadata = 'story_saves';

  /// Get all saved story metadata
  static Future<List<SaveInfo>> getAllSaves() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savesJson = prefs.getString(_keySaveMetadata);

      if (savesJson == null || savesJson.isEmpty) {
        return [];
      }

      final Map<String, dynamic> savesMap = jsonDecode(savesJson);
      return savesMap.entries.map((entry) {
        return SaveInfo.fromJson(entry.value as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      print('Error loading saves: $e');
      return [];
    }
  }

  /// Get save metadata for a specific story
  static Future<SaveInfo?> getSaveForStory(String storyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savesJson = prefs.getString(_keySaveMetadata);

      if (savesJson == null || savesJson.isEmpty) {
        return null;
      }

      final Map<String, dynamic> savesMap = jsonDecode(savesJson);
      final saveData = savesMap[storyId];

      if (saveData == null) {
        return null;
      }

      return SaveInfo.fromJson(saveData as Map<String, dynamic>);
    } catch (e) {
      print('Error loading save for story $storyId: $e');
      return null;
    }
  }

  /// Update or create save metadata for a story
  static Future<void> updateSave({
    required String storyId,
    required String characterId,
    required int messageCount,
    bool isCompleted = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savesJson = prefs.getString(_keySaveMetadata);

      Map<String, dynamic> savesMap = {};
      if (savesJson != null && savesJson.isNotEmpty) {
        savesMap = jsonDecode(savesJson) as Map<String, dynamic>;
      }

      // Get character name from CharacterInfo
      final character = CharacterInfo.all.firstWhere(
        (c) => c.id == characterId,
        orElse: () => CharacterInfo.all.first,
      );

      final saveInfo = SaveInfo(
        storyId: storyId,
        characterId: characterId,
        characterName: character.name,
        messageCount: messageCount,
        lastPlayed: DateTime.now(),
        isCompleted: isCompleted,
      );

      savesMap[storyId] = saveInfo.toJson();
      await prefs.setString(_keySaveMetadata, jsonEncode(savesMap));

      print('SaveService: Updated save for $storyId (${messageCount} messages)');
    } catch (e) {
      print('Error updating save: $e');
    }
  }

  /// Delete save metadata for a story
  static Future<void> deleteSave(String storyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savesJson = prefs.getString(_keySaveMetadata);

      if (savesJson == null || savesJson.isEmpty) {
        return;
      }

      final Map<String, dynamic> savesMap = jsonDecode(savesJson);
      savesMap.remove(storyId);

      await prefs.setString(_keySaveMetadata, jsonEncode(savesMap));

      // Also clear the conversation data for this story
      await _clearConversationData(storyId);

      print('SaveService: Deleted save for $storyId');
    } catch (e) {
      print('Error deleting save: $e');
    }
  }

  /// Clear conversation data for a specific story
  static Future<void> _clearConversationData(String storyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Clear story-specific keys
      await prefs.remove('conversation_history_$storyId');
      await prefs.remove('last_character_$storyId');
      await prefs.remove('last_save_time_$storyId');

      // Also check if old single-story format matches this story
      final currentStoryId = prefs.getString('story_id');
      if (currentStoryId == storyId) {
        await prefs.remove('conversation_history');
        await prefs.remove('last_character');
        await prefs.remove('last_save_time');
        await prefs.remove('story_id');
      }
    } catch (e) {
      print('Error clearing conversation data: $e');
    }
  }

  /// Check if any saves exist
  static Future<bool> hasAnySaves() async {
    final saves = await getAllSaves();
    return saves.isNotEmpty;
  }
}
