import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/session.dart';
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

  List<Session> _sessions = [];
  Session? _currentSession;
  bool _isLoadingSessions = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  /// Load sessions from backend
  Future<void> _loadSessions() async {
    setState(() {
      _isLoadingSessions = true;
    });

    try {
      final sessions = await _chatService.getSessions();
      setState(() {
        _sessions = sessions;
        _isLoadingSessions = false;
        // Set current session to first one if available and none selected
        if (_currentSession == null && sessions.isNotEmpty) {
          _currentSession = sessions.first;
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingSessions = false;
      });
      print('Failed to load sessions: $e');
    }
  }

  /// Create a new chat session
  Future<void> _createNewSession() async {
    final name = 'Chat ${_sessions.length + 1}';
    try {
      final session = await _chatService.createNewSession(name);
      setState(() {
        _sessions.insert(0, session);
        _currentSession = session;
        _messages.clear();
      });
      Navigator.pop(context); // Close drawer
    } catch (e) {
      print('Failed to create session: $e');
    }
  }

  /// Switch to a different session
  Future<void> _switchToSession(Session session) async {
    try {
      final response = await _chatService.switchSession(session.id);

      setState(() {
        _currentSession = session;
        _messages.clear();

        // Load messages from backend response
        if (response != null && response['messages'] != null) {
          final List<dynamic> msgs = response['messages'];
          for (var msg in msgs) {
            _messages.add(ChatMessage(
              content: msg['content'],
              isUser: msg['role'] == 'user',
            ));
          }
        }
      });

      Navigator.pop(context); // Close drawer
    } catch (e) {
      print('Error switching session: $e');
    }
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  /// Build the session drawer
  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
              color: Colors.deepPurple,
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🎭 StoryForge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_sessions.length} conversations',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // New Chat button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createNewSession,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'New Chat',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Sessions list
            Expanded(
              child: _isLoadingSessions
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : _sessions.isEmpty
                      ? Center(
                          child: Text(
                            'No conversations yet',
                            style: TextStyle(color: Colors.grey[500]),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _sessions.length,
                          itemBuilder: (context, index) {
                            final session = _sessions[index];
                            final isActive = _currentSession?.id == session.id;

                            return ListTile(
                              onTap: () => _switchToSession(session),
                              selected: isActive,
                              selectedTileColor:
                                  Colors.deepPurple.withValues(alpha: 0.3),
                              leading: Icon(
                                Icons.chat_bubble_outline,
                                color: isActive
                                    ? Colors.deepPurple[200]
                                    : Colors.grey[500],
                              ),
                              title: Text(
                                session.name,
                                style: TextStyle(
                                  color: isActive
                                      ? Colors.white
                                      : Colors.grey[300],
                                  fontWeight: isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              subtitle: Text(
                                '${session.messageCount} messages • ${_formatDate(session.createdAt)}',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

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
      // Session drawer
      drawer: _buildDrawer(),

      // App Bar
      appBar: AppBar(
        title: const Text('🎭 StoryForge'),
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
                  color: Colors.grey.withValues(alpha: 0.2),
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