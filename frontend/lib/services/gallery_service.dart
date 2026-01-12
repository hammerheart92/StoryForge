// lib/services/gallery_service.dart
// Service for communicating with the gallery API backend

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gallery_content.dart';
import '../models/user_currency.dart';

/// Custom exception for gallery API errors
class GalleryApiException implements Exception {
  final String message;
  final int? statusCode;

  GalleryApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'GalleryApiException: $message (status: $statusCode)';
}

/// Response wrapper for gallery content endpoint
class GalleryContentResponse {
  final List<GalleryContent> content;
  final List<int> unlockedIds;
  final int gemBalance;
  final String storyId;

  GalleryContentResponse({
    required this.content,
    required this.unlockedIds,
    required this.gemBalance,
    required this.storyId,
  });

  factory GalleryContentResponse.fromJson(Map<String, dynamic> json) {
    return GalleryContentResponse(
      content: (json['content'] as List<dynamic>?)
              ?.map((e) => GalleryContent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      unlockedIds: (json['unlockedIds'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      gemBalance: json['gemBalance'] as int? ?? 0,
      storyId: json['storyId'] as String? ?? '',
    );
  }
}

/// Result of an unlock operation
class UnlockResult {
  final bool success;
  final int? contentId;
  final int? newBalance;
  final String? message;

  UnlockResult({
    required this.success,
    this.contentId,
    this.newBalance,
    this.message,
  });

  factory UnlockResult.fromJson(Map<String, dynamic> json) {
    return UnlockResult(
      success: json['success'] as bool? ?? false,
      contentId: json['contentId'] as int?,
      newBalance: json['newBalance'] as int?,
      message: json['message'] as String?,
    );
  }
}

/// Service for gallery and currency API operations
class GalleryService {
  final String baseUrl;
  final http.Client client;

  // Gallery API base URLs (similar to ApiConfig but for /api/gallery)
  static const String _productionUrl =
      'https://storyforge-production.up.railway.app/api/gallery';
  static const String _developmentUrl = 'http://localhost:8080/api/gallery';

  static String get _defaultBaseUrl {
    const environment = String.fromEnvironment('ENV', defaultValue: 'development');
    return environment == 'production' ? _productionUrl : _developmentUrl;
  }

  GalleryService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl,
        client = client ?? http.Client();

  /// Get all gallery content for a story with unlock status and gem balance
  ///
  /// GET /api/gallery/{storyId}/content
  Future<GalleryContentResponse> getGalleryContent(String storyId) async {
    try {
      final url = Uri.parse('$baseUrl/$storyId/content');
      print('🖼️ GET $url');

      final response = await client.get(url);
      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = GalleryContentResponse.fromJson(json);
        print('✅ Loaded ${result.content.length} content items, ${result.unlockedIds.length} unlocked');
        return result;
      } else {
        throw GalleryApiException(
          'Failed to load gallery content: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error in getGalleryContent(): $e');
      rethrow;
    }
  }

  /// Get user's current gem balance
  ///
  /// GET /api/gallery/user/{userId}/balance
  Future<UserCurrency> getGemBalance(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/user/$userId/balance');
      print('💎 GET $url');

      final response = await client.get(url);
      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = UserCurrency.fromJson(json);
        print('✅ Balance: ${result.gemBalance} gems');
        return result;
      } else {
        throw GalleryApiException(
          'Failed to get gem balance: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error in getGemBalance(): $e');
      rethrow;
    }
  }

  /// Unlock content by spending gems
  ///
  /// POST /api/gallery/unlock
  /// Body: { userId, contentId }
  Future<UnlockResult> unlockContent(String userId, int contentId) async {
    try {
      final url = Uri.parse('$baseUrl/unlock');
      print('🔓 POST $url');
      print('📤 Request: userId="$userId", contentId=$contentId');

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': userId,
          'contentId': contentId,
        }),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final result = UnlockResult.fromJson(json);
        if (result.success) {
          print('✅ Unlocked! New balance: ${result.newBalance}');
        } else {
          print('⚠️ Unlock failed: ${result.message}');
        }
        return result;
      } else {
        // Try to parse error message from response
        String errorMsg = 'Failed to unlock content: ${response.statusCode}';
        try {
          final json = jsonDecode(response.body) as Map<String, dynamic>;
          errorMsg = json['message'] as String? ?? errorMsg;
        } catch (_) {}
        throw GalleryApiException(errorMsg, response.statusCode);
      }
    } catch (e) {
      print('❌ Error in unlockContent(): $e');
      rethrow;
    }
  }

  /// Get list of content IDs unlocked by user for a story
  ///
  /// GET /api/gallery/user/{userId}/unlocks?storyId={storyId}
  Future<List<int>> getUserUnlocks(String userId, String storyId) async {
    try {
      final url = Uri.parse('$baseUrl/user/$userId/unlocks?storyId=$storyId');
      print('🔓 GET $url');

      final response = await client.get(url);
      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final unlockedIds = (json['unlockedIds'] as List<dynamic>?)
                ?.map((e) => e as int)
                .toList() ??
            [];
        print('✅ User has ${unlockedIds.length} unlocks');
        return unlockedIds;
      } else {
        throw GalleryApiException(
          'Failed to get user unlocks: ${response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Error in getUserUnlocks(): $e');
      rethrow;
    }
  }
}
