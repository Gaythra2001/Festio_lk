import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../models/booking_model.dart';

/// AI-Based Event Recommendation Engine
/// Implements Collaborative Filtering and Semantic Analysis
class RecommendationEngine {
  /// Collaborative Filtering - Recommend events based on similar users
  List<EventModel> getCollaborativeRecommendations(
    UserModel user,
    List<EventModel> allEvents,
    List<BookingModel> userBookings,
    Map<String, List<BookingModel>> allUserBookings,
  ) {
    // Find similar users based on booking history
    final similarUsers = _findSimilarUsers(user, userBookings, allUserBookings);
    
    // Get events liked by similar users
    final recommendedEventIds = <String>{};
    for (final similarUserId in similarUsers.keys) {
      final bookings = allUserBookings[similarUserId] ?? [];
      for (final booking in bookings) {
        if (!userBookings.any((b) => b.eventId == booking.eventId)) {
          recommendedEventIds.add(booking.eventId);
        }
      }
    }
    
    return allEvents.where((e) => recommendedEventIds.contains(e.id)).toList();
  }

  /// Semantic Analysis & Context Awareness using NLP
  List<EventModel> getSemanticRecommendations(
    UserModel user,
    List<EventModel> allEvents,
    List<BookingModel> userBookings,
    String? searchQuery,
  ) {
    // Analyze user preferences from booking history
    final preferredCategories = _extractPreferredCategories(userBookings, allEvents);
    final preferredLocations = _extractPreferredLocations(userBookings, allEvents);
    
    // Score events based on semantic similarity
    final scoredEvents = allEvents.map((event) {
      double score = 0.0;
      
      // Category match
      if (preferredCategories.contains(event.category)) {
        score += 0.4;
      }
      
      // Location match
      if (preferredLocations.contains(event.location)) {
        score += 0.3;
      }
      
      // Search query similarity (if provided)
      if (searchQuery != null) {
        score += _calculateTextSimilarity(searchQuery, event.title) * 0.3;
      }
      
      // Trust score boost
      score += (event.trustScore / 100) * 0.1;
      
      return MapEntry(event, score);
    }).toList();
    
    // Sort by score and return top recommendations
    scoredEvents.sort((a, b) => b.value.compareTo(a.value));
    return scoredEvents.take(10).map((e) => e.key).toList();
  }

  /// Hybrid Recommendation - Combines Collaborative and Semantic
  List<EventModel> getHybridRecommendations(
    UserModel user,
    List<EventModel> allEvents,
    List<BookingModel> userBookings,
    Map<String, List<BookingModel>> allUserBookings,
    String? searchQuery,
  ) {
    final collaborative = getCollaborativeRecommendations(
      user,
      allEvents,
      userBookings,
      allUserBookings,
    );
    
    final semantic = getSemanticRecommendations(
      user,
      allEvents,
      userBookings,
      searchQuery,
    );
    
    // Combine and deduplicate
    final combined = <String, EventModel>{};
    for (final event in collaborative) {
      combined[event.id] = event;
    }
    for (final event in semantic) {
      combined[event.id] = event;
    }
    
    return combined.values.toList();
  }

  Map<String, double> _findSimilarUsers(
    UserModel user,
    List<BookingModel> userBookings,
    Map<String, List<BookingModel>> allUserBookings,
  ) {
    final similarities = <String, double>{};
    final userEventIds = userBookings.map((b) => b.eventId).toSet();
    
    for (final entry in allUserBookings.entries) {
      if (entry.key == user.id) continue;
      
      final otherEventIds = entry.value.map((b) => b.eventId).toSet();
      final intersection = userEventIds.intersection(otherEventIds).length;
      final union = userEventIds.union(otherEventIds).length;
      
      if (union > 0) {
        similarities[entry.key] = intersection / union; // Jaccard similarity
      }
    }
    
    return similarities;
  }

  Set<String> _extractPreferredCategories(
    List<BookingModel> bookings,
    List<EventModel> events,
  ) {
    final categoryCounts = <String, int>{};
    for (final booking in bookings) {
      final event = events.firstWhere(
        (e) => e.id == booking.eventId,
        orElse: () => events.first,
      );
      categoryCounts[event.category] = (categoryCounts[event.category] ?? 0) + 1;
    }
    
    // Return top 3 categories
    final sorted = categoryCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(3).map((e) => e.key).toSet();
  }

  Set<String> _extractPreferredLocations(
    List<BookingModel> bookings,
    List<EventModel> events,
  ) {
    final locationCounts = <String, int>{};
    for (final booking in bookings) {
      final event = events.firstWhere(
        (e) => e.id == booking.eventId,
        orElse: () => events.first,
      );
      locationCounts[event.location] = (locationCounts[event.location] ?? 0) + 1;
    }
    
    // Return top 2 locations
    final sorted = locationCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(2).map((e) => e.key).toSet();
  }

  double _calculateTextSimilarity(String query, String text) {
    // Simple keyword-based similarity
    final queryWords = query.toLowerCase().split(' ');
    final textWords = text.toLowerCase().split(' ');
    
    int matches = 0;
    for (final word in queryWords) {
      if (textWords.any((tw) => tw.contains(word) || word.contains(tw))) {
        matches++;
      }
    }
    
    return queryWords.isEmpty ? 0.0 : matches / queryWords.length;
  }
}

