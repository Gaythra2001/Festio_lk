import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_preferences_model.dart';
import '../../core/providers/recommendation_provider.dart';

/// Comprehensive User Preferences Form for Research-Grade Recommendations
/// Collects detailed user data to power the AI recommendation engine
class UserPreferencesFormScreen extends StatefulWidget {
  final String userId;
  final UserPreferencesModel? existingPreferences;

  const UserPreferencesFormScreen({
    Key? key,
    required this.userId,
    this.existingPreferences,
  }) : super(key: key);

  @override
  State<UserPreferencesFormScreen> createState() =>
      _UserPreferencesFormScreenState();
}

class _UserPreferencesFormScreenState extends State<UserPreferencesFormScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _totalPages = 6;

  // Form data
  int? _age;
  String? _gender;
  String? _religion;
  String? _occupation;
  String? _educationLevel;
  String? _primaryArea;
  List<String> _preferredAreas = [];
  double? _maxTravelDistance;
  double? _minBudget;
  double? _maxBudget;
  String? _budgetFlexibility;
  List<String> _favoriteEventTypes = [];
  List<String> _favoriteGenres = [];
  List<String> _favoriteArtists = [];
  List<String> _favoriteVenues = [];
  List<String> _dislikedEventTypes = [];
  String? _preferredEventTime;
  List<String> _preferredDays = [];
  int? _groupSize;
  bool _prefersFamilyFriendly = false;
  bool _prefersOutdoor = false;
  bool _prefersIndoor = false;
  bool _observesPoyaDays = false;
  bool _observesReligiousHolidays = false;
  List<String> _culturalInterests = [];
  String? _languagePreference;
  String? _socialStyle;
  bool _likesNewExperiences = true;
  bool _prefersFamiliarEvents = false;
  int _adventureLevel = 3;
  bool _allowsPersonalizedNotifications = true;
  bool _allowsLocationBasedRecommendations = true;
  bool _sharesDataForResearch = false;
  int _notificationFrequency = 3;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingPreferences();
  }

  void _loadExistingPreferences() {
    if (widget.existingPreferences != null) {
      final prefs = widget.existingPreferences!;
      setState(() {
        _age = prefs.age;
        _gender = prefs.gender;
        _religion = prefs.religion;
        _occupation = prefs.occupation;
        _educationLevel = prefs.educationLevel;
        _primaryArea = prefs.primaryArea;
        _preferredAreas = List.from(prefs.preferredAreas);
        _maxTravelDistance = prefs.maxTravelDistance;
        _minBudget = prefs.minBudget;
        _maxBudget = prefs.maxBudget;
        _budgetFlexibility = prefs.budgetFlexibility;
        _favoriteEventTypes = List.from(prefs.favoriteEventTypes);
        _favoriteGenres = List.from(prefs.favoriteGenres);
        _favoriteArtists = List.from(prefs.favoriteArtists);
        _favoriteVenues = List.from(prefs.favoriteVenues);
        _dislikedEventTypes = List.from(prefs.dislikedEventTypes);
        _preferredEventTime = prefs.preferredEventTime;
        _preferredDays = List.from(prefs.preferredDays);
        _groupSize = prefs.groupSize;
        _prefersFamilyFriendly = prefs.prefersFamilyFriendly;
        _prefersOutdoor = prefs.prefersOutdoor;
        _prefersIndoor = prefs.prefersIndoor;
        _observesPoyaDays = prefs.observesPoyaDays;
        _observesReligiousHolidays = prefs.observesReligiousHolidays;
        _culturalInterests = List.from(prefs.culturalInterests);
        _languagePreference = prefs.languagePreference;
        _socialStyle = prefs.socialStyle;
        _likesNewExperiences = prefs.likesNewExperiences;
        _prefersFamiliarEvents = prefs.prefersFamiliarEvents;
        _adventureLevel = prefs.adventureLevel;
        _allowsPersonalizedNotifications =
            prefs.allowsPersonalizedNotifications;
        _allowsLocationBasedRecommendations =
            prefs.allowsLocationBasedRecommendations;
        _sharesDataForResearch = prefs.sharesDataForResearch;
        _notificationFrequency = prefs.notificationFrequency;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Personalize Your Experience', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Form pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: NeverScrollableScrollPhysics(),
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              children: [
                _buildPage1PersonalInfo(),
                _buildPage2LocationBudget(),
                _buildPage3EventPreferences(),
                _buildPage4BehavioralPreferences(),
                _buildPage5CulturalPreferences(),
                _buildPage6NotificationPreferences(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F3A),
        border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1))),
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(_totalPages, (index) {
              return Expanded(
                child: Container(
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: index <= _currentPage
                        ? const LinearGradient(colors: [Color(0xFF667eea), Color(0xFF764ba2)])
                        : null,
                    color: index <= _currentPage ? null : Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Step ${_currentPage + 1} of $_totalPages',
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            _getPageTitle(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case 0:
        return 'Personal Information';
      case 1:
        return 'Location & Budget';
      case 2:
        return 'Event Preferences';
      case 3:
        return 'Behavioral Preferences';
      case 4:
        return 'Cultural Preferences';
      case 5:
        return 'Notifications';
      default:
        return '';
    }
  }

  // Page 1: Personal Information
  Widget _buildPage1PersonalInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
            'This helps us personalize your event recommendations',
            style: TextStyle(color: Colors.white70),
          ),
          SizedBox(height: 24),

          // Age
          TextFormField(
            initialValue: _age?.toString(),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Age',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFF1A1F3A),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _age = int.tryParse(value),
          ),
          SizedBox(height: 16),

          // Gender
          DropdownButtonFormField<String>(
            value: _gender,
            style: const TextStyle(color: Colors.white),
            dropdownColor: const Color(0xFF1A1F3A),
            decoration: InputDecoration(
              labelText: 'Gender',
              labelStyle: const TextStyle(color: Colors.white70),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
              ),
              filled: true,
              fillColor: const Color(0xFF1A1F3A),
            ),
            items: ['male', 'female', 'other', 'prefer_not_to_say']
                .map((g) => DropdownMenuItem(
                      value: g,
                      child: Text(g.replaceAll('_', ' ').toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _gender = value),
          ),
          SizedBox(height: 16),

          // Religion
          DropdownButtonFormField<String>(
            value: _religion,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Religion (Optional)',
              labelStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              'buddhism',
              'hinduism',
              'islam',
              'christianity',
              'other',
              'none'
            ]
                .map((r) => DropdownMenuItem(
                      value: r,
                      child: Text(r.toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _religion = value),
          ),
          SizedBox(height: 16),

          // Occupation
          TextFormField(
            initialValue: _occupation,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Occupation (Optional)',
              labelStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) => _occupation = value,
          ),
          SizedBox(height: 16),

          // Education Level
          DropdownButtonFormField<String>(
            value: _educationLevel,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Education Level (Optional)',
              labelStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: [
              'high_school',
              'undergraduate',
              'graduate',
              'postgraduate',
              'other'
            ]
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e.replaceAll('_', ' ').toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _educationLevel = value),
          ),
        ],
      ),
    );
  }

  // Page 2: Location & Budget
  Widget _buildPage2LocationBudget() {
    final sriLankanDistricts = [
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
      'Kegalle'
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where do you like to go?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          // Primary Area
          DropdownButtonFormField<String>(
            value: _primaryArea,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Primary Location/District',
              labelStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: sriLankanDistricts
                .map((d) =>
                    DropdownMenuItem(value: d.toLowerCase(), child: Text(d)))
                .toList(),
            onChanged: (value) => setState(() => _primaryArea = value),
          ),
          SizedBox(height: 16),

          // Preferred Areas (Multi-select)
          Text('Preferred Areas (select multiple)',
              style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: sriLankanDistricts.take(10).map((district) {
              final isSelected =
                  _preferredAreas.contains(district.toLowerCase());
              return FilterChip(
                label: Text(district),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _preferredAreas.add(district.toLowerCase());
                    } else {
                      _preferredAreas.remove(district.toLowerCase());
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16),

          // Max Travel Distance
          Text(
              'Maximum Travel Distance: ${_maxTravelDistance?.toInt() ?? 50} km'),
          Slider(
            value: _maxTravelDistance ?? 50,
            min: 5,
            max: 200,
            divisions: 39,
            label: '${_maxTravelDistance?.toInt() ?? 50} km',
            onChanged: (value) => setState(() => _maxTravelDistance = value),
          ),
          SizedBox(height: 24),

          Text(
            'What\'s your event budget?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // Budget Range
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: _minBudget?.toInt().toString(),
                  style: TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Min Budget (LKR)',
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _minBudget = double.tryParse(value),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  initialValue: _maxBudget?.toInt().toString(),
                  style: TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    labelText: 'Max Budget (LKR)',
                    labelStyle: TextStyle(color: Colors.black54),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _maxBudget = double.tryParse(value),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Budget Flexibility
          DropdownButtonFormField<String>(
            value: _budgetFlexibility,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Budget Flexibility',
              labelStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: ['strict', 'flexible', 'very_flexible']
                .map((b) => DropdownMenuItem(
                      value: b,
                      child: Text(b.replaceAll('_', ' ').toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _budgetFlexibility = value),
          ),
        ],
      ),
    );
  }

  // Page 3: Event Preferences
  Widget _buildPage3EventPreferences() {
    final eventTypes = [
      'Music',
      'Religious',
      'Cultural',
      'Sports',
      'Educational',
      'Festival',
      'Art',
      'Food',
      'Theater',
      'Dance',
      'Comedy',
      'Technology'
    ];

    final musicGenres = [
      'Rock',
      'Pop',
      'Classical',
      'Hip-Hop',
      'Jazz',
      'Electronic',
      'Traditional',
      'Reggae',
      'Blues',
      'Country'
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What events do you love?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          // Favorite Event Types
          Text('Favorite Event Types',
              style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: eventTypes.map((type) {
              final isSelected =
                  _favoriteEventTypes.contains(type.toLowerCase());
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _favoriteEventTypes.add(type.toLowerCase());
                    } else {
                      _favoriteEventTypes.remove(type.toLowerCase());
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 24),

          // Music Genres
          Text('Favorite Music Genres',
              style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: musicGenres.map((genre) {
              final isSelected = _favoriteGenres.contains(genre.toLowerCase());
              return FilterChip(
                label: Text(genre),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _favoriteGenres.add(genre.toLowerCase());
                    } else {
                      _favoriteGenres.remove(genre.toLowerCase());
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16),

          // Favorite Artists
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Favorite Artists (comma-separated)',
              border: OutlineInputBorder(),
              hintText: 'Artist 1, Artist 2, Artist 3',
            ),
            onChanged: (value) {
              _favoriteArtists = value
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList();
            },
          ),
          SizedBox(height: 16),

          // Disliked Event Types
          Text('Event Types to Avoid',
              style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: eventTypes.take(6).map((type) {
              final isSelected =
                  _dislikedEventTypes.contains(type.toLowerCase());
              return FilterChip(
                label: Text(type),
                selected: isSelected,
                selectedColor: Colors.red[100],
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _dislikedEventTypes.add(type.toLowerCase());
                    } else {
                      _dislikedEventTypes.remove(type.toLowerCase());
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Page 4: Behavioral Preferences
  Widget _buildPage4BehavioralPreferences() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you like to attend events?',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          // Preferred Event Time
          DropdownButtonFormField<String>(
            value: _preferredEventTime,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Preferred Event Time',
              labelStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: ['morning', 'afternoon', 'evening', 'night', 'weekend']
                .map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _preferredEventTime = value),
          ),
          SizedBox(height: 16),

          // Preferred Days
          Text('Preferred Days', style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'monday',
              'tuesday',
              'wednesday',
              'thursday',
              'friday',
              'saturday',
              'sunday'
            ].map((day) {
              final isSelected = _preferredDays.contains(day);
              return FilterChip(
                label: Text(day.substring(0, 3).toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _preferredDays.add(day);
                    } else {
                      _preferredDays.remove(day);
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16),

          // Group Size
          TextFormField(
            initialValue: _groupSize?.toString(),
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Typical Group Size',
              labelStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              hintText: 'How many people do you usually go with?',
              hintStyle: TextStyle(color: Colors.black38),
              filled: true,
              fillColor: Colors.white,
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _groupSize = int.tryParse(value),
          ),
          SizedBox(height: 16),

          // Preferences switches
          SwitchListTile(
            title: Text('Family-Friendly Events'),
            value: _prefersFamilyFriendly,
            onChanged: (value) =>
                setState(() => _prefersFamilyFriendly = value),
          ),
          SwitchListTile(
            title: Text('Outdoor Events'),
            value: _prefersOutdoor,
            onChanged: (value) => setState(() => _prefersOutdoor = value),
          ),
          SwitchListTile(
            title: Text('Indoor Events'),
            value: _prefersIndoor,
            onChanged: (value) => setState(() => _prefersIndoor = value),
          ),
          SwitchListTile(
            title: Text('Likes New Experiences'),
            value: _likesNewExperiences,
            onChanged: (value) => setState(() => _likesNewExperiences = value),
          ),
          SwitchListTile(
            title: Text('Prefers Familiar Events'),
            value: _prefersFamiliarEvents,
            onChanged: (value) =>
                setState(() => _prefersFamiliarEvents = value),
          ),
          SizedBox(height: 16),

          // Adventure Level
          Text('Adventure Level: ${_adventureLevel}',
              style: TextStyle(fontWeight: FontWeight.w500)),
          Text('How adventurous are you?',
              style: TextStyle(fontSize: 12, color: Colors.grey)),
          Slider(
            value: _adventureLevel.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: _adventureLevel.toString(),
            onChanged: (value) =>
                setState(() => _adventureLevel = value.toInt()),
          ),
          Text(
            _adventureLevel == 1
                ? 'Very Conservative'
                : _adventureLevel == 2
                    ? 'Somewhat Conservative'
                    : _adventureLevel == 3
                        ? 'Moderate'
                        : _adventureLevel == 4
                            ? 'Adventurous'
                            : 'Very Adventurous',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),

          // Social Style
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _socialStyle,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Social Style',
              labelStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: ['introverted', 'extroverted', 'ambivert']
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(s.toUpperCase()),
                    ))
                .toList(),
            onChanged: (value) => setState(() => _socialStyle = value),
          ),
        ],
      ),
    );
  }

  // Page 5: Cultural Preferences
  Widget _buildPage5CulturalPreferences() {
    final culturalInterestOptions = [
      'Traditional',
      'Modern',
      'Fusion',
      'Historical',
      'Contemporary',
      'Folk',
      'Classical',
      'Urban',
      'Rural'
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cultural & Religious Preferences',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 24),

          SwitchListTile(
            title: Text('Observes Poya Days'),
            subtitle: Text('Full moon observance days'),
            value: _observesPoyaDays,
            onChanged: (value) => setState(() => _observesPoyaDays = value),
          ),
          SwitchListTile(
            title: Text('Observes Religious Holidays'),
            value: _observesReligiousHolidays,
            onChanged: (value) =>
                setState(() => _observesReligiousHolidays = value),
          ),
          SizedBox(height: 16),

          // Cultural Interests
          Text('Cultural Interests',
              style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: culturalInterestOptions.map((interest) {
              final isSelected =
                  _culturalInterests.contains(interest.toLowerCase());
              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _culturalInterests.add(interest.toLowerCase());
                    } else {
                      _culturalInterests.remove(interest.toLowerCase());
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 16),

          // Language Preference
          DropdownButtonFormField<String>(
            value: _languagePreference,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              labelText: 'Preferred Language for Events',
              labelStyle: TextStyle(color: Colors.black54),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            items: ['en', 'si', 'ta', 'multi'].map((lang) {
              String label;
              switch (lang) {
                case 'en':
                  label = 'English';
                  break;
                case 'si':
                  label = 'Sinhala';
                  break;
                case 'ta':
                  label = 'Tamil';
                  break;
                case 'multi':
                  label = 'Multi-lingual';
                  break;
                default:
                  label = lang;
              }
              return DropdownMenuItem(value: lang, child: Text(label));
            }).toList(),
            onChanged: (value) => setState(() => _languagePreference = value),
          ),
        ],
      ),
    );
  }

  // Page 6: Notification Preferences
  Widget _buildPage6NotificationPreferences() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stay Updated',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Control how we communicate with you',
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 24),

          SwitchListTile(
            title: Text('Personalized Notifications'),
            subtitle: Text('Get recommendations based on your preferences'),
            value: _allowsPersonalizedNotifications,
            onChanged: (value) =>
                setState(() => _allowsPersonalizedNotifications = value),
          ),
          SwitchListTile(
            title: Text('Location-Based Recommendations'),
            subtitle: Text('Events near you'),
            value: _allowsLocationBasedRecommendations,
            onChanged: (value) =>
                setState(() => _allowsLocationBasedRecommendations = value),
          ),
          SwitchListTile(
            title: Text('Share Data for Research'),
            subtitle: Text('Help improve our recommendation system'),
            value: _sharesDataForResearch,
            onChanged: (value) =>
                setState(() => _sharesDataForResearch = value),
          ),
          SizedBox(height: 16),

          // Notification Frequency
          Text('Notification Frequency',
              style: TextStyle(fontWeight: FontWeight.w500)),
          Text(
            'How often do you want recommendations?',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Slider(
            value: _notificationFrequency.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: _getNotificationFrequencyLabel(),
            onChanged: (value) =>
                setState(() => _notificationFrequency = value.toInt()),
          ),
          Text(
            _getNotificationFrequencyLabel(),
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          SizedBox(height: 24),

          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.privacy_tip, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Privacy Notice',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Your data is used only to improve your experience. We never share your personal information with third parties. You can update these preferences anytime.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNotificationFrequencyLabel() {
    switch (_notificationFrequency) {
      case 1:
        return 'Rarely (Weekly)';
      case 2:
        return 'Occasionally (Few times a week)';
      case 3:
        return 'Regularly (Daily)';
      case 4:
        return 'Often (Multiple times daily)';
      case 5:
        return 'Very Often (Several times daily)';
      case 6:
        return 'Frequently (Many times daily)';
      case 7:
        return 'Always (Real-time)';
      default:
        return '';
    }
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                        _pageController.previousPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                child: Text('Back'),
              ),
            ),
          if (_currentPage > 0) SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNext,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text(_currentPage == _totalPages - 1
                      ? 'Save Preferences'
                      : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleNext() async {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _savePreferences();
    }
  }

  Future<void> _savePreferences() async {
    setState(() => _isLoading = true);

    try {
      final preferences = UserPreferencesModel(
        age: _age,
        gender: _gender,
        religion: _religion,
        occupation: _occupation,
        educationLevel: _educationLevel,
        primaryArea: _primaryArea,
        preferredAreas: _preferredAreas,
        maxTravelDistance: _maxTravelDistance,
        minBudget: _minBudget,
        maxBudget: _maxBudget,
        budgetFlexibility: _budgetFlexibility,
        favoriteEventTypes: _favoriteEventTypes,
        favoriteGenres: _favoriteGenres,
        favoriteArtists: _favoriteArtists,
        favoriteVenues: _favoriteVenues,
        dislikedEventTypes: _dislikedEventTypes,
        preferredEventTime: _preferredEventTime,
        preferredDays: _preferredDays,
        groupSize: _groupSize,
        prefersFamilyFriendly: _prefersFamilyFriendly,
        prefersOutdoor: _prefersOutdoor,
        prefersIndoor: _prefersIndoor,
        observesPoyaDays: _observesPoyaDays,
        observesReligiousHolidays: _observesReligiousHolidays,
        culturalInterests: _culturalInterests,
        languagePreference: _languagePreference,
        socialStyle: _socialStyle,
        likesNewExperiences: _likesNewExperiences,
        prefersFamiliarEvents: _prefersFamiliarEvents,
        adventureLevel: _adventureLevel,
        allowsPersonalizedNotifications: _allowsPersonalizedNotifications,
        allowsLocationBasedRecommendations: _allowsLocationBasedRecommendations,
        sharesDataForResearch: _sharesDataForResearch,
        notificationFrequency: _notificationFrequency,
        createdAt: widget.existingPreferences?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        isComplete: true,
        completionPercentage: 100.0,
      );

      // Save through RecommendationProvider (handles both Firebase and mock modes)
      final recommendationProvider =
          Provider.of<RecommendationProvider>(context, listen: false);
      await recommendationProvider.saveUserPreferences(
          widget.userId, preferences);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preferences saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        Navigator.pop(context, preferences);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving preferences: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
