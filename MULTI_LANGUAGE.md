# Multi-Language Support

## Overview
Festio LK now supports three languages:
- **English** (en)
- **සිංහල / Sinhala** (si)
- **தமிழ் / Tamil** (ta)

## Features

### Implemented
1. ✅ Translation files for all three languages
2. ✅ Language selector widget with native language names
3. ✅ Language switcher button on login screen (top-right corner)
4. ✅ Persistent language selection using EasyLocalization
5. ✅ Comprehensive translations for common UI elements

### How to Use

#### For Users
1. Open the app at http://localhost:8080
2. Click the language icon (🌐) in the top-right corner
3. Select your preferred language:
   - English
   - සිංහල (Sinhala)
   - தமிழ் (Tamil)
4. The app will instantly switch to your selected language

#### For Developers

**Adding New Translations:**
1. Edit translation files in `assets/translations/`:
   - `en.json` - English
   - `si.json` - Sinhala
   - `ta.json` - Tamil

2. Add new key-value pairs:
```json
{
  "new_key": "New translated text"
}
```

3. Use in code:
```dart
import 'package:easy_localization/easy_localization.dart';

Text('new_key'.tr())
```

**Show Language Selector:**
```dart
import 'package:festio_lk/widgets/language_selector.dart';

// In a button or menu item
showLanguageSelector(context);
```

**Get Current Language:**
```dart
Locale currentLocale = context.locale; // e.g., Locale('en')
String languageCode = context.locale.languageCode; // e.g., 'en'
```

**Change Language Programmatically:**
```dart
await context.setLocale(Locale('si')); // Switch to Sinhala
await context.setLocale(Locale('ta')); // Switch to Tamil
await context.setLocale(Locale('en')); // Switch to English
```

## Translation Coverage

Currently translated UI elements:
- Authentication screens (login, register)
- Navigation items
- Common actions (save, cancel, edit, delete)
- Event-related terms
- Profile and settings
- Notifications
- Booking system
- Form fields
- Error and success messages

## File Structure

```
assets/
  translations/
    en.json      # English translations
    si.json      # Sinhala translations
    ta.json      # Tamil translations

lib/
  widgets/
    language_selector.dart  # Language selection dialog
  main.dart                 # EasyLocalization setup
```

## Configuration

The app is configured in `lib/main.dart`:

```dart
EasyLocalization(
  supportedLocales: [
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ],
  path: 'assets/translations',
  fallbackLocale: Locale('en'),
  startLocale: Locale('en'),
  child: MyApp(),
)
```

## Testing

To test the multi-language feature:
1. Run the app: `flutter run -d web-server --web-port=8080`
2. Open http://localhost:8080 in your browser
3. Click the language icon (top-right corner)
4. Switch between languages and verify translations
5. Check that the language persists after page reload

## Future Enhancements

- [ ] Add RTL (Right-to-Left) support for better Tamil display
- [ ] Add more specific event category translations
- [ ] Translate admin dashboard
- [ ] Add language-specific date/time formatting
- [ ] Add plural forms support where needed
- [ ] Add context-specific translations for longer descriptions

## Dependencies

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  easy_localization: ^3.0.3
  intl: ^0.20.2
```

## Notes

- Language preference is automatically saved to device storage
- Default language is English
- All new screens should use `'key'.tr()` for text instead of hardcoded strings
- The language selector can be added to any screen by importing and calling `showLanguageSelector(context)`
