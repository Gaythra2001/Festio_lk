import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// AI Revenue Optimizer Card Widget
/// Displays AI-powered pricing recommendations to maximize event revenue
class AIRevenueOptimizerCard extends StatefulWidget {
  final String eventId;
  final String eventCategory;
  final int daysBeforeEvent;
  final int venueCapacity;
  final double currentPrice;
  final String location;
  final double organizerRating;
  final String weatherForecast;
  final int pastAttendance;
  final bool isWeekend;
  final Function(double) onPriceUpdated;
  final String? apiBaseUrl;

  const AIRevenueOptimizerCard({
    super.key,
    required this.eventId,
    required this.eventCategory,
    required this.daysBeforeEvent,
    required this.venueCapacity,
    required this.currentPrice,
    required this.location,
    required this.organizerRating,
    required this.weatherForecast,
    required this.pastAttendance,
    required this.isWeekend,
    required this.onPriceUpdated,
    this.apiBaseUrl,
  });

  @override
  State<AIRevenueOptimizerCard> createState() => _AIRevenueOptimizerCardState();
}

class _AIRevenueOptimizerCardState extends State<AIRevenueOptimizerCard> {
  bool _isLoading = false;
  Map<String, dynamic>? _recommendation;
  String? _error;
  Map<String, int> _categoryMapping = {};
  Map<String, int> _locationMapping = {};
  Map<String, int> _weatherMapping = {};
  late String _apiBaseUrl;

  @override
  void initState() {
    super.initState();
    _apiBaseUrl = widget.apiBaseUrl ??
        (kIsWeb ? 'http://127.0.0.1:8001' : 'http://10.0.2.2:8001');
    _loadMappings();
  }

  Future<void> _loadMappings() async {
    try {
      final response = await http.get(
        Uri.parse('$_apiBaseUrl/api/revenue-optimization/categories'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _categoryMapping = Map<String, int>.from(data['categories'] ?? {});
          _locationMapping = Map<String, int>.from(data['locations'] ?? {});
          _weatherMapping = Map<String, int>.from(data['weather'] ?? {});
        });
      }
    } catch (e) {
      print('Error loading mappings: $e');
    }
  }

  Future<void> _getAIRecommendation() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _recommendation = null;
    });

    try {
      // Map strings to encoded IDs
      int categoryEncoded = _categoryMapping[widget.eventCategory] ?? 0;
      int locationEncoded = _locationMapping[widget.location] ?? 0;
      int weatherEncoded = _weatherMapping[widget.weatherForecast] ?? 0;

      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/revenue-optimization/optimize'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'days_before_event': widget.daysBeforeEvent,
          'category_encoded': categoryEncoded,
          'venue_capacity': widget.venueCapacity,
          'location_encoded': locationEncoded,
          'weekend_flag': widget.isWeekend ? 1 : 0,
          'organizer_rating': widget.organizerRating,
          'weather_encoded': weatherEncoded,
          'past_event_attendance': widget.pastAttendance,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _recommendation = data;
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to get recommendation: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to get AI recommendation: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _applyRecommendation() async {
    if (_recommendation == null) return;

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/revenue-optimization/apply'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'event_id': widget.eventId,
          'old_price': widget.currentPrice,
          'new_price': _recommendation!['recommended_price'].toDouble(),
          'predicted_revenue': _recommendation!['expected_revenue'].toDouble(),
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        widget.onPriceUpdated(_recommendation!['recommended_price'].toDouble());
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('AI recommendation applied successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }

        // Reset recommendation view
        if (mounted) {
          setState(() {
            _recommendation = null;
          });
        }
      } else {
        throw Exception('Failed to apply recommendation: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply recommendation: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _rejectRecommendation() async {
    if (_recommendation == null) return;

    try {
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/api/revenue-optimization/reject-recommendation?event_id=${widget.eventId}'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _recommendation = null;
          });
        }
      }
    } catch (e) {
      print('Error rejecting recommendation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.purple.shade700, Colors.deepPurple.shade900],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Revenue Optimization',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Maximize your event revenue with AI-powered pricing',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_recommendation != null)
                    Chip(
                      label: Text(
                        _recommendation!['model_used'] ?? 'unknown',
                        style: const TextStyle(fontSize: 11, color: Colors.white),
                      ),
                      backgroundColor: Colors.white.withOpacity(0.2),
                      side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Content
              if (_isLoading)
                _buildLoadingState()
              else if (_error != null)
                _buildErrorState()
              else if (_recommendation == null)
                _buildGetRecommendationButton()
              else
                _buildRecommendationDisplay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Analyzing your event data...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _getAIRecommendation,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGetRecommendationButton() {
    return Column(
      children: [
        const Text(
          'Event Details:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildDetailChip(Icons.calendar_today, '${widget.daysBeforeEvent} days'),
            _buildDetailChip(Icons.location_on, widget.location),
            _buildDetailChip(Icons.people, '${widget.venueCapacity} cap'),
            _buildDetailChip(Icons.star, '${widget.organizerRating} rating'),
            _buildDetailChip(Icons.wb_sunny, widget.weatherForecast),
            _buildDetailChip(Icons.weekend, widget.isWeekend ? 'Weekend' : 'Weekday'),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          'Current Price: LKR ${widget.currentPrice.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _getAIRecommendation,
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Get AI Recommendation'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple.shade700,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationDisplay() {
    double recommendedPrice = (_recommendation!['recommended_price'] ?? 2500).toDouble();
    double expectedRevenue = (_recommendation!['expected_revenue'] ?? 0).toDouble();
    double priceDifference = recommendedPrice - widget.currentPrice;
    bool isPriceIncrease = priceDifference > 0;
    double priceChangePercent = (priceDifference / widget.currentPrice * 100);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Recommended Price Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Recommended Ticket Price',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LKR ${recommendedPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current: LKR ${widget.currentPrice.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isPriceIncrease
                          ? Colors.green.withOpacity(0.3)
                          : Colors.orange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isPriceIncrease
                            ? Colors.green.withOpacity(0.5)
                            : Colors.orange.withOpacity(0.5),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isPriceIncrease ? '^' : 'v'} ${priceChangePercent.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: isPriceIncrease
                                ? Colors.greenAccent
                                : Colors.orangeAccent,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${isPriceIncrease ? '+' : ''}LKR ${priceDifference.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Expected Revenue Section
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Expected Revenue',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LKR ${expectedRevenue.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(
                Icons.trending_up,
                color: Colors.greenAccent,
                size: 40,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Price Breakdown
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _buildBreakdownRow('Location', widget.location),
              const SizedBox(height: 8),
              _buildBreakdownRow('Weather', widget.weatherForecast),
              const SizedBox(height: 8),
              _buildBreakdownRow('Day Type', widget.isWeekend ? 'Weekend' : 'Weekday'),
              const SizedBox(height: 8),
              _buildBreakdownRow('Org. Rating', '${widget.organizerRating} ★'),
              const SizedBox(height: 8),
              _buildBreakdownRow('Past Attendance', '${widget.pastAttendance}'),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _rejectRecommendation,
                icon: const Icon(Icons.close),
                label: const Text('Decline'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _getAIRecommendation,
                icon: const Icon(Icons.refresh),
                label: const Text('Recalculate'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _applyRecommendation,
                icon: const Icon(Icons.check_circle),
                label: const Text('Apply Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Info Text
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade200,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'This recommendation is based on historical event data and current market conditions.',
                  style: TextStyle(
                    color: Colors.blue.shade200,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
