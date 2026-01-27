import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for ML-based event recommendations
class MLRecommendationService {
  final String baseUrl;

  MLRecommendationService({this.baseUrl = 'http://localhost:8000'});

  /// Get personalized recommendations for a user
  Future<List<RecommendationModel>> getRecommendations({
    required String userId,
    int limit = 10,
    bool excludeViewed = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/recommendations/').replace(
        queryParameters: {
          'user_id': userId,
          'limit': limit.toString(),
          'exclude_viewed': excludeViewed.toString(),
        },
      );

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => RecommendationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load recommendations: ${response.body}');
      }
    } catch (e) {
      print('Error getting recommendations: $e');
      return [];
    }
  }

  /// Get events similar to a given event
  Future<List<RecommendationModel>> getSimilarEvents({
    required String eventId,
    int limit = 5,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/recommendations/similar/$eventId')
          .replace(queryParameters: {'limit': limit.toString()});

      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((json) => RecommendationModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load similar events: ${response.body}');
      }
    } catch (e) {
      print('Error getting similar events: $e');
      return [];
    }
  }

  /// Record a user interaction with an event
  Future<bool> recordInteraction({
    required String userId,
    required String eventId,
    required String interactionType,
    double? rating,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recommendations/interaction'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'event_id': eventId,
          'interaction_type': interactionType,
          if (rating != null) 'rating': rating,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error recording interaction: $e');
      return false;
    }
  }

  /// Provide feedback on a recommendation
  Future<bool> provideFeedback({
    required String userId,
    required String eventId,
    required bool liked,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recommendations/feedback')
            .replace(queryParameters: {
          'user_id': userId,
          'event_id': eventId,
          'liked': liked.toString(),
        }),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error providing feedback: $e');
      return false;
    }
  }

  /// Get model statistics
  Future<Map<String, dynamic>?> getModelStats() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recommendations/model/stats'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting model stats: $e');
      return null;
    }
  }

  /// Train the model with interaction data
  Future<Map<String, dynamic>?> trainModel({
    required List<Map<String, dynamic>> interactions,
    int nFactors = 50,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/recommendations/train'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'interactions': interactions,
          'n_factors': nFactors,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to train model: ${response.body}');
      }
    } catch (e) {
      print('Error training model: $e');
      return null;
    }
  }
}

/// Model for recommendation results
class RecommendationModel {
  final String eventId;
  final double score;
  final String reason;

  RecommendationModel({
    required this.eventId,
    required this.score,
    required this.reason,
  });

  factory RecommendationModel.fromJson(Map<String, dynamic> json) {
    return RecommendationModel(
      eventId: json['event_id'] as String,
      score: (json['score'] as num).toDouble(),
      reason: json['reason'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event_id': eventId,
      'score': score,
      'reason': reason,
    };
  }

  @override
  String toString() {
    return 'Recommendation(eventId: $eventId, score: ${score.toStringAsFixed(3)}, reason: $reason)';
  }
}
