import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/analytics_service.dart';

class AnalyticsProvider with ChangeNotifier {
  final AnalyticsService _analyticsService = AnalyticsService();
  
  Map<String, dynamic>? _dashboardData;
  bool _isLoading = false;

  Map<String, dynamic>? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;

  Future<void> loadDashboardData({
    required List<EventModel> events,
    required List<BookingModel> bookings,
    required List<UserModel> users,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _dashboardData = _analyticsService.getDashboardData(
        events: events,
        bookings: bookings,
        users: users,
      );
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Map<String, dynamic> getEventAnalytics(List<EventModel> events) {
    return _analyticsService.getEventAnalytics(events);
  }

  Map<String, dynamic> getBookingAnalytics(
    List<BookingModel> bookings,
    List<EventModel> events,
  ) {
    return _analyticsService.getBookingAnalytics(bookings, events);
  }
}

