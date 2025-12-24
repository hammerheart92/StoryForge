import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/session.dart';

/// Handles communication with the Java backend
class ChatService {
  // Your Java backend URL
  static const String baseUrl = 'http://localhost:8080/api/chat';

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

  /// Reset conversation history
  Future<bool> resetChat() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reset'),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Reset failed: $e');
      return false;
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
        return json.decode(response.body);  // ← Return the data!
      } else {
        throw Exception('Failed to switch session');
      }
    } catch (e) {
      print('Error switching session: $e');
      return null;
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