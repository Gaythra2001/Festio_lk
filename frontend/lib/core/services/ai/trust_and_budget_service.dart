import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../config/app_config.dart';

/// Service for Component 3: Organizer Trust Assessment
class TrustAssessmentService {
  final String baseUrl;

  TrustAssessmentService({String? baseUrl})
      : baseUrl = baseUrl ??
            (kIsWeb ? backendBaseUrl : 'http://10.0.2.2:8001');

  /// Validate event and organizer
  Future<Map<String, dynamic>> validateEvent({
    required Map<String, dynamic> eventData,
    required Map<String, dynamic> organizerData,
    required List<Map<String, dynamic>> reviews,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trust/validate-event'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'event': eventData,
          'organizer': organizerData,
          'reviews': reviews,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to validate event: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error validating event: $e');
    }
  }

  /// Detect fraud
  Future<Map<String, dynamic>> detectFraud({
    required Map<String, dynamic> eventData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trust/detect-fraud'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'event': eventData}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to detect fraud: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error detecting fraud: $e');
    }
  }

  /// Check organizer reputation
  Future<Map<String, dynamic>> checkReputation({
    required Map<String, dynamic> organizerData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trust/check-reputation'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'organizer': organizerData}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check reputation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error checking reputation: $e');
    }
  }

  /// Analyze reviews
  Future<Map<String, dynamic>> analyzeReviews({
    required List<Map<String, dynamic>> reviews,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trust/analyze-reviews'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'reviews': reviews}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to analyze reviews: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing reviews: $e');
    }
  }

  /// Batch validate events
  Future<Map<String, dynamic>> batchValidate({
    required List<Map<String, dynamic>> events,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/trust/batch-validate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'events': events}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to batch validate: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error batch validating: $e');
    }
  }

  /// Verify event authenticity using the ML API
  Future<Map<String, dynamic>> verifyEventAuthenticity(Map<String, dynamic> eventData) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/trust/predict-event'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(eventData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'prediction': data['prediction'],
          'trust_score': _formatPercentage(data['trust_score'] ?? data['confidence'] ?? 0),
          'real_probability': _formatPercentage(data['real_probability'] ?? 0),
          'fake_probability': _formatPercentage(data['fake_probability'] ?? 0),
          'trust_level': data['trust_level'] ??
              (data['prediction'] == 'Real' ? 'highly_trusted' : 'not_trusted')
        };
      } else {
        throw Exception('Failed to verify event: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      String errorMessage = e.toString();
      
      // Check if it's a connection error
      if (errorMessage.contains('Failed to fetch') || 
          errorMessage.contains('Connection refused') ||
          errorMessage.contains('Failed host lookup')) {
        throw Exception(
          'Backend server not running. Please start the backend:\n\n'
          'cd backend\n'
          'python run.py\n\n'
          'Then try again. (Server should run on http://127.0.0.1:8001)'
        );
      }
      
      throw Exception('Error predicting event: $errorMessage');
    }
  }

  String _formatPercentage(dynamic value) {
    if (value == null) {
      return '0.0%';
    }

    if (value is num) {
      final percentage = value <= 1 ? value * 100 : value;
      return '${percentage.toStringAsFixed(1)}%';
    }

    final text = value.toString();
    return text.endsWith('%') ? text : '$text%';
  }
}

/// Service for Component 4: Event Budget Planning
class BudgetPlanningService {
  final String baseUrl;

  BudgetPlanningService({String? baseUrl})
      : baseUrl = baseUrl ??
            (kIsWeb ? backendBaseUrl : 'http://10.0.2.2:8001');

  /// Create complete budget plan
  Future<Map<String, dynamic>> createBudgetPlan({
    required Map<String, dynamic> eventData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/budget/create-plan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'event': eventData}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating plan: $e');
    }
  }

  /// Predict event cost
  Future<Map<String, dynamic>> predictCost({
    required Map<String, dynamic> eventData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/budget/predict-cost'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'event': eventData}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to predict cost: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error predicting cost: $e');
    }
  }

  /// Calculate budget breakdown
  Future<Map<String, dynamic>> calculateBreakdown({
    required Map<String, dynamic> eventData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/budget/breakdown'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'event': eventData}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to calculate breakdown: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calculating breakdown: $e');
    }
  }

  /// Get resource recommendations
  Future<Map<String, dynamic>> getRecommendations({
    required Map<String, dynamic> eventData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/budget/recommendations'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'event': eventData}),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting recommendations: $e');
    }
  }

  /// Compare scenarios
  Future<Map<String, dynamic>> compareScenarios({
    required Map<String, dynamic> baseEvent,
    required List<Map<String, dynamic>> scenarios,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/budget/compare-scenarios'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'base_event': baseEvent,
          'scenarios': scenarios,
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to compare scenarios: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error comparing scenarios: $e');
    }
  }

  /// Run sample budget plan
  Future<Map<String, dynamic>> runSamplePlan() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/budget/sample-plan'),
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
}
