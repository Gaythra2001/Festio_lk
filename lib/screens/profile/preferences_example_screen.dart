import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/recommendation_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../widgets/preferences_status_widget.dart';

/// Example screen showing how to integrate the preference system
class PreferencesExampleScreen extends StatefulWidget {
  const PreferencesExampleScreen({Key? key}) : super(key: key);

  @override
  State<PreferencesExampleScreen> createState() =>
      _PreferencesExampleScreenState();
}

class _PreferencesExampleScreenState extends State<PreferencesExampleScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
  }

  Future<void> _initializePreferences() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final recommendationProvider =
          Provider.of<RecommendationProvider>(context, listen: false);

      final userId = authProvider.user?.id;
      if (userId != null) {
        // Load existing preferences
        await recommendationProvider.loadUserPreferences(userId);

        // If no preferences exist, create defaults
        if (recommendationProvider.userPreferences == null) {
          await recommendationProvider.createDefaultPreferences(userId);
        }

        // Load behavior data
        await recommendationProvider.loadUserBehavior(userId);
      }
    } catch (e) {
      debugPrint('Error initializing preferences: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Personalization'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Main preference status widget
                  PreferencesStatusWidget(compact: false),

                  // Additional info cards
                  _buildInfoSection(),

                  // Quick actions
                  _buildQuickActions(),

                  // Developer tools (remove in production)
                  if (const bool.fromEnvironment('dart.vm.product') == false)
                    _buildDevTools(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoSection() {
    return Consumer<RecommendationProvider>(
      builder: (context, provider, child) {
        final summary = provider.getPreferencesSummary();

        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Why Complete Your Preferences?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              _buildBenefitItem(
                icon: Icons.recommend,
                title: 'Better Recommendations',
                description: 'Get event suggestions tailored to your interests',
              ),
              _buildBenefitItem(
                icon: Icons.notifications_active,
                title: 'Smart Notifications',
                description: 'Receive alerts for events you\'ll actually enjoy',
              ),
              _buildBenefitItem(
                icon: Icons.location_on,
                title: 'Location-Based',
                description: 'Find events near you or in your preferred areas',
              ),
              _buildBenefitItem(
                icon: Icons.savings,
                title: 'Budget-Friendly',
                description: 'See events that match your budget range',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Consumer2<RecommendationProvider, AuthProvider>(
      builder: (context, recommendationProvider, authProvider, child) {
        return Card(
          margin: EdgeInsets.all(16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12),

                // Check preference quality
                ListTile(
                  leading: Icon(Icons.analytics, color: Colors.blue),
                  title: Text('Check Preference Quality'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showQualityDialog(recommendationProvider),
                ),

                // View preference summary
                ListTile(
                  leading: Icon(Icons.info, color: Colors.green),
                  title: Text('View Preference Summary'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _showSummaryDialog(recommendationProvider),
                ),

                // Refresh preferences
                ListTile(
                  leading: Icon(Icons.refresh, color: Colors.orange),
                  title: Text('Refresh Preferences'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _refreshPreferences(
                    authProvider.user?.id,
                    recommendationProvider,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDevTools() {
    return Consumer2<RecommendationProvider, AuthProvider>(
      builder: (context, recommendationProvider, authProvider, child) {
        return Card(
          margin: EdgeInsets.all(16),
          color: Colors.grey[100],
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.developer_mode, size: 20, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Developer Tools',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),

                // Reset preferences
                ElevatedButton.icon(
                  onPressed: () => _resetPreferences(
                    authProvider.user?.id,
                    recommendationProvider,
                  ),
                  icon: Icon(Icons.delete_forever),
                  label: Text('Reset Preferences'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                SizedBox(height: 8),

                // Create test data
                ElevatedButton.icon(
                  onPressed: () => _createTestPreferences(
                    authProvider.user?.id,
                    recommendationProvider,
                  ),
                  icon: Icon(Icons.science),
                  label: Text('Create Test Preferences'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showQualityDialog(RecommendationProvider provider) {
    final quality = provider.getPreferenceQualityScore();
    final summary = provider.getPreferencesSummary();

    String qualityText;
    Color qualityColor;

    if (quality >= 80) {
      qualityText = 'Excellent';
      qualityColor = Colors.green;
    } else if (quality >= 60) {
      qualityText = 'Good';
      qualityColor = Colors.blue;
    } else if (quality >= 40) {
      qualityText = 'Fair';
      qualityColor = Colors.orange;
    } else {
      qualityText = 'Poor';
      qualityColor = Colors.red;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preference Quality'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text(
                    quality.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: qualityColor,
                    ),
                  ),
                  Text(
                    qualityText,
                    style: TextStyle(
                      fontSize: 20,
                      color: qualityColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Text('Completion: ${summary['completionPercentage']}%'),
            Text('Is Complete: ${summary['isComplete']}'),
            Text('Needs Update: ${provider.needsPreferenceUpdate()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSummaryDialog(RecommendationProvider provider) {
    final summary = provider.getPreferencesSummary();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Preference Summary'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: summary.entries
                .map((e) => Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Text('${e.key}: ${e.value}'),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshPreferences(
    String? userId,
    RecommendationProvider provider,
  ) async {
    if (userId == null) return;

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refreshing preferences...')),
      );

      await provider.loadUserPreferences(userId);
      await provider.loadUserBehavior(userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preferences refreshed!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetPreferences(
    String? userId,
    RecommendationProvider provider,
  ) async {
    if (userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Reset Preferences?'),
        content: Text('This will delete all your preferences.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await provider.createDefaultPreferences(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Preferences reset!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _createTestPreferences(
    String? userId,
    RecommendationProvider provider,
  ) async {
    if (userId == null) return;

    try {
      await provider.updatePreferenceFields(userId, {
        'age': 25,
        'gender': 'male',
        'primaryArea': 'colombo',
        'favoriteEventTypes': ['music', 'cultural', 'sports'],
        'preferredEventTime': 'evening',
        'maxBudget': 5000.0,
        'minBudget': 500.0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test preferences created!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
