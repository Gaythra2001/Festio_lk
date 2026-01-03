import '../models/event_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';

/// Analytics Dashboard Service
/// Provides analytics and insights for event management
class AnalyticsService {
  /// Get event analytics
  Map<String, dynamic> getEventAnalytics(List<EventModel> events) {
    return {
      'total_events': events.length,
      'approved_events': events.where((e) => e.isApproved).length,
      'pending_events': events.where((e) => !e.isApproved).length,
      'spam_events': events.where((e) => e.isSpam).length,
      'category_distribution': _getCategoryDistribution(events),
      'location_distribution': _getLocationDistribution(events),
      'trust_score_average': _getAverageTrustScore(events),
    };
  }

  /// Get booking analytics
  Map<String, dynamic> getBookingAnalytics(
    List<BookingModel> bookings,
    List<EventModel> events,
  ) {
    return {
      'total_bookings': bookings.length,
      'upcoming_bookings': bookings.where((b) => b.status == BookingStatus.upcoming).length,
      'past_bookings': bookings.where((b) => b.status == BookingStatus.past).length,
      'cancelled_bookings': bookings.where((b) => b.status == BookingStatus.cancelled).length,
      'popular_events': _getPopularEvents(bookings, events),
      'booking_trends': _getBookingTrends(bookings),
      'revenue': _calculateRevenue(bookings),
    };
  }

  /// Get user analytics
  Map<String, dynamic> getUserAnalytics(
    List<UserModel> users,
    List<BookingModel> bookings,
  ) {
    return {
      'total_users': users.length,
      'active_users': _getActiveUsers(users, bookings),
      'average_trust_score': _getAverageUserTrustScore(users),
      'user_growth': _getUserGrowth(users),
      'top_contributors': _getTopContributors(users),
    };
  }

  /// Get comprehensive dashboard data
  Map<String, dynamic> getDashboardData({
    required List<EventModel> events,
    required List<BookingModel> bookings,
    required List<UserModel> users,
  }) {
    return {
      'events': getEventAnalytics(events),
      'bookings': getBookingAnalytics(bookings, events),
      'users': getUserAnalytics(users, bookings),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  Map<String, int> _getCategoryDistribution(List<EventModel> events) {
    final distribution = <String, int>{};
    for (final event in events) {
      distribution[event.category] = (distribution[event.category] ?? 0) + 1;
    }
    return distribution;
  }

  Map<String, int> _getLocationDistribution(List<EventModel> events) {
    final distribution = <String, int>{};
    for (final event in events) {
      distribution[event.location] = (distribution[event.location] ?? 0) + 1;
    }
    return distribution;
  }

  double _getAverageTrustScore(List<EventModel> events) {
    if (events.isEmpty) return 0.0;
    final total = events.fold<int>(0, (sum, e) => sum + e.trustScore);
    return total / events.length;
  }

  List<Map<String, dynamic>> _getPopularEvents(
    List<BookingModel> bookings,
    List<EventModel> events,
  ) {
    final eventCounts = <String, int>{};
    for (final booking in bookings) {
      eventCounts[booking.eventId] = (eventCounts[booking.eventId] ?? 0) + 1;
    }
    
    final sorted = eventCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(10).map((entry) {
      final event = events.firstWhere(
        (e) => e.id == entry.key,
        orElse: () => events.first,
      );
      return {
        'event_id': entry.key,
        'event_title': event.title,
        'booking_count': entry.value,
      };
    }).toList();
  }

  Map<String, dynamic> _getBookingTrends(List<BookingModel> bookings) {
    final monthlyBookings = <String, int>{};
    for (final booking in bookings) {
      final month = '${booking.bookedAt.year}-${booking.bookedAt.month.toString().padLeft(2, '0')}';
      monthlyBookings[month] = (monthlyBookings[month] ?? 0) + 1;
    }
    return monthlyBookings;
  }

  double _calculateRevenue(List<BookingModel> bookings) {
    return bookings.fold<double>(
      0.0,
      (sum, booking) => sum + (booking.totalPrice ?? 0.0),
    );
  }

  int _getActiveUsers(List<UserModel> users, List<BookingModel> bookings) {
    final activeUserIds = bookings.map((b) => b.userId).toSet();
    return activeUserIds.length;
  }

  double _getAverageUserTrustScore(List<UserModel> users) {
    if (users.isEmpty) return 0.0;
    final total = users.fold<int>(0, (sum, u) => sum + u.trustScore);
    return total / users.length;
  }

  Map<String, int> _getUserGrowth(List<UserModel> users) {
    final monthlyGrowth = <String, int>{};
    for (final user in users) {
      final month = '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}';
      monthlyGrowth[month] = (monthlyGrowth[month] ?? 0) + 1;
    }
    return monthlyGrowth;
  }

  List<Map<String, dynamic>> _getTopContributors(List<UserModel> users) {
    final sorted = users.toList()
      ..sort((a, b) => b.trustScore.compareTo(a.trustScore));
    
    return sorted.take(10).map((user) => {
      'user_id': user.id,
      'display_name': user.displayName ?? user.email,
      'trust_score': user.trustScore,
    }).toList();
  }
}

