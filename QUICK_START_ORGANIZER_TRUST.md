# 🚀 Quick Start Guide - Opening Organizer Trust System

## ⚡ 3 Ways to Access

### 1️⃣ **From Event Detail Screen** (Easiest)
- Open any event detail page
- Scroll to "Organizer" section
- **Tap the organizer card or arrow** → Opens full trust profile

### 2️⃣ **From Code - Direct Navigation**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => OrganizerTrustProfileScreen(
      organizerId: 'organizer_id_here',
      organizerName: 'ABC Events',
    ),
  ),
);
```

### 3️⃣ **From Event Listing**
Add trust widgets to event cards:
```dart
OrganizerTrustCard(
  organizerName: 'ABC Events',
  rating: 4.7,
  totalEvents: 24,
  isVerified: true,
  reviewCount: 48,
  onTap: () => navigateToProfile(),
)
```

---

## 📱 What You'll See

When you open an organizer's trust profile, you'll see:

### ✅ Header Section
- Organizer name
- Profile badge (if verified)
- Star rating
- Trust level indicator

### ✅ Trust & Credibility Section
- **Average Rating** - Overall satisfaction (0-5 stars)
- **Events Hosted** - Total number of events organized
- **Total Attendees** - Sum of all attendees
- **Verification Status** - VERIFIED, PENDING, or UNVERIFIED

### ✅ Business Performance Section
- **Total Revenue** - LKR amount earned
- **Response Time** - How fast they reply (in minutes)
- **Response Rating** - How satisfied people are with their response
- **Cancellation Rate** - % of events cancelled

### ✅ Contact Information
- Location
- Phone number
- Social links (if available)

### ✅ Verification Badge
Shows when the organizer was verified

### ✅ Action Button
"View Events by [Organizer Name]" - Browse all their events

---

## 🎨 Trust Badges Explained

### 🔵 **Verified Badge**
✓ Organizer has proven identity
✓ Phone number verified
✓ Email verified

### ⭐ **Top Rated Badge**
✓ 4.5+ stars
✓ Quality assured

### 💚 **Trusted Badge**
✓ 10+ successful events
✓ Proven track record

### 🔴 **New Organizer Badge**
✓ Less than 30 days old
✓ Shows during onboarding period

---

## 🧪 Try It Now!

### Step 1: Run the App
```bash
flutter run -d edge
# or
flutter run -d chrome
```

### Step 2: Navigate to Event
1. Open app
2. Go to "Events" or "Home"
3. Click on any event card
4. Scroll down to "Organizer" section

### Step 3: Tap Organizer Card
- Tap anywhere on the organizer box
- **OR** tap the arrow button (→)
- **OR** tap the organizer name

### Step 4: Explore Profile
- See all trust metrics
- Check verification status
- View business performance
- Call or message organizer

---

## 📊 Trust Score Interpretation

| Score | Status | Color | Meaning |
|-------|--------|-------|---------|
| 90-100 | ⭐⭐⭐⭐⭐ Highly Trustworthy | 🟢 Green | Buy confidently |
| 70-89 | ⭐⭐⭐⭐ Trustworthy | 🟢 Green | Good choice |
| 50-69 | ⭐⭐⭐ Fair | 🟠 Orange | Proceed with caution |
| <50 | ⭐⭐ Limited | 🔴 Red | New or low ratings |

---

## 🎯 Use Cases

### Before Buying Tickets
1. Click on organizer name
2. Check **Average Rating** (should be ≥ 4.0)
3. Check **Verification Badge** (should be present)
4. Check **Cancellation Rate** (should be < 10%)
5. If all green ✓ → Safe to buy!

### Finding Reliable Organizers
1. Go to event listings
2. Look for **Verified** badge
3. Look for **Top Rated** badge
4. Sort by rating (highest first)
5. Browse their profile

### Contacting Support
1. Open organizer profile
2. Scroll to "Contact Information"
3. See phone number or email
4. Tap to contact directly

---

## 🐛 Troubleshooting

**Q: "Organizer not found"**
- Check if organizer data exists in Firestore
- Ensure organizerId is correct

**Q: "Badges not showing"**
- Organizer needs to have rating ≥ 4.0
- Or needs to have 10+ events
- Or needs to be verified

**Q: "Profile doesn't open"**
- Make sure you're on the event detail screen
- Try tapping the arrow (→) button
- Check console for errors

**Q: "Stats are all zeros"**
- This is using demo data
- In production, data comes from Firestore
- Contact admin to update organizer stats

---

## 💡 Pro Tips

### Tip 1: Share Organizer Profile
Copy the organizer link and share with friends:
```
app://organizer/org_demo_1
```

### Tip 2: Favorite Trusted Organizers
- Tap ❤️ heart icon on verified organizers
- Access from "My Favorites" tab

### Tip 3: Leave Reviews
After attending an event:
1. Open organizer profile
2. Scroll to "Reviews" section
3. Tap "Write Review"
4. Share your experience

### Tip 4: Check Availability
On organizer profile:
- See "Upcoming Events" section
- See next available event date
- Reserve early for popular organizers

---

## 📚 Related Screens

| Screen | Access | Purpose |
|--------|--------|---------|
| Event Detail | Click event card | See event + organizer |
| Organizer Profile | Click organizer card | View full trust profile |
| Organizer Dashboard | Login as organizer | Manage your events |
| Ratings Analytics | Organizer dashboard | View your reviews |
| My Events | Organizer dashboard | List your events |

---

## 🔐 Privacy & Security

✓ Organizer data is public
✓ Reviews are verified (booking-based)
✓ Ratings are aggregated
✓ Contact info is optional
✓ No sensitive data exposed

---

## 📞 Need Help?

- **In-app Help**: Tap ? icon → "Organizer Trust Guide"
- **Report Issue**: Tap ... → "Report Organizer"
- **Contact Support**: settings → Support → Organizer Issues
- **FAQ**: www.festio.lk/help/organizer-trust

---

## ✨ Features Coming Soon

🔮 **Organizer Verification Tiers**
- Bronze, Silver, Gold, Platinum

🔮 **Background Check Badge**
- Enhanced security certification

🔮 **Insurance Badge**
- Event cancellation protection

🔮 **Reviews with Photos**
- Attendees can upload pictures

🔮 **Organizer Insurance**
- Buyer protection program

🔮 **Price Guarantee**
- "Best price" badge

---

**Enjoy exploring organizer trust profiles! 🎉**
