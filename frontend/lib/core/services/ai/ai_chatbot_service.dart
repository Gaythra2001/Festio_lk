import 'dart:math';
import '../../models/chat_message_model.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../models/user_preferences_model.dart';
import '../../models/user_behavior_model.dart';
import '../../models/booking_model.dart';
import 'advanced_recommendation_engine.dart';

/// AI-Powered Chatbot Service for Event Recommendations and User Assistance
/// Uses Natural Language Processing and Context-Aware Dialogue Management
class AIEventChatbotService {
  final AdvancedRecommendationEngine _recommendationEngine =
      AdvancedRecommendationEngine();

  // Conversation context (session-based memory)
  final Map<String, List<ChatMessage>> _conversationHistory = {};
  final Map<String, Map<String, dynamic>> _userContext = {};

  /// Process user message and generate AI response
  Future<ChatMessage> processMessage({
    required String userId,
    required String userMessage,
    required UserModel user,
    required List<EventModel> allEvents,
    required List<dynamic> userBookings,
    required Map<String, List<dynamic>> allUserBookings,
    UserPreferencesModel? userPreferences,
    UserBehaviorModel? userBehavior,
  }) async {
    // Store user message in history
    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      message: userMessage,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _addToHistory(userId, userMsg);

    // Analyze intent using NLP
    final intent = await _detectIntent(userMessage, userId);
    final entities = _extractEntities(userMessage);

    // Update user context
    _updateContext(userId, intent, entities);

    // Generate appropriate response based on intent
    String botResponse;
    List<String>? suggestions;
    Map<String, dynamic>? metadata;

    switch (intent) {
      case 'greeting':
        botResponse = _generateGreeting(user);
        suggestions = [
          'Show me events near me',
          'What\'s happening this weekend?',
          'Recommend music events',
        ];
        break;

      case 'event_search':
        final searchResults = await _handleEventSearch(
          userMessage,
          allEvents,
          entities,
        );
        botResponse = _formatEventSearchResponse(searchResults, entities);
        metadata = {'events': searchResults.map((e) => e.id).toList()};
        suggestions = _generateSearchSuggestions(entities);
        break;

      case 'recommendation_request':
        final recommendations = await _handleRecommendationRequest(
          user,
          allEvents,
          userBookings,
          allUserBookings,
          userPreferences,
          userBehavior,
          entities,
        );
        botResponse = _formatRecommendationResponse(recommendations);
        metadata = {'events': recommendations.map((e) => e.event.id).toList()};
        suggestions = ['Show me more', 'Different category', 'Filter by date'];
        break;

      case 'event_details':
        botResponse = _handleEventDetailsQuery(userMessage, allEvents);
        suggestions = ['Book this event', 'Similar events', 'Go back'];
        break;

      case 'booking_help':
        botResponse = _handleBookingHelp(userMessage);
        suggestions = [
          'How to book?',
          'Payment options',
          'Cancellation policy'
        ];
        break;

      case 'preference_update':
        botResponse = _handlePreferenceUpdate(entities);
        suggestions = ['Update location', 'Update budget', 'Update interests'];
        break;

      case 'general_question':
        botResponse = _handleGeneralQuestion(userMessage);
        suggestions = ['Tell me more', 'Show events', 'Go to home'];
        break;

      case 'feedback':
        botResponse = _handleFeedback(userMessage);
        suggestions = ['Rate another event', 'Browse events', 'Done'];
        break;

      default:
        botResponse = _generateFallbackResponse(userMessage);
        suggestions = ['Show recommendations', 'Search events', 'Help'];
    }

    // Create bot response message
    final botMsg = ChatMessage(
      id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
      userId: userId,
      message: botResponse,
      isUser: false,
      timestamp: DateTime.now(),
      intent: intent,
      metadata: metadata,
      suggestedResponses: suggestions,
    );

    _addToHistory(userId, botMsg);

    return botMsg;
  }

  /// Detect user intent from message
  Future<String> _detectIntent(String message, String userId) async {
    final msg = message.toLowerCase();

    // Greeting patterns
    if (RegExp(r'\b(hi|hello|hey|greetings|good morning|good afternoon)\b')
        .hasMatch(msg)) {
      return 'greeting';
    }

    // Event search patterns
    if (RegExp(
            r'\b(search|find|look for|show me|events? in|events? at|events? on)\b')
        .hasMatch(msg)) {
      return 'event_search';
    }

    // Recommendation patterns
    if (RegExp(r'\b(recommend|suggest|what should|popular|trending|best)\b')
        .hasMatch(msg)) {
      return 'recommendation_request';
    }

    // Event details patterns
    if (RegExp(
            r'\b(tell me more|details|about this|what is|when is|where is)\b')
        .hasMatch(msg)) {
      return 'event_details';
    }

    // Booking help patterns
    if (RegExp(r'\b(book|reserve|ticket|buy|purchase|how to book|booking)\b')
        .hasMatch(msg)) {
      return 'booking_help';
    }

    // Preference update patterns
    if (RegExp(
            r'\b(i like|i prefer|my favorite|i want|interested in|change preferences)\b')
        .hasMatch(msg)) {
      return 'preference_update';
    }

    // Feedback patterns
    if (RegExp(r'\b(rate|review|feedback|loved|hated|amazing|terrible)\b')
        .hasMatch(msg)) {
      return 'feedback';
    }

    // General questions
    if (RegExp(r'\b(what|when|where|who|how|why|can you|could you)\b')
        .hasMatch(msg)) {
      return 'general_question';
    }

    return 'unknown';
  }

  /// Extract entities (locations, dates, categories, etc.) from message
  Map<String, dynamic> _extractEntities(String message) {
    final entities = <String, dynamic>{};
    final msg = message.toLowerCase();

    // Extract event categories
    final categories = [
      'music',
      'religious',
      'cultural',
      'sports',
      'educational',
      'festival',
      'art',
      'food'
    ];
    for (final category in categories) {
      if (msg.contains(category)) {
        entities['category'] = category;
        break;
      }
    }

    // Extract locations (example Sri Lankan locations)
    final locations = [
      'colombo',
      'kandy',
      'galle',
      'jaffna',
      'negombo',
      'anuradhapura',
      'trincomalee'
    ];
    for (final location in locations) {
      if (msg.contains(location)) {
        entities['location'] = location;
        break;
      }
    }

    // Extract time references
    if (msg.contains('today')) {
      entities['when'] = 'today';
    } else if (msg.contains('tomorrow')) {
      entities['when'] = 'tomorrow';
    } else if (RegExp(r'this (weekend|week|month)').hasMatch(msg)) {
      final match = RegExp(r'this (weekend|week|month)').firstMatch(msg);
      entities['when'] = 'this_${match?.group(1)}';
    }

    // Extract budget
    final budgetMatch = RegExp(r'(\d+)\s*(lkr|rupees?|rs)').firstMatch(msg);
    if (budgetMatch != null) {
      entities['budget'] = int.parse(budgetMatch.group(1)!);
    }

    // Extract number (for "show me 5 events")
    final numberMatch = RegExp(r'\b(\d+)\s+events?').firstMatch(msg);
    if (numberMatch != null) {
      entities['count'] = int.parse(numberMatch.group(1)!);
    }

    // Extract free vs paid
    if (msg.contains('free')) {
      entities['price'] = 'free';
    } else if (msg.contains('paid')) {
      entities['price'] = 'paid';
    }

    return entities;
  }

  /// Update conversation context
  void _updateContext(
      String userId, String intent, Map<String, dynamic> entities) {
    if (!_userContext.containsKey(userId)) {
      _userContext[userId] = {};
    }

    _userContext[userId]!['lastIntent'] = intent;
    _userContext[userId]!['entities'] = entities;
    _userContext[userId]!['timestamp'] = DateTime.now();
  }

  /// Handle event search
  Future<List<EventModel>> _handleEventSearch(
    String message,
    List<EventModel> allEvents,
    Map<String, dynamic> entities,
  ) async {
    var results = allEvents.where((e) => e.isApproved && !e.isSpam).toList();

    // Filter by category
    if (entities.containsKey('category')) {
      final category = entities['category'] as String;
      results = results
          .where((e) => e.category.toLowerCase().contains(category))
          .toList();
    }

    // Filter by location
    if (entities.containsKey('location')) {
      final location = entities['location'] as String;
      results = results
          .where((e) => e.location.toLowerCase().contains(location))
          .toList();
    }

    // Filter by time
    final now = DateTime.now();
    if (entities.containsKey('when')) {
      switch (entities['when']) {
        case 'today':
          results = results
              .where((e) =>
                  e.startDate.year == now.year &&
                  e.startDate.month == now.month &&
                  e.startDate.day == now.day)
              .toList();
          break;
        case 'tomorrow':
          final tomorrow = now.add(Duration(days: 1));
          results = results
              .where((e) =>
                  e.startDate.year == tomorrow.year &&
                  e.startDate.month == tomorrow.month &&
                  e.startDate.day == tomorrow.day)
              .toList();
          break;
        case 'this_weekend':
          final nextSaturday = now.add(Duration(days: (6 - now.weekday) % 7));
          final nextSunday = nextSaturday.add(Duration(days: 1));
          results = results
              .where((e) =>
                  e.startDate
                      .isAfter(nextSaturday.subtract(Duration(days: 1))) &&
                  e.startDate.isBefore(nextSunday.add(Duration(days: 1))))
              .toList();
          break;
      }
    }

    // Filter by price
    if (entities.containsKey('price')) {
      if (entities['price'] == 'free') {
        results = results
            .where((e) => e.ticketPrice == null || e.ticketPrice == 0)
            .toList();
      }
    }

    // Filter by budget
    if (entities.containsKey('budget')) {
      final budget = entities['budget'] as int;
      results = results.where((e) => (e.ticketPrice ?? 0) <= budget).toList();
    }

    // Sort by date (soonest first)
    results.sort((a, b) => a.startDate.compareTo(b.startDate));

    // Limit results
    final count =
        entities.containsKey('count') ? (entities['count'] as int) : 5;
    return results.take(count).toList();
  }

  /// Handle recommendation request
  Future<List<ScoredEvent>> _handleRecommendationRequest(
    UserModel user,
    List<EventModel> allEvents,
    List<dynamic> userBookings,
    Map<String, List<dynamic>> allUserBookings,
    UserPreferencesModel? userPreferences,
    UserBehaviorModel? userBehavior,
    Map<String, dynamic> entities,
  ) async {
    // Convert dynamic lists to typed lists
    final typedBookings = userBookings.whereType<BookingModel>().toList();
    final typedAllBookings = allUserBookings.map(
      (key, value) => MapEntry(key, value.whereType<BookingModel>().toList()),
    );

    var recommendations = _recommendationEngine.getPersonalizedRecommendations(
      user: user,
      allEvents: allEvents,
      userBookings: typedBookings,
      allUserBookings: typedAllBookings,
      userPreferences: userPreferences,
      userBehavior: userBehavior,
      maxRecommendations:
          entities.containsKey('count') ? (entities['count'] as int) : 10,
    );

    // Filter by entities if provided
    if (entities.containsKey('category')) {
      final category = entities['category'] as String;
      recommendations = recommendations
          .where((r) => r.event.category.toLowerCase().contains(category))
          .toList();
    }

    return recommendations;
  }

  /// Format event search response
  String _formatEventSearchResponse(
      List<EventModel> events, Map<String, dynamic> entities) {
    if (events.isEmpty) {
      return "I couldn't find any events matching your criteria. Try adjusting your search or let me recommend something for you!";
    }

    String response =
        "I found ${events.length} event${events.length > 1 ? 's' : ''} for you:\n\n";

    for (int i = 0; i < min(events.length, 3); i++) {
      final event = events[i];
      response += "${i + 1}. **${event.title}**\n";
      response += "   📅 ${_formatDate(event.startDate)}\n";
      response += "   📍 ${event.location}\n";
      if (event.ticketPrice != null && event.ticketPrice! > 0) {
        response += "   💰 LKR ${event.ticketPrice!.toStringAsFixed(0)}\n";
      } else {
        response += "   💰 Free\n";
      }
      response += "\n";
    }

    if (events.length > 3) {
      response += "... and ${events.length - 3} more events!";
    }

    return response;
  }

  /// Format recommendation response
  String _formatRecommendationResponse(List<ScoredEvent> recommendations) {
    if (recommendations.isEmpty) {
      return "I don't have enough information yet to personalize recommendations. Browse some events and I'll learn your preferences!";
    }

    String response = "Based on your interests, I recommend:\n\n";

    for (int i = 0; i < min(recommendations.length, 3); i++) {
      final scored = recommendations[i];
      final event = scored.event;

      response += "${i + 1}. **${event.title}**\n";
      response += "   📅 ${_formatDate(event.startDate)}\n";
      response += "   📍 ${event.location}\n";
      response += "   ✨ ${scored.getExplanation()}\n";
      response += "\n";
    }

    if (recommendations.length > 3) {
      response +=
          "I have ${recommendations.length - 3} more great suggestions for you!";
    }

    return response;
  }

  /// Generate greeting
  String _generateGreeting(UserModel user) {
    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour < 12) {
      timeGreeting = "Good morning";
    } else if (hour < 17) {
      timeGreeting = "Good afternoon";
    } else {
      timeGreeting = "Good evening";
    }

    final name = user.displayName ?? 'there';
    return "$timeGreeting, $name! 👋 I'm your Festio event assistant. I can help you discover amazing events, get personalized recommendations, and answer questions. What are you looking for today?";
  }

  /// Generate fallback response
  String _generateFallbackResponse(String message) {
    final fallbacks = [
      "I'm not sure I understand. Could you rephrase that?",
      "Hmm, I didn't quite get that. Can you try asking differently?",
      "I'm still learning! Could you ask me about events, recommendations, or bookings?",
    ];
    return fallbacks[Random().nextInt(fallbacks.length)];
  }

  /// Handle event details query
  String _handleEventDetailsQuery(String message, List<EventModel> allEvents) {
    return "To see detailed information about an event, please select it from the list above. I can show you the full description, venue details, ticket prices, and more!";
  }

  /// Handle booking help
  String _handleBookingHelp(String message) {
    return """**Booking Help** 🎫

To book an event:
1. Find an event you like
2. Tap on it to see details
3. Click the 'Book Now' button
4. Select number of tickets
5. Complete the booking

**Payment**: We accept credit cards, debit cards, and mobile payments.
**Cancellation**: You can cancel up to 24 hours before the event for a full refund.

Need specific help? Just ask!""";
  }

  /// Handle preference update
  String _handlePreferenceUpdate(Map<String, dynamic> entities) {
    String response = "I've noted your preferences! ";

    if (entities.containsKey('category')) {
      response += "I'll remember you like ${entities['category']} events. ";
    }
    if (entities.containsKey('location')) {
      response += "I'll focus on events in ${entities['location']}. ";
    }
    if (entities.containsKey('budget')) {
      response += "I'll look for events under LKR ${entities['budget']}. ";
    }

    response += "This will help me give you better recommendations!";
    return response;
  }

  /// Handle general questions
  String _handleGeneralQuestion(String message) {
    final msg = message.toLowerCase();

    if (msg.contains('how') && msg.contains('work')) {
      return "Festio helps you discover and book amazing events in Sri Lanka! I use AI to learn your preferences and recommend events you'll love. Just browse, book, and enjoy!";
    }

    if (msg.contains('free')) {
      return "Yes! Many events on Festio are free. Just ask me to 'show free events' and I'll find them for you.";
    }

    if (msg.contains('location') || msg.contains('where')) {
      return "We have events all across Sri Lanka - Colombo, Kandy, Galle, Jaffna, and more! Tell me your preferred location and I'll find events there.";
    }

    return "I'm here to help you find and book events! Ask me about upcoming events, recommendations, or how to book.";
  }

  /// Handle feedback
  String _handleFeedback(String message) {
    return "Thank you for your feedback! 🙏 Your input helps us improve Festio and provide better event recommendations. Is there anything else I can help you with?";
  }

  /// Generate search suggestions
  List<String> _generateSearchSuggestions(Map<String, dynamic> entities) {
    final suggestions = <String>[];

    if (!entities.containsKey('category')) {
      suggestions.add('Show music events');
    }
    if (!entities.containsKey('when')) {
      suggestions.add('This weekend');
    }
    if (!entities.containsKey('price')) {
      suggestions.add('Free events');
    }

    return suggestions.isEmpty
        ? ['Show more', 'Recommend for me', 'Filter']
        : suggestions;
  }

  /// Format date for display
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  /// Add message to conversation history
  void _addToHistory(String userId, ChatMessage message) {
    if (!_conversationHistory.containsKey(userId)) {
      _conversationHistory[userId] = [];
    }
    _conversationHistory[userId]!.add(message);

    // Keep only last 20 messages
    if (_conversationHistory[userId]!.length > 20) {
      _conversationHistory[userId]!.removeAt(0);
    }
  }

  /// Get conversation history for user
  List<ChatMessage> getConversationHistory(String userId) {
    return _conversationHistory[userId] ?? [];
  }

  /// Clear conversation history
  void clearHistory(String userId) {
    _conversationHistory.remove(userId);
    _userContext.remove(userId);
  }
}
