// lib/services/story_completion_service.dart
// Service for fetching story completion data from backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/story_ending.dart';
import '../models/completion_stats.dart';

/// Exception for story completion API errors
class StoryCompletionApiException implements Exception {
  final String message;
  final int? statusCode;

  StoryCompletionApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'StoryCompletionApiException: $message (status: $statusCode)';
}

/// Service for fetching story endings and completion statistics
class StoryCompletionService {
  final String baseUrl;
  final http.Client client;

  StoryCompletionService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        client = client ?? http.Client();

  /// Get all endings for a story with discovery status
  ///
  /// Returns list of StoryEnding objects with discovered/undiscovered status
  Future<List<StoryEnding>> getStoryEndings(String storyId) async {
    try {
      final url = Uri.parse('$baseUrl/$storyId/endings');
      print('🌐 GET $url');

      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
        final endings = jsonList
            .map((json) => StoryEnding.fromJson(json as Map<String, dynamic>))
            .toList();
        print('✅ Loaded ${endings.length} endings for story $storyId');
        return endings;
      } else {
        throw StoryCompletionApiException(
          'Failed to load endings: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error fetching story endings: $e');
      if (e is StoryCompletionApiException) rethrow;
      throw StoryCompletionApiException('Network error: $e');
    }
  }

  /// Get completion statistics for a story
  ///
  /// Returns CompletionStats with save counts, endings discovered, and completion percentage
  Future<CompletionStats> getCompletionStats(String storyId) async {
    try {
      final url = Uri.parse('$baseUrl/$storyId/completion-stats');
      print('🌐 GET $url');

      final response = await client.get(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final stats = CompletionStats.fromJson(json);
        print('✅ Loaded completion stats for story $storyId: $stats');
        return stats;
      } else {
        throw StoryCompletionApiException(
          'Failed to load completion stats: ${response.body}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error fetching completion stats: $e');
      if (e is StoryCompletionApiException) rethrow;
      throw StoryCompletionApiException('Network error: $e');
    }
  }

  /// Get completion stats with fallback to empty stats on error
  ///
  /// Useful for UI that should still display even if API fails
  Future<CompletionStats> getCompletionStatsSafe(String storyId, {int totalEndings = 0}) async {
    try {
      return await getCompletionStats(storyId);
    } catch (e) {
      print('⚠️ Using empty completion stats for $storyId due to error: $e');
      return CompletionStats.empty(totalEndings: totalEndings);
    }
  }

  /// Get endings with fallback to empty list on error
  ///
  /// Useful for UI that should still display even if API fails
  Future<List<StoryEnding>> getStoryEndingsSafe(String storyId) async {
    try {
      return await getStoryEndings(storyId);
    } catch (e) {
      print('⚠️ Using empty endings list for $storyId due to error: $e');
      return [];
    }
  }
}
