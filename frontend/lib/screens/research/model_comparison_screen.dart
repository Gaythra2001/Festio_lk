import 'package:flutter/material.dart';
import '../../core/services/research_model_service.dart';

/// Model Comparison & Tuning Screen
class ModelComparisonScreen extends StatefulWidget {
  const ModelComparisonScreen({Key? key}) : super(key: key);

  @override
  State<ModelComparisonScreen> createState() => _ModelComparisonScreenState();
}

class _ModelComparisonScreenState extends State<ModelComparisonScreen> {
  final ResearchModelService _service = ResearchModelService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _comparisonResult;
  Map<String, dynamic>? _registeredModels;
  Map<String, dynamic>? _tuningGuide;

  @override
  void initState() {
    super.initState();
    _loadRegisteredModels();
    _loadTuningGuide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Comparison'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Component 3: Model Comparison & Tuning',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Benchmark CF vs Hybrid vs Graph-based recommenders with statistical tests',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Registered Models
            if (_registeredModels != null) ...[
              _buildModelsCard(_registeredModels!),
              const SizedBox(height: 16),
            ],
            
            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _runSampleComparison,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Run Sample Comparison'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _viewTuningGuide,
                  icon: const Icon(Icons.tune),
                  label: const Text('View Tuning Guide'),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            // Comparison Results
            if (_comparisonResult != null) ...[
              _buildComparisonCard(_comparisonResult!),
              const SizedBox(height: 16),
            ],
            
            // Tuning Guide
            if (_tuningGuide != null) ...[
              _buildTuningGuideCard(_tuningGuide!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildModelsCard(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.model_training, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Available Models',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (data['available_models'] != null)
              ...((data['available_models'] as List).map((model) {
                return ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: Text(model['name'] ?? ''),
                  subtitle: Text(model['description'] ?? ''),
                  dense: true,
                );
              }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonCard(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Model Comparison Results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Model Metrics
            if (data['comparison'] != null && data['comparison']['model_metrics'] != null) ...[
              const Text('Performance Metrics:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...((data['comparison']['model_metrics'] as Map).entries.map((entry) {
                final metrics = entry.value as Map<String, dynamic>;
                return Card(
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text('RMSE: ${metrics['rmse']?.toStringAsFixed(4) ?? 'N/A'}'),
                        Text('MAE: ${metrics['mae']?.toStringAsFixed(4) ?? 'N/A'}'),
                        Text('MSE: ${metrics['mse']?.toStringAsFixed(4) ?? 'N/A'}'),
                      ],
                    ),
                  ),
                );
              }).toList()),
            ],
            
            const SizedBox(height: 12),
            
            // Best Model
            if (data['comparison'] != null && data['comparison']['best_model'] != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Best Model: ${data['comparison']['best_model']['name']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Statistical Tests
            if (data['comparison'] != null && data['comparison']['pairwise_comparisons'] != null) ...[
              const Text('Statistical Significance:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...((data['comparison']['pairwise_comparisons'] as Map).entries.map((entry) {
                final test = entry.value as Map<String, dynamic>;
                return ListTile(
                  leading: Icon(
                    test['is_significant'] == true ? Icons.check_circle : Icons.cancel,
                    color: test['is_significant'] == true ? Colors.green : Colors.grey,
                  ),
                  title: Text(entry.key.replaceAll('_', ' ')),
                  subtitle: Text(test['interpretation'] ?? ''),
                  dense: true,
                );
              }).toList()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTuningGuideCard(Map<String, dynamic> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.tune, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Hyperparameter Tuning Guide',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (data['tuning_guides'] != null)
              ...((data['tuning_guides'] as Map).entries.map((model) {
                final params = model.value as Map<String, dynamic>;
                return ExpansionTile(
                  title: Text(model.key.replaceAll('_', ' ').toUpperCase()),
                  children: params.entries.map((param) {
                    return ListTile(
                      title: Text(param.key),
                      subtitle: Text('Values: ${param.value}'),
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

  Future<void> _loadRegisteredModels() async {
    try {
      final models = await _service.getRegisteredModels();
      setState(() => _registeredModels = models);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _loadTuningGuide() async {
    try {
      final guide = await _service.getTuningRecommendations();
      setState(() => _tuningGuide = guide);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> _runSampleComparison() async {
    setState(() => _isLoading = true);
    try {
      final result = await _service.getSampleComparison();
      setState(() => _comparisonResult = result);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comparison completed successfully!'),
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

  void _viewTuningGuide() {
    // Tuning guide is already loaded and displayed
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Scroll down to view tuning guide')),
    );
  }
}
