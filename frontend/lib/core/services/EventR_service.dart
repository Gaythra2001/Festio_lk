import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String demoUserId = "demo_user_001";

  /// Save Registration Data
  Future<void> saveUserPreferences({
    required String city,
    required String district,
    required List<String> preferredCategories,
    required String venueType,
    required String timeOfDay,
  }) async {
    await _firestore.collection('users').doc(demoUserId).set({
      'city': city,
      'district': district,
      'preferredCategories': preferredCategories,
      'venueType': venueType,
      'timeOfDay': timeOfDay,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Get User Preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    final doc = await _firestore.collection('users').doc(demoUserId).get();
    return doc.data();
  }

  /// Track Event Click
  Future<void> incrementEventClick(String eventTitle) async {
    final ref = _firestore.collection('eventClicks').doc(demoUserId);

    await ref.set({
      eventTitle: FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Get Event Clicks
  Future<Map<String, dynamic>?> getUserClicks() async {
    final doc =
        await _firestore.collection('eventClicks').doc(demoUserId).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getApprovedEvents() async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('isApproved', isEqualTo: true)
          .where('isSpam', isEqualTo: false)
          .get();

      final events = snapshot.docs.map((doc) {
        final data = doc.data();

        return {
          'title': data['title'] ?? '',
          'date': (data['startDate'] as Timestamp?)?.toDate(), // KEEP DateTime
          'location': data['location'] ?? '',
          'category': data['category'] ?? '',
          'imageUrl': data['imageUrl'] ?? data['image_url'] ?? '',
        };
      }).toList();

      // sort safely (no crash fix)
      events.sort((a, b) {
        final dateA = a['date'] as DateTime?;
        final dateB = b['date'] as DateTime?;

        if (dateA == null || dateB == null) return 0;

        return dateA.compareTo(dateB);
      });

      return events;
    } catch (e) {
      print("Error fetching events: $e");
      return [];
    }
  }

  /// Start Event View Session
  Future<void> startOrUpdateEventSession({
    required String eventTitle,
  }) async {
    final eventId = "event_${eventTitle.hashCode}";
    final docId = "${demoUserId}_$eventId";

    final docRef = _firestore.collection('eventViewSessions').doc(docId);

    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      // First time opening this event
      await docRef.set({
        'userId': demoUserId,
        'eventId': eventId,
        'eventTitle': eventTitle,
        'totalDurationSeconds': 0,
        'lastOpenedAt': FieldValue.serverTimestamp(),
      });
    } else {
      // Just update lastOpenedAt
      await docRef.update({
        'lastOpenedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// End Event View Session
  Future<void> endEventSession({
    required String eventTitle,
    required DateTime openedAt,
  }) async {
    final eventId = "event_${eventTitle.hashCode}";
    final docId = "${demoUserId}_$eventId";

    final closedAt = DateTime.now();
    final duration = closedAt.difference(openedAt).inSeconds;

    await _firestore.collection('eventViewSessions').doc(docId).update({
      'totalDurationSeconds': FieldValue.increment(duration),
      'lastClosedAt': Timestamp.fromDate(closedAt),
    });
  }

  /// Get total duration (in seconds) by event title
  Future<int> getEventTotalDurationByTitle(String eventTitle) async {
    final eventId = "event_${eventTitle.hashCode}";
    final docId = "${demoUserId}_$eventId";

    final doc =
        await _firestore.collection('eventViewSessions').doc(docId).get();

    if (!doc.exists) return 0;

    return (doc.data()?['totalDurationSeconds'] ?? 0) as int;
  }
}
