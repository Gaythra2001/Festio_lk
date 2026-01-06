import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/rating_model.dart';
import '../config/app_config.dart';

/// Service for managing ratings and reviews
class RatingService {
  FirebaseFirestore? _firestoreInstance;

  // Local storage for demo mode
  final List<RatingModel> _localEventRatings = [];
  final List<RatingModel> _localPlatformRatings = [];

  FirebaseFirestore? get _firestore {
    if (!useFirebase) return null;
    _firestoreInstance ??= FirebaseFirestore.instance;
    return _firestoreInstance;
  }

  // Collections
  static const String _ratingsCollection = 'ratings';
  static const String _ratingStatsCollection = 'rating_stats';

  /// Submit a rating for an event or platform
  Future<void> submitRating(RatingModel rating) async {
    if (!useFirebase) {
      // Store in local memory for demo mode
      if (rating.eventId != null) {
        _localEventRatings.add(rating);
      } else {
        _localPlatformRatings.add(rating);
      }
      debugPrint('✅ Rating submitted successfully (demo mode)');
      return;
    }

    try {
      await _firestore!.collection(_ratingsCollection).doc(rating.id).set(
            rating.toMap(),
          );

      // Update statistics
      await _updateRatingStats(rating.eventId);

      debugPrint('✅ Rating submitted successfully');
    } catch (e) {
      debugPrint('❌ Error submitting rating: $e');
      rethrow;
    }
  }

  /// Update an existing rating
  Future<void> updateRating(RatingModel rating) async {
    if (!useFirebase) {
      debugPrint('⚠️ Firebase disabled - rating not updated');
      return;
    }

    try {
      final updatedRating = rating.copyWith(updatedAt: DateTime.now());

      await _firestore!
          .collection(_ratingsCollection)
          .doc(rating.id)
          .update(updatedRating.toMap());

      // Update statistics
      await _updateRatingStats(rating.eventId);

      debugPrint('✅ Rating updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating rating: $e');
      rethrow;
    }
  }

  /// Delete a rating
  Future<void> deleteRating(String ratingId, String? eventId) async {
    if (!useFirebase) {
      debugPrint('⚠️ Firebase disabled - rating not deleted');
      return;
    }

    try {
      await _firestore!.collection(_ratingsCollection).doc(ratingId).delete();

      // Update statistics
      await _updateRatingStats(eventId);

      debugPrint('✅ Rating deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting rating: $e');
      rethrow;
    }
  }

  /// Get ratings for a specific event
  Future<List<RatingModel>> getEventRatings(String eventId) async {
    if (!useFirebase) {
      // Combine mock data with locally submitted ratings
      final mockRatings = _getMockEventRatings(eventId);
      final localSubmitted =
          _localEventRatings.where((r) => r.eventId == eventId).toList();

      // Sort by creation date (newest first)
      final allRatings = [...mockRatings, ...localSubmitted];
      allRatings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allRatings;
    }

    try {
      final snapshot = await _firestore!
          .collection(_ratingsCollection)
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RatingModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching event ratings: $e');
      return [];
    }
  }

  /// Get platform ratings (overall app ratings)
  Future<List<RatingModel>> getPlatformRatings() async {
    if (!useFirebase) {
      // Combine mock data with locally submitted ratings
      final mockRatings = _getMockPlatformRatings();
      final localSubmitted = _localPlatformRatings;

      // Sort by creation date (newest first)
      final allRatings = [...mockRatings, ...localSubmitted];
      allRatings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allRatings.take(50).toList();
    }

    try {
      final snapshot = await _firestore!
          .collection(_ratingsCollection)
          .where('eventId', isEqualTo: null)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return snapshot.docs
          .map((doc) => RatingModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('❌ Error fetching platform ratings: $e');
      return [];
    }
  }

  /// Get user's rating for an event
  Future<RatingModel?> getUserRating(String userId, String? eventId) async {
    if (!useFirebase) {
      return null;
    }

    try {
      Query query = _firestore!
          .collection(_ratingsCollection)
          .where('userId', isEqualTo: userId);

      if (eventId != null) {
        query = query.where('eventId', isEqualTo: eventId);
      } else {
        query = query.where('eventId', isEqualTo: null);
      }

      final snapshot = await query.limit(1).get();

      if (snapshot.docs.isNotEmpty) {
        return RatingModel.fromMap(
            snapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('❌ Error fetching user rating: $e');
      return null;
    }
  }

  /// Get rating statistics for an event
  Future<RatingStats> getEventStats(String eventId) async {
    if (!useFirebase) {
      // Calculate stats dynamically from mock + local ratings
      final allRatings = await getEventRatings(eventId);
      return _calculateStatsFromRatings(allRatings);
    }

    try {
      final doc = await _firestore!
          .collection(_ratingStatsCollection)
          .doc(eventId)
          .get();

      if (doc.exists && doc.data() != null) {
        return RatingStats.fromMap(doc.data()!);
      }

      // If no stats exist, calculate them
      return await _calculateStats(eventId);
    } catch (e) {
      debugPrint('❌ Error fetching event stats: $e');
      return RatingStats(
        averageRating: 0.0,
        totalRatings: 0,
        ratingDistribution: {},
      );
    }
  }

  /// Get platform rating statistics
  Future<RatingStats> getPlatformStats() async {
    if (!useFirebase) {
      // Calculate stats dynamically from mock + local ratings
      final allRatings = await getPlatformRatings();
      return _calculateStatsFromRatings(allRatings);
    }

    try {
      final doc = await _firestore!
          .collection(_ratingStatsCollection)
          .doc('platform')
          .get();

      if (doc.exists && doc.data() != null) {
        return RatingStats.fromMap(doc.data()!);
      }

      return await _calculateStats(null);
    } catch (e) {
      debugPrint('❌ Error fetching platform stats: $e');
      return RatingStats(
        averageRating: 0.0,
        totalRatings: 0,
        ratingDistribution: {},
      );
    }
  }

  /// Add organizer response to a rating
  Future<void> addOrganizerResponse(
    String ratingId,
    String response,
  ) async {
    if (!useFirebase) {
      debugPrint('⚠️ Firebase disabled - response not saved');
      return;
    }

    try {
      await _firestore!.collection(_ratingsCollection).doc(ratingId).update({
        'organizerResponse': response,
        'responseDate': Timestamp.fromDate(DateTime.now()),
      });

      debugPrint('✅ Organizer response added successfully');
    } catch (e) {
      debugPrint('❌ Error adding organizer response: $e');
      rethrow;
    }
  }

  /// Mark a review as helpful
  Future<void> markHelpful(String ratingId) async {
    if (!useFirebase) {
      debugPrint('⚠️ Firebase disabled - helpful count not updated');
      return;
    }

    try {
      await _firestore!.collection(_ratingsCollection).doc(ratingId).update({
        'helpfulCount': FieldValue.increment(1),
      });

      debugPrint('✅ Marked as helpful');
    } catch (e) {
      debugPrint('❌ Error marking as helpful: $e');
      rethrow;
    }
  }

  /// Update rating statistics
  Future<void> _updateRatingStats(String? eventId) async {
    final stats = await _calculateStats(eventId);
    final docId = eventId ?? 'platform';

    await _firestore!
        .collection(_ratingStatsCollection)
        .doc(docId)
        .set(stats.toMap());
  }

  /// Calculate rating statistics
  Future<RatingStats> _calculateStats(String? eventId) async {
    Query query = _firestore!.collection(_ratingsCollection);

    if (eventId != null) {
      query = query.where('eventId', isEqualTo: eventId);
    } else {
      query = query.where('eventId', isEqualTo: null);
    }

    final snapshot = await query.get();
    final ratings = snapshot.docs
        .map((doc) => RatingModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();

    if (ratings.isEmpty) {
      return RatingStats(
        averageRating: 0.0,
        totalRatings: 0,
        ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );
    }

    // Calculate distribution
    final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    double totalRating = 0;
    int verifiedCount = 0;
    int withTextCount = 0;
    int withImagesCount = 0;
    final tagCounts = <String, int>{};

    for (final rating in ratings) {
      totalRating += rating.rating;
      distribution[rating.rating.round()] =
          (distribution[rating.rating.round()] ?? 0) + 1;

      if (rating.isVerifiedBooking) verifiedCount++;
      if (rating.review != null && rating.review!.isNotEmpty) withTextCount++;
      if (rating.images.isNotEmpty) withImagesCount++;

      for (final tag in rating.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    // Get top tags
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(5).map((e) => e.key).toList();

    // Calculate recommendation score (4+ stars)
    final recommendCount = (distribution[5] ?? 0) + (distribution[4] ?? 0);
    final recommendationScore = (recommendCount / ratings.length) * 100;

    return RatingStats(
      averageRating: totalRating / ratings.length,
      totalRatings: ratings.length,
      ratingDistribution: distribution,
      verifiedRatings: verifiedCount,
      reviewsWithText: withTextCount,
      reviewsWithImages: withImagesCount,
      topTags: topTags,
      recommendationScore: recommendationScore,
    );
  }

  /// Calculate statistics from a list of ratings (for demo mode)
  RatingStats _calculateStatsFromRatings(List<RatingModel> ratings) {
    if (ratings.isEmpty) {
      return RatingStats(
        averageRating: 0.0,
        totalRatings: 0,
        ratingDistribution: {5: 0, 4: 0, 3: 0, 2: 0, 1: 0},
      );
    }

    // Calculate distribution
    final distribution = <int, int>{5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    double totalRating = 0;
    int verifiedCount = 0;
    int withTextCount = 0;
    int withImagesCount = 0;
    final tagCounts = <String, int>{};

    for (final rating in ratings) {
      totalRating += rating.rating;
      distribution[rating.rating.round()] =
          (distribution[rating.rating.round()] ?? 0) + 1;

      if (rating.isVerifiedBooking) verifiedCount++;
      if (rating.review != null && rating.review!.isNotEmpty) withTextCount++;
      if (rating.images.isNotEmpty) withImagesCount++;

      for (final tag in rating.tags) {
        tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
      }
    }

    // Get top tags
    final sortedTags = tagCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topTags = sortedTags.take(5).map((e) => e.key).toList();

    // Calculate recommendation score (4+ stars)
    final recommendCount = (distribution[5] ?? 0) + (distribution[4] ?? 0);
    final recommendationScore = (recommendCount / ratings.length) * 100;

    return RatingStats(
      averageRating: totalRating / ratings.length,
      totalRatings: ratings.length,
      ratingDistribution: distribution,
      verifiedRatings: verifiedCount,
      reviewsWithText: withTextCount,
      reviewsWithImages: withImagesCount,
      topTags: topTags,
      recommendationScore: recommendationScore,
    );
  }

  // ===== MOCK DATA FOR DEMO MODE =====

  List<RatingModel> _getMockEventRatings(String eventId) {
    return [
      RatingModel(
        id: 'r1',
        userId: 'u1',
        userName: 'Sarah Johnson',
        eventId: eventId,
        eventName: 'Sample Event',
        rating: 5.0,
        review:
            'Amazing experience! The venue was perfect and the organization was top-notch.',
        tags: ['Great venue', 'Well organized', 'Great atmosphere'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        isVerifiedBooking: true,
        helpfulCount: 12,
      ),
      RatingModel(
        id: 'r2',
        userId: 'u2',
        userName: 'Michael Chen',
        eventId: eventId,
        eventName: 'Sample Event',
        rating: 4.0,
        review:
            'Good event overall, but the parking situation could be improved.',
        tags: ['Good entertainment', 'Parking issues'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        isVerifiedBooking: true,
        helpfulCount: 8,
      ),
    ];
  }

  List<RatingModel> _getMockPlatformRatings() {
    return [
      RatingModel(
        id: 'p1',
        userId: 'u1',
        userName: 'Emma Wilson',
        rating: 5.0,
        review:
            'Best event management platform! Easy to use and great event recommendations.',
        tags: ['Easy to use', 'Great events', 'User friendly'],
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        helpfulCount: 25,
      ),
      RatingModel(
        id: 'p2',
        userId: 'u2',
        userName: 'David Kumar',
        rating: 4.5,
        review: 'Really good platform. Would love to see more payment options.',
        tags: ['Good selection', 'Need more features'],
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        helpfulCount: 15,
      ),
    ];
  }
}
