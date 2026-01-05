import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for event and platform ratings
class RatingModel {
  final String id;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String? eventId; // null for platform ratings
  final String? eventName; // null for platform ratings
  final double rating; // 1-5 stars
  final String? review; // Optional detailed review
  final List<String> tags; // e.g., ["Great venue", "Poor organization"]
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerifiedBooking; // True if user actually booked the event
  final int helpfulCount; // Number of users who found this helpful
  final List<String> images; // Optional review images
  final String? organizerResponse; // Organizer's response to review
  final DateTime? responseDate;

  RatingModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    this.eventId,
    this.eventName,
    required this.rating,
    this.review,
    this.tags = const [],
    required this.createdAt,
    this.updatedAt,
    this.isVerifiedBooking = false,
    this.helpfulCount = 0,
    this.images = const [],
    this.organizerResponse,
    this.responseDate,
  });

  // Convert to map for Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'eventId': eventId,
      'eventName': eventName,
      'rating': rating,
      'review': review,
      'tags': tags,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isVerifiedBooking': isVerifiedBooking,
      'helpfulCount': helpfulCount,
      'images': images,
      'organizerResponse': organizerResponse,
      'responseDate':
          responseDate != null ? Timestamp.fromDate(responseDate!) : null,
    };
  }

  // Create from Firebase document
  factory RatingModel.fromMap(Map<String, dynamic> map) {
    return RatingModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Anonymous',
      userPhotoUrl: map['userPhotoUrl'],
      eventId: map['eventId'],
      eventName: map['eventName'],
      rating: (map['rating'] ?? 0).toDouble(),
      review: map['review'],
      tags: List<String>.from(map['tags'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      isVerifiedBooking: map['isVerifiedBooking'] ?? false,
      helpfulCount: map['helpfulCount'] ?? 0,
      images: List<String>.from(map['images'] ?? []),
      organizerResponse: map['organizerResponse'],
      responseDate: (map['responseDate'] as Timestamp?)?.toDate(),
    );
  }

  // Copy with
  RatingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userPhotoUrl,
    String? eventId,
    String? eventName,
    double? rating,
    String? review,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerifiedBooking,
    int? helpfulCount,
    List<String>? images,
    String? organizerResponse,
    DateTime? responseDate,
  }) {
    return RatingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      eventId: eventId ?? this.eventId,
      eventName: eventName ?? this.eventName,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerifiedBooking: isVerifiedBooking ?? this.isVerifiedBooking,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      images: images ?? this.images,
      organizerResponse: organizerResponse ?? this.organizerResponse,
      responseDate: responseDate ?? this.responseDate,
    );
  }

  // Check if this is a platform rating
  bool get isPlatformRating => eventId == null;

  // Get formatted date
  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }
}

/// Rating statistics model
class RatingStats {
  final double averageRating;
  final int totalRatings;
  final Map<int, int> ratingDistribution; // {5: 100, 4: 50, 3: 20, 2: 10, 1: 5}
  final int verifiedRatings;
  final int reviewsWithText;
  final int reviewsWithImages;
  final List<String> topTags;
  final double recommendationScore; // Percentage who would recommend

  RatingStats({
    required this.averageRating,
    required this.totalRatings,
    required this.ratingDistribution,
    this.verifiedRatings = 0,
    this.reviewsWithText = 0,
    this.reviewsWithImages = 0,
    this.topTags = const [],
    this.recommendationScore = 0.0,
  });

  // Get percentage for each star rating
  double getPercentage(int stars) {
    if (totalRatings == 0) return 0.0;
    return ((ratingDistribution[stars] ?? 0) / totalRatings) * 100;
  }

  // Get quality indicator
  String get qualityIndicator {
    if (averageRating >= 4.5) return 'Excellent';
    if (averageRating >= 4.0) return 'Very Good';
    if (averageRating >= 3.5) return 'Good';
    if (averageRating >= 3.0) return 'Average';
    if (averageRating >= 2.0) return 'Below Average';
    return 'Poor';
  }

  // Convert to map
  Map<String, dynamic> toMap() {
    return {
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'ratingDistribution': ratingDistribution,
      'verifiedRatings': verifiedRatings,
      'reviewsWithText': reviewsWithText,
      'reviewsWithImages': reviewsWithImages,
      'topTags': topTags,
      'recommendationScore': recommendationScore,
    };
  }

  // Create from map
  factory RatingStats.fromMap(Map<String, dynamic> map) {
    return RatingStats(
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalRatings: map['totalRatings'] ?? 0,
      ratingDistribution: Map<int, int>.from(map['ratingDistribution'] ?? {}),
      verifiedRatings: map['verifiedRatings'] ?? 0,
      reviewsWithText: map['reviewsWithText'] ?? 0,
      reviewsWithImages: map['reviewsWithImages'] ?? 0,
      topTags: List<String>.from(map['topTags'] ?? []),
      recommendationScore: (map['recommendationScore'] ?? 0.0).toDouble(),
    );
  }
}
