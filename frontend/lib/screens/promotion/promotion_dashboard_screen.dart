import 'package:flutter/material.dart';
import 'package:festio_lk/core/services/ai/ma_epom_service.dart';

class PromotionDashboardScreen extends StatefulWidget {
  const PromotionDashboardScreen({Key? key}) : super(key: key);

  @override
  State<PromotionDashboardScreen> createState() =>
      _PromotionDashboardScreenState();
}

class _PromotionDashboardScreenState extends State<PromotionDashboardScreen>
    with SingleTickerProviderStateMixin {
  final MAEPOMService _maEpomService = MAEPOMService();
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, dynamic>? _samplePromotion;
  Map<String, dynamic>? _modelInfo;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadModelInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadModelInfo() async {
    try {
      final info = await _maEpomService.getModelInfo();
      setState(() => _modelInfo = info);
    } catch (e) {
      _showErrorSnackbar('Error loading model info: $e');
    }
  }

  Future<void> _runSamplePromotion() async {
    setState(() => _isLoading = true);
    try {
      final result = await _maEpomService.runSampleWorkflow();
      setState(() {
        _samplePromotion = result;
        _isLoading = false;
      });
      _showSuccessSnackbar('Sample promotion generated successfully!');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackbar('Error: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🌍 MA-EPOM: Multilingual Promotion'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.language), text: 'Translation'),
            Tab(icon: Icon(Icons.trending_up), text: 'Engagement'),
            Tab(icon: Icon(Icons.schedule), text: 'Timing'),
            Tab(icon: Icon(Icons.mood), text: 'Sentiment'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildTranslationTab(),
                _buildEngagementTab(),
                _buildTimingTab(),
                _buildSentimentTab(),
              ],
            ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model Info Card
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MA-EPOM Model',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Multilingual AI-Based Event Promotion Optimization Model',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  if (_modelInfo != null) ...[
                    _buildInfoRow('Total Endpoints', '${_modelInfo!['endpoints_total']}'),
                    _buildInfoRow('Components', '4 major'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Components Overview
          const Text(
            '🧠 Components',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildComponentCard(
            'Language Processor',
            'Detection & Translation',
            Icons.language,
            Colors.blue,
          ),
          _buildComponentCard(
            'Engagement Predictor',
            'RF + LR Ensemble',
            Icons.trending_up,
            Colors.orange,
          ),
          _buildComponentCard(
            'Timing Optimizer',
            'Pattern Recognition',
            Icons.schedule,
            Colors.green,
          ),
          _buildComponentCard(
            'Sentiment Analyzer',
            'Review Analysis',
            Icons.mood,
            Colors.purple,
          ),
          const SizedBox(height: 16),

          // Sample Promotion Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _runSamplePromotion,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run Sample Promotion'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Sample Result
          if (_samplePromotion != null) ...[
            const Text(
              'Sample Promotion Result',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPromotionResultCard(_samplePromotion!),
          ],
        ],
      ),
    );
  }

  Widget _buildComponentCard(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
      ),
    );
  }

  Widget _buildPromotionResultCard(Map<String, dynamic> result) {
    final promo = result['sample_promotion'] ?? {};
    final sentiment = result['sentiment_analysis'] ?? {};

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildResultRow('Event Title', promo['title'] ?? 'N/A'),
            _buildResultRow('Language', promo['language'] ?? 'N/A'),
            _buildResultRow(
              'Engagement Probability',
              '${((promo['engagement_probability'] ?? 0) * 100).toStringAsFixed(1)}%',
            ),
            _buildResultRow(
              'Recommended Send Time',
              promo['recommended_send_time']?.toString().substring(0, 16) ?? 'N/A',
            ),
            _buildResultRow(
              'Translation Quality',
              '${((promo['translation_quality'] ?? 0) * 100).toStringAsFixed(1)}%',
            ),
            const Divider(),
            _buildResultRow(
              'Sentiment Label',
              sentiment['label']?.toString().toUpperCase() ?? 'NEUTRAL',
            ),
            _buildResultRow(
              'Sentiment Score',
              '${(sentiment['combined_sentiment'] ?? 0).toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTranslationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '🌐 Language Translation',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Uses MarianMT / mBART for multilingual translation'),
                  const SizedBox(height: 16),
                  const Text(
                    'Supported Languages:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildLanguageChip('English', 'en'),
                      _buildLanguageChip('Sinhala', 'si'),
                      _buildLanguageChip('Tamil', 'ta'),
                      _buildLanguageChip('Spanish', 'es'),
                      _buildLanguageChip('French', 'fr'),
                      _buildLanguageChip('German', 'de'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Translation Quality Metrics:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• BLEU Score: Quality assessment'),
                        Text('• Language Detection Confidence'),
                        Text('• Multilingual Consistency'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageChip(String label, String code) {
    return FilterChip(
      label: Text(label),
      selected: _selectedLanguage == code,
      onSelected: (selected) {
        setState(() => _selectedLanguage = code);
      },
    );
  }

  Widget _buildEngagementTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📊 Engagement Prediction',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Ensemble model combining Random Forest and Logistic Regression'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Input Features:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Past click rate'),
                        Text('• Past booking rate'),
                        Text('• Session duration'),
                        Text('• Notification open rate'),
                        Text('• Activity level'),
                        Text('• Category affinity'),
                        Text('• Location match'),
                        Text('• Price sensitivity match'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Output Metrics:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Engagement Probability (0-1)'),
                        Text('• Model Confidence'),
                        Text('• Feature Importance Scores'),
                        Text('• RF vs LR Predictions'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimingTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⏰ Notification Timing Optimization',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Analyzes user patterns to find optimal notification time'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pattern Analysis:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Hourly engagement distribution'),
                        Text('• Peak activity hours detection'),
                        Text('• Weekday vs Weekend patterns'),
                        Text('• Seasonal trend analysis'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recommendations:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Next optimal hour'),
                        Text('• Scheduled send time'),
                        Text('• Time until send'),
                        Text('• Alternative time slots'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSentimentTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '😊 Sentiment Analysis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Uses mBERT / XLM-RoBERTa for multilingual sentiment'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Analysis Components:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Text sentiment extraction'),
                        Text('• Rating integration'),
                        Text('• Word-level polarity'),
                        Text('• Combined scoring'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Output Labels:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text('• Positive (> 0.6)'),
                        Text('• Neutral (0.4 - 0.6)'),
                        Text('• Negative (< 0.4)'),
                        Text('• Confidence scores'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
