import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/booking_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Events
  Stream<List<EventModel>> getApprovedEvents() {
    return _firestore
        .collection('events')
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .where((event) =>
                event.status == 'approved' && (event.isSpam == false))
            .toList());
  }

  Stream<List<EventModel>> getOrganizerEvents(String organizerId) {
    return _firestore
        .collection('events')
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<EventModel>> getUpcomingEvents() async {
    final now = DateTime.now();
    // Simplified query to avoid composite index requirements
    final snapshot = await _firestore
        .collection('events')
        .where('isApproved', isEqualTo: true)
        .limit(50) // Get more items and filter on client
        .get();

    final events = snapshot.docs
        .map((doc) => EventModel.fromMap(doc.data(), doc.id))
        .where((event) =>
            event.status == 'approved' &&
            event.isSpam == false &&
            event.startDate.isAfter(now))
        .toList();

    // Sort client-side
    events.sort((a, b) => a.startDate.compareTo(b.startDate));
    return events.take(10).toList();
  }

  Future<String> submitEvent(EventModel event) async {
    if (event.id.isNotEmpty) {
      await _firestore.collection('events').doc(event.id).set(event.toMap());
      return event.id;
    } else {
      final docRef = await _firestore.collection('events').add(event.toMap());
      return docRef.id;
    }
  }

  Future<List<EventModel>> getPendingEvents() async {
    final snapshot = await _firestore
        .collection('events')
        .where('isApproved', isEqualTo: false)
        .get();

    final events = snapshot.docs
        .map((doc) => EventModel.fromMap(doc.data(), doc.id))
        .where((event) => event.status == 'pending' && event.isSpam == false)
        .toList();

    // Sort client-side
    events.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
    return events;
  }

  Future<void> approveEvent(String eventId) async {
    await _firestore.collection('events').doc(eventId).update({
      'status': 'approved',
      'isApproved': true,
      'approvedAt': Timestamp.fromDate(DateTime.now()),
      'rejectionReason': null,
    });
  }

  Future<void> rejectEvent(String eventId, {String? reason}) async {
    await _firestore.collection('events').doc(eventId).update({
      'status': 'rejected',
      'isApproved': false,
      'approvedAt': null,
      'rejectionReason': reason,
    });
  }

  Future<EventModel?> getEventById(String eventId) async {
    final doc = await _firestore.collection('events').doc(eventId).get();
    if (doc.exists) {
      return EventModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  // Bookings
  Future<String> createBooking(BookingModel booking) async {
    final docRef = await _firestore.collection('bookings').add(booking.toMap());
    return docRef.id;
  }

  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('eventDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    await _firestore
        .collection('bookings')
        .doc(bookingId)
        .update({'status': status.name});
  }

  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).delete();
  }
}

