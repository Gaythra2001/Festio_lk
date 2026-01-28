import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';

/// Tracks user interactions for ML recommendations and analytics
class InteractionTrackingProvider extends ChangeNotifier {
  final String baseUrl = ApiConfig.baseUrl;
  
  // Recent interactions cache
  final List<Map<String, dynamic>> _sessionInteractions = [];
  
  // Current session data
  String? _currentUserId;
  List<String> _recommendedEvents = [];
  List<String> _clickedEvents = [];
  List<String> _bookedEvents = [];
  
  // Metrics
  Map<String, dynamic>? _recentMetrics;
  Map<String, dynamic>? _userAnalytics;
  bool _isLoading = false;

  // Getters
  List<Map<String, dynamic>> get sessionInteractions => _sessionInteractions;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get recentMetrics => _recentMetrics;
  Map<String, dynamic>? get userAnalytics => _userAnalytics;

  /// Initialize tracking for a user session
  void initializeSession(String userId) {
    _currentUserId = userId;
    _recommendedEvents = [];
    _clickedEvents = [];
    _bookedEvents = [];
    _sessionInteractions.clear();
  }

  /// Record recommended events shown to user
  void recordRecommendations(List<String> eventIds) {
    _recommendedEvents = eventIds;
    notifyListeners();
  }

  /// Track event impression (shown to user)
  Future<void> logImpression({
    required String eventId,
    required String channel,
    required int position,
    String? organizerId,
    bool isPromoted = false,
  }) async {
    if (_currentUserId == null) return;

    try {
      final queryParams = {
        'user_id': _currentUserId!,
        'event_id': eventId,
        'channel': channel,
        'position': position.toString(),
        if (organizerId != null) 'organizer_id': organizerId,
        'is_promoted': isPromoted.toString(),
      };

      final uri = Uri.parse('$baseUrl/recommendations/impression').replace(
        queryParameters: queryParams,
      );

      final response = await http.post(uri);

      if (response.statusCode != 200) {
        print('Error logging impression: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in logImpression: $e');
    }
  }

  /// Track event view
  Future<void> logEventView({
    required String eventId,
    required String channel,
    String? organizerId,
  }) async {
    if (_currentUserId == null) return;

    try {
      await logInteraction(
        eventId: eventId,
        interactionType: 'view',
        channel: channel,
        metadata: {'organizer_id': organizerId},
      );
    } catch (e) {
      print('Error in logEventView: $e');
    }
  }

  /// Track event click
  Future<void> logEventClick({
    required String eventId,
    required String channel,
  }) async {
    if (_currentUserId == null) return;

    _clickedEvents.add(eventId);

    try {
      await logInteraction(
        eventId: eventId,
        interactionType: 'click',
        channel: channel,
      );
    } catch (e) {
      print('Error in logEventClick: $e');
    }
  }

  /// Track event booking
  Future<void> logEventBooking({
    required String eventId,
    required String channel,
    bool isPromotionClick = false,
  }) async {
    if (_currentUserId == null) return;

    _bookedEvents.add(eventId);

    try {
      await logInteraction(
        eventId: eventId,
        interactionType: 'booking',
        channel: channel,
        isPromotionClick: isPromotionClick,
      );
    } catch (e) {
      print('Error in logEventBooking: $e');
    }
  }

  /// Track promotion click
  Future<void> logPromotionClick({
    required String eventId,
    required String organizerId,
  }) async {
    if (_currentUserId == null) return;

    try {
      await logInteraction(
        eventId: eventId,
        interactionType: 'promotion_click',
        channel: 'promotion',
        isPromotionClick: true,
        metadata: {'organizer_id': organizerId},
      );
    } catch (e) {
      print('Error in logPromotionClick: $e');
    }
  }

  /// Track calendar selection
  Future<void> logCalendarSelection({
    required String eventId,
    required String channel,
  }) async {
    if (_currentUserId == null) return;

    try {
      await logInteraction(
        eventId: eventId,
        interactionType: 'calendar_selected',
        channel: channel,
        calendarSelected: true,
      );
    } catch (e) {
      print('Error in logCalendarSelection: $e');
    }
  }

  /// Track event rating
  Future<void> logEventRating({
    required String eventId,
    required double ratingValue,
    required String channel,
    String? sentiment,
  }) async {
    if (_currentUserId == null) return;

    try {
      final metadata = sentiment != null ? {'sentiment': sentiment} : <String, dynamic>{};
      await logInteraction(
        eventId: eventId,
        interactionType: 'rating',
        channel: channel,
        ratingValue: ratingValue,
        metadata: metadata,
      );
    } catch (e) {
      print('Error in logEventRating: $e');
    }
  }

  /// Track notification action
  Future<void> logNotificationAction({
    required String eventId,
    required String action,
  }) async {
    if (_currentUserId == null) return;

    try {
      String interactionType = 'notification_$action';
      await logInteraction(
        eventId: eventId,
        interactionType: interactionType,
        channel: 'notification',
        notificationAction: action,
      );
    } catch (e) {
      print('Error in logNotificationAction: $e');
    }
  }

  /// Track organizer trust signal
  Future<void> logOrganizerInteraction({
    required String organizerId,
    required String eventId,
    required double trustScore,
  }) async {
    if (_currentUserId == null) return;

    try {
      await logInteraction(
        eventId: eventId,
        interactionType: 'organizer_interaction',
        channel: 'events_tab',
        organizerTrustScore: trustScore,
      );
    } catch (e) {
      print('Error in logOrganizerInteraction: $e');
    }
  }

  /// Generic interaction logging
  Future<void> logInteraction({
    required String eventId,
    required String interactionType,
    String? channel,
    double? rating,
    bool isPromotionClick = false,
    bool calendarSelected = false,
    double? organizerTrustScore,
    double? ratingValue,
    String? notificationAction,
    Map<String, dynamic>? metadata,
  }) async {
    if (_currentUserId == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final body = {
        'user_id': _currentUserId!,
        'event_id': eventId,
        'interaction_type': interactionType,
        if (rating != null) 'rating': rating,
        if (channel != null) 'channel': channel,
        'is_promotion_click': isPromotionClick,
        'calendar_selected': calendarSelected,
        if (organizerTrustScore != null) 'organizer_trust_score': organizerTrustScore,
        if (ratingValue != null) 'rating_value': ratingValue,
        if (notificationAction != null) 'notification_action': notificationAction,
        if (metadata != null) 'metadata': metadata,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/recommendations/interaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        _sessionInteractions.add({
          'event_id': eventId,
          'interaction_type': interactionType,
          'timestamp': DateTime.now().toIso8601String(),
        });
      } else {
        print('Error logging interaction: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in logInteraction: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// End session and log complete session for evaluation
  Future<void> endSession() async {
    if (_currentUserId == null || _recommendedEvents.isEmpty) return;

    try {
      final body = {
        'user_id': _currentUserId!,
        'recommended_events': _recommendedEvents,
        'clicked_events': _clickedEvents,
        'booked_events': _bookedEvents,
      };

      final response = await http.post(
        Uri.parse('$baseUrl/recommendations/session'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        print('Error ending session: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in endSession: $e');
    }
  }

  /// Fetch user analytics
  Future<void> fetchUserAnalytics({
    required String userId,
    int daysBack = 30,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/recommendations/user/$userId/analytics?days_back=$daysBack'),
      );

      if (response.statusCode == 200) {
        _userAnalytics = jsonDecode(response.body);
      } else {
        print('Error fetching user analytics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchUserAnalytics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch recommendation metrics
  Future<void> fetchMetrics({int daysBack = 7}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$baseUrl/recommendations/metrics?days_back=$daysBack'),
      );

      if (response.statusCode == 200) {
        _recentMetrics = jsonDecode(response.body);
      } else {
        print('Error fetching metrics: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchMetrics: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get notification engagement stats
  Future<Map<String, dynamic>?> fetchNotificationEngagement({
    int daysBack = 30,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/recommendations/notifications/engagement?days_back=$daysBack'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error fetching notification engagement: $e');
    }
    return null;
  }

  /// Trigger model retraining
  Future<Map<String, dynamic>?> retainModel() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$baseUrl/recommendations/retrain'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print('Error retraining model: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return null;
  }

  /// Clear session data
  void clearSession() {
    _currentUserId = null;
    _recommendedEvents = [];
    _clickedEvents = [];
    _bookedEvents = [];
    _sessionInteractions.clear();
    notifyListeners();
  }
}
