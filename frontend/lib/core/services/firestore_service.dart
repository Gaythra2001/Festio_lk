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
    final locationDocId = event.location.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    if (locationDocId.isEmpty) {
      throw Exception('Invalid location');
    }

    // Use only YYYY-MM-DD for the date document
    final dateStr = "${event.startDate.year.toString().padLeft(4, '0')}-${event.startDate.month.toString().padLeft(2, '0')}-${event.startDate.day.toString().padLeft(2, '0')}";

    final locationDateRef = _firestore
        .collection('locations')
        .doc(locationDocId)
        .collection('dates')
        .doc(dateStr);

    final eventId = event.id.isNotEmpty ? event.id : _firestore.collection('events').doc().id;
    final eventRef = _firestore.collection('events').doc(eventId);
    
    final eventWriteData = event.toMap();
    if (event.id.isEmpty) {
      eventWriteData['id'] = eventId;
    }

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(locationDateRef);
      List<dynamic> bookedSlots = [];

      if (snapshot.exists) {
        bookedSlots = snapshot.data()?['bookedSlots'] ?? [];
        
        // Check for time overlap
        for (final slot in bookedSlots) {
          final slotStart = (slot['startTime'] as Timestamp).toDate();
          final slotEnd = (slot['endTime'] as Timestamp).toDate();
          
          // Overlap condition: (StartA < EndB) and (EndA > StartB)
          if (event.startDate.isBefore(slotEnd) && event.endDate.isAfter(slotStart)) {
            // Ignore if we are updating the exact same event that already occupies it
            if (slot['eventId'] != eventId) {
               throw Exception('conflict_error'); // specific string to catch later
            }
          }
        }
        
        // Remove old slot if updating
        bookedSlots.removeWhere((slot) => slot['eventId'] == eventId);
      }
      
      bookedSlots.add({
        'startTime': Timestamp.fromDate(event.startDate),
        'endTime': Timestamp.fromDate(event.endDate),
        'eventId': eventId,
      });

      // Write booking lock
      transaction.set(locationDateRef, {'bookedSlots': bookedSlots}, SetOptions(merge: true));
      
      // Write event document
      transaction.set(eventRef, eventWriteData);
    });

    return eventId;
  }

  /// Check location availability (Read-only, for suggestions/real-time checks)
  Future<List<Map<String, dynamic>>> getBookedSlots(String location, DateTime date) async {
    final locationDocId = location.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    if (locationDocId.isEmpty) return [];

    final dateStr = "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    final doc = await _firestore.collection('locations').doc(locationDocId).collection('dates').doc(dateStr).get();
    
    if (doc.exists) {
      final data = doc.data();
      if (data != null && data['bookedSlots'] != null) {
        List<dynamic> slots = data['bookedSlots'];
        return slots.map((s) => {
          'startTime': (s['startTime'] as Timestamp).toDate(),
          'endTime': (s['endTime'] as Timestamp).toDate(),
          'eventId': s['eventId'] as String,
        }).toList();
      }
    }
    return [];
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

