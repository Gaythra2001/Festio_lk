# Firebase Setup Guide for Festio LK

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Add project"** or select an existing project
3. Enter project name: `festio-lk` (or your preferred name)
4. Follow the setup wizard:
   - Disable Google Analytics (optional) or enable it
   - Click **"Create project"**

## Step 2: Add Web App to Firebase Project

1. In your Firebase project dashboard, click the **Web icon** (`</>`)
2. Register your app:
   - App nickname: `Festio LK Web`
   - Check "Also set up Firebase Hosting" (optional)
   - Click **"Register app"**
3. **Copy the Firebase configuration object** that appears (it looks like this):

```javascript
const firebaseConfig = {
  apiKey: "AIza...",
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-id",
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123"
};
```

## Step 3: Add Android App (Optional - for Android builds)

1. Click **"Add app"** → Select **Android icon**
2. Register your app:
   - Android package name: `com.example.festio_lk`
   - App nickname: `Festio LK Android`
   - Click **"Register app"**
3. Download `google-services.json` and place it in `android/app/`

## Step 4: Add iOS App (Optional - for iOS builds)

1. Click **"Add app"** → Select **iOS icon**
2. Register your app:
   - iOS bundle ID: `com.example.festioLk`
   - App nickname: `Festio LK iOS`
   - Click **"Register app"**
3. Download `GoogleService-Info.plist` and place it in `ios/Runner/`

## Step 5: Add Windows App (Optional - for Windows builds)

1. Click **"Add app"** → Select **Windows icon**
2. Register your app:
   - App nickname: `Festio LK Windows`
   - Click **"Register app"**
3. Copy the configuration values

## Step 6: Enable Firebase Services

### Enable Authentication:
1. Go to **Authentication** → **Get started**
2. Click **"Sign-in method"** tab
3. Enable **Email/Password** provider
4. Click **"Save"**

### Enable Firestore Database:
1. Go to **Firestore Database** → **Create database**
2. Choose **"Start in test mode"** (for development)
3. Select a location (choose closest to your users)
4. Click **"Enable"**

### Enable Storage:
1. Go to **Storage** → **Get started**
2. Choose **"Start in test mode"** (for development)
3. Click **"Done"**

## Step 7: Update firebase_options.dart

Copy the values from Step 2-5 into `lib/firebase_options.dart`:

- Replace `YOUR_PROJECT_ID` with your `projectId`
- Replace `YOUR_WEB_API_KEY` with your `apiKey` (from web app)
- Replace `YOUR_WEB_APP_ID` with your `appId` (from web app)
- Replace `YOUR_MESSAGING_SENDER_ID` with your `messagingSenderId`
- Do the same for Android, iOS, Windows if you added those platforms

## Step 8: Test the Setup

Run the app:
```bash
flutter run -d chrome
```

The app should now connect to Firebase successfully!

## Troubleshooting

- **"Firebase App named '[DEFAULT]' already exists"**: Firebase is already initialized, this is fine
- **"MissingPluginException"**: Run `flutter clean` and `flutter pub get`
- **Authentication not working**: Make sure Email/Password is enabled in Firebase Console
- **Database errors**: Ensure Firestore is created and rules allow read/write (for test mode)

