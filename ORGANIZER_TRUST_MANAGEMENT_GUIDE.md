# Event Organizer Profile Trust Management System

## Overview

This comprehensive system builds trust and credibility for event organizers, which is critical for users to confidently purchase tickets. The system includes verification badges, trust scores, ratings, and detailed organizer profiles.

---

## 📦 Components Created

### 1. **Extended UserModel** (`user_model.dart`)
**Purpose**: Enhanced user profile with organizer-specific trust fields

**New Fields**:
- `isVerified` - Identity verification status
- `isPhoneVerified` - Phone number verification
- `isEmailVerified` - Email verification
- `businessName` - Registered business name
- `businessRegistration` - Registration number
- `businessAddress` - Official business address
- `averageRating` - Average review rating (0-5)
- `totalReviews` - Total number of reviews
- `totalEventsHosted` - Lifetime events hosted
- `totalTicketsSold` - Total tickets sold
- `hasVerificationBadge` - Special badge eligibility
- `verificationDate` - When verified
- `verificationDocumentUrl` - Proof documents

**Usage**:
```dart
// Check if organizer is trustworthy
final isReliable = user.averageRating >= 4.5 && 
                   user.totalEventsHosted >= 5 &&
                   user.isVerified;
```

---

### 2. **OrganizerProfileModel** (`organizer_profile_model.dart`)
**Purpose**: Detailed organizer profile information

**Key Features**:
- Business information (type, registration, location)
- Trust metrics (rating, reviews, events)
- Performance indicators (response time, cancellation rate)
- Verification status and documents
- Engagement metrics (attendees, revenue)

**Helper Methods**:
```dart
// Check overall trustworthiness
if (profile.isTrustworthy) {
  // Show premium badge
}

// Identify new organizers for special onboarding
if (profile.isNewOrganizer) {
  // Show "New Organizer" badge
}

// Get appropriate badge text
String badge = profile.getTrustBadgeText();
// Returns: "Verified & Highly Rated", "Verified Organizer", etc.
```

---

### 3. **OrganizerTrustProfileScreen** (`organizer_trust_profile_screen.dart`)
**Purpose**: Beautiful, comprehensive profile display page

**Sections**:
- **Header**: Profile image, name, verification badge, rating
- **About**: Organizer description
- **Trust & Credibility**: Rating, events, attendees, verification status
- **Business Performance**: Revenue, response time, rating, cancellation rate
- **Contact Information**: Location, phone
- **Verification Details**: Verification date and status

**Features**:
- Scrollable profile with sticky header
- Color-coded metrics
- Trust indicators throughout
- Responsive design
- Multi-language ready

**Usage**:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OrganizerTrustProfileScreen(
      organizerId: 'org_123',
      organizerName: 'ABC Events',
    ),
  ),
);
```

---

### 4. **Trust Widgets Library** (`organizer_trust_widgets.dart`)
**Purpose**: Reusable trust indicator components

#### **OrganizerVerificationBadge**
Displays verification status badges
```dart
OrganizerVerificationBadge(
  isVerified: true,
  isPhoneVerified: true,
  rating: 4.7,
  totalEvents: 24,
)
// Shows: [Verified badge] [Top Rated badge] [Trusted badge]
```

#### **TrustScoreIndicator**
Progress bar showing trust score
```dart
TrustScoreIndicator(
  trustScore: 85,
  maxScore: 100,
)
// Shows: Green progress bar "Highly Trustworthy 85/100"
```

#### **RatingDisplay**
Shows star rating with review count
```dart
RatingDisplay(
  rating: 4.7,
  reviewCount: 48,
  compact: false,
)
// Shows: ⭐ 4.7 (48)
```

#### **OrganizerTrustCard**
Compact organizer info card for event listings
```dart
OrganizerTrustCard(
  organizerName: 'ABC Events',
  rating: 4.7,
  totalEvents: 24,
  isVerified: true,
  reviewCount: 48,
  onTap: () { /* Navigate to profile */ },
)
```

#### **NewOrganizerBadge**
Badge for recently joined organizers (30 days)
```dart
NewOrganizerBadge(
  createdAt: DateTime.now(),
  daysToShowBadge: 30,
)
```

#### **TrustInfoBox**
Information box with icon and description
```dart
TrustInfoBox(
  title: 'Verified Organizer',
  description: 'This organizer has been identity verified',
  icon: Icons.verified,
  color: Colors.blue,
)
```

---

## 🔧 Integration Guide

### Step 1: Update Firestore Collections

Add these fields to your Firestore `users` collection organizer documents:

```javascript
{
  // Existing fields...
  email: "organizer@example.com",
  displayName: "ABC Events",
  
  // New trust fields
  isVerified: true,
  isPhoneVerified: true,
  isEmailVerified: true,
  businessName: "ABC Events Pvt Ltd",
  businessRegistration: "REG123456",
  businessAddress: "123 Main St, Colombo",
  averageRating: 4.7,
  totalReviews: 48,
  totalEventsHosted: 24,
  totalTicketsSold: 1250,
  hasVerificationBadge: true,
  verificationDate: timestamp,
  verificationDocumentUrl: "https://..."
}
```

### Step 2: Update AuthProvider

Ensure user data is loaded from updated model:

```dart
// Already compatible with new UserModel fields
final user = UserModel.fromMap(userData, userId);
```

### Step 3: Create OrganizerProfileProvider (Optional)

```dart
class OrganizerProfileProvider extends ChangeNotifier {
  final FirestoreService _firestore;
  OrganizerProfileModel? _profile;

  Future<void> loadOrganizerProfile(String organizerId) async {
    final data = await _firestore.getOrganizerProfile(organizerId);
    _profile = OrganizerProfileModel.fromMap(data, organizerId);
    notifyListeners();
  }

  OrganizerProfileModel? get profile => _profile;
}
```

### Step 4: Display Badges in Event Cards

Update event listing to show organizer trust:

```dart
// In event card widget
Consumer<AuthProvider>(
  builder: (context, authProvider, _) {
    final event = _event;
    final organizer = authProvider.getOrganizerById(event.organizerId);
    
    return Column(
      children: [
        // Event details...
        SizedBox(height: 8),
        OrganizerVerificationBadge(
          isVerified: organizer?.isVerified ?? false,
          rating: organizer?.averageRating ?? 0,
          totalEvents: organizer?.totalEventsHosted ?? 0,
        ),
      ],
    );
  },
)
```

### Step 5: Add Profile Link to Event Details

```dart
// In modern_event_detail_screen.dart organizer section
GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrganizerTrustProfileScreen(
          organizerId: event.organizerId,
          organizerName: event.organizerName,
        ),
      ),
    );
  },
  child: OrganizerTrustCard(
    organizerName: event.organizerName,
    rating: organizer?.averageRating ?? 0,
    totalEvents: organizer?.totalEventsHosted ?? 0,
    isVerified: organizer?.isVerified ?? false,
    reviewCount: organizer?.totalReviews ?? 0,
    onTap: () {}, // Handled by outer GestureDetector
  ),
)
```

---

## 📊 Trust Metrics Explained

### Trust Score Calculation
```
trustScore = (verification_points + rating_points + 
              event_points + review_points)
```

| Factor | Max Points | How It Works |
|--------|-----------|--------------|
| Verification | 30 | Identity verified (+30), Phone (+10), Email (+5) |
| Rating | 30 | 4.0+ = 30, 3.5+ = 25, 3.0+ = 20, etc. |
| Events | 25 | 20+ events = 25, 10+ = 20, 5+ = 15, etc. |
| Reviews | 15 | 50+ = 15, 25+ = 12, 10+ = 8, etc. |

### Trust Levels
- **90-100**: Highly Trustworthy (Verified, 4.5+⭐, 20+ events)
- **70-89**: Trustworthy (Verified, 4.0+⭐, 10+ events)
- **50-69**: Fair (Some verification, 3.5+⭐)
- **Below 50**: Limited (New or low ratings)

---

## 🎨 UI/UX Features

### Trust Badges Shown:
1. **Verified Badge** (Blue) - Identity verified
2. **Top Rated Badge** (Gold) - 4.5+ stars
3. **Trusted Badge** (Green) - 10+ events
4. **New Organizer Badge** (Red) - First 30 days

### Color Scheme:
- **Blue**: Verification/Trust
- **Gold/Amber**: Quality/Rating
- **Green**: Success/Trusted
- **Red**: New/Attention
- **Purple/Indigo**: Primary actions

---

## 🔐 Security Considerations

1. **Document Verification**: Implement document OCR and manual review
2. **Phone Verification**: Send OTP before marking as verified
3. **Email Verification**: Confirm email ownership
4. **Bank Account Verification**: Use Stripe/Payment provider verification
5. **Review Authenticity**: Implement booking-based review system (already done)
6. **Rate Limiting**: Prevent fake review flooding

---

## 📱 Mobile Considerations

- Badges are responsive and resize on smaller screens
- Profile layout adapts to phone height
- Touch targets are 48x48px minimum
- Rating stars are easily tappable

---

## 🌍 Multi-Language Support

All widgets use `GoogleFonts.poppins` and strings should be localized:

```dart
Text(
  'profile'.tr(), // Use easy_localization
  style: GoogleFonts.poppins(...),
)
```

Add to translation files:
```json
{
  "verified_organizer": "Verified Organizer",
  "trust_score": "Trust Score",
  "average_rating": "Average Rating",
  "events_hosted": "Events Hosted"
}
```

---

## 🚀 Future Enhancements

1. **Verification Tiers**: Bronze, Silver, Gold, Platinum
2. **Organizer Insurance**: Badge for insured organizers
3. **Background Check Badge**: For enhanced security
4. **Reviews**: Implement full review system with photos
5. **Response Rate Analytics**: Show organizer responsiveness
6. **Refund Policy**: Display clear refund terms
7. **Price Guarantee**: "Best price" badge
8. **Event Cancellation Insurance**: Premium protection

---

## 📝 Testing Checklist

- [ ] UserModel correctly serializes/deserializes trust fields
- [ ] OrganizerProfileModel loads from Firestore
- [ ] Trust badges display correctly
- [ ] Rating calculations are accurate
- [ ] Profile screen loads and displays all sections
- [ ] Navigation to profile works from events
- [ ] Badges update when organizer data changes
- [ ] Multi-language strings display correctly
- [ ] Responsive design on various screen sizes
- [ ] Performance: Profile loads within 2 seconds

---

## 💾 Database Schema Example

```firestore
/organizer_profiles/{userId}
├── organizerName: string
├── profileDescription: string
├── isVerified: boolean
├── verificationStatus: enum (verified|pending|unverified)
├── verificationDate: timestamp
├── businessType: enum (solo|company|npo)
├── businessRegistration: string
├── averageRating: number (0-5)
├── totalReviews: number
├── totalEventsHosted: number
├── totalTicketsSold: number
├── responseTime: number (minutes)
├── responseRating: number (0-5)
├── cancellationRate: number (0-100)
├── createdAt: timestamp
└── updatedAt: timestamp
```

---

## 📞 Support

For issues or questions:
1. Check if organizer data exists in Firestore
2. Verify UserModel/OrganizerProfileModel serialization
3. Check provider state management
4. Review console logs for API errors

