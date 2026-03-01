# Firebase Local Development Setup

This guide walks you through setting up Firebase for local development of Festio LK.

## Option 1: Using Firebase Emulator Suite (Recommended for Testing)

The Firebase Emulator Suite lets you run Firestore, Auth, and Storage locally without a real Firebase project.

### Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
firebase login
```

### Step 2: Initialize Firebase Project Locally

```bash
cd [project-root]
firebase init emulators
```

When prompted, select:
- ✅ Firestore
- ✅ Authentication  
- ✅ Storage
- ✅ Pub/Sub (optional)
- ✅ Emulator UI

### Step 3: Start Emulators

```bash
firebase emulators:start
```

Expected output:
```
┌─────────────────────────────────────────────────────────────┐
│ ✓  All emulators ready! It is now safe to connect your app. │
│ i  View Emulator UI at http://localhost:4000                │
└─────────────────────────────────────────────────────────────┘

Emulator Hub running at localhost:4400
Authentication Emulator running at http://localhost:9099
Cloud Firestore Emulator running at 127.0.0.1:8080
Cloud Storage emulator running at http://localhost:9199
Pub/Sub Emulator running at localhost:8085
```

### Step 4: Configure Backend for Emulators

Update `backend/.env`:

```env
# For emulator mode - set this to enable emulator
USE_FIREBASE_EMULATOR=true

# These can be dummy values when using emulator
FIREBASE_PROJECT_ID=test-project
FIREBASE_CLIENT_EMAIL=test@test.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC7W8rD5Z9pVGCH\nZbsXq1QIUmcvNjlz2lDoVePWGKVLa2vLg8p2vP1GrFl6VlbPVWZmRqpR5qL3BGOF\nlN7KJ5IBhqC1j5qlKPb8VdKqp1qPvJXqVl5qPvQwZLqQqPvRxMmL5vQyZMsXqPvR\nzNnM6wQzaMuYqQwTbNuZsRwUcNyaqRwVcOybrRwWcOybsRwXcOybtRwYcOybuRwZ\ncOybuRwaK0Q1MTAwMTAxVDAwOjAwOjAwWgowMDAwMDEwMVQwMDowMDowMFowDQYJ\nKoZIhvcNAQEBBQADggEPADCCAQoCggEBALtbysPln2lUYIdluxerVAhSZy82OXPK\nUOjV49YYpUtry8uDyna8/UasWXpWVs9VZmRGqlHmoveEY4WU3sонknGGgLWPmqUo\n9vxV0qqnWo+8lepWXmo+9DBkupCo+9HEyYvm9DJkyxeo+9HM2czrBDNoy5ipDBNs\n25mxHBRw3JqpHBVw7JutHBZw7JuxHBdw7Ju1HBhw7Ju5HBlw7Ju5HBpw7Ju5HBxw\n7Ju5HA==\n-----END PRIVATE KEY-----
FIREBASE_CREDENTIALS_PATH=
```

### Step 5: Update Backend to Use Emulator

Update `backend/src/main.py` lifespan to detect emulator:

```python
import os

@asynccontextmanager
async def lifespan(app: FastAPI):
    print("🚀 Starting Festio LK Backend...")
    
    if os.getenv("USE_FIREBASE_EMULATOR") == "true":
        print("🔥 Using Firebase Emulators (local development)")
        # Set emulator connection environment variables
        os.environ["FIRESTORE_EMULATOR_HOST"] = "127.0.0.1:8080"
        os.environ["FIREBASE_AUTH_EMULATOR_HOST"] = "127.0.0.1:9099"
        os.environ["FIREBASE_STORAGE_EMULATOR_HOST"] = "127.0.0.1:9199"
```

---

## Option 2: Using Real Firebase Project

If you want to use a real Firebase project:

### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create project"
3. Name: `festio-lk-dev`
4. Enable Google Analytics (optional)
5. Click "Create project"

### Step 2: Set Up Services

1. **Authentication:**
   - Go to Build > Authentication
   - Click "Get started"
   - Enable "Email/Password" provider

2. **Firestore:**
   - Go to Build > Firestore Database
   - Click "Create database"
   - Select "Start in test mode" (for development)
   - Choose region closest to you

3. **Storage:**
   - Go to Build > Storage
   - Click "Get started"
   - Start in test mode

### Step 3: Get Service Account Credentials

1. Go to Project Settings (gear icon)
2. Click "Service Accounts"
3. Click "Generate New Private Key"
4. A JSON file will download

### Step 4: Configure Backend

Copy the values from the JSON file to `backend/.env`:

```env
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project-id.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n
FIREBASE_CREDENTIALS_PATH=
USE_FIREBASE_EMULATOR=false
```

---

## Testing Configuration

### Test Backend Initialization

```bash
cd backend
python -c "from src.main import app; print('✅ Backend configured correctly')"
```

### Test Firebase Connection

```bash
python -c "
from services.firestore_service import get_firestore_service
fs = get_firestore_service()
if fs.initialize():
    print('✅ Firestore connected')
else:
    print('⚠️  Firestore not available (running without Firebase)')
"
```

---

## Development Workflow

### Terminal 1: Start Firebase Emulators (if using emulator)

```bash
firebase emulators:start
```

### Terminal 2: Start Backend

```bash
cd backend
python run.py
```

You should see:
```
🚀 Starting Festio LK Backend...
✓ Firestore initialized successfully
✓ Firebase Storage initialized successfully
INFO:     Uvicorn running on http://0.0.0.0:8000
```

### Terminal 3: Start Flutter Frontend

```bash
flutter run -d chrome
```

---

## Firebase Setup Checklist

- [ ] Firebase Emulator Suite installed (or real project created)
- [ ] `.env` file configured with Firebase credentials
- [ ] Backend starts without errors
- [ ] Flutter frontend can reach backend at `http://localhost:8000`
- [ ] Firestore security rules configured
- [ ] Firebase initialized in Flutter app

---

## Troubleshooting

### "Firestore not initialized" message
- **Emulator Mode:** Make sure `firebase emulators:start` is running
- **Real Firebase:** Check your credentials in `.env`

### "Connection refused" from Flutter
- Make sure backend is running on `0.0.0.0:8000` (not `127.0.0.1`)
- Flutter web needs CORS enabled (already configured)

### "Permission denied" errors
- Check Firestore security rules
- Make sure credentials are correct

---

## Next: Flask to Flutter Integration

See `FIREBASE_SETUP.md` for Flutter frontend setup instructions.
