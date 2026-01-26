import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service for Feature Engineering Experiments APIs
class ResearchFeatureService {
  final String baseUrl;

  ResearchFeatureService({this.baseUrl = 'http://localhost:8000'});

  /// Extract temporal features from interaction data
  Future<Map<String, dynamic>> extractTemporalFeatures(
    List<Map<String, dynamic>> interactionData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/features/extract/temporal'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(interactionData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to extract temporal features: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error extracting temporal features: $e');
    }
  }

  /// Extract price-sensitivity features
  Future<Map<String, dynamic>> extractPriceFeatures(
    List<Map<String, dynamic>> interactionData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/features/extract/price-sensitivity'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(interactionData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to extract price features: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error extracting price features: $e');
    }
  }

  /// Extract location-distance features
  Future<Map<String, dynamic>> extractLocationFeatures(
    List<Map<String, dynamic>> interactionData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/features/extract/location-distance'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(interactionData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to extract location features: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error extracting location features: $e');
    }
  }

  /// Extract all features at once
  Future<Map<String, dynamic>> extractAllFeatures(
    List<Map<String, dynamic>> interactionData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/features/extract/all'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(interactionData),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to extract all features: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error extracting all features: $e');
    }
  }

  /// Run ablation study
  Future<Map<String, dynamic>> runAblationStudy(Map<String, dynamic> request) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/research/features/ablation-study'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(request),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to run ablation study: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error running ablation study: $e');
    }
  }

  /// Get sample feature data
  Future<Map<String, dynamic>> getSampleData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/research/features/sample-data'),
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

  /// Get feature documentation
  Future<Map<String, dynamic>> getFeatureDocumentation() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/research/features/feature-documentation'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to get feature documentation: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting feature documentation: $e');
    }
  }
}
