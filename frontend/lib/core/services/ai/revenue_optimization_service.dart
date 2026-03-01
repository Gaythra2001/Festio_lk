import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class RevenueOptimizationService {
  final String baseUrl;

  RevenueOptimizationService({String? baseUrl})
      : baseUrl = baseUrl ?? (kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000');

  Future<Map<String, dynamic>> optimizeRevenue({
    required String organizerId,
    required String eventId,
    String? eventCategory,
    required double currentPrice,
    required int ticketsSold,
    required int ticketsAvailable,
    int? venueCapacity,
    required int daysUntilEvent,
    double? salesTrend,
    double? competitorAvgPrice,
    double marketingBoost = 0.0,
    double demandGrowthRate = 0.0,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/revenue-optimization/optimize'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'organizer_id': organizerId,
        'event_id': eventId,
        'event_category': eventCategory ?? 'Festival',
        'current_price': currentPrice,
        'tickets_sold': ticketsSold,
        'tickets_available': ticketsAvailable,
        'venue_capacity': venueCapacity ?? ticketsAvailable,
        'days_before_event': daysUntilEvent,
        'sales_trend': salesTrend,
        'competitor_avg_price': competitorAvgPrice,
        'marketing_boost': marketingBoost,
        'demand_growth_rate': demandGrowthRate,
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    throw Exception('Revenue optimization failed: ${response.statusCode}');
  }
}
