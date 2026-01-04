import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/models/booking_model.dart';
import '../core/models/chat_message_model.dart';
import '../core/models/event_model.dart';
import '../core/models/user_behavior_model.dart';
import '../core/models/user_model.dart';
import '../core/models/user_preferences_model.dart';
import '../core/providers/recommendation_provider.dart';

/// AI Chatbot Widget for Event Recommendations
class AIChatbotWidget extends StatefulWidget {
  final UserModel user;
  final List<EventModel> allEvents;
  final List<BookingModel> userBookings;
  final Map<String, List<BookingModel>> allUserBookings;
  final UserPreferencesModel? userPreferences;
  final UserBehaviorModel? userBehavior;

  const AIChatbotWidget({
    Key? key,
    required this.user,
    required this.allEvents,
    required this.userBookings,
    required this.allUserBookings,
    this.userPreferences,
    this.userBehavior,
  }) : super(key: key);

  @override
  State<AIChatbotWidget> createState() => _AIChatbotWidgetState();
}

class _AIChatbotWidgetState extends State<AIChatbotWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _loadHistoryAndGreet();
  }

  Future<void> _loadHistoryAndGreet() async {
    final recommendationProvider =
        Provider.of<RecommendationProvider>(context, listen: false);

    // Load existing history if any
    final history = recommendationProvider.getChatHistory(widget.user.id);
    if (history.isNotEmpty) {
      setState(() => _messages.addAll(history));
      _scrollToBottom();
      return;
    }

    // Otherwise send greeting
    await _sendInitialGreeting(recommendationProvider);
  }

  Future<void> _sendInitialGreeting(
    RecommendationProvider recommendationProvider,
  ) async {
    setState(() => _isTyping = true);

    final greeting = await recommendationProvider.sendChatMessage(
      userId: widget.user.id,
      message: "Hello",
      user: widget.user,
      allEvents: widget.allEvents,
      userBookings: widget.userBookings,
      allUserBookings: widget.allUserBookings,
    );

    setState(() {
      _messages.add(greeting);
      _isTyping = false;
    });

    _scrollToBottom();
  }

  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Add user message
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: widget.user.id,
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMsg);
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // Get bot response via provider (keeps shared history alive)
    try {
      final recommendationProvider =
          Provider.of<RecommendationProvider>(context, listen: false);
      final botResponse = await recommendationProvider.sendChatMessage(
        userId: widget.user.id,
        message: message,
        user: widget.user,
        allEvents: widget.allEvents,
        userBookings: widget.userBookings,
        allUserBookings: widget.allUserBookings,
      );

      setState(() {
        _messages.add(botResponse);
        _isTyping = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() => _isTyping = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Typing indicator
          if (_isTyping) _buildTypingIndicator(),

          // Input field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.smart_toy, color: Theme.of(context).primaryColor),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Festio AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Powered by Advanced AI',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment:
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isUser)
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
                ),
              if (!isUser) SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Theme.of(context).primaryColor
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.message,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              if (isUser) SizedBox(width: 8),
              if (isUser)
                CircleAvatar(
                  radius: 16,
                  backgroundImage: widget.user.photoUrl != null
                      ? NetworkImage(widget.user.photoUrl!)
                      : null,
                  child: widget.user.photoUrl == null
                      ? Icon(Icons.person, size: 16)
                      : null,
                ),
            ],
          ),

          // Quick reply suggestions
          if (!isUser && message.suggestedResponses != null)
            Padding(
              padding: EdgeInsets.only(top: 8, left: 40),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: message.suggestedResponses!
                    .map((suggestion) => _buildQuickReply(suggestion))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickReply(String suggestion) {
    return InkWell(
      onTap: () => _sendMessage(suggestion),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).primaryColor),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          suggestion,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).primaryColor,
            child: Icon(Icons.smart_toy, size: 16, color: Colors.white),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                SizedBox(width: 4),
                _buildDot(200),
                SizedBox(width: 4),
                _buildDot(400),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int delay) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Opacity(
          opacity: (value * 2).clamp(0.0, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask me anything about events...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: _sendMessage,
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Theme.of(context).primaryColor,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: () => _sendMessage(_messageController.text),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
