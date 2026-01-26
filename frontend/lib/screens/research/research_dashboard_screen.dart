import 'package:flutter/material.dart';

/// Main Research Dashboard Screen
/// Provides access to all 4 research components
class ResearchDashboardScreen extends StatelessWidget {
  const ResearchDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Research Components'),
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildResearchCard(
              context,
              title: '1. User Behavior Mining',
              subtitle: 'Click/Booking Analysis & Cold-Start',
              icon: Icons.people_outline,
              color: Colors.blue,
              onTap: () {
                Navigator.pushNamed(context, '/research/behavior');
              },
            ),
            _buildResearchCard(
              context,
              title: '2. Feature Engineering',
              subtitle: 'Temporal, Price & Location Features',
              icon: Icons.engineering,
              color: Colors.green,
              onTap: () {
                Navigator.pushNamed(context, '/research/features');
              },
            ),
            _buildResearchCard(
              context,
              title: '3. Model Comparison',
              subtitle: 'CF vs Hybrid vs Graph Benchmarks',
              icon: Icons.compare_arrows,
              color: Colors.orange,
              onTap: () {
                Navigator.pushNamed(context, '/research/models');
              },
            ),
            _buildResearchCard(
              context,
              title: '4. Evaluation & Fairness',
              subtitle: 'NDCG, Diversity & Business KPIs',
              icon: Icons.assessment,
              color: Colors.purple,
              onTap: () {
                Navigator.pushNamed(context, '/research/evaluation');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResearchCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
