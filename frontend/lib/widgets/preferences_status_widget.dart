import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/providers/recommendation_provider.dart';
import '../core/providers/auth_provider.dart';
import '../screens/profile/user_preferences_form_screen.dart';

/// Widget to display user preferences status and prompt for completion
class PreferencesStatusWidget extends StatelessWidget {
  final bool compact;

  const PreferencesStatusWidget({
    Key? key,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer2<RecommendationProvider, AuthProvider>(
      builder: (context, recommendationProvider, authProvider, child) {
        final summary = recommendationProvider.getPreferencesSummary();
        final hasPreferences = summary['hasPreferences'] as bool;
        final isComplete = summary['isComplete'] as bool;
        final completionPercentage =
            summary['completionPercentage'] as double? ?? 0.0;
        final needsUpdate = recommendationProvider.needsPreferenceUpdate();
        final qualityScore = recommendationProvider.getPreferenceQualityScore();

        if (compact) {
          return _buildCompactView(
            context,
            hasPreferences,
            isComplete,
            completionPercentage,
            needsUpdate,
            authProvider.user?.id,
          );
        }

        return _buildFullView(
          context,
          hasPreferences,
          isComplete,
          completionPercentage,
          needsUpdate,
          qualityScore,
          summary,
          authProvider.user?.id,
        );
      },
    );
  }

  Widget _buildCompactView(
    BuildContext context,
    bool hasPreferences,
    bool isComplete,
    double completionPercentage,
    bool needsUpdate,
    String? userId,
  ) {
    if (!hasPreferences || !isComplete) {
      return Card(
        color: Colors.orange[50],
        child: ListTile(
          leading: Icon(Icons.warning_amber_rounded, color: Colors.orange),
          title: Text('Complete Your Preferences'),
          subtitle: Text('Get better event recommendations'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToPreferences(context, userId),
        ),
      );
    }

    if (needsUpdate) {
      return Card(
        color: Colors.blue[50],
        child: ListTile(
          leading: Icon(Icons.refresh, color: Colors.blue),
          title: Text('Update Your Preferences'),
          subtitle: Text('Keep recommendations fresh'),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _navigateToPreferences(context, userId),
        ),
      );
    }

    return SizedBox.shrink();
  }

  Widget _buildFullView(
    BuildContext context,
    bool hasPreferences,
    bool isComplete,
    double completionPercentage,
    bool needsUpdate,
    double qualityScore,
    Map<String, dynamic> summary,
    String? userId,
  ) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Personalization Status',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildQualityBadge(context, qualityScore),
              ],
            ),
            SizedBox(height: 16),

            // Completion Progress
            Text(
              'Profile Completion',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: completionPercentage / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getProgressColor(completionPercentage),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '${completionPercentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(completionPercentage),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Status Messages
            if (!hasPreferences) ...[
              _buildStatusMessage(
                icon: Icons.info_outline,
                message: 'No preferences set yet',
                color: Colors.orange,
              ),
              SizedBox(height: 8),
            ],
            if (!isComplete && hasPreferences) ...[
              _buildStatusMessage(
                icon: Icons.warning_amber_rounded,
                message: 'Complete your profile for better recommendations',
                color: Colors.orange,
              ),
              SizedBox(height: 8),
            ],
            if (needsUpdate && isComplete) ...[
              _buildStatusMessage(
                icon: Icons.update,
                message: 'Your preferences may be outdated',
                color: Colors.blue,
              ),
              SizedBox(height: 8),
            ],
            if (isComplete && !needsUpdate) ...[
              _buildStatusMessage(
                icon: Icons.check_circle_outline,
                message: 'Your preferences are up to date!',
                color: Colors.green,
              ),
              SizedBox(height: 8),
            ],

            // Preferences Summary (if available)
            if (hasPreferences && isComplete) ...[
              Divider(),
              SizedBox(height: 8),
              _buildPreferenceDetail('Age', summary['age']?.toString()),
              _buildPreferenceDetail('Location', summary['primaryArea']),
              _buildPreferenceDetail(
                'Favorite Events',
                (summary['favoriteEventTypes'] as List?)?.join(', '),
              ),
              _buildPreferenceDetail(
                  'Preferred Time', summary['preferredEventTime']),
              _buildPreferenceDetail('Budget', summary['budgetRange']),
              SizedBox(height: 8),
            ],

            // Action Button
            SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToPreferences(context, userId),
                icon: Icon(hasPreferences ? Icons.edit : Icons.add),
                label: Text(
                  hasPreferences ? 'Update Preferences' : 'Set Up Preferences',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityBadge(BuildContext context, double score) {
    Color color;
    String label;

    if (score >= 80) {
      color = Colors.green;
      label = 'Excellent';
    } else if (score >= 60) {
      color = Colors.blue;
      label = 'Good';
    } else if (score >= 40) {
      color = Colors.orange;
      label = 'Fair';
    } else {
      color = Colors.red;
      label = 'Poor';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.blue;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatusMessage({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceDetail(String label, String? value) {
    if (value == null || value.isEmpty || value == 'null') return SizedBox();

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToPreferences(BuildContext context, String? userId) async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to set preferences'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final recommendationProvider =
        Provider.of<RecommendationProvider>(context, listen: false);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserPreferencesFormScreen(
          userId: userId,
          existingPreferences: recommendationProvider.userPreferences,
        ),
      ),
    );

    // Reload preferences after returning
    if (result != null) {
      await recommendationProvider.loadUserPreferences(userId);
    }
  }
}
