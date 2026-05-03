import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AnalyticsApiService {
  final String baseUrl;

  AnalyticsApiService({String? baseUrl})
      : baseUrl = baseUrl ?? (kIsWeb ? 'http://localhost:8001' : 'http://10.0.2.2:8001');

  Future<void> trackEvent({
    required String organizerId,
    String? eventId,
    required String eventType,
    Map<String, dynamic>? metadata,
  }) async {
    await http.post(
      Uri.parse('$baseUrl/api/analytics/events'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'organizer_id': organizerId,
        'event_id': eventId,
        'event_type': eventType,
        'metadata': metadata,
      }),
    );
  }

  Future<Map<String, dynamic>> getSummary({
    required String organizerId,
    String? eventId,
    int windowDays = 30,
  }) async {
    final uri = Uri.parse('$baseUrl/api/analytics/summary').replace(
      queryParameters: {
        'organizer_id': organizerId,
        if (eventId != null) 'event_id': eventId,
        'window_days': windowDays.toString(),
      },
    );

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load analytics summary: ${response.statusCode}');
  }
}
