import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/interaction_tracking_provider.dart';

/// Dedicated metrics dashboard for recommendation quality and business KPIs
class RecommendationMetricsDashboard extends StatefulWidget {
  final String? userId;

  const RecommendationMetricsDashboard({
    Key? key,
    this.userId,
  }) : super(key: key);

  @override
  State<RecommendationMetricsDashboard> createState() =>
      _RecommendationMetricsDashboardState();
}

class _RecommendationMetricsDashboardState
    extends State<RecommendationMetricsDashboard> {
  int _selectedPeriod = 7; // days

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    final trackingProvider =
        Provider.of<InteractionTrackingProvider>(context, listen: false);
    await trackingProvider.fetchMetrics(daysBack: _selectedPeriod);
    if (widget.userId != null) {
      await trackingProvider.fetchUserAnalytics(
        userId: widget.userId!,
        daysBack: _selectedPeriod,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: Text(
          'Recommendation Metrics',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<int>(
            onSelected: (days) {
              setState(() {
                _selectedPeriod = days;
              });
              _loadMetrics();
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 7, child: Text('Last 7 days')),
              const PopupMenuItem(value: 30, child: Text('Last 30 days')),
              const PopupMenuItem(value: 90, child: Text('Last 90 days')),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  'Last $_selectedPeriod days',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<InteractionTrackingProvider>(
        builder: (context, trackingProvider, child) {
          if (trackingProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Quality Metrics Section
              _buildSectionHeader('Ranking Quality'),
              const SizedBox(height: 12),
              _buildQualityMetricsGrid(trackingProvider),

              const SizedBox(height: 32),

              // Engagement Metrics Section
              _buildSectionHeader('Engagement & Conversion'),
              const SizedBox(height: 12),
              _buildEngagementMetricsGrid(trackingProvider),

              const SizedBox(height: 32),

              // User Analytics Section
              if (trackingProvider.userAnalytics != null)
                Column(
                  children: [
                    _buildSectionHeader('Your Activity'),
                    const SizedBox(height: 12),
                    _buildUserAnalyticsCard(trackingProvider),
                    const SizedBox(height: 32),
                  ],
                ),

              // Retraining Option
              ElevatedButton.icon(
                onPressed: () {
                  _showRetrainingDialog(context, trackingProvider);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retrain Model'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),

              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildQualityMetricsGrid(InteractionTrackingProvider provider) {
    final metrics = provider.recentMetrics ?? {};

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricTile(
          'NDCG@10',
          '${((metrics['ndcg_10'] ?? 0) * 100).toStringAsFixed(1)}%',
          'Ranking quality\n(0-100%)',
          Icons.trending_up,
          Colors.blue,
        ),
        _buildMetricTile(
          'Recall@10',
          '${((metrics['recall_10'] ?? 0) * 100).toStringAsFixed(1)}%',
          'Coverage of\nuser interests',
          Icons.checklist,
          Colors.green,
        ),
        _buildMetricTile(
          'Precision@10',
          '${((metrics['precision_10'] ?? 0) * 100).toStringAsFixed(1)}%',
          'Fraction relevant\nin top 10',
          Icons.check_circle,
          Colors.cyan,
        ),
        _buildMetricTile(
          'MRR',
          '${((metrics['mrr'] ?? 0) * 100).toStringAsFixed(1)}%',
          'Position of first\nrelevant item',
          Icons.looks_one,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildEngagementMetricsGrid(InteractionTrackingProvider provider) {
    final metrics = provider.recentMetrics ?? {};

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildMetricTile(
          'CTR',
          '${(metrics['ctr'] ?? 0).toStringAsFixed(2)}%',
          'Click-through rate',
          Icons.touch_app,
          Colors.purple,
        ),
        _buildMetricTile(
          'Booking Rate',
          '${(metrics['booking_rate'] ?? 0).toStringAsFixed(2)}%',
          'Clicks to bookings',
          Icons.event_seat,
          Colors.red,
        ),
        _buildMetricTile(
          'Total Clicks',
          '${metrics['total_clicks'] ?? 0}',
          'Clicks in period',
          Icons.touch_app,
          Colors.indigo,
        ),
        _buildMetricTile(
          'Total Bookings',
          '${metrics['total_bookings'] ?? 0}',
          'Bookings in period',
          Icons.bookmark_add,
          Colors.pink,
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    String title,
    String value,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                title,
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: GoogleFonts.outfit(
                  color: Colors.white54,
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserAnalyticsCard(InteractionTrackingProvider provider) {
    final analytics = provider.userAnalytics ?? {};

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAnalyticRow(
            'Total Interactions',
            '${analytics['total_interactions'] ?? 0}',
            Icons.touch_app,
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildAnalyticRow(
            'Average Rating',
            '${analytics['avg_rating'] ?? 0}/5',
            Icons.star,
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildAnalyticRow(
            'Calendar Selections',
            '${analytics['calendar_selections'] ?? 0}',
            Icons.calendar_today,
          ),
          const Divider(color: Colors.white10, height: 20),
          _buildAnalyticRow(
            'Bookings',
            '${analytics['bookings'] ?? 0}',
            Icons.event_seat,
          ),
          if (analytics['channels'] != null) ...[
            const Divider(color: Colors.white10, height: 20),
            const SizedBox(height: 8),
            Text(
              'Channels Accessed',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (analytics['channels'] as Map?)
                      ?.entries
                      .map<Widget>((e) => Chip(
                            label: Text(
                              '${e.key}: ${e.value}',
                              style: GoogleFonts.outfit(
                                color: Colors.white,
                                fontSize: 11,
                              ),
                            ),
                            backgroundColor: Colors.purple.withOpacity(0.2),
                          ))
                      .toList() ??
                  [],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnalyticRow(String label, String value, IconData icon) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.purple, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showRetrainingDialog(
    BuildContext context,
    InteractionTrackingProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Retrain Model',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Retrain the recommendation model with recent interactions? This will use the last 90 days of data.',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await provider.retainModel();

              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result != null
                          ? 'Model retraining: ${result['message']}'
                          : 'Failed to retrain model',
                    ),
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            child: const Text('Retrain'),
          ),
        ],
      ),
    );
  }
}
