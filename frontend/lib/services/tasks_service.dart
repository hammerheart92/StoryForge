// lib/services/tasks_service.dart
// Service for communicating with the Tasks API backend

import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for Tasks API operations (check-in and achievements)
class TasksService {
  final String baseUrl;
  final http.Client client;

  // Tasks API base URLs
  static const String _productionUrl =
      'https://storyforge-production.up.railway.app/api/tasks';
  static const String _developmentUrl = 'http://localhost:8080/api/tasks';

  static const String _userId = 'default';

  static String get _defaultBaseUrl {
    const environment = String.fromEnvironment('ENV', defaultValue: 'development');
    return environment == 'production' ? _productionUrl : _developmentUrl;
  }

  TasksService({
    String? baseUrl,
    http.Client? client,
  })  : baseUrl = baseUrl ?? _defaultBaseUrl,
        client = client ?? http.Client();

  /// Perform daily check-in and award gems
  ///
  /// POST /api/tasks/check-in
  /// Body: { userId, day, gemAmount }
  /// Returns true if successful
  Future<bool> performCheckIn({
    required int day,
    required int gemAmount,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/check-in');
      print('📅 POST $url');
      print('📤 Request: userId="$_userId", day=$day, gemAmount=$gemAmount');

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userId,
          'day': day,
          'gemAmount': gemAmount,
        }),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final success = json['success'] as bool? ?? false;

        if (success) {
          final newBalance = json['newBalance'] as int?;
          print('✅ Check-in successful! Day $day, +$gemAmount gems, balance: $newBalance');
        } else {
          final error = json['error'] as String?;
          print('⚠️ Check-in failed: $error');
        }

        return success;
      } else {
        print('❌ Check-in failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error in performCheckIn(): $e');
      return false;
    }
  }

  /// Claim achievement reward
  ///
  /// POST /api/tasks/claim-achievement
  /// Body: { userId, achievementId, gemAmount }
  /// Returns true if successful
  Future<bool> claimAchievement({
    required String achievementId,
    required int gemAmount,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/claim-achievement');
      print('🏆 POST $url');
      print('📤 Request: userId="$_userId", achievementId="$achievementId", gemAmount=$gemAmount');

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userId': _userId,
          'achievementId': achievementId,
          'gemAmount': gemAmount,
        }),
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final success = json['success'] as bool? ?? false;

        if (success) {
          final newBalance = json['newBalance'] as int?;
          print('✅ Achievement claimed! $achievementId, +$gemAmount gems, balance: $newBalance');
        } else {
          final error = json['error'] as String?;
          print('⚠️ Claim failed: $error');
        }

        return success;
      } else {
        print('❌ Claim failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error in claimAchievement(): $e');
      return false;
    }
  }

  /// Get user's current gem balance
  ///
  /// GET /api/tasks/status?userId=default
  /// Returns gem balance or null on error
  Future<int?> getGemBalance() async {
    try {
      final url = Uri.parse('$baseUrl/status?userId=$_userId');
      print('💎 GET $url');

      final response = await client.get(url);
      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        final balance = json['gemBalance'] as int?;
        print('✅ Gem balance: $balance');
        return balance;
      } else {
        print('❌ Failed to get balance: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error in getGemBalance(): $e');
      return null;
    }
  }
}
