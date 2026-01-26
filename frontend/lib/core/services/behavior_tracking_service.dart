import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_behavior_model.dart';
import '../models/event_model.dart';
import '../models/booking_model.dart';
import '../config/app_config.dart';

/// Service for tracking and analyzing user behavior patterns
/// Provides implicit feedback for the recommendation engine
class UserBehaviorTrackingService {
  // Don't eagerly initialize Firestore - only when actually needed
  static const String COLLECTION = 'user_behaviors';

  // Session tracking
  DateTime? _sessionStartTime;
  final Map<String, DateTime> _eventViewStartTimes = {};

  /// Initialize or get user behavior data
  Future<UserBehaviorModel?> getUserBehavior(String userId) async {
    if (!useFirebase) {
      return _createMockBehavior(userId);
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .get();
      if (doc.exists) {
        return UserBehaviorModel.fromMap(doc.data()!, userId);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user behavior: $e');
      return null;
    }
  }

  /// Create mock behavior data when Firebase is disabled
  UserBehaviorModel _createMockBehavior(String userId) {
    return UserBehaviorModel(
      userId: userId,
      totalSessions: 5,
      averageSessionDuration: 300,
      lastActiveAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      eventViews: {},
      eventClicks: {},
      eventTimeSpent: {},
      searchQueries: [],
      totalBookings: 0,
      bookingsByCategory: {},
      clickThroughRate: 0.0,
    );
  }

  /// Create new behavior tracking for user
  Future<void> initializeUserBehavior(String userId) async {
    if (!useFirebase) return;

    try {
      final behavior = UserBehaviorModel(
        userId: userId,
        lastActiveAt: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .set(behavior.toMap());
    } catch (e) {
      debugPrint('Error initializing user behavior: $e');
    }
  }

  /// Track when user starts a session
  Future<void> trackSessionStart(String userId) async {
    _sessionStartTime = DateTime.now();
    if (!useFirebase) return;

    try {
      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'lastActiveAt': FieldValue.serverTimestamp(),
        'totalSessions': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error tracking session start: $e');
    }
  }

  /// Track when user ends a session
  Future<void> trackSessionEnd(String userId) async {
    if (_sessionStartTime == null) return;
    if (!useFirebase) {
      _sessionStartTime = null;
      return;
    }

    final sessionDuration =
        DateTime.now().difference(_sessionStartTime!).inSeconds / 60.0;

    try {
      final doc = await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final currentAvg =
          (data['averageSessionDuration'] as num?)?.toDouble() ?? 0.0;
      final sessions = (data['totalSessions'] as num?)?.toInt() ?? 1;

      // Calculate new average
      final newAvg =
          ((currentAvg * (sessions - 1)) + sessionDuration) / sessions;

      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'averageSessionDuration': newAvg,
      });

      _sessionStartTime = null;
    } catch (e) {
      debugPrint('Error tracking session end: $e');
    }
  }

  /// Track when user views an event
  Future<void> trackEventView(String userId, EventModel event) async {
    _eventViewStartTimes[event.id] = DateTime.now();
    if (!useFirebase) return;

    try {
      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'eventViews.${event.id}': FieldValue.increment(1),
        'categoryViews.${event.category}': FieldValue.increment(1),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error tracking event view: $e');
    }
  }

  /// Track when user stops viewing an event (to calculate time spent)
  Future<void> trackEventViewEnd(String userId, String eventId) async {
    if (!_eventViewStartTimes.containsKey(eventId)) return;
    if (!useFirebase) {
      _eventViewStartTimes.remove(eventId);
      return;
    }

    final timeSpent = DateTime.now()
        .difference(_eventViewStartTimes[eventId]!)
        .inSeconds
        .toDouble();

    try {
      final doc = await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final currentTimeSpent =
          ((data['eventTimeSpent'] as Map?)?[eventId] as num?)?.toDouble() ??
              0.0;
      final newTimeSpent = currentTimeSpent + timeSpent;

      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'eventTimeSpent.$eventId': newTimeSpent,
      });

      _eventViewStartTimes.remove(eventId);
    } catch (e) {
      debugPrint('Error tracking event view end: $e');
    }
  }

  /// Track when user clicks on an event
  Future<void> trackEventClick(String userId, EventModel event) async {
    if (!useFirebase) return;
    try {
      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'eventClicks.${event.id}': FieldValue.increment(1),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error tracking event click: $e');
    }
  }

  /// Track when user shares an event
  Future<void> trackEventShare(String userId, String eventId) async {
    if (!useFirebase) return;
    try {
      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'eventShares.$eventId': FieldValue.increment(1),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error tracking event share: $e');
    }
  }

  /// Track when user favorites an event
  Future<void> trackEventFavorite(
      String userId, String eventId, bool isFavorite) async {
    try {
      if (isFavorite) {
        await FirebaseFirestore.instance
            .collection(COLLECTION)
            .doc(userId)
            .update({
          'eventFavorites.$eventId': FieldValue.increment(1),
        });
      } else {
        await FirebaseFirestore.instance
            .collection(COLLECTION)
            .doc(userId)
            .update({
          'eventFavorites.$eventId': FieldValue.delete(),
        });
      }
    } catch (e) {
      debugPrint('Error tracking event favorite: $e');
    }
  }

  /// Track user search queries
  Future<void> trackSearch(String userId, String query) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final queries = List<String>.from(data['searchQueries'] ?? []);
      queries.add(query);

      // Keep only last 50 queries
      if (queries.length > 50) {
        queries.removeRange(0, queries.length - 50);
      }

      // Update search term frequency
      final words = query.toLowerCase().split(' ');
      final updates = <String, dynamic>{
        'searchQueries': queries,
        'lastActiveAt': FieldValue.serverTimestamp(),
      };

      for (final word in words) {
        if (word.length > 2) {
          // Ignore very short words
          updates['searchTermFrequency.$word'] = FieldValue.increment(1);
        }
      }

      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update(updates);
    } catch (e) {
      debugPrint('Error tracking search: $e');
    }
  }

  /// Track when user clicks on search result
  Future<void> trackSearchResultClick(String userId, String eventId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final results = List<String>.from(data['clickedSearchResults'] ?? []);
      results.add(eventId);

      // Keep only last 30
      if (results.length > 30) {
        results.removeRange(0, results.length - 30);
      }

      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'clickedSearchResults': results,
      });
    } catch (e) {
      debugPrint('Error tracking search result click: $e');
    }
  }

  /// Track booking creation
  Future<void> trackBooking(
      String userId, BookingModel booking, EventModel event) async {
    try {
      final dayName = _getDayName(event.startDate.weekday);
      final timeSlot = _getTimeSlot(event.startDate.hour);

      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'totalBookings': FieldValue.increment(1),
        'bookingsByCategory.${event.category}': FieldValue.increment(1),
        'bookingsByDay.$dayName': FieldValue.increment(1),
        'bookingsByTimeSlot.$timeSlot': FieldValue.increment(1),
        'visitedLocations.${event.location}': FieldValue.increment(1),
        'lastActiveAt': FieldValue.serverTimestamp(),
      });

      // Update conversion rate
      await _updateConversionRate(userId);
    } catch (e) {
      debugPrint('Error tracking booking: $e');
    }
  }

  /// Track booking cancellation
  Future<void> trackBookingCancellation(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'cancelledBookings': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error tracking booking cancellation: $e');
    }
  }

  /// Track when user abandons an event (viewed but didn't book)
  Future<void> trackAbandonedEvent(String userId, String eventId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final abandoned = List<String>.from(data['abandonnedEvents'] ?? []);

      if (!abandoned.contains(eventId)) {
        abandoned.add(eventId);

        // Keep only last 20
        if (abandoned.length > 20) {
          abandoned.removeAt(0);
        }

        await FirebaseFirestore.instance
            .collection(COLLECTION)
            .doc(userId)
            .update({
          'abandonnedEvents': abandoned,
        });
      }
    } catch (e) {
      debugPrint('Error tracking abandoned event: $e');
    }
  }

  /// Track notification interaction
  Future<void> trackNotificationClick(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'notificationClicks': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error tracking notification click: $e');
    }
  }

  /// Track notification dismissal
  Future<void> trackNotificationDismissal(String userId) async {
    try {
      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'notificationDismissals': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error tracking notification dismissal: $e');
    }
  }

  /// Track activity by time of day
  Future<void> trackActivityTime(String userId) async {
    final now = DateTime.now();
    final hour = now.hour;
    final dayName = _getDayName(now.weekday);

    try {
      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'activityByHour.$hour': FieldValue.increment(1),
        'activityByDay.$dayName': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error tracking activity time: $e');
    }
  }

  /// Track tag clicks
  Future<void> trackTagClick(String userId, String tag) async {
    try {
      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'tagClicks.$tag': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error tracking tag click: $e');
    }
  }

  /// Update booking conversion rate
  Future<void> _updateConversionRate(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final totalBookings = (data['totalBookings'] as num?)?.toInt() ?? 0;
      final totalViews = (data['eventViews'] as Map?)
              ?.values
              .fold(0, (sum, val) => sum + (val as int)) ??
          1;

      final conversionRate = totalViews > 0 ? totalBookings / totalViews : 0.0;

      await FirebaseFirestore.instance
          .collection(COLLECTION)
          .doc(userId)
          .update({
        'bookingConversionRate': conversionRate,
      });
    } catch (e) {
      debugPrint('Error updating conversion rate: $e');
    }
  }

  /// Get user engagement analytics
  Future<Map<String, dynamic>> getUserEngagementAnalytics(String userId) async {
    try {
      final behavior = await getUserBehavior(userId);
      if (behavior == null) return {};

      return {
        'totalSessions': behavior.totalSessions,
        'averageSessionDuration': behavior.averageSessionDuration,
        'daysActive': behavior.daysActive,
        'totalBookings': behavior.totalBookings,
        'conversionRate': behavior.bookingConversionRate,
        'clickThroughRate': behavior.clickThroughRate,
        'topCategories': _getTopItems(behavior.categoryViews, 5),
        'topLocations': _getTopItems(behavior.visitedLocations, 5),
        'topSearchTerms': _getTopItems(behavior.searchTermFrequency, 10),
        'peakActivityHours': _getTopItems(behavior.activityByHour, 3),
        'preferredDays': _getTopItems(behavior.activityByDay, 3),
      };
    } catch (e) {
      debugPrint('Error getting engagement analytics: $e');
      return {};
    }
  }

  List<MapEntry<String, int>> _getTopItems(Map<dynamic, int> map, int limit) {
    final entries =
        map.entries.map((e) => MapEntry(e.key.toString(), e.value)).toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.take(limit).toList();
  }

  String _getDayName(int weekday) {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday'
    ];
    return days[weekday - 1];
  }

  String _getTimeSlot(int hour) {
    if (hour >= 6 && hour < 12) return 'morning';
    if (hour >= 12 && hour < 17) return 'afternoon';
    if (hour >= 17 && hour < 21) return 'evening';
    return 'night';
  }
}
