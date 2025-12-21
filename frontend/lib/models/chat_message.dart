/// Represents a single chat message
class ChatMessage {
  final String content;
  final bool isUser;  // true = user message, false = Claude's response
  final DateTime timestamp;

  ChatMessage({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
}) : timestamp = timestamp ?? DateTime.now();
}