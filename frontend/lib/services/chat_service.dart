import 'dart:convert';
import 'package:http/http.dart' as http;

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