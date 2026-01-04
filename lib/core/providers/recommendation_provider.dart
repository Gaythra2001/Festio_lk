import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/user_preferences_model.dart';
import '../models/user_behavior_model.dart';
import '../models/chat_message_model.dart';
import '../services/ai/recommendation_engine.dart';
import '../services/ai/advanced_recommendation_engine.dart';
import '../services/ai/ai_chatbot_service.dart';
import '../services/behavior_tracking_service.dart';
import '../config/app_config.dart';

/// Enhanced Recommendation Provider with Advanced AI and Chatbot Integration
class RecommendationProvider with ChangeNotifier {
  final RecommendationEngine _legacyEngine = RecommendationEngine();
  final AdvancedRecommendationEngine _advancedEngine = AdvancedRecommendationEngine();
  final AIEventChatbotService _chatbotService = AIEventChatbotService();
  final UserBehaviorTrackingService _behaviorService = UserBehaviorTrackingService();
  FirebaseFirestore? get _firestore => useFirebase ? FirebaseFirestore.instance : null;
  
  List<ScoredEvent> _recommendations = [];
  List<EventModel> _legacyRecommendations = [];
  UserPreferencesModel? _userPreferences;
  UserBehaviorModel? _userBehavior;
  bool _isLoading = false;
  bool _useAdvancedEngine = true; // Toggle between old and new engine

  List<ScoredEvent> get recommendations => _recommendations;
  List<EventModel> get legacyRecommendations => _legacyRecommendations;
  UserPreferencesModel? get userPreferences => _userPreferences;
  UserBehaviorModel? get userBehavior => _userBehavior;
  bool get isLoading => _isLoading;
  bool get useAdvancedEngine => _useAdvancedEngine;

  /// Toggle between advanced and legacy recommendation engine
  void toggleEngine() {
    _useAdvancedEngine = !_useAdvancedEngine;
    notifyListeners();
  }

  /// Load user preferences
  Future<void> loadUserPreferences(String userId) async {
    try {
      final doc = await _firestore.collection('user_preferences').doc(userId).get();
      if (doc.exists) {
        _userPreferences = UserPreferencesModel.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }
  }

  /// Load user behavior data
  Future<void> loadUserBehavior(String userId) async {
    try {
      _userBehavior = await _behaviorService.getUserBehavior(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user behavior: $e');
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(String userId, UserPreferencesModel preferences) async {
    try {
      await _firestore.collection('user_preferences').doc(userId).set(preferences.toMap());
      _userPreferences = preferences;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
      rethrow;
    }
  }

  /// Load advanced personalized recommendations
  Future<void> loadAdvancedRecommendations({
    required UserModel user,
    required List<EventModel> allEvents,
    required List<BookingModel> userBookings,
    required Map<String, List<BookingModel>> allUserBookings,
    String? currentLocation,
    int maxRecommendations = 20,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Load user data if not already loaded
      if (_userPreferences == null) {
        await loadUserPreferences(user.id);
      }
      if (_userBehavior == null) {
        await loadUserBehavior(user.id);
      }

      // Get advanced recommendations
      _recommendations = _advancedEngine.getPersonalizedRecommendations(
        user: user,
        allEvents: allEvents,
        userBookings: userBookings,
        allUserBookings: allUserBookings,
        userPreferences: _userPreferences,
        userBehavior: _userBehavior,
        currentLocation: currentLocation,
        maxRecommendations: maxRecommendations,
        explainRecommendations: true,
      );
    } catch (e) {
      debugPrint('Error loading advanced recommendations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load legacy recommendations (backwards compatibility)
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
      if (_useAdvancedEngine) {
        // Use advanced engine
        await loadAdvancedRecommendations(
          user: user,
          allEvents: allEvents,
          userBookings: userBookings,
          allUserBookings: allUserBookings,
        );
      } else {
        // Use legacy engine
        _legacyRecommendations = _legacyEngine.getHybridRecommendations(
          user,
          allEvents,
          userBookings,
          allUserBookings,
          searchQuery,
        );
      }
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

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
  Future<void> trackBooking(String userId, BookingModel booking, EventModel event) async {
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
}

