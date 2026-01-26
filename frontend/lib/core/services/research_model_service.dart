import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for Model Comparison & Tuning APIs
class ResearchModelService {
  final String baseUrl;

  ResearchModelService({this.baseUrl = 'http://localhost:8000'});

  /// Benchmark multiple models
  Future<Map<String, dynamic>> benchmarkModels(Map<String, dynamic> request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/models/benchmark'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to benchmark models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error benchmarking models: $e');
    }
  }

  /// Perform hyperparameter search
  Future<Map<String, dynamic>> hyperparameterSearch(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/models/hyperparameter-search'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to perform hyperparameter search: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error performing hyperparameter search: $e');
    }
  }

  /// Create ensemble from multiple models
  Future<Map<String, dynamic>> createEnsemble(Map<String, dynamic> request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/models/ensemble'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create ensemble: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating ensemble: $e');
    }
  }

  /// Test statistical significance
  Future<Map<String, dynamic>> statisticalSignificanceTest(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/models/significance-test'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to test significance: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error testing significance: $e');
    }
  }

  /// Compare CF, Hybrid, and Graph models
  Future<Map<String, dynamic>> compareThreeModels(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/models/compare-cf-hybrid-graph'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to compare models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error comparing models: $e');
    }
  }

  /// Get list of registered models
  Future<Map<String, dynamic>> getRegisteredModels() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/research/models/registered-models'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get registered models: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting registered models: $e');
    }
  }

  /// Get sample model comparison
  Future<Map<String, dynamic>> getSampleComparison() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/research/models/sample-comparison'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get sample comparison: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting sample comparison: $e');
    }
  }

  /// Get tuning recommendations
  Future<Map<String, dynamic>> getTuningRecommendations() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/research/models/tuning-recommendations'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get tuning recommendations: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting tuning recommendations: $e');
    }
  }
}
