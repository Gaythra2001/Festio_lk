# Two-Part Registration System Documentation

## Overview

The Festio LK application now implements a comprehensive two-part registration system that separates the registration flows for **Event Attendees** and **Event Organizers**. This approach ensures that each user type gets the appropriate registration experience and only collects relevant information for their use case.

## System Architecture

### Registration Flow

```
Login Screen
    ↓
Registration Type Selection Screen (NEW)
    ├─→ Event Attendee Registration ← Google OAuth / Email
    └─→ Event Organizer Registration ← Full Details (Multi-step)
```

## Part 1: Event Attendee Registration

**Location:** `lib/screens/auth/user_registration_screen.dart`

### Features

- **Quick Registration Options:**
  - Google Sign-Up (One-click registration)
  - Traditional Email/Password Registration

- **Required Information:**
  - First Name
  - Last Name
  - Email Address
  - Contact Number
  - Password (with confirmation)

- **User Experience:**
  - Single screen form
  - Google OAuth button prominently displayed
  - Email/password option as fallback
  - Minimal fields to reduce friction
  - Terms & Conditions agreement checkbox

### Google Registration Flow

When users click "Sign up with Google":
1. User authenticates with their Google account
2. Basic profile information is automatically filled
3. Account is created with `UserType.user`
4. User is directed to login screen
5. After login, user can immediately browse and book events

### Email Registration Flow

When users register with email:
1. Fill in personal details (First Name, Last Name, Email, Phone)
2. Create a password (with confirmation)
3. Agree to terms and conditions
4. Account is created with `UserType.user`
5. User is directed to login screen

## Part 2: Event Organizer Registration

**Location:** `lib/screens/auth/organizer_registration_screen.dart`

### Features

- **Multi-Step Registration (3 Pages)**
  - Page 1: Personal Information
  - Page 2: Business Information
  - Page 3: Account Security

- **NO Google Sign-Up:** Organizers must register with full details to ensure proper verification

- **Page 1: Personal Information**
  - First Name
  - Last Name
  - Email Address
  - Contact Number
  - NIC/Passport Number (for verification)

- **Page 2: Business Information**
  - Business Name
  - Business Registration Number
  - Business Address
  - Event Category (type of events they organize)
  - Note: Users can upload verification documents after registration

- **Page 3: Account Security**
  - Password (minimum 8 characters)
  - Confirm Password
  - Password strength requirements displayed
  - Terms & Conditions agreement

### User Experience

- **Progress Tracking:** Visual progress bar showing step 1, 2, or 3 of 3
- **Back Navigation:** Users can navigate back to previous steps
- **Form Validation:** Each step is validated before proceeding
- **Clear Instructions:** Each step has a title and description
- **Security Focus:** Password requirements are clearly outlined

### Registration Flow

1. **Step 1 - Personal Information**
   - User enters personal details
   - Validation ensures all fields are filled
   - "Next" button advances to step 2

2. **Step 2 - Business Information**
   - User enters business details
   - Business registration number is required for verification
   - Back button allows returning to step 1
   - "Next" button advances to step 3

3. **Step 3 - Account Security**
   - User creates a secure password
   - Password must be at least 8 characters
   - Password requirements are displayed as reference
   - User agrees to terms and conditions
   - "Complete Registration" button submits the form

### Post-Registration

After registration:
- Account is created with `UserType.organizer`
- User is directed to login screen
- **Important:** User should complete their profile after login:
  - Upload business verification documents
  - Add business logo and banner
  - Set up payment information
  - Complete trust profile

## Type Selection Screen

**Location:** `lib/screens/auth/registration_type_selection_screen.dart`

### Purpose

Acts as a gateway to choose the appropriate registration path.

### Components

- **Event Attendee Card:**
  - Icon: Event seat
  - Description: "Discover, explore, and book events easily"
  - Features: Browse events, Book tickets, Quick Google registration
  - Primary styling (prominent)

- **Event Organizer Card:**
  - Icon: Business center
  - Description: "Create and manage events professionally"
  - Features: Create events, Manage bookings, Build trust profile
  - Secondary styling

- **Login Link:** Direct users to login if they already have an account

## Key Differences Summary

| Aspect | Event Attendee | Event Organizer |
|--------|---|---|
| Registration Method | Google OAuth / Email | Email only (full details) |
| Steps | Single page | 3-page form |
| Required Info | Minimal (name, email, phone) | Full (personal + business) |
| Verification Documents | Not required at signup | Required (uploaded later) |
| Business Registration | Not required | Required during signup |
| Target Time | < 1 minute | 5-10 minutes |
| Trust Profile | Optional enhancement | Critical for business |

## User Model Enhancement

The `UserModel` includes both user and organizer-specific fields:

```dart
enum UserType {
  user,           // Event Attendee
  organizer;      // Event Organizer
}

class UserModel {
  final UserType userType;
  final String? businessName;
  final String? businessRegistration;
  final String? businessAddress;
  final bool isVerified;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  // ... other fields
}
```

## Navigation Integration

### Modified Files

1. **modern_login_screen.dart**
   - Updated to navigate to `RegistrationTypeSelectionScreen`
   - Replaced `ModernRegistrationScreen` import

### Entry Point Flow

```
App Start
  ↓
Modern Login Screen
  ├─→ Existing Users: Login
  └─→ New Users: Registration Type Selection
       ├─→ Event Attendee: User Registration Screen
       └─→ Event Organizer: Organizer Registration Screen
```

## Implementation Details

### File Structure

```
lib/screens/auth/
├── registration_type_selection_screen.dart    (NEW)
├── user_registration_screen.dart              (NEW)
├── organizer_registration_screen.dart         (NEW)
├── modern_login_screen.dart                   (MODIFIED)
├── modern_registration_screen.dart            (EXISTING - can be deprecated)
└── login_screen.dart                          (EXISTING)
```

### User Data Provider Integration

Both registration flows call:

```dart
Provider.of<UserDataProvider>(context, listen: false).registerUser(
  email: _emailController.text,
  fullName: fullName,
  phone: phoneNumber,
  location: location,
  userType: UserType.user,  // or UserType.organizer
  businessName: businessName,  // Organizer only
  businessRegistration: businessReg,  // Organizer only
);
```

## Security Considerations

### Event Attendees
- Simple registration with email verification
- Google OAuth provides additional security layer
- Basic identity verification via email

### Event Organizers
- More stringent requirements
- Business registration verification
- NIC/Passport number collection
- Stronger password requirements
- Separate verification badge system
- Documents can be uploaded for trust building

## Future Enhancements

1. **Email Verification:** Send verification emails to both user types
2. **SMS Verification:** Optional SMS verification for organizers
3. **Document Upload:** Allow organizers to upload documents immediately
4. **KYC Integration:** Know Your Customer verification for organizers
5. **Reference Checking:** Call existing organizers as references
6. **Payment Setup:** Collect payment information before allowing event creation

## Testing Recommendations

### Event Attendee Flow
- [ ] Test Google OAuth registration
- [ ] Test email registration with valid email
- [ ] Test password validation (must match)
- [ ] Test terms acceptance requirement
- [ ] Test form validation (all fields required)
- [ ] Test redirect to login after registration

### Event Organizer Flow
- [ ] Test navigation between all 3 steps
- [ ] Test back button functionality
- [ ] Test step-specific validation
- [ ] Test progress bar updates
- [ ] Test password strength requirements
- [ ] Test terms acceptance requirement
- [ ] Test form submission
- [ ] Test redirect to login after registration

### Type Selection
- [ ] Test card selection and highlighting
- [ ] Test navigation to user registration
- [ ] Test navigation to organizer registration
- [ ] Test login link functionality

## API Endpoints (Backend Integration)

When ready for backend integration, implement these endpoints:

### User Registration
```
POST /api/auth/register/user
{
  email: string,
  firstName: string,
  lastName: string,
  phone: string,
  password: string,
  registrationMethod: "google" | "email"
}
```

### Organizer Registration
```
POST /api/auth/register/organizer
{
  email: string,
  firstName: string,
  lastName: string,
  phone: string,
  nicPassport: string,
  businessName: string,
  businessRegistration: string,
  businessAddress: string,
  businessCategory: string,
  password: string
}
```

## Rollout Strategy

1. **Phase 1:** Deploy new registration screens (current state)
2. **Phase 2:** Implement email verification
3. **Phase 3:** Add Google OAuth integration
4. **Phase 4:** Implement backend endpoints
5. **Phase 5:** Add document upload system
6. **Phase 6:** Enable trust verification workflow
