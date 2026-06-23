class ChatMessage {
  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    // Normalize role — handles "User", "user", "USER", "Assistant", etc.
    final role = (json['role'] as String? ?? '').toLowerCase().trim();

    // Support both 'message' and 'content' field names
    final content =
        (json['message'] as String?)?.trim() ??
        (json['content'] as String?)?.trim() ??
        (json['reply'] as String?)?.trim() ??
        (json['response'] as String?)?.trim() ??
        '';

    return ChatMessage(
      id:
          json['id']?.toString() ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isUser: role == 'user',
      timestamp: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
    );
  }

  final String id;
  final String content;
  final bool isUser;
  final DateTime? timestamp;
}

class ChatSession {
  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    this.createdAt,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id:
          json['id'] as String? ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'New Chat',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime? createdAt;
}
