import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RevenueOptimizationService {
  final String baseUrl;

  RevenueOptimizationService({String? baseUrl})
      : baseUrl = baseUrl ?? (kIsWeb ? 'http://localhost:8001' : 'http://10.0.2.2:8001');

  Future<Map<String, dynamic>> optimizeRevenue({
    required int daysBeforeEvent,
    required int categoryEncoded,
    required int venueCapacity,
    required int locationEncoded,
    required int weekendFlag,
    required double organizerRating,
    required int weatherEncoded,
    required int pastEventAttendance,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/revenue-optimization/optimize'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'days_before_event': daysBeforeEvent,
        'category_encoded': categoryEncoded,
        'venue_capacity': venueCapacity,
        'location_encoded': locationEncoded,
        'weekend_flag': weekendFlag,
        'organizer_rating': organizerRating,
        'weather_encoded': weatherEncoded,
        'past_event_attendance': pastEventAttendance,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Revenue optimization failed: ${response.statusCode} - ${response.body}');
  }
}
