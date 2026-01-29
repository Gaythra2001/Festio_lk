import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for MA-EPOM (Multilingual AI-Based Event Promotion Optimization)
class MAEPOMService {
  final String baseUrl;

  MAEPOMService({this.baseUrl = 'http://localhost:8000'});

  /// Generate personalized multilingual event promotion
  Future<Map<String, dynamic>> generatePromotion({
    required String userId,
    required Map<String, dynamic> eventData,
    required Map<String, dynamic> userPreferences,
    required List<Map<String, dynamic>> interactionHistory,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/promotion/generate-promotion'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'event': eventData,
          'user_preferences': userPreferences,
          'interaction_history': interactionHistory,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to generate promotion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error generating promotion: $e');
    }
  }

  /// Detect language from text
  Future<Map<String, dynamic>> detectLanguage(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/promotion/detect-language'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'text': text}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to detect language: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error detecting language: $e');
    }
  }

  /// Translate event to target language
  Future<Map<String, dynamic>> translateEvent({
    required Map<String, dynamic> eventData,
    required String targetLanguage,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/promotion/translate-event'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'event_data': eventData,
          'target_language': targetLanguage,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to translate event: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error translating event: $e');
    }
  }

  /// Predict engagement probability
  Future<Map<String, dynamic>> predictEngagement({
    required Map<String, dynamic> interactionData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/promotion/predict-engagement'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'interaction_data': interactionData}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to predict engagement: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error predicting engagement: $e');
    }
  }

  /// Optimize notification timing
  Future<Map<String, dynamic>> optimizeNotificationTime({
    required String userId,
    required List<Map<String, dynamic>> interactionHistory,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/promotion/optimize-notification-time'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'user_id': userId,
          'interaction_history': interactionHistory,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to optimize timing: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error optimizing timing: $e');
    }
  }

  /// Analyze sentiment from review
  Future<Map<String, dynamic>> analyzeSentiment({
    required String reviewText,
    required double rating,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/promotion/analyze-sentiment'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'review_text': reviewText,
          'rating': rating,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze sentiment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing sentiment: $e');
    }
  }

  /// Evaluate campaign performance
  Future<Map<String, dynamic>> evaluateCampaigns({
    required List<Map<String, dynamic>> promotions,
    required List<Map<String, dynamic>> feedback,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/promotion/evaluate-campaigns'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'promotions': promotions,
          'feedback': feedback,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to evaluate campaigns: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error evaluating campaigns: $e');
    }
  }

  /// Get supported languages
  Future<Map<String, dynamic>> getSupportedLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/promotion/supported-languages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get languages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting languages: $e');
    }
  }

  /// Run sample promotion workflow
  Future<Map<String, dynamic>> runSampleWorkflow() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/promotion/sample-promotion-workflow'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to run sample: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error running sample: $e');
    }
  }

  /// Get model information
  Future<Map<String, dynamic>> getModelInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/promotion/model-info'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get model info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting model info: $e');
    }
  }
}
