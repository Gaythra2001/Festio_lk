# Firebase Backend Migration - Setup Guide

This guide helps you set up the Firebase backend for the Festio LK Event Management Platform.

## Prerequisites

- Python 3.9+
- pip or poetry
- A Firebase project (free tier available at https://firebase.google.com)

## Step 1: Create Firefox Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create project" or select an existing project
3. Enable the following services:
   - **Authentication** → Enable Email/Password provider
   - **Cloud Firestore** → Create database in production mode
   - **Cloud Storage** → Create bucket

## Step 2: Get Firebase Credentials

1. In Firebase Console, go to **Settings** (gear icon) → **Project Settings**
2. Click on the **Service Accounts** tab
3. Click **Generate New Private Key** (Node.js is fine)
4. A JSON file will download with your credentials

## Step 3: Configure Environment Variables

1. Copy the Firebase credentials from the downloaded JSON file:

```json
{
  "type": "service_account",
  "project_id": "your-project-id",
  "private_key_id": "key-id",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
  "client_x509_cert_url": "https://www.googleapis.com/..."
}
```

2. Open `backend/.env` and fill in:
   ```
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
   FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n
   ```

   **Optional:** Set `FIREBASE_CREDENTIALS_PATH` to the path of your service account JSON file instead of using the individual fields.

## Step 4: Install Dependencies

```bash
cd backend
pip install -r requirements.txt
```

## Step 5: Set Up Firestore Security Rules

1. In Firebase Console, go to **Cloud Firestore** → **Rules**
2. Replace the default rules with:

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - only accessible by the user themselves or admins
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow create: if request.auth.uid == userId;
      allow update: if request.auth.uid == userId;
      allow delete: if request.auth.uid == userId;
    }
    
    // Events collection - published events readable by all, writable only by organizers
    match /events/{eventId} {
      allow read: if resource.data.status == 'published' || request.auth.uid == resource.data.organizer_id;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.organizer_id;
      allow delete: if request.auth.uid == resource.data.organizer_id;
    }
    
    // Bookings collection - only accessible by user or organizer
    match /bookings/{bookingId} {
      allow read: if request.auth.uid == resource.data.user_id || request.auth.uid == resource.data.organizer_id;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.user_id || request.auth.uid == resource.data.organizer_id;
      allow delete: if request.auth.uid == resource.data.user_id;
    }
    
    // Analytics - write-only for authenticated users
    match /analytics_events/{docId} {
      allow write: if request.auth != null;
      allow read: if false;
    }
    
    // Interactions - write-only for authenticated users
    match /interactions/{docId} {
      allow write: if request.auth != null;
      allow read: if false;
    }
    
    // Recommendations - read-only for users
    match /recommendations/{docId} {
      allow read: if request.auth.uid == resource.data.user_id;
      allow write: if false;
    }
    
    // Reviews - readable by all, writable by reviewers
    match /reviews/{docId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update: if request.auth.uid == resource.data.user_id;
      allow delete: if request.auth.uid == resource.data.user_id;
    }
  }
}
```

**Publish** these rules.

## Step 6: Run the Backend

```bash
# From backend directory
python run.py
```

Expected output:
```
🚀 Starting Festio LK Backend...
Environment: development
✅ Firestore initialized successfully
✅ Firebase Storage initialized successfully
✅ All services initialized
INFO:     Uvicorn running on http://0.0.0.0:8000
```

## Step 7: Test Firebase Integration

### Test Authentication Endpoint

```bash
# Register a new user
curl -X POST "http://localhost:8000/api/auth/register" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpassword123",
    "display_name": "Test User",
    "user_type": "attendee"
  }'
```

### Verify Firestore Data

1. Go to Firebase Console → Cloud Firestore
2. Check the `users` collection
3. You should see the registered user document

### Create an Event (As Organizer)

1. First, register an organizer user or update user type to "organizer"
2. Get Firebase ID token from your Flutter app or Firebase Authentication emulator
3. Create an event:

```bash
curl -X POST "http://localhost:8000/api/events/" \
  -H "Authorization: Bearer YOUR_FIREBASE_ID_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Event",
    "description": "A test event",
    "category": "technology",
    "start_date": "2024-03-15T10:00:00",
    "end_date": "2024-03-15T17:00:00",
    "timezone": "UTC",
    "location": {
      "name": "Tech Hub",
      "address": "123 Main St",
      "city": "San Francisco",
      "state": "CA",
      "postal_code": "94102",
      "country": "USA"
    },
    "is_online": false,
    "tickets": [
      {
        "name": "Standard",
        "price": 50.0,
        "quantity": 100,
        "available": 100
      }
    ],
    "total_capacity": 100
  }'
```

## Troubleshooting

### ❌ "Firebase credentials not configured"

**Solution:** Ensure your `.env` file has valid Firebase credentials:
- Check `FIREBASE_PROJECT_ID` is not empty
- Verify `FIREBASE_PRIVATE_KEY` starts with `-----BEGIN PRIVATE KEY-----`
- Ensure `FIREBASE_CLIENT_EMAIL` contains your service account email

### ❌ "Permission denied" errors in Firestore

**Solution:** Update Firestore security rules (see Step 5) to properly allow reads/writes.

### ❌ "User not found" after registration

**Solution:** Firebase Auth and Firestore are separate. Make sure:
1. User is created in Firebase Auth
2. User profile is created in Firestore `users` collection with UID as document ID

### ❌ Backend won't start - import errors

**Solution:** Reinstall dependencies:
```bash
pip install --upgrade -r requirements.txt
```

## API Endpoints Summary

### Authentication (`/api/auth`)
- `POST /register` - Register new user
- `POST /login` - Verify Firebase token and login
- `GET /me` - Get current user profile
- `PUT /profile` - Update user profile
- `POST /logout` - Logout user
- `GET /verify-token` - Verify if token is valid

### Users (`/api/users`)
- `GET /profile` - Get current user profile
- `GET /{user_id}` - Get user profile by ID
- `PUT /profile` - Update own profile
- `GET /preferences` - Get user preferences
- `POST /preferences` - Set user preferences
- `POST /{user_id}/follow` - Follow a user
- `POST /{user_id}/unfollow` - Unfollow a user

### Events (`/api/events`)
- `GET /` - List published events with filters
- `GET /{event_id}` - Get event details
- `POST /` - Create event (organizer only)
- `PUT /{event_id}` - Update event (organizer only)
- `DELETE /{event_id}` - Delete event (organizer only)
- `POST /{event_id}/publish` - Publish event
- `POST /{event_id}/upload-image` - Upload event image

### Bookings (`/api/bookings`)
- `GET /` - Get user's bookings
- `POST /` - Create booking
- `GET /{booking_id}` - Get booking details
- `POST /{booking_id}/confirm` - Confirm booking
- `DELETE /{booking_id}` - Cancel booking

## Next Steps

1. **Frontend Integration:** Update Flutter app to use Firebase Auth with the new backend
2. **Database Indexing:** Create Firestore indexes for queries with multiple filters
3. **Admin Panel:** Create admin dashboard to manage users and events
4. **Backup:** Set up automatic Firestore backups
5. **Monitoring:** Enable Firebase Cloud Monitoring for performance tracking

## Documentation

- [Firebase Admin SDK Docs](https://firebase.google.com/docs/admin/setup)
- [Cloud Firestore Docs](https://firebase.google.com/docs/firestore)
- [FastAPI Docs](https://fastapi.tiangolo.com/)
- [Firebase Security Rules](https://firebase.google.com/docs/database/security)

For questions or issues, check the project's issue tracker or documentation.
