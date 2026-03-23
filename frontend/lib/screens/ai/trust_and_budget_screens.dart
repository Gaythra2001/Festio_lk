import 'package:festio_lk/screens/ai/budget_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:festio_lk/core/services/ai/trust_and_budget_service.dart';

/// Component 3: Organizer Trust Assessment Screen
class TrustAssessmentScreen extends StatefulWidget {
  const TrustAssessmentScreen({super.key});

  @override
  State<TrustAssessmentScreen> createState() => _TrustAssessmentScreenState();
}

class _TrustAssessmentScreenState extends State<TrustAssessmentScreen>
    with SingleTickerProviderStateMixin {
  late TrustAssessmentService _trustService;
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, dynamic>? _validationResult;
  Map<String, dynamic>? _fraudResult;
  Map<String, dynamic>? _reputationResult;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _trustService = TrustAssessmentService();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _runSampleValidation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final result = await _trustService.runSampleValidation();
      setState(() {
        _validationResult = result;
        _tabController.index = 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runSampleFraudDetection() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sampleEvent = {
        'event_id': 'evt_sample_fraud',
        'title': 'Test Event',
        'ticket_price': 150.0,
        'max_capacity': 500,
        'description': 'Test description',
        'image_count': 3,
      };
      final result = await _trustService.detectFraud(eventData: sampleEvent);
      setState(() {
        _fraudResult = result;
        _tabController.index = 1;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runSampleReputation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sampleOrganizer = {
        'organizer_id': 'org_sample',
        'email': 'organizer@example.com',
        'total_events': 25,
        'completed_events': 23,
        'avg_rating': 4.5,
        'account_created': '2020-01-15',
        'is_verified': true,
      };
      final result = await _trustService.checkReputation(
        organizerData: sampleOrganizer,
      );
      setState(() {
        _reputationResult = result;
        _tabController.index = 2;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Organizer Trust Assessment'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Full Validation'),
            Tab(text: 'Fraud Detection'),
            Tab(text: 'Reputation'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildValidationTab(),
                _buildFraudDetectionTab(),
                _buildReputationTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showErrorMessage,
        child: const Icon(Icons.info),
      ),
    );
  }

  Widget _buildValidationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Full Event & Organizer Validation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _runSampleValidation,
            icon: const Icon(Icons.check_circle),
            label: const Text('Run Sample Validation'),
          ),
          const SizedBox(height: 24),
          if (_validationResult != null) ...[
            _buildResultCard(
              title: 'Validation Result',
              data: _validationResult!,
              color: _getTrustColor(_validationResult?['trust_level'] ?? ''),
            ),
          ] else
            const Center(
              child: Text('Run sample validation to see results'),
            ),
        ],
      ),
    );
  }

  Widget _buildFraudDetectionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Fraud Detection',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _runSampleFraudDetection,
            icon: const Icon(Icons.security),
            label: const Text('Run Fraud Detection'),
          ),
          const SizedBox(height: 24),
          if (_fraudResult != null) ...[
            _buildResultCard(
              title: 'Fraud Analysis',
              data: _fraudResult!,
              color: Colors.orange,
            ),
          ] else
            const Center(
              child: Text('Run fraud detection to see results'),
            ),
        ],
      ),
    );
  }

  Widget _buildReputationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Organizer Reputation Scoring',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _runSampleReputation,
            icon: const Icon(Icons.star),
            label: const Text('Check Reputation'),
          ),
          const SizedBox(height: 24),
          if (_reputationResult != null) ...[
            _buildResultCard(
              title: 'Reputation Score',
              data: _reputationResult!,
              color: Colors.blue,
            ),
          ] else
            const Center(
              child: Text('Check reputation to see results'),
            ),
        ],
      ),
    );
  }

  Widget _buildResultCard({
    required String title,
    required Map<String, dynamic> data,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            ...data.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key.replaceAll('_', ' ').toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      e.value.toString(),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTrustColor(String trustLevel) {
    switch (trustLevel) {
      case 'highly_trusted':
        return Colors.green;
      case 'trusted':
        return Colors.lightGreen;
      case 'neutral':
        return Colors.orange;
      case 'low_trust':
        return Colors.deepOrange;
      case 'not_trusted':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage), backgroundColor: Colors.red),
      );
    }
  }
}

/// Component 4: Event Budget Planning Screen
class BudgetPlanningScreen extends StatefulWidget {
  const BudgetPlanningScreen({super.key});

  @override
  State<BudgetPlanningScreen> createState() => _BudgetPlanningScreenState();
}

class _BudgetPlanningScreenState extends State<BudgetPlanningScreen>
    with SingleTickerProviderStateMixin {
  late BudgetPlanningService _budgetService;
  late TabController _tabController;
  bool _isLoading = false;
  Map<String, dynamic>? _budgetPlan;
  Map<String, dynamic>? _costPrediction;
  Map<String, dynamic>? _breakdown;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _budgetService = BudgetPlanningService();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _createSampleBudgetPlan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sampleEvent = {
        'event_id': 'evt_budget_sample',
        'event_type': 'concert',
        'expected_audience': 500,
        'duration_hours': 4,
        'venue_type': 'outdoor',
        'has_catering': true,
        'has_entertainment': true,
      };
      final result = await _budgetService.createBudgetPlan(
        eventData: sampleEvent,
      );
      setState(() {
        _budgetPlan = result;
        _tabController.index = 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _predictCost() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sampleEvent = {
        'event_type': 'festival',
        'expected_audience': 1000,
        'duration_hours': 8,
        'venue_type': 'outdoor',
      };
      final result = await _budgetService.predictCost(eventData: sampleEvent);
      setState(() {
        _costPrediction = result;
        _tabController.index = 1;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getBreakdown() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sampleEvent = {
        'event_type': 'wedding',
        'expected_audience': 200,
        'total_budget': 50000.0,
      };
      final result = await _budgetService.calculateBreakdown(
        eventData: sampleEvent,
      );
      setState(() {
        _breakdown = result;
        _tabController.index = 2;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Budget Planning'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Full Plan'),
            Tab(text: 'Cost Prediction'),
            Tab(text: 'Breakdown'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFullPlanTab(),
                _buildCostPredictionTab(),
                _buildBreakdownTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showErrorMessage,
        child: const Icon(Icons.info),
      ),
    );
  }

  Widget _buildFullPlanTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
  const Text(
    'Complete Budget Plan',
    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  ),
  const SizedBox(height: 16),
  ElevatedButton.icon(
    onPressed: () {
      // Navigate to the new page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const BudgetDetailsScreen(),
        ),
      );
    },
    icon: const Icon(Icons.attach_money),
    label: const Text('Go to Budget Details'),
  ),
  const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _createSampleBudgetPlan,
            icon: const Icon(Icons.attach_money),
            label: const Text('Create Sample Plan'),
          ),
          const SizedBox(height: 24),
          if (_budgetPlan != null) ...[
            _buildBudgetCard(
              title: 'Budget Plan',
              data: _budgetPlan!,
              color: Colors.green,
            ),
          ] else
            const Center(
              child: Text('Create a sample plan to see results'),
            ),
        ],
      ),
    );
  }

  Widget _buildCostPredictionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cost Prediction',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _predictCost,
            icon: const Icon(Icons.calculate),
            label: const Text('Predict Cost'),
          ),
          const SizedBox(height: 24),
          if (_costPrediction != null) ...[
            _buildBudgetCard(
              title: 'Cost Prediction',
              data: _costPrediction!,
              color: Colors.blue,
            ),
          ] else
            const Center(
              child: Text('Predict cost to see results'),
            ),
        ],
      ),
    );
  }

  Widget _buildBreakdownTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Budget Breakdown by Category',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _getBreakdown,
            icon: const Icon(Icons.pie_chart),
            label: const Text('View Breakdown'),
          ),
          const SizedBox(height: 24),
          if (_breakdown != null) ...[
            _buildBudgetCard(
              title: 'Budget Breakdown',
              data: _breakdown!,
              color: Colors.purple,
            ),
          ] else
            const Center(
              child: Text('Get breakdown to see results'),
            ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard({
    required String title,
    required Map<String, dynamic> data,
    required Color color,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 12),
            ...data.entries.map(
              (e) {
                final value = e.value;
                String displayValue;

                if (value is double) {
                  displayValue = '\$${value.toStringAsFixed(2)}';
                } else if (value is int) {
                  displayValue = '\$$value';
                } else if (value is Map) {
                  displayValue = '(nested data)';
                } else {
                  displayValue = value.toString();
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key.replaceAll('_', ' ').toUpperCase(),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        displayValue,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorMessage() {
    if (_errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage), backgroundColor: Colors.red),
      );
    }
  }
}
