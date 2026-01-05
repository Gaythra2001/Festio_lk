import 'package:flutter/foundation.dart';
import '../models/rating_model.dart';
import '../services/rating_service.dart';

/// Provider for managing ratings and reviews
class RatingProvider with ChangeNotifier {
  final RatingService _ratingService = RatingService();

  List<RatingModel> _eventRatings = [];
  List<RatingModel> _platformRatings = [];
  RatingStats? _eventStats;
  RatingStats? _platformStats;
  RatingModel? _userRating;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<RatingModel> get eventRatings => _eventRatings;
  List<RatingModel> get platformRatings => _platformRatings;
  RatingStats? get eventStats => _eventStats;
  RatingStats? get platformStats => _platformStats;
  RatingModel? get userRating => _userRating;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load ratings for a specific event
  Future<void> loadEventRatings(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _eventRatings = await _ratingService.getEventRatings(eventId);
      _eventStats = await _ratingService.getEventStats(eventId);
    } catch (e) {
      _error = 'Failed to load ratings: $e';
      debugPrint('❌ Error loading event ratings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load platform ratings
  Future<void> loadPlatformRatings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _platformRatings = await _ratingService.getPlatformRatings();
      _platformStats = await _ratingService.getPlatformStats();
    } catch (e) {
      _error = 'Failed to load platform ratings: $e';
      debugPrint('❌ Error loading platform ratings: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load user's rating for an event or platform
  Future<void> loadUserRating(String userId, String? eventId) async {
    try {
      _userRating = await _ratingService.getUserRating(userId, eventId);
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error loading user rating: $e');
    }
  }

  /// Submit a new rating
  Future<bool> submitRating(RatingModel rating) async {
    try {
      await _ratingService.submitRating(rating);
      _userRating = rating;

      // Reload ratings to get updated list
      if (rating.eventId != null) {
        await loadEventRatings(rating.eventId!);
      } else {
        await loadPlatformRatings();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to submit rating: $e';
      debugPrint('❌ Error submitting rating: $e');
      notifyListeners();
      return false;
    }
  }

  /// Update an existing rating
  Future<bool> updateRating(RatingModel rating) async {
    try {
      await _ratingService.updateRating(rating);
      _userRating = rating;

      // Reload ratings to get updated list
      if (rating.eventId != null) {
        await loadEventRatings(rating.eventId!);
      } else {
        await loadPlatformRatings();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to update rating: $e';
      debugPrint('❌ Error updating rating: $e');
      notifyListeners();
      return false;
    }
  }

  /// Delete a rating
  Future<bool> deleteRating(String ratingId, String? eventId) async {
    try {
      await _ratingService.deleteRating(ratingId, eventId);
      _userRating = null;

      // Reload ratings to get updated list
      if (eventId != null) {
        await loadEventRatings(eventId);
      } else {
        await loadPlatformRatings();
      }

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to delete rating: $e';
      debugPrint('❌ Error deleting rating: $e');
      notifyListeners();
      return false;
    }
  }

  /// Add organizer response
  Future<bool> addOrganizerResponse(String ratingId, String response) async {
    try {
      await _ratingService.addOrganizerResponse(ratingId, response);
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to add response: $e';
      debugPrint('❌ Error adding organizer response: $e');
      notifyListeners();
      return false;
    }
  }

  /// Mark review as helpful
  Future<void> markHelpful(String ratingId) async {
    try {
      await _ratingService.markHelpful(ratingId);
      // Update the local rating
      final index = _eventRatings.indexWhere((r) => r.id == ratingId);
      if (index != -1) {
        _eventRatings[index] = _eventRatings[index].copyWith(
          helpfulCount: _eventRatings[index].helpfulCount + 1,
        );
      }
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error marking as helpful: $e');
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Reset state
  void reset() {
    _eventRatings = [];
    _platformRatings = [];
    _eventStats = null;
    _platformStats = null;
    _userRating = null;
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
