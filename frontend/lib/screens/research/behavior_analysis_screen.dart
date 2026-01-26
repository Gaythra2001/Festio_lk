import 'package:flutter/material.dart';
import '../../core/services/research_behavior_service.dart';

/// User Behavior Mining & Cold-Start Study Screen
class BehaviorAnalysisScreen extends StatefulWidget {
  const BehaviorAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<BehaviorAnalysisScreen> createState() => _BehaviorAnalysisScreenState();
}

class _BehaviorAnalysisScreenState extends State<BehaviorAnalysisScreen> {
  final ResearchBehaviorService _service = ResearchBehaviorService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _clickAnalysis;
  Map<String, dynamic>? _bookingAnalysis;
  Map<String, dynamic>? _clusteringResult;
  Map<String, dynamic>? _coldStartResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Behavior Mining'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Component 1: User Behavior Mining & Cold-Start Study',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Analyze click/booking logs, cluster user intents, and test cold-start strategies',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadSampleData,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load Sample Data'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _analyzeClicks,
                  icon: const Icon(Icons.mouse),
                  label: const Text('Analyze Clicks'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _analyzeBookings,
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Analyze Bookings'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _clusterUsers,
                  icon: const Icon(Icons.group_work),
                  label: const Text('Cluster Users'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _testColdStart,
                  icon: const Icon(Icons.person_add),
                  label: const Text('Test Cold-Start'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            // Results Display
            if (_clickAnalysis != null) ...[
              _buildResultCard(
                'Click Analysis Results',
                _clickAnalysis!,
                Icons.mouse,
                Colors.blue,
              ),
              const SizedBox(height: 16),
            ],
            
            if (_bookingAnalysis != null) ...[
              _buildResultCard(
                'Booking Analysis Results',
                _bookingAnalysis!,
                Icons.shopping_cart,
                Colors.green,
              ),
              const SizedBox(height: 16),
            ],
            
            if (_clusteringResult != null) ...[
              _buildResultCard(
                'User Clustering Results',
                _clusteringResult!,
                Icons.group_work,
                Colors.orange,
              ),
              const SizedBox(height: 16),
            ],
            
            if (_coldStartResult != null) ...[
              _buildResultCard(
                'Cold-Start Recommendations',
                _coldStartResult!,
                Icons.person_add,
                Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    String title,
    Map<String, dynamic> data,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                _formatJson(data),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatJson(Map<String, dynamic> json) {
    return json.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }

  Future<void> _loadSampleData() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.getSampleData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Loaded ${result['data']['click_logs_count']} click logs'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _analyzeClicks() async {
    setState(() => _isLoading = true);
    try {
      // Using sample data
      final sampleData = await _service.getSampleData();
      final clickLogs = sampleData['data']['click_logs'] as List;
      final result = await _service.analyzeClicks(
        clickLogs.cast<Map<String, dynamic>>(),
      );
      setState(() => _clickAnalysis = result['analysis']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _analyzeBookings() async {
    setState(() => _isLoading = true);
    try {
      final sampleData = await _service.getSampleData();
      final bookingLogs = sampleData['data']['booking_logs'] as List;
      final result = await _service.analyzeBookings(
        bookingLogs.cast<Map<String, dynamic>>(),
      );
      setState(() => _bookingAnalysis = result['analysis']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clusterUsers() async {
    setState(() => _isLoading = true);
    try {
      final sampleData = await _service.getSampleData();
      final userFeatures = sampleData['data']['user_features'] as List;
      final result = await _service.clusterUsers(
        userFeatures.cast<Map<String, dynamic>>(),
      );
      setState(() => _clusteringResult = result['clustering']);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testColdStart() async {
    setState(() => _isLoading = true);
    try {
      // Mock event data for cold-start
      final eventData = List.generate(20, (i) => {
        'event_id': i + 1,
        'view_count': (i + 1) * 10,
        'booking_count': (i + 1) * 2,
        'rating': 3.5 + (i % 3) * 0.5,
      });
      
      final result = await _service.coldStartPopularity(eventData, 10);
      setState(() => _coldStartResult = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
