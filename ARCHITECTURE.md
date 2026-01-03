# Festio LK - System Architecture

This document describes the complete system architecture based on the AI-Based Cultural Event Discovery App diagram.

## System Overview

The app follows a comprehensive architecture with the following main components:

### 1. Event Data Ingestion Layer

**Public APIs Integration**
- **Location**: `lib/core/services/public_api_service.dart`
- **Purpose**: Fetches events from external sources (Eventbrite, city guides)
- **Features**:
  - Eventbrite API integration
  - City guide API integration
  - Event aggregation and deduplication

**User-Submitted Events**
- **Location**: `lib/screens/submission/event_submission_screen.dart`
- **Purpose**: Allows users to submit events via Web/Mobile interface
- **Features**:
  - Multilingual form (Sinhala, Tamil, English)
  - Image upload
  - Real-time validation

### 2. AI-Based Cultural Event Discovery App (Core)

#### Event Recommendation Engine
- **Location**: `lib/core/services/ai/recommendation_engine.dart`
- **Features**:
  - **Collaborative Filtering**: Recommends events based on similar users
  - **Semantic Analysis**: NLP-based content analysis
  - **Context Awareness**: Considers user preferences, location, time
  - **Hybrid Recommendations**: Combines multiple recommendation strategies

#### Multi-Language NLP Parser
- **Location**: `lib/core/services/ai/nlp_parser.dart`
- **Features**:
  - Language detection (Sinhala, Tamil, English)
  - Event information extraction
  - Auto-tagging
  - Spam detection using ML

#### Extract & Translate Event System
- **Location**: `lib/core/services/ai/event_extractor.dart`
- **Features**:
  - Extract events from text
  - Multi-language translation
  - API response parsing

#### Notification System
- **Location**: `lib/core/services/notification_service.dart`
- **Features**:
  - Real-time push notifications
  - Email notifications
  - POI (Point of Interest) notifications
  - Event reminders

### 3. Event Organizing & Management

**CRUD Operations**
- **Location**: `lib/core/services/firestore_service.dart`
- **Features**:
  - Create, Read, Update, Delete events
  - Event approval workflow
  - Spam detection integration

**Analytics Dashboard**
- **Location**: `lib/screens/admin/analytics_dashboard_screen.dart`
- **Location**: `lib/core/services/analytics_service.dart`
- **Features**:
  - Event analytics
  - Booking analytics
  - User analytics
  - Real-time statistics

### 4. Machine Learning Model Training

**Training Service**
- **Location**: `lib/core/services/ml/training_service.dart`
- **Features**:
  - Historical data processing
  - Feature extraction
  - Model training
  - Feedback loop for continuous learning

### 5. Local Event Submission Platform

**Submission Interface**
- **Location**: `lib/screens/submission/event_submission_screen.dart`
- **Features**:
  - Multilingual input
  - Image upload
  - Real-time NLP processing
  - Spam detection

**Event Management**
- **Location**: Admin screens (to be implemented)
- **Features**:
  - Review submitted events
  - Approve/reject events
  - Manage event status

### 6. User Interface (Mobile-Web App)

**Main Screens**:
- **Home**: `lib/screens/home/home_screen.dart` - Event discovery and recommendations
- **Events**: `lib/screens/events/events_screen.dart` - Browse all events
- **Event Detail**: `lib/screens/events/event_detail_screen.dart` - View event details
- **Bookings**: `lib/screens/bookings/bookings_screen.dart` - Manage bookings
- **Profile**: `lib/screens/profile/profile_screen.dart` - User profile
- **Analytics**: `lib/screens/admin/analytics_dashboard_screen.dart` - Admin dashboard

## Data Flow

1. **Event Ingestion**:
   - Public APIs → Event Extractor → Firestore
   - User Submission → NLP Parser → Spam Detection → Firestore

2. **Recommendation**:
   - User Query → Recommendation Engine → Collaborative Filtering + Semantic Analysis → Recommended Events

3. **Notification**:
   - Event Updates → Notification Service → Push/Email/POI Notifications

4. **Analytics**:
   - Event/Booking/User Data → Analytics Service → Dashboard

5. **ML Training**:
   - Historical Data → Training Service → Model Updates → Improved Recommendations

## Technology Stack

- **Frontend**: Flutter (Mobile & Web)
- **Backend**: Firebase (Firestore, Auth, Storage)
- **AI/ML**: Custom recommendation engine, NLP parser
- **Notifications**: Firebase Cloud Messaging (to be integrated)
- **APIs**: HTTP client for external API integration

## File Structure

```
lib/
├── core/
│   ├── models/          # Data models
│   ├── providers/       # State management
│   ├── services/
│   │   ├── ai/          # AI/ML services
│   │   │   ├── recommendation_engine.dart
│   │   │   ├── nlp_parser.dart
│   │   │   └── event_extractor.dart
│   │   ├── ml/          # ML training
│   │   │   └── training_service.dart
│   │   ├── analytics_service.dart
│   │   ├── notification_service.dart
│   │   └── public_api_service.dart
│   ├── routes/          # App routing
│   └── theme/            # App theming
├── screens/
│   ├── admin/           # Admin screens
│   │   └── analytics_dashboard_screen.dart
│   ├── auth/            # Authentication
│   ├── bookings/        # Booking management
│   ├── events/          # Event browsing
│   ├── home/            # Home screen
│   ├── profile/         # User profile
│   └── submission/      # Event submission
└── widgets/             # Reusable widgets
```

## Next Steps

1. ✅ Core architecture implemented
2. ✅ AI/ML services created
3. ✅ Analytics dashboard created
4. ⏳ Integrate notification system with Firebase Cloud Messaging
5. ⏳ Complete admin event management screens
6. ⏳ Implement actual ML model training (TensorFlow Lite integration)
7. ⏳ Add translation API integration
8. ⏳ Complete public API integrations with actual API keys

