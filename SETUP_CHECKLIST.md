# Festio LK - Firebase Setup Checklist

Complete these steps to get Festio LK running with Firebase as the primary backend.

---

## ✅ Phase 1: Backend Setup (Firebase Configuration)

### Step 1: Choose Firebase Configuration

Choose ONE of the following options:

#### Option A: Firebase Emulator (Recommended for Local Development)
- **Pros**: No credentials needed, instant setup, perfect for testing
- **Requirements**: Google Cloud CLI installed
- **Setup Time**: ~5 minutes

**Action Steps:**
```bash
# 1. Install Google Cloud CLI (if not installed)
# Visit: https://cloud.google.com/sdk/docs/install

# 2. Copy .env.development to .env
cd backend
copy .env.development .env

# 3. Ensure these are set in .env:
#    USE_FIREBASE_EMULATOR=true
#    FIREBASE_PROJECT_ID=festio-lk-emulator

# 4. In a NEW terminal, start Firebase Emulator:
firebase emulators:start --project=festio-lk-emulator

# 5. Terminal should show:
#    ✔  Cloud Firestore Emulator started at 127.0.0.1:8080
#    ✔  Authentication emulator started at 127.0.0.1:9099
#    ✔  Storage emulator started at 127.0.0.1:9199
```

#### Option B: Real Firebase Project (For Production/Staging)
- **Pros**: Production-ready, real data persistence
- **Requirements**: Firebase account, service account credentials
- **Setup Time**: ~15-20 minutes

**Action Steps:**
1. Visit [Firebase Console](https://console.firebase.google.com)
2. Create a new project (or use existing)
3. Enable these services:
   - ✅ Firestore Database
   - ✅ Authentication (Email/Password)
   - ✅ Cloud Storage
4. Download service account credentials:
   - Click ⚙️ > Project Settings
   - Go to "Service Accounts" tab
   - Click "Generate New Private Key"
   - Save the JSON file
5. Copy `.env.development` to `.env` and update:
   ```
   USE_FIREBASE_EMULATOR=false
   FIREBASE_PROJECT_ID=your-project-id
   FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
   FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n
   ```

**Choose Now:** [ ] Option A (Emulator) | [ ] Option B (Real Firebase)

---

### Step 2: Update Backend Configuration

```bash
cd backend

# Copy development env to active env
copy .env.development .env

# Verify .env file has:
# - ENVIRONMENT=development
# - DATABASE_URL set (PostgreSQL or SQLite)
# - Firebase credentials (Option A or B above)
# - CORS_ORIGINS includes your app URL
```

**Verification:**
```bash
# Test that backend can import Firebase
python -c "from src.main import app; print('✅ Backend imports successful')"
```

Expected output:
```
✅ Backend imports successful
```

---

### Step 3: Start Backend Server

```bash
# Terminal 1: If using Firebase Emulator
firebase emulators:start --project=festio-lk-emulator

# Terminal 2: Start backend
cd backend
python run.py

# Should see:
# 🚀 Starting Festio LK Backend...
# 🔥 Using Firebase Emulators (local development mode)
# ✅ Firestore initialized successfully
# ✅ Firebase Storage initialized successfully
# INFO:     Uvicorn running on http://0.0.0.0:8000
```

**Verification:**
- Open http://localhost:8000/docs 
- Should see Swagger API documentation with 129+ endpoints
- Try GET /api/v1/events (should return [] or events from Firestore)

---

## ✅ Phase 2: Frontend Setup (Flutter Configuration)

### Step 1: Configure Firebase in Flutter

```bash
cd frontend

# Re-run FlutterFire configuration
flutterfire configure

# Select your Firebase project
# Choose platforms: web, android, ios, windows, macos
```

This will update `lib/firebase_options.dart` with your credentials.

### Step 2: Update Backend API URL

Open `lib/core/constants.dart` (or create if doesn't exist):

```dart
// For local development
const String API_BASE_URL = 'http://localhost:8000';

// For Android emulator (change 'localhost' to '10.0.2.2')
// const String API_BASE_URL = 'http://10.0.2.2:8000';

// For production
// const String API_BASE_URL = 'https://api.festio.lk';
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

### Step 4: Update CORS in Backend (if needed)

Backend `.env`:
```
CORS_ORIGINS=["http://localhost:3000","http://localhost:5500","http://localhost:8080"]
```

---

## ✅ Phase 3: Testing Backend & Frontend Communication

### Backend Test: API Endpoints

```bash
# Terminal with backend running (http://localhost:8000)

# Test 1: List events (public endpoint)
curl -X GET http://localhost:8000/api/v1/events

# Expected: [] or list of events from Firestore

# Test 2: Health check
curl http://localhost:8000/health

# Expected: {"status":"ok"}

# Test 3: API docs
open http://localhost:8000/docs
# Opens Swagger UI with all endpoints
```

### Firebase Emulator UI (if using Option A)

Access Firestore Emulator UI:
```
http://localhost:4000
```

You can:
- View Firestore collections in real-time
- Inspect Authentication entries
- Monitor Storage files
- Test security rules

---

## ✅ Phase 4: Flutter App Testing

### Run on Web (Development)

```bash
cd frontend

# Run on Chrome
flutter run -d chrome

# Opens app at http://localhost:XXXX

# Expected: App loads, can see events list
```

### Run on Android (Physical/Emulator)

```bash
# Start Android emulator first, or connect physical device
adb devices

# Run flutter app
flutter run

# For emulator, use 10.0.2.2:8000 instead of localhost:8000
```

### Run on iOS (Physical/Simulator)

```bash
# Start iOS simulator
open -a Simulator

# Run flutter app  
flutter run

# Or specify device
flutter run -d "iPhone 14 Pro"
```

### Test Authentication Flow

In Flutter app:
1. Go to registration page
2. Register with email/password
3. Should create user in Firebase Auth
4. Should create user profile in Firestore
5. Should receive ID token
6. Should be able to access authenticated endpoints

---

## ✅ Phase 5: Data Verification

### Check Firestore Data (Using Emulator UI)

1. Open http://localhost:4000
2. Navigate to Firestore section
3. Should see collections:
   - `users/` - User profiles
   - `events/` - Published events
   - `bookings/` - User bookings
   - `analytics_events/` - Analytics data
   - `interactions/` - User interactions

### Check Firebase Auth (Using Emulator UI)

1. Open http://localhost:4000
2. Navigate to Authentication section
3. Should see registered users with:
   - Email
   - User ID (uid)
   - Custom claims (userType: attendee|organizer)

---

## ✅ Phase 6: Common Issues & Fixes

### Issue: "Connection refused" (Backend won't start)

**Solution:**
- Check port 8000 is available: `netstat -ano | findstr :8000` (Windows)
- Check DATABASE_URL in .env is valid
- Check PYTHONPATH includes backend directory

```bash
# Windows - Force port release
netstat -ano | findstr :8000
taskkill /PID <PID> /F

# Then restart: python run.py
```

### Issue: "CORS error" (Frontend can't reach backend)

**Solution:**
- Ensure backend has Frontend URL in CORS_ORIGINS
- Backend `.env` should have: `CORS_ORIGINS=["http://localhost:3000",...]`
- Restart backend after changing .env
- Chrome: Open DevTools > Network tab, check CORS headers

### Issue: "Unauthorized" (401 response from API)

**Solution:**
- Check Firebase token is being sent: `Authorization: Bearer <token>`
- Verify token isn't expired (usually 1 hour)
- For Emulator: Check FIREBASE_AUTH_EMULATOR_HOST is set
- Check Backend logs for token verification errors

### Issue: Firestore Emulator not starting

**Solution:**
```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Initialize Firebase in project root
firebase init

# Start emulator with verbose logging
firebase emulators:start --project=festio-lk-emulator --debug
```

### Issue: "Project not found" (Emulator)

**Solution:**
- When starting emulator, must include: `--project=festio-lk-emulator`
- This is a dummy project ID for testing
- Full command: `firebase emulators:start --project=festio-lk-emulator`

### Issue: Flutter can't find backend at localhost

**Android Emulator:**
```dart
// Change from:
const String API_BASE_URL = 'http://localhost:8000';

// To:
const String API_BASE_URL = 'http://10.0.2.2:8000';
```

**iOS Simulator:**
```dart
// Can use localhost directly
const String API_BASE_URL = 'http://localhost:8000';
```

---

## ✅ Phase 7: Production Deployment

### Backend Deployment

1. **Get Real Firebase Credentials:**
   - Firebase Console > Settings > Service Accounts
   - Download JSON key
   - Add to production environment

2. **Deploy Backend:**
   ```bash
   # Using Google Cloud Run (free tier available)
   gcloud run deploy festio-lk --source .
   
   # Or Docker on your server
   docker build -t festio-lk .
   docker run -p 8000:8000 -e FIREBASE_PROJECT_ID=... festio-lk
   ```

3. **Set Environment Variables:**
   - FIREBASE_PROJECT_ID
   - FIREBASE_CLIENT_EMAIL
   - FIREBASE_PRIVATE_KEY
   - DATABASE_URL (production)
   - USE_FIREBASE_EMULATOR=false

### Frontend Deployment

1. **Build Flutter Web:**
   ```bash
   flutter build web --release
   ```

2. **Deploy to Hosting:**
   - Firebase Hosting (free SSL)
   - Netlify / Vercel (Git integration)
   - AWS S3 + CloudFront
   - Custom server

3. **Update API_BASE_URL:**
   ```dart
   const String API_BASE_URL = 'https://api.festio.lk';
   ```

---

## ✅ Verification Checklist

Use this to verify each step is complete:

### Backend
- [ ] Firebase credentials configured in `.env`
- [ ] Backend starts without errors
- [ ] API docs accessible at `http://localhost:8000/docs`
- [ ] Events endpoint returns data: `curl http://localhost:8000/api/v1/events`
- [ ] Firestore/Storage initialized message in logs

### Frontend
- [ ] Flutter dependencies installed (`flutter pub get`)
- [ ] Firebase options updated (`flutterfire configure`)
- [ ] API_BASE_URL configured for platform (localhost, 10.0.2.2, production)
- [ ] App builds successfully (`flutter build web`)
- [ ] App runs on target platform

### Integration
- [ ] Flutter app can load events from backend
- [ ] User registration creates Firestore user
- [ ] Backend shows received request in logs
- [ ] Firestore Emulator UI shows Firestore data
- [ ] End-to-end booking flow works (create event → book → confirm)

---

## 📚 Documentation References

- [Backend Firebase Setup](./backend/LOCAL_FIREBASE_SETUP.md)
- [Firebase Production Setup](./backend/FIREBASE_SETUP.md)
- [Flutter Integration Guide](./frontend/FIREBASE_FLUTTER_INTEGRATION.md)
- [Backend API Documentation](http://localhost:8000/docs) (when running)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)

---

## 🎯 Quick Commands Reference

```bash
# Start Firebase Emulator
firebase emulators:start --project=festio-lk-emulator

# Start Backend
cd backend && python run.py

# Start Flutter Web
cd frontend && flutter run -d chrome

# Test API
curl http://localhost:8000/api/v1/events

# View API Docs
open http://localhost:8000/docs

# View Emulator UI
open http://localhost:4000
```

---

## 💪 Next Steps

1. Choose Firebase configuration (Emulator or Real)
2. Complete Phase 1: Backend Setup
3. Complete Phase 2: Frontend Setup  
4. Complete Phase 3-4: Testing
5. Monitor logs and fix any issues using Phase 6
6. Deploy to production using Phase 7

**Good luck! 🚀 The hardest part is done - you have a complete Firebase backend ready to go!**
