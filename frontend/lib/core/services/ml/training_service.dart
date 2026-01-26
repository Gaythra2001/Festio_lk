import 'package:flutter/foundation.dart';
import '../../models/event_model.dart';
import '../../models/booking_model.dart';
import '../../models/user_model.dart';

/// Machine Learning Model Training Service
/// Handles historical data processing and feedback loop for continuous learning
class MLTrainingService {
  /// Train recommendation model with historical data
  Future<void> trainRecommendationModel({
    required List<BookingModel> historicalBookings,
    required List<EventModel> historicalEvents,
    required List<UserModel> users,
  }) async {
    debugPrint('Training recommendation model with ${historicalBookings.length} bookings...');
    
    // Extract features from historical data
    final features = _extractFeatures(historicalBookings, historicalEvents, users);
    
    // Train model (in real implementation, this would use TensorFlow Lite, ML Kit, etc.)
    await _trainModel(features);
    
    debugPrint('Model training completed');
  }

  /// Process feedback loop - update model based on user interactions
  Future<void> processFeedback({
    required String userId,
    required String eventId,
    required String interactionType, // 'view', 'book', 'cancel', 'like'
    required Map<String, dynamic> context,
  }) async {
    debugPrint('Processing feedback: $userId -> $eventId ($interactionType)');
    
    // Update user preferences based on feedback
    await _updateUserPreferences(userId, eventId, interactionType);
    
    // Retrain model periodically with new feedback
    // In production, this would be done asynchronously
  }

  /// Extract features for ML model training
  Map<String, dynamic> _extractFeatures(
    List<BookingModel> bookings,
    List<EventModel> events,
    List<UserModel> users,
  ) {
    // Feature extraction logic
    return {
      'user_features': _extractUserFeatures(users, bookings),
      'event_features': _extractEventFeatures(events),
      'interaction_features': _extractInteractionFeatures(bookings, events),
    };
  }

  Map<String, dynamic> _extractUserFeatures(
  List<UserModel> users,
  List<BookingModel> bookings,
) {
  final userStats = <String, Map<String, dynamic>>{};
  
  for (final user in users) {
    final userBookings = bookings.where((b) => b.userId == user.id).toList();
    userStats[user.id] = {
      'trust_score': user.trustScore,
      'booking_count': userBookings.length,
      'preferred_categories': [], // Will be calculated separately
      'preferred_locations': [], // Will be calculated separately
    };
  }
  
  return userStats;
}


  Map<String, dynamic> _extractEventFeatures(List<EventModel> events) {
    return {
      'category_distribution': _getCategoryDistribution(events),
      'location_distribution': _getLocationDistribution(events),
      'popularity_scores': _calculatePopularityScores(events),
    };
  }

  Map<String, dynamic> _extractInteractionFeatures(
    List<BookingModel> bookings,
    List<EventModel> events,
  ) {
    return {
      'booking_patterns': _analyzeBookingPatterns(bookings),
      'event_success_rate': _calculateSuccessRate(bookings, events),
      'user_event_matrix': _buildUserEventMatrix(bookings),
    };
  }

  Future<void> _trainModel(Map<String, dynamic> features) async {
    // Model training implementation
    // This would integrate with ML framework (TensorFlow, PyTorch, etc.)
    await Future.delayed(const Duration(seconds: 1)); // Simulate training
  }

  Future<void> _updateUserPreferences(
    String userId,
    String eventId,
    String interactionType,
  ) async {
    // Update user preferences based on interaction
    debugPrint('Updating preferences for user $userId based on $interactionType');
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

  Map<String, double> _calculatePopularityScores(List<EventModel> events) {
    final scores = <String, double>{};
    for (final event in events) {
      // Simple popularity score based on trust score and approval status
      scores[event.id] = (event.trustScore / 100.0) * (event.isApproved ? 1.0 : 0.5);
    }
    return scores;
  }

  Map<String, dynamic> _analyzeBookingPatterns(List<BookingModel> bookings) {
    return {
      'peak_booking_times': _getPeakBookingTimes(bookings),
      'average_advance_booking_days': _getAverageAdvanceDays(bookings),
    };
  }

  double _calculateSuccessRate(
    List<BookingModel> bookings,
    List<EventModel> events,
  ) {
    final totalBookings = bookings.length;
    final successfulBookings = bookings
        .where((b) => b.status != BookingStatus.cancelled)
        .length;
    return totalBookings > 0 ? successfulBookings / totalBookings : 0.0;
  }

  Map<String, Map<String, int>> _buildUserEventMatrix(
    List<BookingModel> bookings,
  ) {
    final matrix = <String, Map<String, int>>{};
    for (final booking in bookings) {
      if (!matrix.containsKey(booking.userId)) {
        matrix[booking.userId] = {};
      }
      matrix[booking.userId]![booking.eventId] =
          (matrix[booking.userId]![booking.eventId] ?? 0) + 1;
    }
    return matrix;
  }

  List<int> _getPeakBookingTimes(List<BookingModel> bookings) {
    final hourCounts = List<int>.filled(24, 0);
    for (final booking in bookings) {
      final hour = booking.bookedAt.hour;
      hourCounts[hour]++;
    }
    return hourCounts;
  }

  double _getAverageAdvanceDays(List<BookingModel> bookings) {
    if (bookings.isEmpty) return 0.0;
    double totalDays = 0.0;
    for (final booking in bookings) {
      final days = booking.eventDate.difference(booking.bookedAt).inDays;
      totalDays += days;
    }
    return totalDays / bookings.length;
  }
}

