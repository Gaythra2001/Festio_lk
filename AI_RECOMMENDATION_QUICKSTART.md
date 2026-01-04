# AI Recommendation System - Quick Start Guide

## Overview

This guide will help you integrate and use the advanced AI recommendation system and chatbot in your Festio application.

## Setup

### 1. Initialize User Behavior Tracking

When a user logs in or signs up, initialize their behavior tracking:

```dart
import 'package:provider/provider.dart';
import 'package:festio_lk/core/providers/recommendation_provider.dart';

// In your login/signup screen
final recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);
await recommendationProvider.initializeBehaviorTracking(user.id);
await recommendationProvider.trackSessionStart(user.id);
```

### 2. Prompt User to Complete Preferences

After first login, show the preferences form:

```dart
import 'package:festio_lk/screens/profile/user_preferences_form_screen.dart';

// Check if user has completed preferences
if (!recommendationProvider.hasCompletedPreferences()) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserPreferencesFormScreen(
        userId: user.id,
      ),
    ),
  );
}
```

### 3. Track User Interactions

Track user behavior throughout the app:

```dart
// When user views an event
await recommendationProvider.trackEventView(user.id, event);

// When user leaves event details (to calculate time spent)
await recommendationProvider.trackEventViewEnd(user.id, event.id);

// When user clicks on an event
await recommendationProvider.trackEventClick(user.id, event);

// When user searches
await recommendationProvider.trackSearch(user.id, searchQuery);

// When user books an event
await recommendationProvider.trackBooking(user.id, booking, event);
```

## Using Recommendations

### Load Personalized Recommendations

```dart
import 'package:provider/provider.dart';
import 'package:festio_lk/core/providers/recommendation_provider.dart';

// In your events screen
final recommendationProvider = Provider.of<RecommendationProvider>(context);
final authProvider = Provider.of<AuthProvider>(context);
final eventProvider = Provider.of<EventProvider>(context);
final bookingProvider = Provider.of<BookingProvider>(context);

await recommendationProvider.loadAdvancedRecommendations(
  user: authProvider.currentUser!,
  allEvents: eventProvider.events,
  userBookings: bookingProvider.userBookings,
  allUserBookings: {}, // Load from Firestore if needed
  maxRecommendations: 20,
);

// Access recommendations
final recommendations = recommendationProvider.recommendations;
```

### Display Recommendations

```dart
// Build recommendation list
ListView.builder(
  itemCount: recommendations.length,
  itemBuilder: (context, index) {
    final scoredEvent = recommendations[index];
    final event = scoredEvent.event;
    
    return Card(
      child: ListTile(
        title: Text(event.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event.location),
            SizedBox(height: 4),
            Text(
              scoredEvent.getExplanation(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, color: Colors.amber, size: 16),
            Text(
              '${(scoredEvent.score * 100).toStringAsFixed(0)}%',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        onTap: () {
          // Track click
          recommendationProvider.trackEventClick(user.id, event);
          
          // Navigate to event details
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EventDetailScreen(event: event),
            ),
          );
        },
      ),
    );
  },
)
```

## Using the AI Chatbot

### Open Chatbot

```dart
import 'package:festio_lk/widgets/ai_chatbot_widget.dart';

// Add a floating action button or button to open chatbot
FloatingActionButton(
  onPressed: () {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return AIChatbotWidget(
            user: authProvider.currentUser!,
            allEvents: eventProvider.events,
            userBookings: bookingProvider.userBookings,
            allUserBookings: {},
            userPreferences: recommendationProvider.userPreferences,
            userBehavior: recommendationProvider.userBehavior,
          );
        },
      ),
    );
  },
  child: Icon(Icons.chat),
  tooltip: 'AI Assistant',
)
```

### Chatbot Usage Examples

Users can interact with the chatbot using natural language:

**Example Queries**:
- "Show me music events in Colombo"
- "What's happening this weekend?"
- "Recommend events for me"
- "Find free events"
- "Events under 1000 rupees"
- "I like jazz music, what do you suggest?"
- "Tell me about upcoming cultural festivals"

## Managing User Preferences

### Update Preferences

```dart
// Allow user to update preferences
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UserPreferencesFormScreen(
      userId: user.id,
      existingPreferences: recommendationProvider.userPreferences,
    ),
  ),
);
```

### View User Analytics

```dart
// Get user engagement analytics
final analytics = await recommendationProvider.getUserAnalytics(user.id);

print('Total Sessions: ${analytics['totalSessions']}');
print('Average Session Duration: ${analytics['averageSessionDuration']} minutes');
print('Conversion Rate: ${analytics['conversionRate'] * 100}%');
print('Top Categories: ${analytics['topCategories']}');
```

## Advanced Features

### Toggle Between Engines

```dart
// Switch between advanced and legacy recommendation engine
recommendationProvider.toggleEngine();

// Check which engine is active
if (recommendationProvider.useAdvancedEngine) {
  print('Using advanced AI engine');
} else {
  print('Using legacy engine');
}
```

### Get High-Confidence Recommendations Only

```dart
// Get only recommendations with score >= 70%
final highConfidence = recommendationProvider.getHighConfidenceRecommendations(
  threshold: 0.7,
);
```

### Explanation for Recommendations

```dart
// Get explanation for why an event was recommended
final explanation = recommendationProvider.getRecommendationExplanation(eventId);
print(explanation);
// Output: "Similar to events you enjoyed • Popular with similar users"
```

## Session Management

### Track Session Lifecycle

```dart
// In your app's main screen or root widget

@override
void initState() {
  super.initState();
  
  // Track session start
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final recommendationProvider = Provider.of<RecommendationProvider>(
      context,
      listen: false,
    );
    recommendationProvider.trackSessionStart(user.id);
  });
}

@override
void dispose() {
  // Track session end
  final recommendationProvider = Provider.of<RecommendationProvider>(
    context,
    listen: false,
  );
  recommendationProvider.trackSessionEnd(user.id);
  
  super.dispose();
}
```

## Firestore Data Structure

### User Preferences Collection

```
user_preferences/{userId}
  - age: int
  - gender: string
  - religion: string
  - primaryArea: string
  - preferredAreas: array<string>
  - maxBudget: number
  - favoriteEventTypes: array<string>
  - favoriteArtists: array<string>
  ... (see UserPreferencesModel for complete structure)
```

### User Behavior Collection

```
user_behaviors/{userId}
  - totalSessions: int
  - averageSessionDuration: number
  - eventViews: map<eventId, count>
  - eventClicks: map<eventId, count>
  - eventTimeSpent: map<eventId, seconds>
  - searchQueries: array<string>
  - bookingsByCategory: map<category, count>
  ... (see UserBehaviorModel for complete structure)
```

## Performance Tips

1. **Lazy Loading**: Only load recommendations when needed
2. **Caching**: Use Provider's caching to avoid repeated API calls
3. **Batch Updates**: Behavior tracking uses batching internally
4. **Background Processing**: Long-running tasks are async

## Troubleshooting

### Issue: No recommendations showing

**Solution**: 
1. Check if user has any bookings (cold start problem)
2. Verify events are approved and not spam
3. Check if preferences are loaded
4. Try legacy engine as fallback

### Issue: Chatbot not responding

**Solution**:
1. Check if all required parameters are provided
2. Verify event data is loaded
3. Check for network errors
4. Clear chat history and retry

### Issue: Behavior tracking not working

**Solution**:
1. Verify user is initialized
2. Check Firestore permissions
3. Ensure tracking methods are called with correct userId
4. Check Firebase console for errors

## Best Practices

1. **Always track interactions**: More data = better recommendations
2. **Prompt for preferences early**: Cold start mitigation
3. **Show explanations**: Build user trust
4. **Provide diversity**: Use diversity re-ranking
5. **Monitor metrics**: Track CTR, conversion rate, engagement
6. **A/B test**: Compare engine performance
7. **Respect privacy**: Honor user consent settings

## Example Integration

Here's a complete example of integrating the recommendation system in an events screen:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:festio_lk/core/providers/recommendation_provider.dart';
import 'package:festio_lk/core/providers/auth_provider.dart';
import 'package:festio_lk/core/providers/event_provider.dart';
import 'package:festio_lk/core/providers/booking_provider.dart';
import 'package:festio_lk/widgets/ai_chatbot_widget.dart';

class RecommendedEventsScreen extends StatefulWidget {
  @override
  _RecommendedEventsScreenState createState() => _RecommendedEventsScreenState();
}

class _RecommendedEventsScreenState extends State<RecommendedEventsScreen> {
  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    final recommendationProvider = Provider.of<RecommendationProvider>(
      context,
      listen: false,
    );
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final eventProvider = Provider.of<EventProvider>(context, listen: false);
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await recommendationProvider.loadAdvancedRecommendations(
        user: authProvider.currentUser!,
        allEvents: eventProvider.events,
        userBookings: bookingProvider.userBookings,
        allUserBookings: {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommended for You'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Open preferences
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserPreferencesFormScreen(
                    userId: Provider.of<AuthProvider>(context, listen: false)
                        .currentUser!
                        .id,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<RecommendationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (provider.recommendations.isEmpty) {
            return Center(
              child: Text('No recommendations yet. Browse events to get started!'),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadRecommendations,
            child: ListView.builder(
              itemCount: provider.recommendations.length,
              itemBuilder: (context, index) {
                final scoredEvent = provider.recommendations[index];
                final event = scoredEvent.event;

                return _buildEventCard(event, scoredEvent);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openChatbot,
        icon: Icon(Icons.chat),
        label: Text('AI Assistant'),
      ),
    );
  }

  Widget _buildEventCard(EventModel event, ScoredEvent scoredEvent) {
    // Implement your event card UI
    return Card(
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(scoredEvent.getExplanation()),
        trailing: Chip(
          label: Text('${(scoredEvent.score * 100).toInt()}%'),
          backgroundColor: Colors.green[100],
        ),
        onTap: () {
          // Track click
          Provider.of<RecommendationProvider>(context, listen: false)
              .trackEventClick(
            Provider.of<AuthProvider>(context, listen: false).currentUser!.id,
            event,
          );
          
          // Navigate to details
          // Navigator.push(...);
        },
      ),
    );
  }

  void _openChatbot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final authProvider = Provider.of<AuthProvider>(context);
        final eventProvider = Provider.of<EventProvider>(context);
        final bookingProvider = Provider.of<BookingProvider>(context);
        final recommendationProvider = Provider.of<RecommendationProvider>(context);

        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return AIChatbotWidget(
              user: authProvider.currentUser!,
              allEvents: eventProvider.events,
              userBookings: bookingProvider.userBookings,
              allUserBookings: {},
              userPreferences: recommendationProvider.userPreferences,
              userBehavior: recommendationProvider.userBehavior,
            );
          },
        );
      },
    );
  }
}
```

## Next Steps

1. Test the recommendation system with real users
2. Collect metrics for research analysis
3. Fine-tune algorithm weights based on A/B tests
4. Expand chatbot capabilities
5. Implement deep learning models
6. Publish research findings

## Support

For issues or questions, refer to:
- [AI_RECOMMENDATION_SYSTEM_RESEARCH.md](AI_RECOMMENDATION_SYSTEM_RESEARCH.md) - Detailed research documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- Firebase console for data inspection

---

**Version**: 1.0  
**Last Updated**: January 2026
