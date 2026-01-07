// lib/models/chat_history.dart
class ChatHistory {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ChatMessage> messages;

  ChatHistory({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }

  factory ChatHistory.fromJson(Map<String, dynamic> json) {
    return ChatHistory(
      id: json['id'] as String,
      title: json['title'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      messages: (json['messages'] as List)
          .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }

  String get previewText {
    if (messages.isEmpty) return 'No messages';
    final firstUserMessage = messages.firstWhere(
      (m) => m.role == 'user',
      orElse: () => messages.first,
    );
    return firstUserMessage.text.length > 50
        ? '${firstUserMessage.text.substring(0, 50)}...'
        : firstUserMessage.text;
  }
}

class ChatMessage {
  final String role; // 'user' or 'ai'
  final String text;
  final String? imagePath;

  ChatMessage({
    required this.role,
    required this.text,
    this.imagePath,
  });

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'text': text,
      'imagePath': imagePath,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] as String,
      text: json['text'] as String,
      imagePath: json['imagePath'] as String?,
    );
  }
}

