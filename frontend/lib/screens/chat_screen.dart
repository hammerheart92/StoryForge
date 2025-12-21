import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Our services and data
  final ChatService _chatService = ChatService();
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();

  // Track if we're waiting for Claude
  bool _isLoading = false;

  /// Send message to backend and get response
  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    // Clear input field
    _textController.clear();

    // Add user message to list
    setState(() {
      _messages.add(ChatMessage(content: text, isUser: true));
      _isLoading = true;
    });

    // Send to backend and get Claude's response
    final response = await _chatService.sendMessage(text);

    setState(() {
      _isLoading = false;
      if (response != null) {
        _messages.add(ChatMessage(content: response, isUser: false));
      } else {
        _messages.add(ChatMessage(
          content: 'Error: Could not get response. Is the backend running?',
          isUser: false,
        ));
      }
    });
  }

  /// Reset the conversation
  Future<void> _resetChat() async {
    final success = await _chatService.resetChat();
    if (success) {
      setState(() {
        _messages.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App Bar
      appBar: AppBar(
        title: const Text('🎭 ScenarioChat'),
        backgroundColor: Colors.greenAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetChat,
            tooltip: 'Reset conversation',
          ),
        ],
      ),

      // Body
      body: Column(
        children: [
          // Chat messages list
          Expanded(
            child: _messages.isEmpty
                ? const Center(
              child: Text(
                'Start a conversation!\nTry: "A wizard enters a dark cave"',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Claude is thinking...'),
                ],
              ),
            ),

          // Input area
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Text input
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                // Send button
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                  color: Colors.deepPurple,
                  iconSize: 28,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build a single message bubble
  Widget _buildMessageBubble(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.deepPurple : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}