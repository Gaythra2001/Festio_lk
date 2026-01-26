import 'package:flutter/material.dart';
import '../../core/services/research_evaluation_service.dart';

/// Evaluation & Fairness/Diversity Analysis Screen
class EvaluationDashboardScreen extends StatefulWidget {
  const EvaluationDashboardScreen({Key? key}) : super(key: key);

  @override
  State<EvaluationDashboardScreen> createState() => _EvaluationDashboardScreenState();
}

class _EvaluationDashboardScreenState extends State<EvaluationDashboardScreen> {
  final ResearchEvaluationService _service = ResearchEvaluationService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _evaluationResult;
  Map<String, dynamic>? _metricsDocs;

  @override
  void initState() {
    super.initState();
    _loadMetricsDocs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evaluation & Fairness'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Component 4: Evaluation & Fairness/Diversity Analysis',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Track NDCG/MAP/Recall@K, diversity, novelty, and business KPIs',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Metrics Documentation
            if (_metricsDocs != null) ...[
              _buildMetricsDocsCard(_metricsDocs!),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _runSampleEvaluation,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run Sample Evaluation'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            // Evaluation Results
            if (_evaluationResult != null) ...[
              _buildEvaluationCard(_evaluationResult!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsDocsCard(Map<String, dynamic> docs) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Evaluation Metrics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (docs['metrics'] != null)
              ...((docs['metrics'] as Map).entries.map((category) {
                final metrics = category.value as Map<String, dynamic>;
                return ExpansionTile(
                  title: Text(
                    category.key.replaceAll('_', ' ').toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  children: metrics.entries.map((metric) {
                    return ListTile(
                      title: Text(metric.key),
                      subtitle: Text(metric.value.toString()),
                      dense: true,
                    );
                  }).toList(),
                );
              }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationCard(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assessment, color: Colors.purple),
                SizedBox(width: 8),
                Text(
                  'Comprehensive Evaluation Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Data Summary
            if (data['data_summary'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Data Summary:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Recommended: ${data['data_summary']['recommended_count']}'),
                    Text('Relevant: ${data['data_summary']['relevant_count']}'),
                    Text('Total Items: ${data['data_summary']['total_items']}'),
                    Text('Interactions: ${data['data_summary']['total_interactions']}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            // Ranking Metrics
            if (data['evaluation_report'] != null && data['evaluation_report']['ranking_metrics'] != null) ...[
              const Text('Ranking Quality Metrics:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              ...((data['evaluation_report']['ranking_metrics'] as Map).entries.map((kEntry) {
                final metrics = kEntry.value as Map<String, dynamic>;
                return Card(
                  color: Colors.green[50],
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(kEntry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildMetricChip('NDCG', metrics['ndcg'], Colors.blue),
                            _buildMetricChip('MAP', metrics['map'], Colors.green),
                            _buildMetricChip('Recall', metrics['recall'], Colors.orange),
                            _buildMetricChip('Precision', metrics['precision'], Colors.purple),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList()),
              const SizedBox(height: 16),
            ],
            
            // Diversity & Novelty
            if (data['evaluation_report'] != null && data['evaluation_report']['diversity_novelty'] != null) ...[
              const Text('Diversity & Novelty Metrics:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Card(
                color: Colors.purple[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      _buildMetricRow('Diversity', data['evaluation_report']['diversity_novelty']['diversity']),
                      _buildMetricRow('Novelty', data['evaluation_report']['diversity_novelty']['novelty']),
                      _buildMetricRow('Popularity Bias', data['evaluation_report']['diversity_novelty']['popularity_bias']),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, dynamic value, Color color) {
    return Chip(
      label: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 10)),
          Text(
            value?.toStringAsFixed(3) ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      backgroundColor: color.withOpacity(0.2),
    );
  }

  Widget _buildMetricRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value?.toStringAsFixed(4) ?? 'N/A',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _loadMetricsDocs() async {
    try {
      final docs = await _service.getMetricsDocumentation();
      setState(() => _metricsDocs = docs);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _runSampleEvaluation() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.getSampleEvaluation();
      setState(() => _evaluationResult = result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evaluation completed successfully!'),
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
}
