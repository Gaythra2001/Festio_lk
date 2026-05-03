import '../models/event_model.dart';
import '../models/booking_model.dart';

/// Mock Firestore service for demo mode (no Firebase required)
class MockFirestoreService {
  final List<EventModel> _mockEvents = [
    EventModel(
      id: '1',
      title: 'Traditional Kandyan Dance Festival',
      description:
          'Experience the rich cultural heritage of Sri Lanka through traditional Kandyan dance performances.',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      location: 'Kandy, Sri Lanka',
      category: 'Dance',
      tags: ['Dance', 'Traditional', 'Kandyan'],
      organizerId: 'org_1',
      organizerName: 'Cultural Heritage Society',
      submittedAt: DateTime.now().subtract(const Duration(days: 5)),
      isApproved: true,
      trustScore: 85,
    ),
    EventModel(
      id: '2',
      title: 'Vesak Festival Celebration',
      description:
          'Join us for a beautiful Vesak celebration with lanterns, dansal, and Buddhist teachings.',
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 14)),
      location: 'Colombo, Sri Lanka',
      category: 'Festival',
      tags: ['Vesak', 'Buddhist', 'Festival'],
      organizerId: 'org_2',
      organizerName: 'Buddhist Society',
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      isApproved: true,
      trustScore: 90,
    ),
    EventModel(
      id: '3',
      title: 'Galle Live Music Night',
      description:
          'An electrifying live music night featuring top Sri Lankan artists at the Galle Fort.',
      startDate: DateTime.now().add(const Duration(days: 10)),
      endDate: DateTime.now().add(const Duration(days: 10)),
      location: 'Galle, Sri Lanka',
      category: 'Music',
      tags: ['Music', 'Live', 'Concert'],
      organizerId: 'org_3',
      organizerName: 'Music Academy',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      isApproved: true,
      trustScore: 80,
    ),
    EventModel(
      id: '4',
      title: 'Colombo Music Fest 2025',
      description:
          'Sri Lanka\'s biggest music festival featuring local and international artists.',
      startDate: DateTime.now().add(const Duration(days: 21)),
      endDate: DateTime.now().add(const Duration(days: 22)),
      location: 'Colombo, Sri Lanka',
      category: 'Music',
      tags: ['Music', 'Festival', 'Colombo'],
      organizerId: 'org_4',
      organizerName: 'Colombo Events Co.',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      isApproved: true,
      trustScore: 92,
    ),
    EventModel(
      id: '5',
      title: 'Kandy Dance Showcase',
      description:
          'Watch mesmerising dance performances from classical and contemporary dancers.',
      startDate: DateTime.now().add(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 5)),
      location: 'Kandy, Sri Lanka',
      category: 'Dance',
      tags: ['Dance', 'Performance', 'Kandy'],
      organizerId: 'org_5',
      organizerName: 'Kandy Arts Centre',
      submittedAt: DateTime.now().subtract(const Duration(days: 4)),
      isApproved: true,
      trustScore: 78,
    ),
    EventModel(
      id: '6',
      title: 'Gampaha Cultural Theater Night',
      description:
          'A brilliant theater production showcasing Sri Lankan folk tales on stage.',
      startDate: DateTime.now().add(const Duration(days: 12)),
      endDate: DateTime.now().add(const Duration(days: 12)),
      location: 'Gampaha, Sri Lanka',
      category: 'Theater',
      tags: ['Theater', 'Drama', 'Cultural'],
      organizerId: 'org_6',
      organizerName: 'Gampaha Performing Arts',
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      isApproved: true,
      trustScore: 82,
    ),
    EventModel(
      id: '7',
      title: 'Kandy Music & Arts Festival',
      description:
          'A weekend festival celebrating music, art and culture in the heart of Kandy.',
      startDate: DateTime.now().add(const Duration(days: 18)),
      endDate: DateTime.now().add(const Duration(days: 19)),
      location: 'Kandy, Sri Lanka',
      category: 'Music',
      tags: ['Music', 'Arts', 'Festival'],
      organizerId: 'org_7',
      organizerName: 'Kandy Arts Foundation',
      submittedAt: DateTime.now().subtract(const Duration(days: 6)),
      isApproved: true,
      trustScore: 88,
    ),
    EventModel(
      id: '8',
      title: 'Colombo Street Theater Festival',
      description:
          'An open-air theater festival bringing world-class performances to Colombo streets.',
      startDate: DateTime.now().add(const Duration(days: 9)),
      endDate: DateTime.now().add(const Duration(days: 9)),
      location: 'Colombo, Sri Lanka',
      category: 'Theater',
      tags: ['Theater', 'Street', 'Open-air'],
      organizerId: 'org_8',
      organizerName: 'Colombo Arts Council',
      submittedAt: DateTime.now().subtract(const Duration(days: 2)),
      isApproved: true,
      trustScore: 84,
    ),
    EventModel(
      id: '9',
      title: 'Galle Heritage Festival',
      description:
          'Celebrate the rich heritage of Galle Fort with cultural displays and performances.',
      startDate: DateTime.now().add(const Duration(days: 25)),
      endDate: DateTime.now().add(const Duration(days: 26)),
      location: 'Galle, Sri Lanka',
      category: 'Festival',
      tags: ['Festival', 'Heritage', 'Galle'],
      organizerId: 'org_9',
      organizerName: 'Galle Heritage Trust',
      submittedAt: DateTime.now().subtract(const Duration(days: 7)),
      isApproved: true,
      trustScore: 91,
    ),
    EventModel(
      id: '10',
      title: 'Matara Dance Competition',
      description:
          'Annual inter-school dance competition with participants from all over southern Sri Lanka.',
      startDate: DateTime.now().add(const Duration(days: 15)),
      endDate: DateTime.now().add(const Duration(days: 15)),
      location: 'Matara, Sri Lanka',
      category: 'Dance',
      tags: ['Dance', 'Competition', 'Youth'],
      organizerId: 'org_10',
      organizerName: 'Southern Arts Board',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      isApproved: true,
      trustScore: 76,
    ),
  ];

  final List<BookingModel> _mockBookings = [];

  Stream<List<EventModel>> getApprovedEvents() {
    return Stream.value(
      _mockEvents.where((e) => e.status == 'approved' && !e.isSpam).toList());
  }

  Stream<List<EventModel>> getOrganizerEvents(String organizerId) {
    return Stream.value(
      _mockEvents.where((e) => e.organizerId == organizerId).toList(),
    );
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    final now = DateTime.now();
    return _mockEvents
        .where((e) =>
            e.status == 'approved' && !e.isSpam && e.startDate.isAfter(now))
        .toList();
  }

  Future<String> submitEvent(EventModel event) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final locationStr = event.location.trim().toLowerCase();
    
    // Check for overlap against existing mock events
    for (final existingEvent in _mockEvents) {
      if (existingEvent.location.trim().toLowerCase() == locationStr && existingEvent.id != event.id) {
         if (event.startDate.isBefore(existingEvent.endDate) && event.endDate.isAfter(existingEvent.startDate)) {
            throw Exception('conflict_error');
         }
      }
    }

    final newEvent = EventModel(
      id: event.id.isNotEmpty ? event.id : DateTime.now().millisecondsSinceEpoch.toString(),
      title: event.title,
      description: event.description,
      startDate: event.startDate,
      endDate: event.endDate,
      location: event.location,
      category: event.category,
      tags: event.tags,
      organizerId: event.organizerId,
      organizerName: event.organizerName,
      imageUrl: event.imageUrl,
      submittedAt: DateTime.now(),
      isApproved: event.isApproved, // Use the approval status from the event
      status: event.status,
      rejectionReason: event.rejectionReason,
      ticketPrice: event.ticketPrice,
      ticketUrl: event.ticketUrl,
      tickets: event.tickets,
    );
    
    if (event.id.isNotEmpty) {
      final index = _mockEvents.indexWhere((e) => e.id == event.id);
      if (index != -1) {
        _mockEvents[index] = newEvent;
      } else {
        _mockEvents.add(newEvent);
      }
    } else {
      _mockEvents.add(newEvent);
    }
    
    return newEvent.id;
  }

  Future<List<Map<String, dynamic>>> getBookedSlots(String location, DateTime date) async {
    final locationStr = location.trim().toLowerCase();
    
    return _mockEvents.where((e) {
      return e.location.trim().toLowerCase() == locationStr &&
             e.startDate.year == date.year &&
             e.startDate.month == date.month &&
             e.startDate.day == date.day;
    }).map((e) => {
      'startTime': e.startDate,
      'endTime': e.endDate,
      'eventId': e.id,
    }).toList();
  }

  /// Auto-approve the most recently submitted event (demo mode shortcut so
  /// submitted events appear immediately in the UI without a separate admin step).
  Future<void> autoApproveLatest() async {
    if (_mockEvents.isEmpty) return;
    final idx = _mockEvents.length - 1;
    final e = _mockEvents[idx];
    if (e.status == 'pending') {
      _mockEvents[idx] = EventModel(
        id: e.id,
        title: e.title,
        description: e.description,
        titleSi: e.titleSi,
        titleTa: e.titleTa,
        descriptionSi: e.descriptionSi,
        descriptionTa: e.descriptionTa,
        startDate: e.startDate,
        endDate: e.endDate,
        location: e.location,
        locationSi: e.locationSi,
        locationTa: e.locationTa,
        category: e.category,
        tags: e.tags,
        organizerId: e.organizerId,
        organizerName: e.organizerName,
        imageUrl: e.imageUrl,
        latitude: e.latitude,
        longitude: e.longitude,
        isApproved: true,
        isSpam: e.isSpam,
        spamScore: e.spamScore,
        trustScore: e.trustScore,
        submittedAt: e.submittedAt,
        approvedAt: DateTime.now(),
        status: 'approved',
        rejectionReason: null,
        maxAttendees: e.maxAttendees,
        ticketPrice: e.ticketPrice,
        ticketUrl: e.ticketUrl,
      );
    }
  }

  Future<List<EventModel>> getPendingEvents() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockEvents
      .where((e) => e.status == 'pending' && !e.isSpam)
        .toList(growable: false);
  }

  Future<void> approveEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _mockEvents[index];
      _mockEvents[index] = EventModel(
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
        imageUrl: event.imageUrl,
        latitude: event.latitude,
        longitude: event.longitude,
        isApproved: true,
        isSpam: event.isSpam,
        spamScore: event.spamScore,
        trustScore: event.trustScore,
        submittedAt: event.submittedAt,
        approvedAt: DateTime.now(),
        status: 'approved',
        rejectionReason: null,
        maxAttendees: event.maxAttendees,
        ticketPrice: event.ticketPrice,
        ticketUrl: event.ticketUrl,
        tickets: event.tickets,
      );
    }
  }

  Future<void> rejectEvent(String eventId, {String? reason}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _mockEvents.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final event = _mockEvents[index];
      _mockEvents[index] = EventModel(
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
        imageUrl: event.imageUrl,
        latitude: event.latitude,
        longitude: event.longitude,
        isApproved: false,
        isSpam: event.isSpam,
        spamScore: event.spamScore,
        trustScore: event.trustScore,
        submittedAt: event.submittedAt,
        approvedAt: null,
        status: 'rejected',
        rejectionReason: reason,
        maxAttendees: event.maxAttendees,
        ticketPrice: event.ticketPrice,
        ticketUrl: event.ticketUrl,
        tickets: event.tickets,
      );
    }
  }

  Future<EventModel?> getEventById(String eventId) async {
    try {
      return _mockEvents.firstWhere((e) => e.id == eventId);
    } catch (e) {
      return null;
    }
  }

  Future<String> createBooking(BookingModel booking) async {
    await Future.delayed(const Duration(seconds: 1));
    final newBooking = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      eventId: booking.eventId,
      userId: booking.userId,
      eventTitle: booking.eventTitle,
      eventDate: booking.eventDate,
      eventLocation: booking.eventLocation,
      eventImageUrl: booking.eventImageUrl,
      status: booking.status,
      bookedAt: DateTime.now(),
      numberOfTickets: booking.numberOfTickets,
      totalPrice: booking.totalPrice,
    );
    _mockBookings.add(newBooking);
    return newBooking.id;
  }

  Stream<List<BookingModel>> getUserBookings(String userId) {
    return Stream.value(
      _mockBookings.where((b) => b.userId == userId).toList(),
    );
  }

  Future<void> updateBookingStatus(
      String bookingId, BookingStatus status) async {
    final index = _mockBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final booking = _mockBookings[index];
      _mockBookings[index] = BookingModel(
        id: booking.id,
        eventId: booking.eventId,
        userId: booking.userId,
        eventTitle: booking.eventTitle,
        eventDate: booking.eventDate,
        eventLocation: booking.eventLocation,
        eventImageUrl: booking.eventImageUrl,
        status: status,
        bookedAt: booking.bookedAt,
        numberOfTickets: booking.numberOfTickets,
        totalPrice: booking.totalPrice,
      );
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    _mockBookings.removeWhere((b) => b.id == bookingId);
  }
}
