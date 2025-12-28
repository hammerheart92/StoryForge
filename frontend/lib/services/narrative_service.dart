// lib/services/narrative_service.dart
// Service for communicating with the narrative API backend

import '../config/api_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/narrative_response.dart';
import '../models/choice.dart';

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
  Future<NarrativeResponse> speak(String message, String speaker) async {
    try {
      final url = Uri.parse('$baseUrl/speak');

      print('🌐 POST $url');
      print('📤 Request: message="$message", speaker="$speaker"');

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'message': message,
          'speaker': speaker,
        }),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
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
  Future<NarrativeResponse> choose(Choice choice) async {
    try {
      final url = Uri.parse('$baseUrl/choose');

      print('🌐 POST $url');
      print('📤 Request: choice="${choice.label}", nextSpeaker="${choice.nextSpeaker}"');

      final response = await client.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(choice.toJson()),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
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