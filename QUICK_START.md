# Festio LK - Quick Start Reference

## 🚀 Three Steps to Launch

### Step 1: Configure Firebase (5-20 minutes)

**Option A: Emulator (Fastest - Recommended)**
```bash
# 1. Copy env file
cd backend
copy .env.development .env

# 2. In .env, verify:
USE_FIREBASE_EMULATOR=true

# 3. In NEW terminal, start emulator:
firebase emulators:start --project=festio-lk-emulator

# Output should show:
# ✔ Cloud Firestore Emulator started at 127.0.0.1:8080
# ✔ Authentication emulator started at 127.0.0.1:9099
# ✔ Storage emulator started at 127.0.0.1:9199
```

**Option B: Real Firebase**
```bash
# 1. Visit https://console.firebase.google.com
# 2. Create project and download service account JSON
# 3. Copy .env.development to .env
# 4. Update these in .env:
USE_FIREBASE_EMULATOR=false
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@...iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY=-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n
```

---

### Step 2: Start Backend (1 minute)

```bash
cd backend
python run.py

# Should see:
# 🚀 Starting Festio LK Backend...
# 🔥 Using Firebase Emulators (local development mode)
# ✅ Firestore initialized successfully
# ✅ Firebase Storage initialized successfully
# INFO:     Uvicorn running on http://0.0.0.0:8000

# Verify: Open http://localhost:8000/docs
```

---

### Step 3: Connect Flutter Frontend (2-3 minutes)

**Desktop/Web:**
```bash
cd frontend

# Option 1: Web Browser
flutter run -d chrome

# Option 2: Windows Desktop
flutter run -d windows
```

**Android:**
```bash
# Start emulator first or connect physical device
adb devices

# Run app (use 10.0.2.2:8000 for emulator)
flutter run
```

**iOS:**
```bash
# Start simulator
open -a Simulator

# Run app (use localhost:8000)
flutter run
```

---

## 📋 Configuration Quick Reference

### Backend Env File (.env)
```
ENVIRONMENT=development
DATABASE_URL=postgresql://user:password@localhost:5432/festio_lk_dev
USE_FIREBASE_EMULATOR=true          # Or false for real Firebase
FIREBASE_PROJECT_ID=festio-lk-emulator
CORS_ORIGINS=["http://localhost:3000","http://localhost:8080"]
```

### Frontend Constants (lib/core/constants.dart)
```dart
// Web/Desktop
const String API_BASE_URL = 'http://localhost:8000';

// Android Emulator (use 10.0.2.2, not localhost)
// const String API_BASE_URL = 'http://10.0.2.2:8000';

// iOS Simulator
// const String API_BASE_URL = 'http://localhost:8000';
```

---

## 🔍 Verification Commands

```bash
# Backend alive?
curl http://localhost:8000/health

# Can reach API?
curl http://localhost:8000/api/v1/events

# API docs?
open http://localhost:8000/docs

# Emulator UI (if using Firebase Emulator)?
open http://localhost:4000
```

---

## ⚡ Common Commands

| Task | Command |
|------|---------|
| Start Emulator | `firebase emulators:start --project=festio-lk-emulator` |
| Start Backend | `cd backend && python run.py` |
| Start Flutter Web | `cd frontend && flutter run -d chrome` |
| View API Docs | `open http://localhost:8000/docs` |
| View Emulator UI | `open http://localhost:4000` |
| Run Tests | `flutter test` |
| Build Web | `flutter build web --release` |

---

## 🐛 Quick Fixes

### "Connection refused" to backend
```bash
# Check if port 8000 is free
netstat -ano | findstr :8000

# If occupied, kill it
taskkill /PID <PID> /F

# Then restart backend
python run.py
```

### "Firebase Emulator not starting"
```bash
# Ensure project flag is set
firebase emulators:start --project=festio-lk-emulator

# Check if port 8080, 9099, 9199 are free
# If ports in use, stop previous emulator or restart computer
```

### "Android app can't connect to backend"
```dart
// Change API_BASE_URL to:
const String API_BASE_URL = 'http://10.0.2.2:8000';
```

### "Unauthorized (401)" from API
```dart
// Ensure Bearer token is sent:
headers: {
  'Authorization': 'Bearer $idToken',
}

// Check token isn't expired (usually 1 hour)
```

---

## 📚 Full Documentation

- **Setup Guide**: [SETUP_CHECKLIST.md](./SETUP_CHECKLIST.md)
- **Local Emulator**: [backend/LOCAL_FIREBASE_SETUP.md](./backend/LOCAL_FIREBASE_SETUP.md)
- **Production Firebase**: [backend/FIREBASE_SETUP.md](./backend/FIREBASE_SETUP.md)
- **Flutter Integration**: [frontend/FIREBASE_FLUTTER_INTEGRATION.md](./frontend/FIREBASE_FLUTTER_INTEGRATION.md)
- **Migration Summary**: [FIREBASE_MIGRATION_SUMMARY.md](./FIREBASE_MIGRATION_SUMMARY.md)

---

## ✅ Before You Start

- [ ] Backend `.env.development` exists
- [ ] Firebase CLI installed (for emulator)
- [ ] Python 3.12 installed
- [ ] Flutter SDK installed
- [ ] Android SDK / iOS Xcode (for mobile)
- [ ] 5-10 GB free disk space

---

## 📱 Recommended Platform Order

1. **Web** (Desktop development - fastest)
2. **Android Emulator** (Testing, same as web)
3. **Physical Phone** (Real-world testing)
4. **iOS** (Final validation)

---

## 🎯 Success Criteria

You'll know it's working when:

✅ Backend starts without errors
✅ API docs visible at http://localhost:8000/docs
✅ Flutter app loads without crashes
✅ Can see events list in app (from Firestore)
✅ Can register a new user
✅ New user appears in Firestore (via Emulator UI)
✅ Can create an event (if organizer)
✅ Can book an event (if attendee)

---

## 🆘 Help

1. Check **SETUP_CHECKLIST.md** (Phase 6) for common issues
2. Review backend logs (make sure to look for errors/warnings)
3. Use Emulator UI (http://localhost:4000) to inspect data
4. Check Flutter console output for API errors
5. Use Chrome DevTools Network tab (web only) to see requests

---

## 🚀 You're Ready!

Everything is configured and ready. Just follow the three steps above and you'll have a fully functional Firebase-powered event booking platform.

**Questions? Check the documentation files above. Everything you need is documented!**

Good luck! 🎉
