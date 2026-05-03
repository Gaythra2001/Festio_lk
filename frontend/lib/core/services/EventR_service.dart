import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../models/event_model.dart';
import 'mock_firestore_service.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String demoUserId = 'demo_user_001';
  final MockFirestoreService _mockFirestoreService = MockFirestoreService();

  static const String _localPreferencesKey = 'eventr_user_preferences';
  static const String _localClicksKey = 'eventr_event_clicks';
  static const String _localSessionsKey = 'eventr_event_sessions';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<Map<String, dynamic>> _readLocalMap(String key) async {
    final prefs = await _prefs;
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return <String, dynamic>{};
  }

  Future<void> _writeLocalMap(String key, Map<String, dynamic> value) async {
    final prefs = await _prefs;
    await prefs.setString(key, jsonEncode(value));
  }

  String? _getFirebaseUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  /// Save Registration Data
  Future<void> saveUserPreferences({
    required String city,
    required String district,
    required List<String> preferredCategories,
    required String venueType,
    required String timeOfDay,
  }) async {
    final payload = <String, dynamic>{
      'city': city,
      'district': district,
      'preferredCategories': preferredCategories,
      'venueType': venueType,
      'timeOfDay': timeOfDay,
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (!useFirebase) {
      await _writeLocalMap(_localPreferencesKey, payload);
      debugPrint('✅ User preferences saved locally (demo mode)');
      return;
    }

    final userId = _getFirebaseUserId();
    if (userId == null) {
      throw Exception('User not logged in');
    }

    await _firestore.collection('users').doc(userId).set(
          payload,
          SetOptions(merge: true),
        );
  }

  /// Get User Preferences
  Future<Map<String, dynamic>?> getUserPreferences() async {
    if (!useFirebase) {
      final data = await _readLocalMap(_localPreferencesKey);
      return data.isEmpty ? null : data;
    }

    final userId = _getFirebaseUserId();
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  /// Track Event Click
  Future<void> incrementEventClick(String eventTitle) async {
    if (!useFirebase) {
      final clicks = await _readLocalMap(_localClicksKey);
      final key = eventTitle.trim();
      final current = clicks[key];
      final next = current is int
          ? current + 1
          : current is num
              ? current.toInt() + 1
              : 1;

      clicks[key] = next;
      await _writeLocalMap(_localClicksKey, clicks);
      return;
    }

    final userId = _getFirebaseUserId() ?? demoUserId;
    final ref = _firestore.collection('eventClicks').doc(userId);

    await ref.set({
      eventTitle: FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Get Event Clicks
  Future<Map<String, dynamic>?> getUserClicks() async {
    if (!useFirebase) {
      final data = await _readLocalMap(_localClicksKey);
      return data.isEmpty ? null : data;
    }

    final userId = _getFirebaseUserId() ?? demoUserId;
    final doc = await _firestore.collection('eventClicks').doc(userId).get();
    return doc.data();
  }

  Future<List<Map<String, dynamic>>> getApprovedEvents() async {
    if (!useFirebase) {
      final events = await _mockFirestoreService.getUpcomingEvents();
      return events
          .map((EventModel event) => {
                'title': event.title,
                'date': event.startDate,
                'location': event.location,
                'category': event.category,
                'imageUrl': event.imageUrl ?? '',
              })
          .toList();
    }

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
      print('Error fetching events: $e');
      return [];
    }
  }

  /// Start Event View Session
  Future<void> startOrUpdateEventSession({
    required String eventTitle,
  }) async {
    final eventId = 'event_${eventTitle.hashCode}';
    final userId = useFirebase ? _getFirebaseUserId() ?? demoUserId : demoUserId;
    final docId = '${userId}_$eventId';

    if (!useFirebase) {
      final sessions = await _readLocalMap(_localSessionsKey);
      final existing = sessions[docId];
      final now = DateTime.now().toIso8601String();

      sessions[docId] = {
        if (existing is Map) ...Map<String, dynamic>.from(existing),
        'userId': userId,
        'eventId': eventId,
        'eventTitle': eventTitle,
        'totalDurationSeconds':
            (existing is Map && existing['totalDurationSeconds'] is num)
                ? (existing['totalDurationSeconds'] as num).toInt()
                : 0,
        'lastOpenedAt': now,
      };
      await _writeLocalMap(_localSessionsKey, sessions);
      return;
    }

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
    final eventId = 'event_${eventTitle.hashCode}';
    final userId = useFirebase ? _getFirebaseUserId() ?? demoUserId : demoUserId;
    final docId = '${userId}_$eventId';

    final closedAt = DateTime.now();
    final duration = closedAt.difference(openedAt).inSeconds;

    if (!useFirebase) {
      final sessions = await _readLocalMap(_localSessionsKey);
      final existing = sessions[docId];
      final previousDuration =
          existing is Map && existing['totalDurationSeconds'] is num
              ? (existing['totalDurationSeconds'] as num).toInt()
              : 0;

      sessions[docId] = {
        if (existing is Map) ...Map<String, dynamic>.from(existing),
        'userId': userId,
        'eventId': eventId,
        'eventTitle': eventTitle,
        'totalDurationSeconds': previousDuration + duration,
        'lastClosedAt': closedAt.toIso8601String(),
      };
      await _writeLocalMap(_localSessionsKey, sessions);
      return;
    }

    await _firestore.collection('eventViewSessions').doc(docId).update({
      'totalDurationSeconds': FieldValue.increment(duration),
      'lastClosedAt': Timestamp.fromDate(closedAt),
    });
  }

  /// Get total duration (in seconds) by event title
  Future<int> getEventTotalDurationByTitle(String eventTitle) async {
    final eventId = 'event_${eventTitle.hashCode}';
    final userId = useFirebase ? _getFirebaseUserId() ?? demoUserId : demoUserId;
    final docId = '${userId}_$eventId';

    if (!useFirebase) {
      final sessions = await _readLocalMap(_localSessionsKey);
      final session = sessions[docId];
      if (session is Map && session['totalDurationSeconds'] is num) {
        return (session['totalDurationSeconds'] as num).toInt();
      }
      return 0;
    }

    final doc =
        await _firestore.collection('eventViewSessions').doc(docId).get();

    if (!doc.exists) return 0;

    return (doc.data()?['totalDurationSeconds'] ?? 0) as int;
  }
}
