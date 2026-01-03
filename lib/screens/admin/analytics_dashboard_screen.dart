import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/analytics_provider.dart';

class AnalyticsDashboardScreen extends StatelessWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics Dashboard'),
      ),
      body: Consumer<AnalyticsProvider>(
        builder: (context, analyticsProvider, _) {
          if (analyticsProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final dashboardData = analyticsProvider.dashboardData;
          if (dashboardData == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Event Analytics'),
                _buildEventStats(dashboardData['events'] as Map<String, dynamic>),
                const SizedBox(height: 24),
                _buildSectionTitle('Booking Analytics'),
                _buildBookingStats(dashboardData['bookings'] as Map<String, dynamic>),
                const SizedBox(height: 24),
                _buildSectionTitle('User Analytics'),
                _buildUserStats(dashboardData['users'] as Map<String, dynamic>),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildEventStats(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Total Events', stats['total_events'].toString()),
            _buildStatRow('Approved Events', stats['approved_events'].toString()),
            _buildStatRow('Pending Events', stats['pending_events'].toString()),
            _buildStatRow('Spam Events', stats['spam_events'].toString()),
            _buildStatRow('Avg Trust Score', stats['trust_score_average'].toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingStats(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Total Bookings', stats['total_bookings'].toString()),
            _buildStatRow('Upcoming', stats['upcoming_bookings'].toString()),
            _buildStatRow('Past', stats['past_bookings'].toString()),
            _buildStatRow('Cancelled', stats['cancelled_bookings'].toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildUserStats(Map<String, dynamic> stats) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Total Users', stats['total_users'].toString()),
            _buildStatRow('Active Users', stats['active_users'].toString()),
            _buildStatRow('Avg Trust Score', stats['average_trust_score'].toStringAsFixed(1)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

