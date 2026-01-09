# Modern Organizer Profile - User Guide

## Overview

The **Modern Organizer Profile Screen** is a completely redesigned, user-friendly interface for event organizers to manage their professional profiles. It features:

- **Tab-based Navigation** - Organized into 4 intuitive sections
- **Profile Completion Tracker** - Visual progress indicator
- **Smart Validation** - Real-time feedback on required fields
- **Modern UI/UX** - Beautiful gradient cards and smooth animations
- **Document Upload** - Easy verification document management
- **Trust Metrics Dashboard** - Performance analytics at a glance

## Features

### 1. Profile Completion Banner
A prominent banner at the top shows your profile completion percentage with a visual progress bar. This helps organizers understand what information is still needed.

**Benefits:**
- Clear visibility of profile status
- Motivates organizers to complete their profiles
- 100% completion unlocks full features and better visibility

### 2. Four Organized Tabs

#### **Overview Tab**
Your profile dashboard showing:
- Profile photo with easy upload
- Performance metrics (Rating, Events, Reviews)
- Quick statistics grid (Attendees, Upcoming Events, Tickets Sold, Response Time)
- Recent activity timeline

#### **Business Tab**
Essential business information:
- Business name and description
- Business type (Solo, Company, NPO)
- Registration number
- Tax ID (optional)
- Helpful tips and validation

#### **Contact Tab**
Communication and online presence:
- Business address (required)
- City and country
- Phone number with format validation
- Email (non-editable, pulled from account)
- Website URL
- Social media links (Facebook, Instagram, Twitter/X)

#### **Verify Tab**
Trust and verification section:
- Verification status card with color-coded status
- Interactive verification checklist
- Document upload interface
- Benefits of verification card

### 3. Smart Features

#### **Auto-save Indicators**
- Loading spinners during save operations
- Success/error notifications with icons
- Confirmation dialogs for discarding changes

#### **Field Validation**
- Required fields marked with *
- Real-time format validation (phone, URL)
- Clear error messages
- Visual feedback on focus

#### **Image Management**
- Profile photo upload with preview
- Automatic resizing to 1024x1024
- Quality optimization (85%)
- Upload progress indicator

## How to Use

### Accessing the Screen

```dart
import 'package:festio_lk/screens/organizer/modern_organizer_profile_screen.dart';

// Navigate to the screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ModernOrganizerProfileScreen(),
  ),
);

// Or use routes
Navigator.pushNamed(context, AppRoutes.modernOrganizerProfile);
```

### Editing Your Profile

1. **Tap the Edit Button** in the app bar
2. **Fill in or update** your information across the tabs
3. **Upload a photo** by tapping the camera icon on your profile picture
4. **Save changes** using the Save button in the app bar
5. **Cancel anytime** to discard changes (with confirmation dialog)

### Completing Verification

1. Navigate to the **Verify tab**
2. Check your **verification status**
3. Review the **checklist** to see what's needed
4. **Upload required documents**:
   - Business Registration Certificate
   - National ID or Passport
   - Proof of Address
   - Tax Registration (optional)
5. Wait for **admin review** (2-3 business days)

### Understanding Trust Metrics

Your **Performance Card** displays:
- **Rating**: Average rating from event attendees (out of 5.0)
- **Events**: Total number of events you've hosted
- **Reviews**: Total number of reviews received

**Quick Stats** show:
- **Total Attendees**: Cumulative attendance across all events
- **Upcoming Events**: Events scheduled for the future
- **Tickets Sold**: Total ticket sales
- **Response Time**: Average response time in hours

## Verification Benefits

Completing verification gives you:
- ✓ **Verified badge** on your profile and events
- ✓ **Higher visibility** in search results
- ✓ **Increased trust** from potential attendees
- ✓ **Priority support** from the platform
- ✓ **Premium features** access

## Profile Completion Scoring

The completion percentage is calculated based on:
1. Business name (10%)
2. Profile description (10%)
3. Business registration (10%)
4. Business address (10%)
5. City (10%)
6. Phone number (10%)
7. Email verified (10%)
8. Profile photo (10%)
9. Website URL (10%)
10. At least one social media link (10%)

**Tip:** Aim for 100% completion to maximize your profile's effectiveness!

## Best Practices

### Profile Photo
- Use a **professional logo** or business photo
- Ensure good **lighting and clarity**
- **Square format** works best (auto-cropped to circle)

### Business Description
- Explain what makes your events **unique**
- Mention your **experience and expertise**
- Keep it **concise but informative** (2-3 paragraphs)
- Use **keywords** that attendees might search for

### Contact Information
- Provide **accurate phone number** (with country code)
- Use your **business email** for professional communication
- Keep **social media links updated**
- Ensure **website URL is active**

### Verification Documents
- Upload **clear, readable scans** or photos
- Ensure documents are **current and valid**
- **File formats**: PDF, JPG, or PNG
- **File size**: Maximum 5MB per document

## Troubleshooting

### "Failed to save profile"
- Check your **internet connection**
- Ensure all **required fields** are filled
- Verify **phone and URL formats** are correct
- Try again after a few moments

### "Failed to upload image"
- Check **file size** (should be under 10MB)
- Ensure **stable internet** connection
- Try a **different image**
- Check **storage permissions**

### "Verification pending for too long"
- Typical review time is **2-3 business days**
- Check that all **required documents** are uploaded
- Ensure documents are **clear and legible**
- Contact **support** if waiting more than 5 business days

## Technical Details

### Dependencies
- `flutter/material.dart` - UI framework
- `google_fonts` - Typography
- `provider` - State management
- `image_picker` - Image selection
- `firebase_storage` - Image storage
- `cloud_firestore` - Data persistence

### Data Storage
Profile data is stored in Firestore under:
```
/users/{userId}
  - displayName
  - businessName
  - profileDescription
  - businessType
  - businessRegistration
  - taxId
  - businessAddress
  - city
  - country
  - phoneNumber
  - websiteUrl
  - socialMediaUrls (JSON)
  - photoUrl
  - verificationStatus
  - verificationDocuments (array)
  - isVerified
  - isPhoneVerified
  - updatedAt
```

### Image Storage
Profile images are stored in Firebase Storage:
```
/organizer_profiles/{userId}.jpg
```

Verification documents:
```
/verification_documents/{userId}/{documentType}.jpg
```

## Integration with Other Features

The Modern Organizer Profile integrates with:
- **Authentication System** - Auto-loads user data
- **Event Management** - Profile shown on event listings
- **Rating System** - Displays trust metrics
- **Verification System** - Document upload and status tracking
- **Analytics Dashboard** - Performance tracking

## Migration from Old Profile Screen

If you have an existing `OrganizerProfileManagementScreen`, you can:

1. **Keep both screens** for gradual migration
2. **Update navigation** to use the new screen
3. **Data remains compatible** - same Firestore structure
4. **No data migration needed**

Example replacement in navigation:
```dart
// Old
Navigator.push(context, MaterialPageRoute(
  builder: (_) => OrganizerProfileManagementScreen()
));

// New
Navigator.push(context, MaterialPageRoute(
  builder: (_) => ModernOrganizerProfileScreen()
));
```

## Future Enhancements

Planned improvements:
- [ ] Phone verification OTP integration
- [ ] Email verification resend
- [ ] Document preview before upload
- [ ] Multi-language support
- [ ] Export profile as PDF
- [ ] QR code for profile sharing
- [ ] Analytics graphs and charts
- [ ] Bulk photo upload for gallery
- [ ] Video introduction support
- [ ] Integration with calendar for availability

## Support

For issues or questions:
- Check the **troubleshooting section** above
- Review **Firebase console** for data/storage issues
- Test in **debug mode** for detailed error messages
- Contact development team with error logs

---

**Last Updated:** January 2026
**Version:** 1.0.0
**Compatibility:** Flutter 3.0+, Firebase 10+
