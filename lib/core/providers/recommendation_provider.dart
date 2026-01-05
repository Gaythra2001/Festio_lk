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
    if (!useFirebase) {
      debugPrint('⚠️ Firebase disabled - skipping preference load');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        _userPreferences = UserPreferencesModel.fromMap(doc.data()!);
        debugPrint(
            '✅ User preferences loaded (${_userPreferences!.completionPercentage.toStringAsFixed(1)}% complete)');
        notifyListeners();
      } else {
        debugPrint('ℹ️ No existing preferences found for user $userId');
        _userPreferences = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error loading user preferences: $e');
      _userPreferences = null;
      notifyListeners();
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
  Future<void> saveUserPreferences(
      String userId, UserPreferencesModel preferences) async {
    try {
      // Calculate completion percentage
      final completionPercentage = _calculateCompletionPercentage(preferences);
      final isComplete =
          completionPercentage >= 60.0; // 60% minimum for completion

      // Update preferences with completion data and timestamp
      final updatedPreferences = preferences.copyWith(
        updatedAt: DateTime.now(),
        isComplete: isComplete,
        completionPercentage: completionPercentage,
      );

      // Validate preferences
      _validatePreferences(updatedPreferences);

      // Save to Firebase if enabled
      if (useFirebase) {
        await FirebaseFirestore.instance
            .collection('user_preferences')
            .doc(userId)
            .set(updatedPreferences.toMap());
      }

      // Always update local state
      _userPreferences = updatedPreferences;
      notifyListeners();

      debugPrint(
          '✅ User preferences saved successfully (${completionPercentage.toStringAsFixed(1)}% complete)');
    } catch (e) {
      debugPrint('❌ Error saving user preferences: $e');
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

  /// Calculate preference completion percentage
  double _calculateCompletionPercentage(UserPreferencesModel prefs) {
    int filledFields = 0;
    int totalFields = 0;

    // Core fields (higher weight)
    totalFields += 5;
    if (prefs.age != null) filledFields++;
    if (prefs.gender != null) filledFields++;
    if (prefs.primaryArea != null) filledFields++;
    if (prefs.favoriteEventTypes.isNotEmpty) filledFields++;
    if (prefs.preferredEventTime != null) filledFields++;

    // Important fields (medium weight)
    totalFields += 5;
    if (prefs.religion != null) filledFields++;
    if (prefs.preferredAreas.isNotEmpty) filledFields++;
    if (prefs.maxBudget != null) filledFields++;
    if (prefs.favoriteGenres.isNotEmpty) filledFields++;
    if (prefs.culturalInterests.isNotEmpty) filledFields++;

    // Optional fields (lower weight)
    totalFields += 5;
    if (prefs.occupation != null) filledFields++;
    if (prefs.educationLevel != null) filledFields++;
    if (prefs.socialStyle != null) filledFields++;
    if (prefs.favoriteArtists.isNotEmpty) filledFields++;
    if (prefs.favoriteVenues.isNotEmpty) filledFields++;

    return (filledFields / totalFields) * 100;
  }

  /// Validate preferences before saving
  void _validatePreferences(UserPreferencesModel prefs) {
    // Validate age range
    if (prefs.age != null && (prefs.age! < 13 || prefs.age! > 120)) {
      throw ArgumentError('Age must be between 13 and 120');
    }

    // Validate budget
    if (prefs.minBudget != null && prefs.maxBudget != null) {
      if (prefs.minBudget! > prefs.maxBudget!) {
        throw ArgumentError('Minimum budget cannot exceed maximum budget');
      }
      if (prefs.minBudget! < 0 || prefs.maxBudget! < 0) {
        throw ArgumentError('Budget values must be non-negative');
      }
    }

    // Validate travel distance
    if (prefs.maxTravelDistance != null && prefs.maxTravelDistance! < 0) {
      throw ArgumentError('Travel distance must be non-negative');
    }

    // Validate adventure level
    if (prefs.adventureLevel < 1 || prefs.adventureLevel > 5) {
      throw ArgumentError('Adventure level must be between 1 and 5');
    }

    // Validate notification frequency
    if (prefs.notificationFrequency < 0 || prefs.notificationFrequency > 10) {
      throw ArgumentError('Notification frequency must be between 0 and 10');
    }
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

  /// Update specific preference fields without replacing entire model
  Future<void> updatePreferenceFields(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    if (_userPreferences == null) {
      debugPrint(
          '⚠️ Cannot update preferences - no existing preferences loaded');
      return;
    }

    try {
      // Merge updates with existing preferences
      final currentMap = _userPreferences!.toMap();
      currentMap.addAll(updates);
      currentMap['updatedAt'] = Timestamp.fromDate(DateTime.now());

      final updatedPrefs = UserPreferencesModel.fromMap(currentMap);

      // Save updated preferences
      await saveUserPreferences(userId, updatedPrefs);

      debugPrint('✅ Preference fields updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating preference fields: $e');
      rethrow;
    }
  }

  /// Create default preferences for a new user
  Future<void> createDefaultPreferences(String userId) async {
    final defaultPrefs = UserPreferencesModel(
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isComplete: false,
      completionPercentage: 0.0,
      // Set some sensible defaults
      allowsPersonalizedNotifications: true,
      allowsLocationBasedRecommendations: true,
      sharesDataForResearch: false,
      notificationFrequency: 3,
      likesNewExperiences: true,
      prefersFamiliarEvents: false,
      adventureLevel: 3,
      prefersFamilyFriendly: false,
      prefersOutdoor: false,
      prefersIndoor: false,
      observesPoyaDays: false,
      observesReligiousHolidays: false,
    );

    await saveUserPreferences(userId, defaultPrefs);
    debugPrint('✅ Default preferences created for user $userId');
  }

  /// Get a summary of user preferences for display
  Map<String, dynamic> getPreferencesSummary() {
    if (_userPreferences == null) {
      return {
        'hasPreferences': false,
        'isComplete': false,
        'completionPercentage': 0.0,
      };
    }

    return {
      'hasPreferences': true,
      'isComplete': _userPreferences!.isComplete,
      'completionPercentage': _userPreferences!.completionPercentage,
      'age': _userPreferences!.age,
      'gender': _userPreferences!.gender,
      'primaryArea': _userPreferences!.primaryArea,
      'favoriteEventTypes': _userPreferences!.favoriteEventTypes,
      'preferredEventTime': _userPreferences!.preferredEventTime,
      'budgetRange': _userPreferences!.minBudget != null &&
              _userPreferences!.maxBudget != null
          ? '\$${_userPreferences!.minBudget} - \$${_userPreferences!.maxBudget}'
          : 'Not set',
      'updatedAt': _userPreferences!.updatedAt,
    };
  }

  /// Check if preferences need updating (older than 30 days)
  bool needsPreferenceUpdate() {
    if (_userPreferences?.updatedAt == null) return true;

    final daysSinceUpdate =
        DateTime.now().difference(_userPreferences!.updatedAt!).inDays;
    return daysSinceUpdate > 30;
  }

  /// Get preference quality score (0-100)
  double getPreferenceQualityScore() {
    if (_userPreferences == null) return 0.0;

    double score = _userPreferences!.completionPercentage;

    // Bonus for recent updates
    if (_userPreferences!.updatedAt != null) {
      final daysSinceUpdate =
          DateTime.now().difference(_userPreferences!.updatedAt!).inDays;
      if (daysSinceUpdate < 7) {
        score += 5; // Fresh data bonus
      } else if (daysSinceUpdate > 90) {
        score -= 10; // Stale data penalty
      }
    }

    // Bonus for detailed preferences
    if (_userPreferences!.favoriteEventTypes.length >= 3) score += 5;
    if (_userPreferences!.favoriteGenres.length >= 3) score += 5;
    if (_userPreferences!.culturalInterests.isNotEmpty) score += 5;

    return score.clamp(0.0, 100.0);
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
