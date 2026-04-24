import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for Component 3: Organizer Trust Assessment
class TrustAssessmentService {
  final String baseUrl;

  TrustAssessmentService({this.baseUrl = 'http://localhost:8000'});

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

  /// Run sample validation
  Future<Map<String, dynamic>> runSampleValidation() async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/predict-event'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "title": "Food Festival Colombo",
          "description": "A community event with local food stalls.",
          "price": 1500,
          "location": "Colombo",
          "category": "Food"
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'prediction': data['prediction'],
          'trust_score': '${data['trust_score']}%',
          'real_probability': '${(data['real_probability'] * 100).toStringAsFixed(1)}%',
          'fake_probability': '${(data['fake_probability'] * 100).toStringAsFixed(1)}%',
          'trust_level': data['prediction'] == 'Real' ? 'trusted' : 'not_trusted'
        };
      } else {
        throw Exception('Failed to run sample: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error predicting event: $e');
    }
  }
}

/// Service for Component 4: Event Budget Planning
class BudgetPlanningService {
  final String baseUrl;

  BudgetPlanningService({this.baseUrl = 'http://localhost:8000'});

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
