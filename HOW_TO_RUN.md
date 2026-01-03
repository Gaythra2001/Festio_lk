# How to Run Festio LK App

## Quick Start

### Option 1: Run on Chrome (Web) - Recommended for Development
```bash
flutter run -d chrome
```

### Option 2: Run on Windows Desktop
```bash
flutter run -d windows
```

### Option 3: Run on Edge Browser
```bash
flutter run -d edge
```

## Step-by-Step Instructions

### 1. Make sure dependencies are installed
```bash
flutter pub get
```

### 2. Check available devices
```bash
flutter devices
```

### 3. Run the app
Choose one of the options above based on your preference.

## Running on Mobile Devices

### For Android:
1. Connect your Android device via USB
2. Enable USB debugging on your device
3. Run: `flutter run`

### For iOS (Mac only):
1. Connect your iPhone/iPad
2. Open Xcode and trust the device
3. Run: `flutter run`

## Running on Emulators

### List available emulators:
```bash
flutter emulators
```

### Launch an emulator:
```bash
flutter emulators --launch <emulator_id>
```

### Then run the app:
```bash
flutter run
```

## Hot Reload & Hot Restart

While the app is running:
- Press `r` in the terminal for **Hot Reload** (quick updates)
- Press `R` for **Hot Restart** (full restart)
- Press `q` to **Quit** the app

## Troubleshooting

### If you get "No devices found":
1. Make sure Chrome/Edge is installed
2. For mobile: Enable USB debugging
3. Check: `flutter doctor` to see if everything is set up correctly

### If you get build errors:
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Check Flutter setup:
```bash
flutter doctor
```

## Current App Status

- ✅ **Mode**: Demo Mode (No Firebase required)
- ✅ **Status**: Ready to run
- ✅ **Available Devices**: Chrome, Edge, Windows Desktop

## First Time Setup

If this is your first time running Flutter:
1. Install Flutter SDK (if not already installed)
2. Run `flutter doctor` to check setup
3. Install Chrome/Edge browser
4. Run `flutter pub get` to install dependencies
5. Run `flutter run -d chrome`

