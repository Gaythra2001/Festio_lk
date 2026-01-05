import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/recommendation_provider.dart';
import '../../core/models/user_preferences_model.dart';
import 'search_results_screen.dart';

/// User Preferences Input Screen
class UserPreferenceInputScreen extends StatefulWidget {
  const UserPreferenceInputScreen({Key? key}) : super(key: key);

  @override
  State<UserPreferenceInputScreen> createState() =>
      _UserPreferenceInputScreenState();
}

class _UserPreferenceInputScreenState extends State<UserPreferenceInputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form fields
  String _age = '';
  String _preferredArea = '';
  String _budgetPerEvent = '';
  String _favouriteArtist = '';

  // Event type checkboxes
  final Map<String, bool> _eventTypes = {
    'Concerts': false,
    'Sports': false,
    'Festivals': false,
    'Cultural': false,
  };

  final List<String> _sriLankanAreas = [
    'Colombo',
    'Gampaha',
    'Kalutara',
    'Kandy',
    'Matale',
    'Nuwara Eliya',
    'Galle',
    'Matara',
    'Hambantota',
    'Jaffna',
    'Kilinochchi',
    'Mannar',
    'Vavuniya',
    'Mullaitivu',
    'Batticaloa',
    'Ampara',
    'Trincomalee',
    'Kurunegala',
    'Puttalam',
    'Anuradhapura',
    'Polonnaruwa',
    'Badulla',
    'Moneragala',
    'Ratnapura',
    'Kegalle',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Set Your Preferences',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Tell us about your preferences',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'We\'ll find the perfect events for you',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 32),

                // Age Field
                _buildTextField(
                  label: 'Age',
                  hint: 'Enter your age',
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _age = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your age';
                    }
                    final age = int.tryParse(value);
                    if (age == null || age < 13 || age > 120) {
                      return 'Please enter a valid age (13-120)';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Preferred Area
                _buildDropdownField(
                  label: 'Preferred Area',
                  hint: 'Select your preferred area',
                  icon: Icons.location_on,
                  items: _sriLankanAreas,
                  onChanged: (value) => setState(() => _preferredArea = value!),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a preferred area';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Budget per Event
                _buildTextField(
                  label: 'Budget per Event (LKR)',
                  hint: 'Enter your budget',
                  icon: Icons.account_balance_wallet,
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _budgetPerEvent = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your budget';
                    }
                    final budget = double.tryParse(value);
                    if (budget == null || budget < 0) {
                      return 'Please enter a valid budget';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Favourite Artist
                _buildTextField(
                  label: 'Favourite Artist',
                  hint: 'Enter your favourite artist',
                  icon: Icons.person,
                  onChanged: (value) => _favouriteArtist = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your favourite artist';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Event Types Section
                const Text(
                  'Favourite Event Types',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Select all that apply',
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 16),

                // Checkboxes
                ..._eventTypes.keys.map((eventType) {
                  return CheckboxListTile(
                    title: Text(
                      eventType,
                      style: const TextStyle(fontSize: 16),
                    ),
                    value: _eventTypes[eventType],
                    activeColor: const Color(0xFF1A73E8),
                    onChanged: (bool? value) {
                      setState(() {
                        _eventTypes[eventType] = value ?? false;
                      });
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  );
                }).toList(),

                const SizedBox(height: 40),

                // Get Recommendations Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _submitPreferences,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1A73E8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Get Recommendations',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF1A73E8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          keyboardType: keyboardType,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF1A73E8)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
          items: items
              .map((area) => DropdownMenuItem(
                    value: area,
                    child: Text(area),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Future<void> _submitPreferences() async {
    debugPrint('🔵 _submitPreferences() called');

    if (!_formKey.currentState!.validate()) {
      debugPrint('❌ Form validation failed');
      return;
    }

    // Check if at least one event type is selected
    final selectedTypes =
        _eventTypes.entries.where((e) => e.value).map((e) => e.key).toList();

    debugPrint('✓ Selected event types: $selectedTypes');

    if (selectedTypes.isEmpty) {
      debugPrint('❌ No event types selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one event type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('📝 Form data:');
    debugPrint('   Age: $_age');
    debugPrint('   Area: $_preferredArea');
    debugPrint('   Budget: $_budgetPerEvent');
    debugPrint('   Artist: $_favouriteArtist');
    debugPrint('   Types: $selectedTypes');

    // Save preferences
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final recommendationProvider =
        Provider.of<RecommendationProvider>(context, listen: false);

    try {
      debugPrint('🔨 Creating UserPreferencesModel...');

      final preferences = UserPreferencesModel(
        age: int.parse(_age),
        primaryArea: _preferredArea.toLowerCase(),
        maxBudget: double.parse(_budgetPerEvent),
        favoriteArtists: [_favouriteArtist],
        favoriteEventTypes: selectedTypes.map((e) => e.toLowerCase()).toList(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isComplete: true,
        completionPercentage: 100.0,
      );

      debugPrint('✅ UserPreferencesModel created');

      // Save preferences if user is logged in
      if (authProvider.user != null) {
        debugPrint('💾 Saving preferences to database...');
        await recommendationProvider.saveUserPreferences(
          authProvider.user!.id,
          preferences,
        );
        debugPrint('✅ Preferences saved to database');
      } else {
        debugPrint('⚠️ User not logged in - skipping database save');
      }

      // Navigate to search results screen regardless
      if (mounted) {
        debugPrint('🚀 Navigating to SearchResultsScreen...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsScreen(
              userPreferences: preferences,
            ),
          ),
        );
        debugPrint('✅ Navigation completed');
      } else {
        debugPrint('⚠️ Widget not mounted - cannot navigate');
      }
    } catch (e) {
      debugPrint('❌ Error: $e');
      debugPrint('❌ Stack trace: ${StackTrace.current}');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
