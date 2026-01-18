// lib/services/narrative_service.dart
// Service for communicating with the narrative API backend

import '../config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/narrative_response.dart';
import '../models/choice.dart';
import '../models/save_info.dart';

class NarrativeService {
  // Backend URL - change this if your backend is on a different port
  final String baseUrl;
  final http.Client client;

  NarrativeService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? ApiConfig.baseUrl,  // ← Use config
        client = client ?? http.Client();

  /// Send a message and get a narrative response with choices
  ///
  /// Example:
  /// ```dart
  /// final response = await narrativeService.speak(
  ///   'I approach the observatory',
  ///   'narrator'
  /// );
  /// ```
  Future<NarrativeResponse> speak(String message, String speaker, String storyId, int saveSlot) async {  // Session 29: Added saveSlot
    try {
      final url = Uri.parse('$baseUrl/speak');

      print('🌐 POST $url');
      print('📤 Request: message="$message", speaker="$speaker", storyId="$storyId", saveSlot=$saveSlot');

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'speaker': speaker,
          'storyId': storyId,
          'saveSlot': saveSlot.toString(),  // Session 29: Multi-slot support
        }),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // ═══════════════════════════════════════════════════════════════════
        // DEBUG: Print raw JSON to find Ilyra bug
        // ═══════════════════════════════════════════════════════════════════
        print('═══════════════════════════════════════════════════════════════');
        print('🔍 DEBUG - Raw JSON from backend:');
        print('   speaker: ${json['speaker']}');
        print('   dialogue: ${json['dialogue']}');
        print('   actionText: ${json['actionText']}');
        print('   dialogue type: ${json['dialogue'].runtimeType}');
        print('   dialogue starts with {: ${json['dialogue'].toString().trim().startsWith('{')}');
        print('   isEnding: ${json['isEnding']}');
        print('   endingId: ${json['endingId']}');
        print('═══════════════════════════════════════════════════════════════');

        final narrativeResponse = NarrativeResponse.fromJson(json);

        print('✅ Success: ${narrativeResponse.speakerName} with ${narrativeResponse.choices.length} choices');

        return narrativeResponse;
      } else {
        throw NarrativeApiException(
          'Failed to get response: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error in speak(): $e');
      rethrow;
    }
  }

  /// Select a choice and get the next narrative response
  ///
  /// Example:
  /// ```dart
  /// final response = await narrativeService.choose(choice);
  /// ```
  Future<NarrativeResponse> choose(Choice choice, String storyId, int saveSlot) async {  // Session 29: Added saveSlot
    try {
      final url = Uri.parse('$baseUrl/choose');

      print('🌐 POST $url');
      print('📤 Request: choice="${choice.label}", nextSpeaker="${choice.nextSpeaker}", storyId="$storyId", saveSlot=$saveSlot');

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          ...choice.toJson(),
          'storyId': storyId,
          'saveSlot': saveSlot.toString(),  // Session 29: Multi-slot support
        }),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;

        // ═══════════════════════════════════════════════════════════════════
        // DEBUG: Print raw JSON to find Ilyra bug (choose endpoint)
        // ═══════════════════════════════════════════════════════════════════
        print('═══════════════════════════════════════════════════════════════');
        print('🔍 DEBUG CHOOSE - Raw JSON from backend:');
        print('   speaker: ${json['speaker']}');
        print('   dialogue: ${json['dialogue']}');
        print('   actionText: ${json['actionText']}');
        print('   dialogue type: ${json['dialogue'].runtimeType}');
        print('   dialogue starts with {: ${json['dialogue'].toString().trim().startsWith('{')}');
        print('   isEnding: ${json['isEnding']}');
        print('   endingId: ${json['endingId']}');
        print('═══════════════════════════════════════════════════════════════');

        final narrativeResponse = NarrativeResponse.fromJson(json);

        print('✅ Success: Switched to ${narrativeResponse.speakerName}');

        return narrativeResponse;
      } else {
        throw NarrativeApiException(
          'Failed to process choice: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error in choose(): $e');
      rethrow;
    }
  }

  /// Get all available characters (optional, for future use)
  Future<List<Map<String, dynamic>>> getCharacters() async {
    try {
      final url = Uri.parse('$baseUrl/characters');

      print('🌐 GET $url');

      final response = await client.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        print('✅ Success: ${json.length} characters loaded');
        return json.cast<Map<String, dynamic>>();
      } else {
        throw NarrativeApiException(
          'Failed to get characters: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error in getCharacters(): $e');
      rethrow;
    }
  }

  /// Check if the narrative API is available
  Future<bool> checkStatus() async {
    try {
      final url = Uri.parse('$baseUrl/status');
      final response = await client.get(url);

      if (response.statusCode == 200) {
        print('✅ Narrative API is running');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Narrative API is not available: $e');
      return false;
    }
  }

  // ==================== SESSION 28: Save Management API ====================

  /// Get all saves from backend API
  Future<List<SaveInfo>> getAllSavesFromBackend() async {
    try {
      final url = Uri.parse('$baseUrl/saves');
      print('🌐 GET $url');

      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final saves = json.map((item) => SaveInfo.fromJson(item as Map<String, dynamic>)).toList();
        print('✅ Success: ${saves.length} saves loaded from backend');
        return saves;
      } else {
        throw NarrativeApiException(
          'Failed to load saves: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error in getAllSavesFromBackend(): $e');
      rethrow;
    }
  }

  /// Delete save from backend API
  Future<void> deleteSaveFromBackend(String storyId) async {
    try {
      final url = Uri.parse('$baseUrl/saves/$storyId');
      print('🌐 DELETE $url');

      final response = await client.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response status: ${response.statusCode}');

      // 204 = success, 404 = already deleted (both OK)
      if (response.statusCode != 204 && response.statusCode != 404) {
        throw NarrativeApiException(
          'Failed to delete save: ${response.statusCode}',
          response.statusCode,
        );
      }
      print('✅ Save deleted for story: $storyId');
    } catch (e) {
      print('❌ Error in deleteSaveFromBackend(): $e');
      rethrow;
    }
  }

  // ==================== SESSION 29: Multi-Slot Save API ====================

  /// Get all saves for a specific story (all slots 1-5)
  Future<List<SaveInfo>> getSavesForStory(String storyId) async {
    try {
      final url = Uri.parse('$baseUrl/saves/story/$storyId');
      print('🌐 GET $url');

      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> json = jsonDecode(response.body);
        final saves = json.map((item) => SaveInfo.fromJson(item as Map<String, dynamic>)).toList();
        print('✅ Success: ${saves.length} saves loaded for story $storyId');
        return saves;
      } else {
        throw NarrativeApiException(
          'Failed to load saves for story: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error in getSavesForStory(): $e');
      rethrow;
    }
  }

  /// Delete a specific save slot
  Future<void> deleteSaveSlot(String storyId, int saveSlot) async {
    try {
      final url = Uri.parse('$baseUrl/saves/$storyId/$saveSlot');
      print('🌐 DELETE $url');

      final response = await client.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response status: ${response.statusCode}');

      // 204 = success, 404 = already deleted (both OK)
      if (response.statusCode != 204 && response.statusCode != 404) {
        throw NarrativeApiException(
          'Failed to delete save slot: ${response.statusCode}',
          response.statusCode,
        );
      }
      print('✅ Deleted save slot $saveSlot for story: $storyId');
    } catch (e) {
      print('❌ Error in deleteSaveSlot(): $e');
      rethrow;
    }
  }

  /// Print current environment info (for debugging)
  static void printCurrentEnvironment() {
    ApiConfig.printEnvironment();
    print('   Endpoints:');
    print('     - POST /speak  (get narrative response)');
    print('     - POST /choose (select a choice)');
    print('     - GET /characters (list characters)');
    print('     - GET /status (health check)');
  }

  /// Dispose resources
  void dispose() {
    client.close();
  }
}

/// Custom exception for narrative API errors
class NarrativeApiException implements Exception {
  final String message;
  final int? statusCode;

  NarrativeApiException(this.message, [this.statusCode]);

  @override
  String toString() {
    if (statusCode != null) {
      return 'NarrativeApiException ($statusCode): $message';
    }
    return 'NarrativeApiException: $message';
  }
}