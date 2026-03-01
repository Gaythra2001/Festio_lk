import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Chat message model
class ChatMessage {
  final String id;
  final String content;
  final bool isUserMessage;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final List<String>? suggestedActions;

  ChatMessage({
    required this.id,
    required this.content,
    required this.isUserMessage,
    required this.timestamp,
    this.metadata,
    this.suggestedActions,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      isUserMessage: json['is_user_message'] ?? false,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
      metadata: json['metadata'],
      suggestedActions: List<String>.from(json['suggested_actions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'is_user_message': isUserMessage,
      'timestamp': timestamp.toIso8601String(),
      'metadata': metadata,
      'suggested_actions': suggestedActions,
    };
  }
}

/// Quick action model
class QuickAction {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String intent;

  QuickAction({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.intent,
  });

  factory QuickAction.fromJson(Map<String, dynamic> json) {
    return QuickAction(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? 'help',
      intent: json['intent'] ?? '',
    );
  }
}

/// Organizer Chatbot Provider
class OrganizerChatbotProvider extends ChangeNotifier {
  static final String baseUrl = kIsWeb ? 'http://localhost:8000/api/organizer-chatbot' : 'http://10.0.2.2:8000/api/organizer-chatbot';

  final String organizerId;
  final String eventId;

  List<ChatMessage> messages = [];
  List<QuickAction> quickActions = [];
  bool isLoading = false;
  bool isTyping = false;
  String? errorMessage;

  OrganizerChatbotProvider({
    required this.organizerId,
    required this.eventId,
  });

  /// Initialize the chatbot
  Future<void> initialize() async {
    try {
      await loadQuickActions();
      
      // Add welcome message
      addMessage(
        ChatMessage(
          id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
          content: '👋 Hi! I\'m your Event Manager AI Assistant. How can I help you today?',
          isUserMessage: false,
          timestamp: DateTime.now(),
          suggestedActions: ['Use quick actions', 'Ask a question'],
        ),
      );
      
      notifyListeners();
    } catch (e) {
      errorMessage = 'Failed to initialize chatbot: $e';
      notifyListeners();
    }
  }

  /// Load quick actions from backend
  Future<void> loadQuickActions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/quick-actions'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final actionsList = data['quick_actions'] as List;
        
        quickActions = actionsList
            .map((action) => QuickAction.fromJson(action))
            .toList();
        
        notifyListeners();
      }
    } catch (e) {
      print('Error loading quick actions: $e');
    }
  }

  /// Add message to chat
  void addMessage(ChatMessage message) {
    messages.add(message);
    notifyListeners();
  }

  /// Send message to chatbot
  Future<void> sendMessage(String userMessage) async {
    if (userMessage.isEmpty) return;

    try {
      // Add user message
      addMessage(
        ChatMessage(
          id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
          content: userMessage,
          isUserMessage: true,
          timestamp: DateTime.now(),
        ),
      );

      // Show typing indicator
      isTyping = true;
      notifyListeners();

      // Send to backend
      final response = await http.post(
        Uri.parse('$baseUrl/send-message'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'organizer_id': organizerId,
          'event_id': eventId,
          'message': userMessage,
        }),
      ).timeout(const Duration(seconds: 30));

      isTyping = false;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chatResponse = data['data']['response'];

        // Add bot message
        addMessage(
          ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            content: chatResponse['message'] ?? 'No response',
            isUserMessage: false,
            timestamp: DateTime.now(),
            metadata: {
              'title': chatResponse['title'],
              'intent': data['data']['intent'],
              'metrics': chatResponse['metrics'],
              'recommendations': chatResponse['recommendations'],
              'trends': chatResponse['trends'],
            },
            suggestedActions: List<String>.from(
              chatResponse['suggested_next_actions'] ?? [],
            ),
          ),
        );

        errorMessage = null;
      } else {
        errorMessage = 'Failed to get response from chatbot';
      }

      notifyListeners();
    } catch (e) {
      isTyping = false;
      errorMessage = 'Error sending message: $e';
      notifyListeners();
    }
  }

  /// Execute quick action
  Future<void> executeQuickAction(String actionId) async {
    try {
      isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl/quick-action'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'organizer_id': organizerId,
          'event_id': eventId,
          'action_id': actionId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final chatResponse = data['data']['response'];

        // Add bot message with action result
        addMessage(
          ChatMessage(
            id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
            content: chatResponse['message'] ?? 'Action executed',
            isUserMessage: false,
            timestamp: DateTime.now(),
            metadata: {
              'title': chatResponse['title'],
              'metrics': chatResponse['metrics'],
              'recommendations': chatResponse['recommendations'],
            },
            suggestedActions: List<String>.from(
              chatResponse['suggested_next_actions'] ?? [],
            ),
          ),
        );
      }

      isLoading = false;
      notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = 'Error executing action: $e';
      notifyListeners();
    }
  }

  /// Clear chat history
  void clearHistory() {
    messages.clear();
    errorMessage = null;
    notifyListeners();
  }

  /// Detect intent from message
  Future<String> detectIntent(String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/detect-intent'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['intent'] ?? 'general_help';
      }

      return 'general_help';
    } catch (e) {
      print('Error detecting intent: $e');
      return 'general_help';
    }
  }
}
