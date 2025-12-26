import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session.dart';

/// Handles communication with the Java backend
class ChatService {
  /// Automatically determines the correct API base URL based on the current environment.
  ///
  /// Priority order:
  /// 1. Environment variable override (--dart-define=API_URL=...)
  /// 2. Debug mode → localhost (web only)
  /// 3. Production mode → Railway cloud backend
  static String get baseUrl {
    // PRIORITY 1: Check for explicit environment variable override
    // Usage: flutter run --dart-define=API_URL=http://custom.url/api/chat
    const envUrl = String.fromEnvironment('API_URL', defaultValue: '');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }

    // PRIORITY 2: Debug mode (development)
    if (kDebugMode) {
      // Web development uses localhost
      if (kIsWeb) {
        return 'http://localhost:8080/api/chat';
      } else {
        // Mobile development uses Railway production
        // (Local network IP testing requires manual override via --dart-define)
        return 'https://storyforge-production.up.railway.app/api/chat';
      }
    } else {
      // PRIORITY 3: Production mode (release builds)
      return 'https://storyforge-production.up.railway.app/api/chat';
    }
  }

  // Optional: Debug helper to see which URL is being used
  static void printCurrentEnvironment() {
    print('🌐 Using API: $baseUrl');
    print('🐛 Debug mode: $kDebugMode');
  }

  /// Send a message and get Claude's response
  Future<String?> sendMessage(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        print('Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Request failed: $e');
      return null;
    }
  }

  Future<List<Session>> getSessions() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/sessions'));

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Session.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load sessions');
      }
    } catch (e) {
      print('Error getting sessions: $e');
      rethrow;
    }
  }

  Future<Session> createNewSession(String name) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sessions'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'name': name}),
      );

      if (response.statusCode == 200) {
        return Session.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create session');
      }
    } catch (e) {
      print('Error creating session: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> switchSession(int sessionId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/sessions/$sessionId/switch'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to switch session');
      }
    } catch (e) {
      print('Error switching session: $e');
      return null;
    }
  }

  /// Reset/clear the current chat session
  Future<bool> resetChat() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset'),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Error resetting chat: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error resetting chat: $e');
      return false;
    }
  }

  /// Check if backend is running
  Future<bool> checkStatus() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/status'),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}