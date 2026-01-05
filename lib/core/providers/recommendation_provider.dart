import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../services/ai/recommendation_engine.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationEngine _engine = RecommendationEngine();
  
  List<EventModel> _recommendations = [];
  bool _isLoading = false;

  List<EventModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;

  Future<void> loadRecommendations({
    required UserModel user,
    required List<EventModel> allEvents,
    required List<BookingModel> userBookings,
    required Map<String, List<BookingModel>> allUserBookings,
    String? searchQuery,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _recommendations = _engine.getHybridRecommendations(
        user,
        allEvents,
        userBookings,
        allUserBookings,
        searchQuery,
      );
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
<<<<<<< Updated upstream
=======

  // ============ CHATBOT METHODS ============

  /// Send message to chatbot and get response
  Future<ChatMessage> sendChatMessage({
    required String userId,
    required String message,
    required UserModel user,
    required List<EventModel> allEvents,
    required List<BookingModel> userBookings,
    required Map<String, List<BookingModel>> allUserBookings,
  }) async {
    return await _chatbotService.processMessage(
      userId: userId,
      userMessage: message,
      user: user,
      allEvents: allEvents,
      userBookings: userBookings,
      allUserBookings: allUserBookings,
      userPreferences: _userPreferences,
      userBehavior: _userBehavior,
    );
  }

  /// Get chatbot conversation history
  List<ChatMessage> getChatHistory(String userId) {
    return _chatbotService.getConversationHistory(userId);
  }

  /// Clear chatbot history
  void clearChatHistory(String userId) {
    _chatbotService.clearHistory(userId);
    notifyListeners();
  }

  // ============ BEHAVIOR TRACKING METHODS ============

  /// Track event view
  Future<void> trackEventView(String userId, EventModel event) async {
    await _behaviorService.trackEventView(userId, event);
  }

  /// Track event view end (calculate time spent)
  Future<void> trackEventViewEnd(String userId, String eventId) async {
    await _behaviorService.trackEventViewEnd(userId, eventId);
  }

  /// Track event click
  Future<void> trackEventClick(String userId, EventModel event) async {
    await _behaviorService.trackEventClick(userId, event);
  }

  /// Track search query
  Future<void> trackSearch(String userId, String query) async {
    await _behaviorService.trackSearch(userId, query);
  }

  /// Track booking
  Future<void> trackBooking(
      String userId, BookingModel booking, EventModel event) async {
    await _behaviorService.trackBooking(userId, booking, event);
  }

  /// Track session start
  Future<void> trackSessionStart(String userId) async {
    await _behaviorService.trackSessionStart(userId);
  }

  /// Track session end
  Future<void> trackSessionEnd(String userId) async {
    await _behaviorService.trackSessionEnd(userId);
  }

  /// Get user engagement analytics
  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    return await _behaviorService.getUserEngagementAnalytics(userId);
  }

  /// Initialize behavior tracking for new user
  Future<void> initializeBehaviorTracking(String userId) async {
    await _behaviorService.initializeUserBehavior(userId);
  }

  // ============ UTILITY METHODS ============

  /// Check if user has completed preferences
  bool hasCompletedPreferences() {
    return _userPreferences?.isComplete ?? false;
  }

  /// Get recommendation explanation for event
  String getRecommendationExplanation(String eventId) {
    final scoredEvent = _recommendations.firstWhere(
      (r) => r.event.id == eventId,
      orElse: () => _recommendations.first,
    );
    return scoredEvent.getExplanation();
  }

  /// Get events by score threshold
  List<ScoredEvent> getHighConfidenceRecommendations({double threshold = 0.7}) {
    return _recommendations.where((r) => r.score >= threshold).toList();
  }

  /// Clear all cached data
  void clearCache() {
    _recommendations = [];
    _legacyRecommendations = [];
    _userPreferences = null;
    _userBehavior = null;
    notifyListeners();
  }

  /// Save preferences and generate recommendations in one call
  Future<void> savePreferencesAndGetRecommendations({
    required String userId,
    required Map<String, dynamic> preferences,
    required UserModel user,
    required List<EventModel> allEvents,
    required List<BookingModel> userBookings,
    required Map<String, List<BookingModel>> allUserBookings,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Convert map to UserPreferencesModel
      final userPreferences = UserPreferencesModel.fromMap(preferences);

      // Save preferences
      await saveUserPreferences(userId, userPreferences);

      // Load recommendations
      await loadAdvancedRecommendations(
        user: user,
        allEvents: allEvents,
        userBookings: userBookings,
        allUserBookings: allUserBookings,
        maxRecommendations: 20,
      );
    } catch (e) {
      debugPrint('Error saving preferences and getting recommendations: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }
>>>>>>> Stashed changes
}

