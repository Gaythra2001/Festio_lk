# Flutter Frontend Integration with Firebase Backend

## Quick Start

### 1. Prerequisites
- Flutter SDK installed (version 3.0 or higher)
- Firebase project set up (use same project as backend)
- iOS: CocoaPods installed
- Android: Android SDK/NDK installed

### 2. Firebase Configuration

#### Update `firebase_options.dart`

Open [lib/firebase_options.dart](lib/firebase_options.dart) and ensure your Firebase configuration matches your project:

```dart
// Example for web platform
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_WEB_API_KEY',
  appId: 'YOUR_WEB_APP_ID',
  messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
  projectId: 'your-firebase-project-id',
  authDomain: 'your-project.firebaseapp.com',
  databaseURL: 'your-project.firebaseio.com',
  storageBucket: 'your-project.appspot.com',
);
```

#### Get Your Firebase Credentials

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Click "Project Settings" (⚙️ icon)
4. Copy credentials for each platform:
   - **Web**: Copy Web API Key
   - **Android**: Download `google-services.json` and place in `android/app/`
   - **iOS**: Download `GoogleService-Info.plist` and add to Xcode project

### 3. Enable Firebase Services

Ensure these are enabled in Firebase Console:
- ✅ **Firestore Database** (production mode, then configure security rules)
- ✅ **Authentication** (enable Email/Password, Google, Apple)
- ✅ **Cloud Storage** (for event/profile images)

### 4. Backend API Connection

Update your Flutter app to point to your backend:

```dart
// lib/core/constants.dart (or equivalent)
const String API_BASE_URL = 'http://localhost:8000';  // For local development
// const String API_BASE_URL = 'https://api.festio.lk';  // For production

// Or detect dynamically:
final String apiBaseUrl = kIsWeb 
  ? 'http://localhost:8000'
  : 'http://YOUR_BACKEND_IP:8000';  // Android emulator: 10.0.2.2:8000
```

### 5. Authentication Flow

#### Web/Desktop (Development)

```dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get Firebase ID token
  Future<String?> getIdToken() async {
    User? user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  // Make authenticated API call
  Future<Response> makeAuthenticatedRequest(String endpoint) async {
    String? idToken = await getIdToken();
    
    return await http.get(
      Uri.parse('$API_BASE_URL$endpoint'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );
  }
}
```

#### Android/iOS (Physical Device/Emulator)

For Android emulator (not using Firebase Emulator):
```dart
// Use 10.0.2.2 instead of localhost for emulator access to host machine
const String API_BASE_URL = 'http://10.0.2.2:8000';
```

### 6. API Integration Examples

#### Login/Registration

```dart
// POST /api/v1/auth/register
Future<void> register({
  required String email,
  required String password,
  required String displayName,
  required String userType,  // 'attendee' or 'organizer'
}) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    
    String? idToken = await userCredential.user!.getIdToken();
    
    final response = await http.post(
      Uri.parse('$API_BASE_URL/api/v1/auth/register'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'display_name': displayName,
        'user_type': userType,
        'email': email,
      }),
    );
    
    if (response.statusCode == 201) {
      print('✅ Registration successful');
    } else {
      print('❌ Error: ${response.body}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

#### Get User Profile

```dart
// GET /api/v1/users/profile
Future<Map<String, dynamic>> getUserProfile() async {
  String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
  
  final response = await http.get(
    Uri.parse('$API_BASE_URL/api/v1/users/profile'),
    headers: {
      'Authorization': 'Bearer $idToken',
    },
  );
  
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  }
  throw Exception('Failed to load user profile');
}
```

#### List Events

```dart
// GET /api/v1/events?category=music&skip=0&limit=10
Future<List<Map<String, dynamic>>> getEvents({
  String? category,
  int skip = 0,
  int limit = 10,
}) async {
  String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
  
  final uri = Uri.parse('$API_BASE_URL/api/v1/events')
    .replace(queryParameters: {
      if (category != null) 'category': category,
      'skip': skip.toString(),
      'limit': limit.toString(),
    });
  
  final response = await http.get(
    uri,
    headers: {
      'Authorization': 'Bearer $idToken',
    },
  );
  
  if (response.statusCode == 200) {
    return List<Map<String, dynamic>>.from(jsonDecode(response.body));
  }
  throw Exception('Failed to load events');
}
```

#### Create Event (Organizers)

```dart
// POST /api/v1/events
Future<String> createEvent({
  required String title,
  required String description,
  required String category,
  required DateTime eventDate,
  required String location,
}) async {
  String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
  
  final response = await http.post(
    Uri.parse('$API_BASE_URL/api/v1/events'),
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'title': title,
      'description': description,
      'category': category,
      'event_date': eventDate.toIso8601String(),
      'location': {
        'venue': location,
        'coordinates': {'latitude': 0.0, 'longitude': 0.0},
      },
      'tickets': [
        {
          'ticket_type': 'General',
          'price': 0,
          'quantity': 100,
        }
      ],
    }),
  );
  
  if (response.statusCode == 201) {
    return jsonDecode(response.body)['id'];
  }
  throw Exception('Failed to create event');
}
```

#### Book Event

```dart
// POST /api/v1/bookings
Future<String> bookEvent({
  required String eventId,
  required String ticketType,
  required int quantity,
}) async {
  String? idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
  
  final response = await http.post(
    Uri.parse('$API_BASE_URL/api/v1/bookings'),
    headers: {
      'Authorization': 'Bearer $idToken',
      'Content-Type': 'application/json',
    },
    body: jsonEncode({
      'event_id': eventId,
      'ticket_type': ticketType,
      'quantity': quantity,
    }),
  );
  
  if (response.statusCode == 201) {
    return jsonDecode(response.body)['id'];
  }
  throw Exception('Failed to create booking');
}
```

### 7. Running the App

#### Development (Web)

```bash
cd frontend

# Run on web
flutter run -d chrome

# Or with backend on different machine
flutter run -d chrome --dart-define=API_BASE_URL=http://192.168.1.100:8000
```

#### Development (Android)

```bash
# On Android emulator
flutter run

# Check backend IP for emulator
adb shell cat /proc/net/arp | grep 192
```

#### Development (iOS)

```bash
# On iOS simulator
flutter run

# On physical device, update firebase_options.dart with emulator IP
flutter run -d <device_id>
```

### 8. Firestore Security Rules (Setup in Firebase Console)

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - authenticated users only
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    // Events collection - read public, write by organizer
    match /events/{eventId} {
      allow read: if true;  // Public read
      allow create: if request.auth.uid != null;
      allow update, delete: if request.auth.uid == resource.data.organizer_id;
      
      // Bookings subcollection
      match /bookings/{bookingId} {
        allow read: if request.auth.uid == resource.data.user_id || 
                       request.auth.uid == get(/databases/$(database)/documents/events/$(eventId)).data.organizer_id;
        allow create: if request.auth.uid != null;
        allow update, delete: if request.auth.uid == resource.data.user_id;
      }
    }
    
    // Bookings collection (root level)
    match /bookings/{bookingId} {
      allow read: if request.auth.uid == resource.data.user_id;
      allow create: if request.auth.uid != null && request.auth.uid == request.resource.data.user_id;
      allow update: if request.auth.uid == resource.data.user_id;
    }
  }
}
```

### 9. Troubleshooting

#### "CORS error" when calling API
- Ensure backend has CORS enabled for your Flutter app origin
- Check CORS_ORIGINS in backend `.env` file
- For web: `http://localhost:3000`, `localhost:5500`, etc.

#### "Unauthorized" (401) responses
- Verify Bearer token is being sent in Authorization header
- Check token hasn't expired: `FirebaseAuth.instance.currentUser?.getIdToken()`
- Verify backend can read Firebase tokens (check logs)

#### Android emulator can't reach backend
- Use `10.0.2.2` instead of `localhost` or `127.0.0.1`
- Backend must be listening on `0.0.0.0` (check `run.py`)

#### Firestore connection issues
- Verify Firebase project ID matches in both backend and frontend
- Check Firestore security rules allow access
- For emulator: verify `FIRESTORE_EMULATOR_HOST` is set correctly

#### "Failed to load configuration from Firebase"
- Rerun: `flutterfire configure`
- Delete `build/` and `pubspec.lock`
- Run: `flutter pub get`

### 10. Next Steps

1. ✅ Set up Firebase configuration in `firebase_options.dart`
2. ✅ Update backend API URL in your app constants
3. ✅ Implement authentication flow with Firebase Auth
4. ✅ Test API endpoints with sample requests
5. ✅ Deploy Firestore security rules
6. ✅ Set up push notifications (optional)
7. ✅ Implement ML recommendations (if enabled)

### 11. Production Deployment

- Update API_BASE_URL to production backend
- Enable Firebase Authentication providers (email, Google, Apple)
- Set up Email templates in Firebase Console
- Configure Firestore backup policies
- Enable Cloud Storage backup
- Test end-to-end with real data
- Monitor Firebase quotas and costs

For detailed backend API documentation, visit `http://localhost:8000/docs` when backend is running.
