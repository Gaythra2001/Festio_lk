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
        .where('isSpam', isEqualTo: false)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => EventModel.fromMap(doc.data(), doc.id))
        .where((event) => event.status == 'approved')
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
    final snapshot = await _firestore
        .collection('events')
      .where('isApproved', isEqualTo: true)
        .where('isSpam', isEqualTo: false)
        .where('startDate', isGreaterThan: Timestamp.fromDate(now))
        .orderBy('startDate', descending: false)
        .limit(10)
        .get();

    return snapshot.docs
      .map((doc) => EventModel.fromMap(doc.data(), doc.id))
      .where((event) => event.status == 'approved')
      .toList();
  }

  Future<String> submitEvent(EventModel event) async {
    final docRef = await _firestore.collection('events').add(event.toMap());
    return docRef.id;
  }

  Future<List<EventModel>> getPendingEvents() async {
    final snapshot = await _firestore
        .collection('events')
      .where('isApproved', isEqualTo: false)
        .where('isSpam', isEqualTo: false)
        .orderBy('submittedAt', descending: true)
        .get();

    return snapshot.docs
      .map((doc) => EventModel.fromMap(doc.data(), doc.id))
      .where((event) => event.status == 'pending')
      .toList();
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

