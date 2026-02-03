import 'dart:convert';
import 'package:http/http.dart' as http;

class RevenueOptimizationService {
  final String baseUrl;

  RevenueOptimizationService({this.baseUrl = 'http://localhost:8000'});

  Future<Map<String, dynamic>> optimizeRevenue({
    required String organizerId,
    required String eventId,
    required double currentPrice,
    required int ticketsSold,
    required int ticketsAvailable,
    required int daysUntilEvent,
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
        'current_price': currentPrice,
        'tickets_sold': ticketsSold,
        'tickets_available': ticketsAvailable,
        'days_until_event': daysUntilEvent,
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
