# How to Use the Event Organizer Trust Management System

## 📍 Quick Access Methods

### Method 1: Direct Navigation (Recommended)
From any screen, navigate to an organizer's trust profile:

```dart
// Option A: From event detail screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OrganizerTrustProfileScreen(
      organizerId: event.organizerId,
      organizerName: event.organizerName,
    ),
  ),
);
```

### Method 2: From Event Listing
Click on organizer info in an event card to see full trust profile:

```dart
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizerTrustProfileScreen(
          organizerId: organizer.id,
          organizerName: organizer.displayName ?? 'Organizer',
        ),
      ),
    );
  },
  child: OrganizerTrustCard(
    organizerName: organizer.displayName ?? 'Organizer',
    rating: organizer.averageRating,
    totalEvents: organizer.totalEventsHosted,
    isVerified: organizer.isVerified,
    reviewCount: organizer.totalReviews,
    onTap: () {}, // Handled by outer GestureDetector
  ),
)
```

---

## 🎨 Where to Use Trust Widgets

### 1. Event Card (Event Listings)
Add trust badges to event cards:

```dart
// In your event card widget
Column(
  children: [
    // Event details...
    SizedBox(height: 8),
    
    // Add trust badges
    OrganizerVerificationBadge(
      isVerified: organizer.isVerified,
      rating: organizer.averageRating,
      totalEvents: organizer.totalEventsHosted,
    ),
  ],
)
```

### 2. Event Detail Screen
Add organizer info with trust indicators:

```dart
// In modern_event_detail_screen.dart or event_detail_screen.dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: const Color(0xFF1A1F3A),
    borderRadius: BorderRadius.circular(16),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Organizer', style: Theme.of(context).textTheme.titleMedium),
      SizedBox(height: 12),
      
      // Organizer trust card
      GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrganizerTrustProfileScreen(
              organizerId: event.organizerId,
              organizerName: event.organizerName,
            ),
          ),
        ),
        child: OrganizerTrustCard(
          organizerName: event.organizerName,
          rating: 4.7, // Get from organizer data
          totalEvents: 24,
          isVerified: true,
          reviewCount: 48,
          onTap: () {},
        ),
      ),
    ],
  ),
)
```

### 3. Organizer Profile/Dashboard
Show trust metrics in organizer's own profile:

```dart
// In organizer_dashboard_screen.dart _ProfileTab
RatingDisplay(
  rating: authProvider.user?.averageRating ?? 0,
  reviewCount: authProvider.user?.totalReviews ?? 0,
)
```

### 4. Search/Discovery Results
Add trust badges to search results:

```dart
// Show in search results list
ListTile(
  title: Text(organizer.displayName ?? 'Organizer'),
  subtitle: RatingDisplay(
    rating: organizer.averageRating,
    reviewCount: organizer.totalReviews,
    compact: true,
  ),
  trailing: organizer.isVerified 
    ? Icon(Icons.verified, color: Colors.blue)
    : null,
)
```

---

## 🖥️ Opening the Full Profile Screen

### Step 1: Import Required Files
```dart
// Add to your screen's imports
import 'package:festio_lk/core/models/organizer_profile_model.dart';
import 'package:festio_lk/screens/organizer/organizer_trust_profile_screen.dart';
import 'package:festio_lk/widgets/organizer_trust_widgets.dart';
```

### Step 2: Navigate from Events
```dart
// From event_detail_screen.dart
class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  void _viewOrganizerProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizerTrustProfileScreen(
          organizerId: event.organizerId,
          organizerName: event.organizerName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Event details...
          
          // Organizer section
          GestureDetector(
            onTap: () => _viewOrganizerProfile(context),
            child: Container(
              child: Text('View Full Profile →'),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🧪 Testing the System

### Test 1: View Organizer Profile Screen
1. Open app
2. Navigate to an event detail
3. Tap on organizer section
4. See full trust profile with:
   - Verification badge
   - Star rating
   - Event count
   - All trust metrics

### Test 2: Trust Badges Display
1. Create a list of events
2. Look at event cards
3. Should show:
   - Verified badge (if verified)
   - Top rated badge (if rating ≥ 4.5)
   - Trusted badge (if 10+ events)

### Test 3: Check Trust Indicators
```dart
// In debug console, check trust status
final profile = OrganizerProfileModel(
  userId: 'org_1',
  organizerName: 'ABC Events',
  businessAddress: 'Colombo',
  isVerified: true,
  averageRating: 4.7,
  totalEventsHosted: 24,
  cancellationRate: 2,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

print(profile.isTrustworthy); // true
print(profile.getTrustBadgeText()); // "Verified & Highly Rated"
```

---

## 🔌 Integration Checklist

### Before You Start
- [ ] Have organizer data in Firestore with trust fields
- [ ] UserModel updated with trust fields
- [ ] OrganizerProfileModel imported in relevant screens

### Integration Steps
- [ ] Import `OrganizerTrustProfileScreen` in event detail screen
- [ ] Import trust widgets in event card components
- [ ] Add navigation from events to organizer profile
- [ ] Add trust badges to event listings
- [ ] Test trust profile screen loads without errors
- [ ] Verify badges display correctly
- [ ] Test navigation works

---

## 📱 Widget Reference

### Trust Badges Widget
```dart
OrganizerVerificationBadge(
  isVerified: true,
  rating: 4.7,
  totalEvents: 24,
)
// Shows: [Verified] [Top Rated] [Trusted]
```

### Rating Display
```dart
RatingDisplay(
  rating: 4.7,
  reviewCount: 48,
  compact: false,
)
// Shows: ⭐ 4.7 (48)
```

### Trust Card (Compact)
```dart
OrganizerTrustCard(
  organizerName: 'ABC Events',
  rating: 4.7,
  totalEvents: 24,
  isVerified: true,
  reviewCount: 48,
  onTap: () => navigateToProfile(),
)
// Shows: Profile card with tap action
```

### Trust Score Progress
```dart
TrustScoreIndicator(
  trustScore: 85,
  maxScore: 100,
  showLabel: true,
)
// Shows: Green progress bar "Highly Trustworthy 85/100"
```

### New Organizer Badge
```dart
NewOrganizerBadge(
  createdAt: DateTime.now(),
  daysToShowBadge: 30,
)
// Shows: Red "New Organizer" badge for first 30 days
```

### Trust Info Box
```dart
TrustInfoBox(
  title: 'Verified Organizer',
  description: 'This organizer has been identity verified',
  icon: Icons.verified,
  color: Colors.blue,
)
// Shows: Info box with icon and description
```

---

## 🎯 Common Use Cases

### 1. Show Verification Status on Event Card
```dart
Container(
  child: Row(
    children: [
      CircleAvatar(child: Text(organizer.displayName![0])),
      SizedBox(width: 8),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(organizer.displayName ?? 'Organizer'),
            RatingDisplay(
              rating: organizer.averageRating,
              reviewCount: organizer.totalReviews,
              compact: true,
            ),
          ],
        ),
      ),
      if (organizer.isVerified)
        Icon(Icons.verified, color: Colors.blue),
    ],
  ),
)
```

### 2. Display Trust Level Before Purchase
```dart
// Before showing "Book Now" button
if (organizer.averageRating < 3.0) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Organizer Trust'),
      content: TrustInfoBox(
        title: 'New Organizer',
        description: 'This organizer is relatively new. Proceed with caution.',
        icon: Icons.info,
        color: Colors.orange,
      ),
    ),
  );
}
```

### 3. Highlight Top-Rated Organizers
```dart
// In search/discovery
if (organizer.averageRating >= 4.5 && organizer.isVerified) {
  Container(
    decoration: BoxDecoration(
      border: Border.all(color: Colors.gold),
    ),
    child: Badge(
      label: Text('Top Rated'),
      child: EventCard(event: event),
    ),
  );
}
```

---

## 🔑 Key Files Location

| File | Purpose |
|------|---------|
| `lib/core/models/user_model.dart` | Extended with trust fields |
| `lib/core/models/organizer_profile_model.dart` | Detailed organizer profile |
| `lib/screens/organizer/organizer_trust_profile_screen.dart` | Full profile display screen |
| `lib/widgets/organizer_trust_widgets.dart` | Reusable trust widgets |
| `ORGANIZER_TRUST_MANAGEMENT_GUIDE.md` | Complete technical guide |

---

## 🚀 Quick Start Example

```dart
// Complete example integration
import 'package:flutter/material.dart';
import 'package:festio_lk/screens/organizer/organizer_trust_profile_screen.dart';
import 'package:festio_lk/widgets/organizer_trust_widgets.dart';

class EventDetailDemo extends StatelessWidget {
  final String organizerId = 'org_123';
  final String organizerName = 'ABC Events';
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Event Details')),
      body: Column(
        children: [
          // Event details...
          
          SizedBox(height: 20),
          Text('Organizer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          
          SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrganizerTrustProfileScreen(
                    organizerId: organizerId,
                    organizerName: organizerName,
                  ),
                ),
              );
            },
            child: OrganizerTrustCard(
              organizerName: organizerName,
              rating: 4.7,
              totalEvents: 24,
              isVerified: true,
              reviewCount: 48,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 📞 Troubleshooting

**Q: Profile screen shows mock data**
A: In production, load data from Firestore using OrganizerProfileProvider

**Q: Badges not showing**
A: Check if organizer data exists in UserModel with correct fields

**Q: Icons not found**
A: Ensure you're using valid Material Icons (e.g., `Icons.verified`, not `Icons.shield_verified`)

**Q: Navigation not working**
A: Make sure MaterialPageRoute is used and context.mounted is checked

---

## 🎓 Next Steps

1. **Integrate Trust Widgets** into existing event listing screens
2. **Add Navigation** from event detail to organizer profile
3. **Load Real Data** from Firestore instead of mock data
4. **Implement Provider** for organizer profile data management
5. **Add Reviews Section** to show user feedback on profile
6. **Setup Verification Flow** for organizers to get verified badges

