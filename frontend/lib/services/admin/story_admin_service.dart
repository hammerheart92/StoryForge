import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/admin/story_dto.dart';
import '../../models/admin/story_requests.dart';

/// Exception types for story admin operations
class StoryAdminException implements Exception {
  final String message;
  final int? statusCode;

  StoryAdminException(this.message, {this.statusCode});

  @override
  String toString() => 'StoryAdminException: $message (status: $statusCode)';
}

class UnauthorizedException extends StoryAdminException {
  UnauthorizedException([String message = 'Session expired'])
      : super(message, statusCode: 401);
}

class ForbiddenException extends StoryAdminException {
  ForbiddenException([String message = 'Access denied'])
      : super(message, statusCode: 403);
}

class NetworkException extends StoryAdminException {
  NetworkException([String message = 'Network error'])
      : super(message);
}

/// Service for Story Admin API operations
class StoryAdminService {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  StoryAdminService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = '${baseUrl ?? ApiConfig.authBaseUrl}/api/admin/stories',
        client = client ?? http.Client();

  /// Get JWT token from secure storage
  Future<String> _getToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) {
      throw UnauthorizedException('No auth token found');
    }
    return token;
  }

  /// Build headers with JWT token
  Future<Map<String, String>> _authHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Handle HTTP response, throwing appropriate exceptions
  void _handleErrorResponse(http.Response response) {
    debugPrint('❌ API Error: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else if (response.statusCode == 403) {
      throw ForbiddenException();
    }

    String message;
    try {
      final data = jsonDecode(response.body);
      message = data['error'] ?? data['message'] ?? 'Request failed';
    } catch (_) {
      message = 'Request failed with status ${response.statusCode}';
    }
    throw StoryAdminException(message, statusCode: response.statusCode);
  }

  /// List all stories for the authenticated creator
  Future<List<StoryDto>> getCreatorStories() async {
    debugPrint('📤 GET $baseUrl');

    try {
      final headers = await _authHeaders();
      final response = await client.get(
        Uri.parse(baseUrl),
        headers: headers,
      );

      debugPrint('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final stories = data.map((json) => StoryDto.fromJson(json)).toList();
        debugPrint('✅ Loaded ${stories.length} stories');
        return stories;
      }

      _handleErrorResponse(response);
      return []; // unreachable
    } on StoryAdminException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Network error: $e');
      throw NetworkException('Failed to load stories. Check your connection.');
    }
  }

  /// Create a new story
  Future<StoryDto> createStory(CreateStoryRequest request) async {
    debugPrint('📤 POST $baseUrl');
    debugPrint('📦 Body: ${jsonEncode(request.toJson())}');

    try {
      final headers = await _authHeaders();
      final response = await client.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      debugPrint('📥 Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final story = StoryDto.fromJson(jsonDecode(response.body));
        debugPrint('✅ Story created: ${story.id} - ${story.title}');
        return story;
      }

      _handleErrorResponse(response);
      throw StoryAdminException('Unexpected error'); // unreachable
    } on StoryAdminException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Network error: $e');
      throw NetworkException('Failed to create story. Check your connection.');
    }
  }

  /// Update an existing story
  Future<StoryDto> updateStory(int id, UpdateStoryRequest request) async {
    final url = '$baseUrl/$id';
    debugPrint('📤 PUT $url');
    debugPrint('📦 Body: ${jsonEncode(request.toJson())}');

    try {
      final headers = await _authHeaders();
      final response = await client.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(request.toJson()),
      );

      debugPrint('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final story = StoryDto.fromJson(jsonDecode(response.body));
        debugPrint('✅ Story updated: ${story.id} - ${story.title}');
        return story;
      }

      _handleErrorResponse(response);
      throw StoryAdminException('Unexpected error'); // unreachable
    } on StoryAdminException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Network error: $e');
      throw NetworkException('Failed to update story. Check your connection.');
    }
  }

  /// Delete a story
  Future<void> deleteStory(int id) async {
    final url = '$baseUrl/$id';
    debugPrint('📤 DELETE $url');

    try {
      final headers = await _authHeaders();
      final response = await client.delete(
        Uri.parse(url),
        headers: headers,
      );

      debugPrint('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Story deleted: $id');
        return;
      }

      _handleErrorResponse(response);
    } on StoryAdminException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Network error: $e');
      throw NetworkException('Failed to delete story. Check your connection.');
    }
  }

  /// Toggle publish status of a story
  Future<StoryDto> togglePublishStatus(int id) async {
    final url = '$baseUrl/$id/publish';
    debugPrint('📤 PATCH $url');

    try {
      final headers = await _authHeaders();
      final response = await client.patch(
        Uri.parse(url),
        headers: headers,
      );

      debugPrint('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final story = StoryDto.fromJson(jsonDecode(response.body));
        debugPrint('✅ Publish toggled: ${story.id} -> ${story.published}');
        return story;
      }

      _handleErrorResponse(response);
      throw StoryAdminException('Unexpected error'); // unreachable
    } on StoryAdminException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Network error: $e');
      throw NetworkException('Failed to update publish status. Check your connection.');
    }
  }
}
