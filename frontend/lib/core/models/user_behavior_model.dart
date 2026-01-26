import 'package:cloud_firestore/cloud_firestore.dart';

/// User Behavior Tracking Model for ML-Based Recommendations
/// Captures implicit feedback and engagement patterns
class UserBehaviorModel {
  final String userId;
  
  // Session & Usage Metrics
  final int totalSessions;
  final double averageSessionDuration; // in minutes
  final DateTime lastActiveAt;
  final int daysActive; // Number of unique days user was active
  
  // Event Interaction Metrics
  final Map<String, int> eventViews; // eventId -> view count
  final Map<String, int> eventClicks; // eventId -> click count
  final Map<String, double> eventTimeSpent; // eventId -> time in seconds
  final Map<String, int> eventShares; // eventId -> share count
  final Map<String, int> eventFavorites; // eventId -> favorite count
  
  // Category & Tag Engagement
  final Map<String, int> categoryViews; // category -> view count
  final Map<String, int> tagClicks; // tag -> click count
  final Map<String, double> categoryTimeSpent; // category -> time in seconds
  
  // Search Behavior
  final List<String> searchQueries; // Recent search queries (last 50)
  final Map<String, int> searchTermFrequency; // term -> frequency
  final List<String> clickedSearchResults; // eventIds clicked from search
  
  // Booking Behavior
  final int totalBookings;
  final int cancelledBookings;
  final double averageTicketPrice;
  final int bookingsPerMonth;
  final Map<String, int> bookingsByCategory; // category -> count
  final Map<String, int> bookingsByDay; // 'monday', 'tuesday', etc. -> count
  final Map<String, int> bookingsByTimeSlot; // 'morning', 'afternoon', etc. -> count
  
  // Engagement Patterns
  final double clickThroughRate; // CTR for recommendations
  final double bookingConversionRate; // Bookings / Event views
  final List<String> abandonnedEvents; // Viewed but not booked
  final int notificationClicks;
  final int notificationDismissals;
  
  // Temporal Patterns
  final Map<int, int> activityByHour; // hour (0-23) -> activity count
  final Map<String, int> activityByDay; // day name -> activity count
  final List<DateTime> peakActivityTimes;
  
  // Location & Travel Behavior
  final Map<String, int> visitedLocations; // location -> visit count
  final double averageTravelDistance; // in km
  final Set<String> exploredAreas;
  
  // Social Behavior
  final int friendsInvited;
  final int groupBookings;
  final int soloBookings;
  
  // Metadata
  final DateTime createdAt;
  final DateTime updatedAt;

  UserBehaviorModel({
    required this.userId,
    this.totalSessions = 0,
    this.averageSessionDuration = 0.0,
    required this.lastActiveAt,
    this.daysActive = 0,
    this.eventViews = const {},
    this.eventClicks = const {},
    this.eventTimeSpent = const {},
    this.eventShares = const {},
    this.eventFavorites = const {},
    this.categoryViews = const {},
    this.tagClicks = const {},
    this.categoryTimeSpent = const {},
    this.searchQueries = const [],
    this.searchTermFrequency = const {},
    this.clickedSearchResults = const [],
    this.totalBookings = 0,
    this.cancelledBookings = 0,
    this.averageTicketPrice = 0.0,
    this.bookingsPerMonth = 0,
    this.bookingsByCategory = const {},
    this.bookingsByDay = const {},
    this.bookingsByTimeSlot = const {},
    this.clickThroughRate = 0.0,
    this.bookingConversionRate = 0.0,
    this.abandonnedEvents = const [],
    this.notificationClicks = 0,
    this.notificationDismissals = 0,
    this.activityByHour = const {},
    this.activityByDay = const {},
    this.peakActivityTimes = const [],
    this.visitedLocations = const {},
    this.averageTravelDistance = 0.0,
    this.exploredAreas = const {},
    this.friendsInvited = 0,
    this.groupBookings = 0,
    this.soloBookings = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserBehaviorModel.fromMap(Map<String, dynamic> map, String userId) {
    return UserBehaviorModel(
      userId: userId,
      totalSessions: map['totalSessions'] ?? 0,
      averageSessionDuration: (map['averageSessionDuration'] as num?)?.toDouble() ?? 0.0,
      lastActiveAt: (map['lastActiveAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      daysActive: map['daysActive'] ?? 0,
      eventViews: Map<String, int>.from(map['eventViews'] ?? {}),
      eventClicks: Map<String, int>.from(map['eventClicks'] ?? {}),
      eventTimeSpent: (map['eventTimeSpent'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())) ?? {},
      eventShares: Map<String, int>.from(map['eventShares'] ?? {}),
      eventFavorites: Map<String, int>.from(map['eventFavorites'] ?? {}),
      categoryViews: Map<String, int>.from(map['categoryViews'] ?? {}),
      tagClicks: Map<String, int>.from(map['tagClicks'] ?? {}),
      categoryTimeSpent: (map['categoryTimeSpent'] as Map?)?.map((k, v) => MapEntry(k.toString(), (v as num).toDouble())) ?? {},
      searchQueries: List<String>.from(map['searchQueries'] ?? []),
      searchTermFrequency: Map<String, int>.from(map['searchTermFrequency'] ?? {}),
      clickedSearchResults: List<String>.from(map['clickedSearchResults'] ?? []),
      totalBookings: map['totalBookings'] ?? 0,
      cancelledBookings: map['cancelledBookings'] ?? 0,
      averageTicketPrice: (map['averageTicketPrice'] as num?)?.toDouble() ?? 0.0,
      bookingsPerMonth: map['bookingsPerMonth'] ?? 0,
      bookingsByCategory: Map<String, int>.from(map['bookingsByCategory'] ?? {}),
      bookingsByDay: Map<String, int>.from(map['bookingsByDay'] ?? {}),
      bookingsByTimeSlot: Map<String, int>.from(map['bookingsByTimeSlot'] ?? {}),
      clickThroughRate: (map['clickThroughRate'] as num?)?.toDouble() ?? 0.0,
      bookingConversionRate: (map['bookingConversionRate'] as num?)?.toDouble() ?? 0.0,
      abandonnedEvents: List<String>.from(map['abandonnedEvents'] ?? []),
      notificationClicks: map['notificationClicks'] ?? 0,
      notificationDismissals: map['notificationDismissals'] ?? 0,
      activityByHour: Map<int, int>.from(map['activityByHour'] ?? {}),
      activityByDay: Map<String, int>.from(map['activityByDay'] ?? {}),
      peakActivityTimes: (map['peakActivityTimes'] as List?)?.map((e) => (e as Timestamp).toDate()).toList() ?? [],
      visitedLocations: Map<String, int>.from(map['visitedLocations'] ?? {}),
      averageTravelDistance: (map['averageTravelDistance'] as num?)?.toDouble() ?? 0.0,
      exploredAreas: Set<String>.from(map['exploredAreas'] ?? []),
      friendsInvited: map['friendsInvited'] ?? 0,
      groupBookings: map['groupBookings'] ?? 0,
      soloBookings: map['soloBookings'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'totalSessions': totalSessions,
      'averageSessionDuration': averageSessionDuration,
      'lastActiveAt': Timestamp.fromDate(lastActiveAt),
      'daysActive': daysActive,
      'eventViews': eventViews,
      'eventClicks': eventClicks,
      'eventTimeSpent': eventTimeSpent,
      'eventShares': eventShares,
      'eventFavorites': eventFavorites,
      'categoryViews': categoryViews,
      'tagClicks': tagClicks,
      'categoryTimeSpent': categoryTimeSpent,
      'searchQueries': searchQueries,
      'searchTermFrequency': searchTermFrequency,
      'clickedSearchResults': clickedSearchResults,
      'totalBookings': totalBookings,
      'cancelledBookings': cancelledBookings,
      'averageTicketPrice': averageTicketPrice,
      'bookingsPerMonth': bookingsPerMonth,
      'bookingsByCategory': bookingsByCategory,
      'bookingsByDay': bookingsByDay,
      'bookingsByTimeSlot': bookingsByTimeSlot,
      'clickThroughRate': clickThroughRate,
      'bookingConversionRate': bookingConversionRate,
      'abandonnedEvents': abandonnedEvents,
      'notificationClicks': notificationClicks,
      'notificationDismissals': notificationDismissals,
      'activityByHour': activityByHour,
      'activityByDay': activityByDay,
      'peakActivityTimes': peakActivityTimes.map((e) => Timestamp.fromDate(e)).toList(),
      'visitedLocations': visitedLocations,
      'averageTravelDistance': averageTravelDistance,
      'exploredAreas': exploredAreas.toList(),
      'friendsInvited': friendsInvited,
      'groupBookings': groupBookings,
      'soloBookings': soloBookings,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
