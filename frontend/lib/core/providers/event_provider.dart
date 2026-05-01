import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../services/mock_firestore_service.dart';
import '../services/storage_service.dart';
import '../services/ml/multi_language_nlp_service.dart';
import '../services/ml/text_classifier_service.dart';
import '../config/app_config.dart';

class EventProvider with ChangeNotifier {
  final FirestoreService? _firestoreService =
      useFirebase ? FirestoreService() : null;
  final MockFirestoreService? _mockFirestoreService =
      useFirebase ? null : MockFirestoreService();
  // Cloudinary-backed — works in both Firebase and mock modes
  final StorageService _storageService = StorageService();
  final MultiLanguageNLPService _nlpService = MultiLanguageNLPService();
  final TextClassifierService _classifierService = TextClassifierService();

  List<EventModel> _events = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _searchResults = [];
  List<EventModel> _organizerEvents = [];
  List<EventModel> _pendingEvents = [];
  bool _isLoading = false;
  String _currentLanguage = 'en';

  List<EventModel> get events => _events;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get searchResults => _searchResults;
  List<EventModel> get organizerEvents => _organizerEvents;
  List<EventModel> get pendingEvents => _pendingEvents;
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

  void loadOrganizerEvents(String organizerId) {
    if (useFirebase && _firestoreService != null) {
      _firestoreService!.getOrganizerEvents(organizerId).listen((events) {
        _organizerEvents = events;
        notifyListeners();
      });
    } else if (_mockFirestoreService != null) {
      _mockFirestoreService!.getOrganizerEvents(organizerId).listen((events) {
        _organizerEvents = events;
        notifyListeners();
      });
    }
  }

  Future<void> loadPendingEvents() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (useFirebase && _firestoreService != null) {
        _pendingEvents = await _firestoreService!.getPendingEvents();
      } else if (_mockFirestoreService != null) {
        _pendingEvents = await _mockFirestoreService!.getPendingEvents();
      }
    } catch (e) {
      debugPrint('Error loading pending events: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveEvent(String eventId, {String? organizerId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (useFirebase && _firestoreService != null) {
        await _firestoreService!.approveEvent(eventId);
      } else if (_mockFirestoreService != null) {
        await _mockFirestoreService!.approveEvent(eventId);
      }

      await loadPendingEvents();
      if (organizerId != null && organizerId.isNotEmpty) {
        loadOrganizerEvents(organizerId);
      }
      await loadUpcomingEvents();
    } catch (e) {
      debugPrint('Error approving event: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> rejectEvent(String eventId,
      {String? organizerId, String? reason}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (useFirebase && _firestoreService != null) {
        await _firestoreService!.rejectEvent(eventId, reason: reason);
      } else if (_mockFirestoreService != null) {
        await _mockFirestoreService!.rejectEvent(eventId, reason: reason);
      }

      await loadPendingEvents();
      if (organizerId != null && organizerId.isNotEmpty) {
        loadOrganizerEvents(organizerId);
      }
      await loadUpcomingEvents();
    } catch (e) {
      debugPrint('Error rejecting event: $e');
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

  /// Check location availability and return a warning/suggestion if occupied
  Future<String?> checkLocationAvailability(String location, DateTime start, DateTime end) async {
    if (location.trim().isEmpty) return null;

    try {
      List<Map<String, dynamic>> bookedSlots = [];
      if (useFirebase && _firestoreService != null) {
        bookedSlots = await _firestoreService!.getBookedSlots(location, start);
      } else if (_mockFirestoreService != null) {
        bookedSlots = await _mockFirestoreService!.getBookedSlots(location, start);
      }

      for (final slot in bookedSlots) {
        final slotStart = slot['startTime'] as DateTime;
        final slotEnd = slot['endTime'] as DateTime;

        if (start.isBefore(slotEnd) && end.isAfter(slotStart)) {
          // Conflict detected. Find nearest available times
          return _findNearestAvailableSlot(start, end, bookedSlots);
        }
      }
      return null; // Available
    } catch (e) {
      debugPrint('Error checking availability: $e');
      return null; // default to true if error, allow backend failure to catch it
    }
  }

  String _findNearestAvailableSlot(DateTime start, DateTime end, List<Map<String, dynamic>> slots) {
    // Basic suggestion engine: find the earliest end time of the conflicting slots
    slots.sort((a, b) => (a['endTime'] as DateTime).compareTo(b['endTime'] as DateTime));
    
    // Suggest the time immediately after the latest conflicting slot
    DateTime suggestedTime = slots.last['endTime'] as DateTime;
    
    final hourFormat = "${suggestedTime.hour.toString().padLeft(2, '0')}:${suggestedTime.minute.toString().padLeft(2, '0')}";
    return "This location is already booked. Nearest available time is after $hourFormat.";
  }

  Future<Map<String, dynamic>> submitEvent(EventModel event, XFile? imageFile, {String? authToken}) async {
    _isLoading = true;
    notifyListeners();

    try {
      debugPrint('Starting event submission for: ${event.title}');
      final String finalEventId = event.id.isEmpty ? const Uuid().v4() : event.id;
      
      String? uploadedImageUrl;

      if (imageFile != null) {
        debugPrint('Uploading image to Cloudinary for event: $finalEventId');
        uploadedImageUrl = await _storageService.uploadEventImage(imageFile, finalEventId, authToken: authToken);
        debugPrint('Cloudinary image URL: $uploadedImageUrl');
      }

      final eventWithImage = EventModel(
        id: finalEventId,
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
        imageUrl: uploadedImageUrl ?? event.imageUrl,
        latitude: event.latitude,
        longitude: event.longitude,
        isApproved: event.isApproved,
        isSpam: event.isSpam,
        spamScore: event.spamScore,
        trustScore: event.trustScore,
        submittedAt: event.submittedAt,
        approvedAt: event.isApproved ? DateTime.now() : null,
        status: event.status,
        rejectionReason: null,
        maxAttendees: event.maxAttendees,
        ticketPrice: event.ticketPrice,
        ticketUrl: event.ticketUrl,
      );

      String? newId;
      if (useFirebase && _firestoreService != null) {
        debugPrint('Submitting to Firestore...');
        newId = await _firestoreService!.submitEvent(eventWithImage);
        debugPrint('Firestore submission result ID: $newId');
      } else if (_mockFirestoreService != null) {
        debugPrint('Submitting to Mock Firestore...');
        newId = await _mockFirestoreService!.submitEvent(eventWithImage);
        await _mockFirestoreService!.autoApproveLatest();
        debugPrint('Mock Firestore submission result ID: $newId');
      }

      await loadPendingEvents();
      await loadUpcomingEvents();
      loadEvents(); 
      if (event.organizerId.isNotEmpty) {
        loadOrganizerEvents(event.organizerId);
      }
      
      _isLoading = false;
      notifyListeners();
      return {'success': true, 'id': newId};
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error submitting event: $e');
      
      if (e.toString().contains('conflict_error')) {
        return {'success': false, 'error': 'conflict_error'};
      }
      return {'success': false, 'error': e.toString()};
    }
  }
}
