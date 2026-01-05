# AI Recommendation Preferences - Complete Setup

## Overview
The AI recommendation system now includes a comprehensive user preferences management system with validation, completion tracking, and quality scoring.

## Features Implemented ✅

### 1. **Enhanced Preference Saving**
- ✅ Automatic timestamp updates (`updatedAt`)
- ✅ Completion percentage calculation
- ✅ Data validation before saving
- ✅ Better error handling and logging
- ✅ Firebase and local state synchronization

### 2. **Preference Validation**
The system validates:
- Age range (13-120 years)
- Budget constraints (min ≤ max, non-negative)
- Travel distance (non-negative)
- Adventure level (1-5 scale)
- Notification frequency (0-10)

### 3. **Completion Tracking**
Preferences are tracked across three tiers:
- **Core fields** (5): age, gender, primaryArea, favoriteEventTypes, preferredEventTime
- **Important fields** (5): religion, preferredAreas, maxBudget, favoriteGenres, culturalInterests
- **Optional fields** (5): occupation, educationLevel, socialStyle, favoriteArtists, favoriteVenues

Minimum 60% completion required for `isComplete = true`.

### 4. **New Provider Methods**

#### Preference Management
```dart
// Load user preferences
await recommendationProvider.loadUserPreferences(userId);

// Save preferences with auto-validation
await recommendationProvider.saveUserPreferences(userId, preferences);

// Update specific fields only
await recommendationProvider.updatePreferenceFields(
  userId,
  {'maxBudget': 10000, 'preferredEventTime': 'evening'},
);

// Create default preferences for new users
await recommendationProvider.createDefaultPreferences(userId);
```

#### Preference Analysis
```dart
// Check if preferences are complete
bool isComplete = recommendationProvider.hasCompletedPreferences();

// Get preference summary
Map<String, dynamic> summary = recommendationProvider.getPreferencesSummary();

// Check if preferences need updating (30+ days old)
bool needsUpdate = recommendationProvider.needsPreferenceUpdate();

// Get quality score (0-100)
double quality = recommendationProvider.getPreferenceQualityScore();
```

### 5. **Quality Scoring System**
The quality score (0-100) is calculated based on:
- Base completion percentage
- **+5 bonus**: Updated within last 7 days (fresh data)
- **-10 penalty**: Not updated in 90+ days (stale data)
- **+5 bonus**: 3+ favorite event types
- **+5 bonus**: 3+ favorite genres
- **+5 bonus**: Cultural interests specified

### 6. **UI Widget: PreferencesStatusWidget**
A reusable widget to display preference status:

```dart
// Compact view (banner)
PreferencesStatusWidget(compact: true)

// Full view (card with details)
PreferencesStatusWidget(compact: false)
```

Features:
- Visual progress indicator
- Quality badge (Excellent/Good/Fair/Poor)
- Status messages with icons
- Preference summary display
- Navigation to preferences form

## Usage Examples

### 1. Initialize Preferences on User Registration
```dart
final recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);
await recommendationProvider.createDefaultPreferences(userId);
```

### 2. Load Preferences on App Start
```dart
class HomeScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userId = authProvider.user?.id;
    if (userId != null) {
      await recommendationProvider.loadUserPreferences(userId);
      await recommendationProvider.loadUserBehavior(userId);
    }
  }
}
```

### 3. Display Preferences Status
```dart
// In profile screen or home screen
PreferencesStatusWidget(compact: false)

// In drawer or notification area
PreferencesStatusWidget(compact: true)
```

### 4. Update Specific Fields
```dart
// User changes notification settings
await recommendationProvider.updatePreferenceFields(
  userId,
  {
    'allowsPersonalizedNotifications': true,
    'notificationFrequency': 5,
  },
);
```

### 5. Check Preference Quality
```dart
final quality = recommendationProvider.getPreferenceQualityScore();

if (quality < 50) {
  // Show prompt to improve preferences
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Improve Your Recommendations'),
      content: Text('Complete more preferences to get better event suggestions!'),
      actions: [
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => UserPreferencesFormScreen(
                userId: userId,
                existingPreferences: recommendationProvider.userPreferences,
              ),
            ),
          ),
          child: Text('Update Now'),
        ),
      ],
    ),
  );
}
```

## Error Handling

All preference operations include proper error handling:

```dart
try {
  await recommendationProvider.saveUserPreferences(userId, preferences);
  // Success
} catch (e) {
  if (e is ArgumentError) {
    // Validation error - show specific message
    showSnackBar('Invalid data: ${e.message}');
  } else {
    // Other errors
    showSnackBar('Failed to save preferences: $e');
  }
}
```

## Validation Rules

### Age
- Minimum: 13 years
- Maximum: 120 years
- Optional field

### Budget
- Both values must be non-negative
- `minBudget ≤ maxBudget`
- Optional fields

### Travel Distance
- Must be non-negative
- Optional field

### Adventure Level
- Range: 1-5
- Default: 3
- Required field

### Notification Frequency
- Range: 0-10
- Default: 3
- Required field

## Best Practices

1. **Load preferences early**: Load user preferences when the user logs in or app starts
2. **Check completion**: Prompt users to complete preferences if completion < 60%
3. **Refresh recommendations**: After saving preferences, reload recommendations
4. **Monitor quality**: Periodically check quality score and prompt for updates
5. **Handle errors gracefully**: Show user-friendly messages for validation errors

## Testing

```dart
// Test preference validation
test('validates age range', () {
  expect(
    () => recommendationProvider.saveUserPreferences(
      userId,
      preferences.copyWith(age: 10),
    ),
    throwsA(isA<ArgumentError>()),
  );
});

// Test completion calculation
test('calculates completion correctly', () {
  final summary = recommendationProvider.getPreferencesSummary();
  expect(summary['completionPercentage'], greaterThan(0));
});
```

## Integration with Recommendations

The enhanced preferences automatically improve recommendation quality:

```dart
await recommendationProvider.loadAdvancedRecommendations(
  user: user,
  allEvents: events,
  userBookings: bookings,
  allUserBookings: allBookings,
  currentLocation: location,
);

// Recommendations now use:
// - User preferences (if available)
// - User behavior data
// - Preference quality score
// - Completion status
```

## Migration Notes

No migration needed! The system is backwards compatible:
- Existing preferences work without changes
- Missing fields are handled gracefully
- Completion percentage calculated on-the-fly
- Old preferences automatically updated on next save

## Monitoring

Track preference system health:

```dart
// Log preference stats
debugPrint('Preferences loaded: ${recommendationProvider.userPreferences != null}');
debugPrint('Completion: ${recommendationProvider.getPreferencesSummary()['completionPercentage']}%');
debugPrint('Quality: ${recommendationProvider.getPreferenceQualityScore()}');
debugPrint('Needs update: ${recommendationProvider.needsPreferenceUpdate()}');
```

## Next Steps

To fully integrate the system:

1. ✅ Add `PreferencesStatusWidget` to your home/profile screen
2. ✅ Call `loadUserPreferences()` on app startup
3. ✅ Create default preferences for new users
4. ✅ Monitor quality scores and prompt for updates
5. ✅ Test all validation rules

## Summary

The AI recommendation preferences system is now:
- ✅ **Robust**: Full validation and error handling
- ✅ **Smart**: Automatic completion tracking and quality scoring
- ✅ **User-friendly**: Clear status display and update prompts
- ✅ **Flexible**: Supports partial updates and defaults
- ✅ **Reliable**: Works in both Firebase and mock modes
