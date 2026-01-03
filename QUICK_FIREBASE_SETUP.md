# Quick Firebase Setup - Step by Step

## You need to ADD an app first to see the configuration values!

### Step 1: Go to Firebase Console
Visit: https://console.firebase.google.com/

### Step 2: Create or Select Project
- If you don't have a project: Click **"Add project"** → Enter name → Create
- If you have a project: Click on it

### Step 3: Add Web App (This is where you get the values!)
1. On the project overview page, look for **"Get started by adding Firebase to your app"**
2. Click the **Web icon** (`</>`) - it looks like this: `</>`
3. You'll see a form:
   - **App nickname**: Enter `Festio LK Web`
   - **Firebase Hosting**: Leave unchecked (optional)
   - Click **"Register app"**

### Step 4: Copy the Configuration
After registering, you'll see a code block like this:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyC...",           // ← Copy this
  authDomain: "your-project.firebaseapp.com",
  projectId: "your-project-12345", // ← Copy this
  storageBucket: "your-project.appspot.com",
  messagingSenderId: "123456789",  // ← Copy this
  appId: "1:123456789:web:abc123"  // ← Copy this
};
```

### Step 5: Update lib/firebase_options.dart
Replace these values in the `web` section:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyC...',                    // From firebaseConfig.apiKey
  appId: '1:123456789:web:abc123',         // From firebaseConfig.appId
  messagingSenderId: '123456789',          // From firebaseConfig.messagingSenderId
  projectId: 'your-project-12345',         // From firebaseConfig.projectId
  authDomain: 'your-project-12345.firebaseapp.com',  // projectId + '.firebaseapp.com'
  storageBucket: 'your-project-12345.appspot.com',   // projectId + '.appspot.com'
);
```

### Step 6: Enable Services
1. **Authentication**: 
   - Left menu → Authentication → Get started → Sign-in method → Enable Email/Password

2. **Firestore**:
   - Left menu → Firestore Database → Create database → Start in test mode → Enable

3. **Storage**:
   - Left menu → Storage → Get started → Start in test mode → Done

### That's it! The app will now work with Firebase.

