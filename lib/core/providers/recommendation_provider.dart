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
  final AdvancedRecommendationEngine _advancedEngine =
      AdvancedRecommendationEngine();
  final AIEventChatbotService _chatbotService = AIEventChatbotService();
  final UserBehaviorTrackingService _behaviorService =
      UserBehaviorTrackingService();

  List<ScoredEvent> _recommendations = [];
  List<EventModel> _legacyRecommendations = [];
  UserPreferencesModel? _userPreferences;
  UserBehaviorModel? _userBehavior;
  bool _isLoading = false;
  bool _useAdvancedEngine = true;

  List<ScoredEvent> get recommendations => _recommendations;
  List<EventModel> get legacyRecommendations => _legacyRecommendations;
  UserPreferencesModel? get userPreferences => _userPreferences;
  UserBehaviorModel? get userBehavior => _userBehavior;
  bool get isLoading => _isLoading;
  bool get useAdvancedEngine => _useAdvancedEngine;

  /// Toggle between advanced and legacy engines
  void toggleEngine() {
    _useAdvancedEngine = !_useAdvancedEngine;
    notifyListeners();
  }

  /// Load user preferences
  Future<void> loadUserPreferences(String userId) async {
    if (!useFirebase) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(userId)
          .get();

      if (doc.exists) {
        _userPreferences = UserPreferencesModel.fromMap(doc.data()!);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user preferences: $e');
    }
  }

  /// Load user behavior
  Future<void> loadUserBehavior(String userId) async {
    try {
      _userBehavior = await _behaviorService.getUserBehavior(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading user behavior: $e');
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(
      String userId, UserPreferencesModel preferences) async {
    try {
      if (useFirebase) {
        await FirebaseFirestore.instance
            .collection('user_preferences')
            .doc(userId)
            .set(preferences.toMap());
      }
      _userPreferences = preferences;
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving user preferences: $e');
      rethrow;
    }
  }

  /// Load advanced recommendations
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
      if (_userPreferences == null) {
        await loadUserPreferences(user.id);
      }
      if (_userBehavior == null) {
        await loadUserBehavior(user.id);
      }

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

  /// Load recommendations (legacy or advanced)
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
        await loadAdvancedRecommendations(
          user: user,
          allEvents: allEvents,
          userBookings: userBookings,
          allUserBookings: allUserBookings,
        );
      } else {
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

  // ================= CHATBOT METHODS =================

  Future<ChatMessage> sendChatMessage({
    required String userId,
    required String message,
    required UserModel user,
    required List<EventModel> allEvents,
    required List<BookingModel> userBookings,
    required Map<String, List<BookingModel>> allUserBookings,
  }) async {
    return _chatbotService.processMessage(
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

  List<ChatMessage> getChatHistory(String userId) {
    return _chatbotService.getConversationHistory(userId);
  }

  void clearChatHistory(String userId) {
    _chatbotService.clearHistory(userId);
    notifyListeners();
  }

  // ================= BEHAVIOR TRACKING =================

  Future<void> trackEventView(String userId, EventModel event) async {
    await _behaviorService.trackEventView(userId, event);
  }

  Future<void> trackEventViewEnd(String userId, String eventId) async {
    await _behaviorService.trackEventViewEnd(userId, eventId);
  }

  Future<void> trackEventClick(String userId, EventModel event) async {
    await _behaviorService.trackEventClick(userId, event);
  }

  Future<void> trackSearch(String userId, String query) async {
    await _behaviorService.trackSearch(userId, query);
  }

  Future<void> trackBooking(
      String userId, BookingModel booking, EventModel event) async {
    await _behaviorService.trackBooking(userId, booking, event);
  }

  Future<void> trackSessionStart(String userId) async {
    await _behaviorService.trackSessionStart(userId);
  }

  Future<void> trackSessionEnd(String userId) async {
    await _behaviorService.trackSessionEnd(userId);
  }

  Future<Map<String, dynamic>> getUserAnalytics(String userId) async {
    return _behaviorService.getUserEngagementAnalytics(userId);
  }

  Future<void> initializeBehaviorTracking(String userId) async {
    await _behaviorService.initializeUserBehavior(userId);
  }

  // ================= UTILITIES =================

  bool hasCompletedPreferences() {
    return _userPreferences?.isComplete ?? false;
  }

  String getRecommendationExplanation(String eventId) {
    final scoredEvent = _recommendations.firstWhere(
      (r) => r.event.id == eventId,
      orElse: () => _recommendations.first,
    );
    return scoredEvent.getExplanation();
  }

  List<ScoredEvent> getHighConfidenceRecommendations(
      {double threshold = 0.7}) {
    return _recommendations.where((r) => r.score >= threshold).toList();
  }

  void clearCache() {
    _recommendations = [];
    _legacyRecommendations = [];
    _userPreferences = null;
    _userBehavior = null;
    notifyListeners();
  }
}
