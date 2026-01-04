# Festio.lk - Cultural Event Discovery Platform

## 📋 Project Overview

Festio.lk is an AI-powered cultural event discovery and submission platform designed specifically for Sri Lanka. The application enables users to discover, explore, and participate in cultural events across the island while providing event organizers with a streamlined submission process.

### Key Features

- **Multi-Language Support**: Full support for English, Sinhala (සිංහල), and Tamil (தமிழ்) languages
- **Event Discovery**: Browse upcoming and past cultural events with advanced filtering
- **Category Filtering**: Filter events by categories including Festivals, Dance, Music, Theater, Art, Food, and Poya Days
- **Poya Day Calendar**: Automatically generated Buddhist full moon (Poya) days with accurate dates and temple information
- **Interactive Calendar**: Visual calendar view with event markers for easy date selection
- **Event Tabs**: Separate views for Upcoming and Past events with real-time date-based filtering
- **Modern UI**: Professional, gradient-based design with smooth animations
- **Firebase Integration**: Optional cloud-based backend for event storage and user authentication
- **Demo Mode**: Fully functional demo mode with mock data for testing without Firebase setup

### Target Audience

- Cultural event enthusiasts in Sri Lanka
- Event organizers and promoters
- Tourists seeking authentic cultural experiences
- Buddhist devotees tracking Poya days
- Families planning cultural outings

---

## 🏗️ Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                        │
├─────────────────────────────────────────────────────────────────┤
│  Screens/                                                        │
│  ├── Home Screen         (Featured Events, Quick Access)        │
│  ├── Events Screen       (Upcoming/Past Tabs, Filters)          │
│  ├── Event Detail Screen (Full event information)               │
│  ├── Bookings Screen     (User event bookings)                  │
│  ├── Profile Screen      (User profile & settings)              │
│  ├── Auth Screens        (Login, Registration)                  │
│  ├── Admin Dashboard     (Analytics, Event Management)          │
│  └── Contact Screen      (Support & Information)                │
│                                                                  │
│  Widgets/                                                        │
│  ├── Event Calendar      (Interactive date picker)              │
│  ├── Language Selector   (Multi-language switcher)              │
│  ├── Notification Widget (In-app notifications)                 │
│  └── Juice Rating        (Event popularity indicator)           │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        BUSINESS LOGIC LAYER                      │
├─────────────────────────────────────────────────────────────────┤
│  Providers/ (State Management via Provider)                     │
│  ├── Auth Provider          (User authentication state)         │
│  ├── Event Provider         (Event data management)             │
│  ├── Booking Provider       (Booking state management)          │
│  ├── User Data Provider     (User profile & preferences)        │
│  ├── Analytics Provider     (Usage analytics)                   │
│  ├── Notification Provider  (Push notification handling)        │
│  └── Recommendation Provider (AI-based suggestions)             │
│                                                                  │
│  Services/                                                       │
│  ├── Auth Service           (Login, register, logout)           │
│  ├── Firestore Service      (Database operations)               │
│  ├── Storage Service        (Image/file uploads)                │
│  ├── Analytics Service      (Event tracking)                    │
│  ├── Notification Service   (Push notifications)                │
│  ├── Public API Service     (External integrations)             │
│  └── Mock Services          (Demo mode implementations)         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                          DATA LAYER                              │
├─────────────────────────────────────────────────────────────────┤
│  Models/                                                         │
│  ├── Event Model           (Event data structure)               │
│  ├── User Model            (User profile structure)             │
│  └── Booking Model         (Booking data structure)             │
│                                                                  │
│  Configuration/                                                  │
│  ├── App Config            (Feature flags, demo mode)           │
│  ├── Firebase Options      (Firebase configuration)             │
│  └── App Theme             (UI styling & colors)                │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      EXTERNAL SERVICES                           │
├─────────────────────────────────────────────────────────────────┤
│  ├── Firebase Authentication (User management)                  │
│  ├── Cloud Firestore         (Event & user data storage)        │
│  ├── Firebase Storage        (Image hosting)                    │
│  ├── Firebase Analytics      (Usage tracking)                   │
│  └── Unsplash API            (Poya day images)                  │
└─────────────────────────────────────────────────────────────────┘
```

### Architecture Patterns

- **MVVM Pattern**: Separation of UI, business logic, and data layers
- **Provider Pattern**: Reactive state management with ChangeNotifier
- **Repository Pattern**: Abstract data sources for easy testing
- **Dependency Injection**: Services injected via Provider for modularity
- **Feature-First Structure**: Organized by features for scalability

---

## 📦 Project Dependencies

### Core Flutter Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter` | SDK | Core Flutter framework |
| `flutter_localizations` | SDK | Internationalization support |

### UI & Design

| Package | Version | Purpose |
|---------|---------|---------|
| `cupertino_icons` | ^1.0.6 | iOS-style icons |
| `google_fonts` | ^6.1.0 | Custom typography (Poppins, etc.) |
| `flutter_svg` | ^2.0.9 | SVG image rendering |
| `cached_network_image` | ^3.3.0 | Optimized network image loading |
| `image_picker` | ^1.0.5 | Camera/gallery image selection |

### State Management

| Package | Version | Purpose |
|---------|---------|---------|
| `provider` | ^6.1.1 | App-wide state management |

### Firebase & Backend

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^4.3.0 | Firebase SDK initialization |
| `firebase_auth` | ^6.1.3 | User authentication |
| `cloud_firestore` | ^6.1.1 | NoSQL database |
| `firebase_storage` | ^13.0.5 | Cloud file storage |

### Localization

| Package | Version | Purpose |
|---------|---------|---------|
| `intl` | ^0.20.2 | Date/number formatting |
| `easy_localization` | ^3.0.3 | Multi-language translations |

### Utilities

| Package | Version | Purpose |
|---------|---------|---------|
| `http` | ^1.1.2 | HTTP requests |
| `shared_preferences` | ^2.2.2 | Local key-value storage |
| `qr_flutter` | ^4.1.0 | QR code generation |
| `url_launcher` | ^6.2.2 | Open external links |
| `path_provider` | ^2.1.1 | File system paths |

### Forms & Validation

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_form_builder` | ^10.2.0 | Dynamic form creation |
| `form_builder_validators` | ^11.0.0 | Input validation rules |

### Date & Time

| Package | Version | Purpose |
|---------|---------|---------|
| `intl_phone_field` | ^3.2.0 | International phone input |
| `table_calendar` | ^3.0.9 | Interactive calendar widget |

### Development Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Unit & widget testing |
| `flutter_lints` | ^6.0.0 | Dart code linting |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Chrome (for web development)
- Android Studio / VS Code
- Firebase account (optional for demo mode)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/festio_lk.git
   cd festio_lk
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run -d chrome
   ```

### Demo Mode

The app runs in demo mode by default with mock data. To enable Firebase:

1. Update `lib/core/config/app_config.dart`:
   ```dart
   static const bool useFirebase = true;
   ```

2. Configure Firebase following `FIREBASE_SETUP.md`

---

## 📱 Features in Detail

### Event Management
- **Upcoming/Past Tabs**: Events automatically sorted by date
- **Category Filters**: 8 categories including Poya Days
- **Event Cards**: Rich cards with images, ratings, location, and pricing
- **Calendar Integration**: Visual date selection with event markers

### Poya Days System
- **Automated Generation**: All 12 monthly Poya days for 2026
- **Accurate Dates**: Real full moon dates (Duruthu, Navam, Vesak, etc.)
- **Temple Information**: Specific locations (Kelaniya, Mihintale, etc.)
- **Unique Images**: Each Poya day has distinct imagery

### Multi-Language Support
- **3 Languages**: English, Sinhala, Tamil
- **Runtime Switching**: Change language without restart
- **Persistent Selection**: Language preference saved locally

---

## 📄 License

This project is private and proprietary.

---

## 👥 Contributors

Festio.lk Development Team

---

## 📞 Support

For support and inquiries, please contact through the app's Contact screen.