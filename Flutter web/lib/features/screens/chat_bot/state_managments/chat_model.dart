class ChatMessage {
  ChatMessage({
    required this.id,
    required this.content,
    required this.isUser,
    this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final role = (json['role'] as String? ?? '').toLowerCase().trim();

    // API returns {response: "..."} as wrapper — check that first
    final content =
        (json['response'] as String?)?.trim() ??
        (json['message'] as String?)?.trim() ??
        (json['content'] as String?)?.trim() ??
        (json['reply'] as String?)?.trim() ??
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'isUser': isUser,
    'timestamp': timestamp?.toIso8601String(),
  };

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

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'createdAt': createdAt?.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime? createdAt;
}
