import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for Evaluation & Fairness/Diversity Analysis APIs
class ResearchEvaluationService {
  final String baseUrl;

  ResearchEvaluationService({this.baseUrl = 'http://localhost:8000'});

  /// Calculate ranking metrics (NDCG, MAP, Recall, Precision)
  Future<Map<String, dynamic>> calculateRankingMetrics(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/evaluation/ranking-metrics'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to calculate ranking metrics: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calculating ranking metrics: $e');
    }
  }

  /// Calculate diversity score
  Future<Map<String, dynamic>> calculateDiversity(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/evaluation/diversity'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to calculate diversity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calculating diversity: $e');
    }
  }

  /// Calculate novelty score
  Future<Map<String, dynamic>> calculateNovelty(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/evaluation/novelty'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to calculate novelty: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calculating novelty: $e');
    }
  }

  /// Calculate popularity bias
  Future<Map<String, dynamic>> calculatePopularityBias(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/evaluation/popularity-bias'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to calculate popularity bias: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calculating popularity bias: $e');
    }
  }

  /// Assess demographic parity
  Future<Map<String, dynamic>> assessDemographicParity(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/evaluation/demographic-parity'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to assess demographic parity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error assessing demographic parity: $e');
    }
  }

  /// Assess provider parity
  Future<Map<String, dynamic>> assessProviderParity(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/evaluation/provider-parity'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to assess provider parity: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error assessing provider parity: $e');
    }
  }

  /// Calculate business KPIs
  Future<Map<String, dynamic>> calculateBusinessKPIs(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/evaluation/business-kpis'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to calculate business KPIs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error calculating business KPIs: $e');
    }
  }

  /// Run comprehensive evaluation
  Future<Map<String, dynamic>> comprehensiveEvaluation(
    Map<String, dynamic> request,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/evaluation/comprehensive'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to run comprehensive evaluation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error running comprehensive evaluation: $e');
    }
  }

  /// Get sample evaluation
  Future<Map<String, dynamic>> getSampleEvaluation() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/research/evaluation/sample-evaluation'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get sample evaluation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting sample evaluation: $e');
    }
  }

  /// Get metrics documentation
  Future<Map<String, dynamic>> getMetricsDocumentation() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/research/evaluation/metrics-documentation'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get metrics documentation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting metrics documentation: $e');
    }
  }
}
