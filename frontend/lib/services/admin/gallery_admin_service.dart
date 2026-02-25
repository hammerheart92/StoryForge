import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../config/api_config.dart';
import '../../models/admin/gallery_item_dto.dart';
import '../../models/admin/gallery_item_requests.dart';

/// Exception types for gallery admin operations
class GalleryAdminException implements Exception {
  final String message;
  final int? statusCode;

  GalleryAdminException(this.message, {this.statusCode});

  @override
  String toString() => 'GalleryAdminException: $message (status: $statusCode)';
}

class UnauthorizedException extends GalleryAdminException {
  UnauthorizedException([String message = 'Session expired'])
      : super(message, statusCode: 401);
}

class ForbiddenException extends GalleryAdminException {
  ForbiddenException([String message = 'Access denied'])
      : super(message, statusCode: 403);
}

class NetworkException extends GalleryAdminException {
  NetworkException([String message = 'Network error'])
      : super(message);
}

/// Service for Gallery Admin API operations
class GalleryAdminService {
  final String baseUrl;
  final http.Client client;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _tokenKey = 'auth_token';

  GalleryAdminService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = '${baseUrl ?? ApiConfig.authBaseUrl}/api/admin/gallery',
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
    throw GalleryAdminException(message, statusCode: response.statusCode);
  }

  /// List all gallery items for the authenticated creator
  Future<List<GalleryItemDto>> getCreatorGalleryItems() async {
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
        final items = data.map((json) => GalleryItemDto.fromJson(json)).toList();
        debugPrint('✅ Loaded ${items.length} gallery items');
        return items;
      }

      _handleErrorResponse(response);
      return []; // unreachable
    } on GalleryAdminException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Network error: $e');
      throw NetworkException('Failed to load gallery items. Check your connection.');
    }
  }

  /// List gallery items for a specific story
  Future<List<GalleryItemDto>> getGalleryItemsByStory(String storyId) async {
    final url = '$baseUrl/story/$storyId';
    debugPrint('📤 GET $url');

    try {
      final headers = await _authHeaders();
      final response = await client.get(
        Uri.parse(url),
        headers: headers,
      );

      debugPrint('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final items = data.map((json) => GalleryItemDto.fromJson(json)).toList();
        debugPrint('✅ Loaded ${items.length} items for story $storyId');
        return items;
      }

      _handleErrorResponse(response);
      return []; // unreachable
    } on GalleryAdminException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Network error: $e');
      throw NetworkException('Failed to load gallery items. Check your connection.');
    }
  }

  /// Create a new gallery item
  Future<GalleryItemDto> createGalleryItem(CreateGalleryItemRequest request) async {
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
        final item = GalleryItemDto.fromJson(jsonDecode(response.body));
        debugPrint('✅ Gallery item created: ${item.contentId} - ${item.title}');
        return item;
      }

      _handleErrorResponse(response);
      throw GalleryAdminException('Unexpected error'); // unreachable
    } on GalleryAdminException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Network error: $e');
      throw NetworkException('Failed to create gallery item. Check your connection.');
    }
  }

  /// Update an existing gallery item
  Future<GalleryItemDto> updateGalleryItem(int contentId, UpdateGalleryItemRequest request) async {
    final url = '$baseUrl/$contentId';
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
        final item = GalleryItemDto.fromJson(jsonDecode(response.body));
        debugPrint('✅ Gallery item updated: ${item.contentId} - ${item.title}');
        return item;
      }

      _handleErrorResponse(response);
      throw GalleryAdminException('Unexpected error'); // unreachable
    } on GalleryAdminException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Network error: $e');
      throw NetworkException('Failed to update gallery item. Check your connection.');
    }
  }

  /// Delete a gallery item
  Future<void> deleteGalleryItem(int contentId) async {
    final url = '$baseUrl/$contentId';
    debugPrint('📤 DELETE $url');

    try {
      final headers = await _authHeaders();
      final response = await client.delete(
        Uri.parse(url),
        headers: headers,
      );

      debugPrint('📥 Response: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        debugPrint('✅ Gallery item deleted: $contentId');
        return;
      }

      _handleErrorResponse(response);
    } on GalleryAdminException {
      rethrow;
    } catch (e) {
      debugPrint('❌ Network error: $e');
      throw NetworkException('Failed to delete gallery item. Check your connection.');
    }
  }
}
