import 'package:flutter/material.dart';
import '../../core/services/research_feature_service.dart';

/// Feature Engineering Experiments Screen
class FeatureEngineeringScreen extends StatefulWidget {
  const FeatureEngineeringScreen({Key? key}) : super(key: key);

  @override
  State<FeatureEngineeringScreen> createState() => _FeatureEngineeringScreenState();
}

class _FeatureEngineeringScreenState extends State<FeatureEngineeringScreen> {
  final ResearchFeatureService _service = ResearchFeatureService();
  
  bool _isLoading = false;
  Map<String, dynamic>? _temporalFeatures;
  Map<String, dynamic>? _priceFeatures;
  Map<String, dynamic>? _locationFeatures;
  Map<String, dynamic>? _allFeatures;
  Map<String, dynamic>? _featureDocs;

  @override
  void initState() {
    super.initState();
    _loadFeatureDocs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feature Engineering'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Component 2: Feature Engineering Experiments',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Compare temporal, price-sensitivity, and location-distance features',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // Feature Documentation
            if (_featureDocs != null) ...[
              _buildFeatureDocsCard(_featureDocs!),
              const SizedBox(height: 24),
            ],
            
            // Action Buttons
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _extractTemporalFeatures,
                  icon: const Icon(Icons.schedule),
                  label: const Text('Extract Temporal'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _extractPriceFeatures,
                  icon: const Icon(Icons.attach_money),
                  label: const Text('Extract Price'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _extractLocationFeatures,
                  icon: const Icon(Icons.location_on),
                  label: const Text('Extract Location'),
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _extractAllFeatures,
                  icon: const Icon(Icons.all_inclusive),
                  label: const Text('Extract All'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            // Results Display
            if (_temporalFeatures != null) ...[
              _buildFeatureResultCard(
                'Temporal Features',
                _temporalFeatures!,
                Icons.schedule,
                Colors.blue,
              ),
              const SizedBox(height: 16),
            ],
            
            if (_priceFeatures != null) ...[
              _buildFeatureResultCard(
                'Price Features',
                _priceFeatures!,
                Icons.attach_money,
                Colors.green,
              ),
              const SizedBox(height: 16),
            ],
            
            if (_locationFeatures != null) ...[
              _buildFeatureResultCard(
                'Location Features',
                _locationFeatures!,
                Icons.location_on,
                Colors.orange,
              ),
              const SizedBox(height: 16),
            ],
            
            if (_allFeatures != null) ...[
              _buildFeatureResultCard(
                'All Features Combined',
                _allFeatures!,
                Icons.all_inclusive,
                Colors.purple,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureDocsCard(Map<String, dynamic> docs) {
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
                  'Available Features',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (docs['feature_categories'] != null)
              ...((docs['feature_categories'] as Map).entries.map((category) {
                final categoryData = category.value as Map<String, dynamic>;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.key.toString().replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        categoryData['description'] ?? '',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: ((categoryData['features'] as List?) ?? [])
                            .map((f) => Chip(
                                  label: Text(f.toString(), style: const TextStyle(fontSize: 10)),
                                  visualDensity: VisualDensity.compact,
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                );
              }).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureResultCard(
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
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Summary stats
            if (data['feature_count'] != null)
              Text('Feature Count: ${data['feature_count']}'),
            if (data['sample_count'] != null)
              Text('Samples: ${data['sample_count']}'),
            
            const SizedBox(height: 8),
            
            // Feature list
            if (data['features'] != null) ...[
              const Text('Features:', style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: (data['features'] as List)
                    .map((f) => Chip(
                          label: Text(f.toString(), style: const TextStyle(fontSize: 10)),
                          visualDensity: VisualDensity.compact,
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _loadFeatureDocs() async {
    try {
      final docs = await _service.getFeatureDocumentation();
      setState(() => _featureDocs = docs);
    } catch (e) {
      // Silent fail for docs
    }
  }

  Future<void> _extractTemporalFeatures() async {
    setState(() => _isLoading = true);
    try {
      final sampleData = await _service.getSampleData();
      final interactions = sampleData['data']['sample_interactions'] as List;
      final result = await _service.extractTemporalFeatures(
        interactions.cast<Map<String, dynamic>>(),
      );
      setState(() => _temporalFeatures = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _extractPriceFeatures() async {
    setState(() => _isLoading = true);
    try {
      final sampleData = await _service.getSampleData();
      final interactions = sampleData['data']['sample_interactions'] as List;
      final result = await _service.extractPriceFeatures(
        interactions.cast<Map<String, dynamic>>(),
      );
      setState(() => _priceFeatures = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _extractLocationFeatures() async {
    setState(() => _isLoading = true);
    try {
      final sampleData = await _service.getSampleData();
      final interactions = sampleData['data']['sample_interactions'] as List;
      final result = await _service.extractLocationFeatures(
        interactions.cast<Map<String, dynamic>>(),
      );
      setState(() => _locationFeatures = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _extractAllFeatures() async {
    setState(() => _isLoading = true);
    try {
      final sampleData = await _service.getSampleData();
      final interactions = sampleData['data']['sample_interactions'] as List;
      final result = await _service.extractAllFeatures(
        interactions.cast<Map<String, dynamic>>(),
      );
      setState(() => _allFeatures = result);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
