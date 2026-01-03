import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../services/firestore_service.dart';
import '../services/mock_firestore_service.dart';
import '../services/storage_service.dart';
import '../config/app_config.dart';
import 'dart:io';

class EventProvider with ChangeNotifier {
  final FirestoreService? _firestoreService = useFirebase ? FirestoreService() : null;
  final MockFirestoreService? _mockFirestoreService = useFirebase ? null : MockFirestoreService();
  final StorageService? _storageService = useFirebase ? StorageService() : null;
  
  List<EventModel> _events = [];
  List<EventModel> _upcomingEvents = [];
  bool _isLoading = false;

  List<EventModel> get events => _events;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  bool get isLoading => _isLoading;

  EventProvider() {
    loadEvents();
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

  Future<bool> submitEvent(EventModel event, File? imageFile) async {
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

      if (useFirebase && _firestoreService != null) {
        await _firestoreService!.submitEvent(eventWithImage);
      } else if (_mockFirestoreService != null) {
        await _mockFirestoreService!.submitEvent(eventWithImage);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error submitting event: $e');
      return false;
    }
  }
}

