import 'package:cloud_firestore/cloud_firestore.dart';

/// Chat Message Model for the AI Chatbot
class ChatMessage {
  final String id;
  final String userId;
  final String message;
  final bool isUser; // true if message from user, false if from bot
  final DateTime timestamp;
  final String? intent; // Detected intent: 'event_search', 'recommendation', 'booking_help', etc.
  final Map<String, dynamic>? metadata; // Additional context
  final List<String>? suggestedResponses; // Quick reply options

  ChatMessage({
    required this.id,
    required this.userId,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.intent,
    this.metadata,
    this.suggestedResponses,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map, String id) {
    return ChatMessage(
      id: id,
      userId: map['userId'] ?? '',
      message: map['message'] ?? '',
      isUser: map['isUser'] ?? true,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      intent: map['intent'],
      metadata: map['metadata'] != null ? Map<String, dynamic>.from(map['metadata']) : null,
      suggestedResponses: map['suggestedResponses'] != null
          ? List<String>.from(map['suggestedResponses'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'message': message,
      'isUser': isUser,
      'timestamp': Timestamp.fromDate(timestamp),
      'intent': intent,
      'metadata': metadata,
      'suggestedResponses': suggestedResponses,
    };
  }
}
