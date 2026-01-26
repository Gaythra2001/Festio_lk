import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for User Behavior Mining & Cold-Start Study APIs
class ResearchBehaviorService {
  final String baseUrl;

  ResearchBehaviorService({this.baseUrl = 'http://localhost:8000'});

  /// Analyze user click patterns
  Future<Map<String, dynamic>> analyzeClicks(List<Map<String, dynamic>> clickData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/behavior/analyze-clicks'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(clickData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze clicks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing clicks: $e');
    }
  }

  /// Analyze booking conversion patterns
  Future<Map<String, dynamic>> analyzeBookings(List<Map<String, dynamic>> bookingData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/behavior/analyze-bookings'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(bookingData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze bookings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing bookings: $e');
    }
  }

  /// Cluster users by behavioral patterns
  Future<Map<String, dynamic>> clusterUsers(List<Map<String, dynamic>> userFeatures) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/behavior/cluster-users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userFeatures),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to cluster users: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error clustering users: $e');
    }
  }

  /// Get cold-start recommendations using popularity
  Future<Map<String, dynamic>> coldStartPopularity(
    List<Map<String, dynamic>> eventData,
    int topN,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/behavior/cold-start/popularity?top_n=$topN'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(eventData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get cold-start recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting cold-start recommendations: $e');
    }
  }

  /// Get cold-start recommendations using content similarity
  Future<Map<String, dynamic>> coldStartContentSimilarity(
    Map<String, dynamic> userPrefs,
    List<Map<String, dynamic>> eventFeatures,
    int topN,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/behavior/cold-start/content-similarity?top_n=$topN'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_prefs': userPrefs,
          'event_features': eventFeatures,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get content-based recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting content-based recommendations: $e');
    }
  }

  /// Evaluate cold-start strategy
  Future<Map<String, dynamic>> evaluateColdStart(
    String strategyName,
    List<int> recommendations,
    List<int> actualInteractions,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/behavior/cold-start/evaluate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'strategy_name': strategyName,
          'recommendations': recommendations,
          'actual_interactions': actualInteractions,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to evaluate cold-start: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error evaluating cold-start: $e');
    }
  }

  /// Get sample behavior data for testing
  Future<Map<String, dynamic>> getSampleData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/research/behavior/sample-data'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get sample data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting sample data: $e');
    }
  }
}
