// lib/services/save_service.dart
// Service for managing multi-story save metadata
// Session 28: Backend API integration with local cache fallback

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/save_info.dart';
import '../models/character_info.dart';
import 'narrative_service.dart';
import 'story_state_service.dart';

class SaveService {
  final NarrativeService _narrativeService;
  static const String _keySaveMetadata = 'story_saves';

  SaveService(this._narrativeService);

  /// Get all saves - backend first, local cache fallback
  Future<List<SaveInfo>> getAllSaves() async {
    try {
      // Try backend first
      final saves = await _narrativeService.getAllSavesFromBackend();
      // Cache to local for offline access
      await _cacheToLocal(saves);
      return saves;
    } catch (e) {
      print('⚠️ Backend unavailable, using local cache: $e');
      return await _loadFromLocalCache();
    }
  }

  /// Get save for specific story - backend first, local cache fallback
  Future<SaveInfo?> getSaveForStory(String storyId) async {
    try {
      final saves = await getAllSaves();
      return saves.where((s) => s.storyId == storyId).firstOrNull;
    } catch (e) {
      print('⚠️ Error getting save for story $storyId: $e');
      return null;
    }
  }

  /// Delete save - backend + local
  Future<void> deleteSave(String storyId) async {
    try {
      await _narrativeService.deleteSaveFromBackend(storyId);
    } catch (e) {
      print('⚠️ Failed to delete from backend: $e');
    }
    // Always delete locally
    await _deleteFromLocalCache(storyId);
    await StoryStateService.clearStateForStory(storyId);
  }

  /// Check if any saves exist
  Future<bool> hasAnySaves() async {
    final saves = await getAllSaves();
    return saves.isNotEmpty;
  }

  // ==================== Local Cache Helpers ====================

  /// Cache saves to local storage
  Future<void> _cacheToLocal(List<SaveInfo> saves) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> savesMap = {};
      for (final save in saves) {
        savesMap[save.storyId] = save.toJson();
      }
      await prefs.setString(_keySaveMetadata, jsonEncode(savesMap));
      print('💾 Cached ${saves.length} saves to local storage');
    } catch (e) {
      print('Error caching saves: $e');
    }
  }

  /// Load saves from local cache
  Future<List<SaveInfo>> _loadFromLocalCache() async {
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
      print('Error loading from local cache: $e');
      return [];
    }
  }

  /// Delete save from local cache
  Future<void> _deleteFromLocalCache(String storyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savesJson = prefs.getString(_keySaveMetadata);

      if (savesJson == null || savesJson.isEmpty) {
        return;
      }

      final Map<String, dynamic> savesMap = jsonDecode(savesJson);
      savesMap.remove(storyId);

      await prefs.setString(_keySaveMetadata, jsonEncode(savesMap));
      print('🗑️ Deleted save from local cache: $storyId');
    } catch (e) {
      print('Error deleting from local cache: $e');
    }
  }

  // ==================== Static Methods for NarrativeNotifier ====================
  // These remain static for backward compatibility with NarrativeNotifier

  /// Update or create save metadata locally (called after each choice)
  /// Backend auto-saves on speak/choose, this is for UI responsiveness
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

      print('💾 SaveService: Updated local save for $storyId ($messageCount messages)');
    } catch (e) {
      print('Error updating save: $e');
    }
  }
}
