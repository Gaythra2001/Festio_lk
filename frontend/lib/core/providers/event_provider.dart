import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../services/mock_firestore_service.dart';
import '../services/storage_service.dart';
import '../services/ml/multi_language_nlp_service.dart';
import '../services/ml/text_classifier_service.dart';
import '../config/app_config.dart';
import 'dart:io';

class EventProvider with ChangeNotifier {
  final FirestoreService? _firestoreService =
      useFirebase ? FirestoreService() : null;
  final MockFirestoreService? _mockFirestoreService =
      useFirebase ? null : MockFirestoreService();
  final StorageService? _storageService = useFirebase ? StorageService() : null;
  final MultiLanguageNLPService _nlpService = MultiLanguageNLPService();
  final TextClassifierService _classifierService = TextClassifierService();

  List<EventModel> _events = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _searchResults = [];
  bool _isLoading = false;
  String _currentLanguage = 'en';

  List<EventModel> get events => _events;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get currentLanguage => _currentLanguage;

  EventProvider() {
    loadEvents();
  }

  /// Set user's preferred language for NLP processing
  void setLanguage(String language) {
    _currentLanguage = language;
    notifyListeners();
  }

  void loadEvents() {
    if (useFirebase && _firestoreService != null) {
      _firestoreService!.getApprovedEvents().listen((events) {
        _events = events;
        notifyListeners();
      });
    } else if (_mockFirestoreService != null) {
      _mockFirestoreService!.getApprovedEvents().listen((events) {
        _events = events;
        notifyListeners();
      });
    }
  }

  Future<void> loadUpcomingEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (useFirebase && _firestoreService != null) {
        _upcomingEvents = await _firestoreService!.getUpcomingEvents();
      } else if (_mockFirestoreService != null) {
        _upcomingEvents = await _mockFirestoreService!.getUpcomingEvents();
      }
    } catch (e) {
      debugPrint('Error loading upcoming events: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Multi-language semantic search using NLP
  Future<void> searchEvents(String query, {String? language}) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final lang = language ?? _currentLanguage;
      _searchResults = _nlpService.semanticSearch(
        query,
        _events,
        language: lang,
        maxResults: 50,
      );
    } catch (e) {
      debugPrint('Error in semantic search: $e');
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Get search suggestions for autocomplete
  List<String> getSearchSuggestions(String partial, {String? language}) {
    final lang = language ?? _currentLanguage;
    return _nlpService.generateSearchSuggestions(
      partial,
      _events,
      language: lang,
      maxSuggestions: 8,
    );
  }

  /// Auto-classify event and suggest tags
  Map<String, dynamic> classifyEvent(EventModel event) {
    return _classifierService.classifyEvent(event);
  }

  /// Validate event translations
  Map<String, dynamic> validateEventTranslations(EventModel event) {
    return _classifierService.validateTranslations(event);
  }

  /// Generate smart tags for event
  List<String> generateEventTags(EventModel event, {int maxTags = 8}) {
    return _classifierService.generateSmartTags(event, maxTags: maxTags);
  }

  /// Detect spam content
  Map<String, dynamic> detectSpam(EventModel event) {
    return _classifierService.detectSpam(event);
  }

  /// Analyze event content quality
  Map<String, dynamic> analyzeEventQuality(EventModel event) {
    return _classifierService.analyzeContentQuality(event);
  }

  /// Get events by category with NLP enhancement
  List<EventModel> getEventsByCategory(String category, {String? language}) {
    return _events.where((event) {
      // Exact category match
      if (event.category.toLowerCase() == category.toLowerCase()) {
        return true;
      }

      // NLP-based category classification
      final classification = _classifierService.classifyEvent(event);
      final suggestedCategories =
          classification['allCategories'] as List<String>;

      return suggestedCategories
          .any((cat) => cat.toLowerCase() == category.toLowerCase());
    }).toList();
  }

  Future<String?> submitEvent(EventModel event, File? imageFile) async {
    _isLoading = true;
    notifyListeners();

    try {
      String? imageUrl;
      if (imageFile != null && useFirebase && _storageService != null) {
        // First create a temporary ID for the event
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await _storageService!.uploadEventImage(imageFile, tempId);
      }
      // In mock mode, skip image upload

      final eventWithImage = EventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        titleSi: event.titleSi,
        titleTa: event.titleTa,
        descriptionSi: event.descriptionSi,
        descriptionTa: event.descriptionTa,
        startDate: event.startDate,
        endDate: event.endDate,
        location: event.location,
        locationSi: event.locationSi,
        locationTa: event.locationTa,
        category: event.category,
        tags: event.tags,
        organizerId: event.organizerId,
        organizerName: event.organizerName,
        imageUrl: imageUrl ?? event.imageUrl,
        latitude: event.latitude,
        longitude: event.longitude,
        isApproved: event.isApproved,
        isSpam: event.isSpam,
        spamScore: event.spamScore,
        trustScore: event.trustScore,
        submittedAt: event.submittedAt,
        approvedAt: event.approvedAt,
        maxAttendees: event.maxAttendees,
        ticketPrice: event.ticketPrice,
        ticketUrl: event.ticketUrl,
      );

      String? newId;
      if (useFirebase && _firestoreService != null) {
        newId = await _firestoreService!.submitEvent(eventWithImage);
      } else if (_mockFirestoreService != null) {
        newId = await _mockFirestoreService!.submitEvent(eventWithImage);
      }
      _isLoading = false;
      notifyListeners();
      return newId;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error submitting event: $e');
      return null;
    }
  }
}
