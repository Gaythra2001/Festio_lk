import '../models/event_model.dart';
import '../models/booking_model.dart';

/// Mock Firestore service for demo mode (no Firebase required)
class MockFirestoreService {
  final List<EventModel> _mockEvents = [
    EventModel(
      id: '1',
      title: 'Traditional Kandyan Dance Festival',
      description: 'Experience the rich cultural heritage of Sri Lanka through traditional Kandyan dance performances.',
      startDate: DateTime.now().add(const Duration(days: 7)),
      endDate: DateTime.now().add(const Duration(days: 7)),
      location: 'Kandy, Sri Lanka',
      category: 'Cultural',
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
      description: 'Join us for a beautiful Vesak celebration with lanterns, dansal, and Buddhist teachings.',
      startDate: DateTime.now().add(const Duration(days: 14)),
      endDate: DateTime.now().add(const Duration(days: 14)),
      location: 'Colombo, Sri Lanka',
      category: 'Religious',
      tags: ['Vesak', 'Buddhist', 'Festival'],
      organizerId: 'org_2',
      organizerName: 'Buddhist Society',
      submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      isApproved: true,
      trustScore: 90,
    ),
    EventModel(
      id: '3',
      title: 'Traditional Drumming Workshop',
      description: 'Learn traditional Sri Lankan drumming techniques from master musicians.',
      startDate: DateTime.now().add(const Duration(days: 21)),
      endDate: DateTime.now().add(const Duration(days: 21)),
      location: 'Galle, Sri Lanka',
      category: 'Workshop',
      tags: ['Music', 'Drumming', 'Traditional'],
      organizerId: 'org_3',
      organizerName: 'Music Academy',
      submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      isApproved: true,
      trustScore: 75,
    ),
  ];

  final List<BookingModel> _mockBookings = [];

  Stream<List<EventModel>> getApprovedEvents() {
    return Stream.value(_mockEvents.where((e) => e.isApproved && !e.isSpam).toList());
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    final now = DateTime.now();
    return _mockEvents
        .where((e) => e.isApproved && !e.isSpam && e.startDate.isAfter(now))
        .toList();
  }

  Future<String> submitEvent(EventModel event) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final newEvent = EventModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
      isApproved: false, // Needs approval in real app
    );
    
    _mockEvents.add(newEvent);
    return newEvent.id;
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

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
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

