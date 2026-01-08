import 'package:cloud_firestore/cloud_firestore.dart';

enum UserType {
  user,
  organizer;

  String get displayName {
    switch (this) {
      case UserType.user:
        return 'Event Attendee';
      case UserType.organizer:
        return 'Event Organizer';
    }
  }
}

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final int trustScore;
  final DateTime createdAt;
  final String? phoneNumber;
  final String preferredLanguage; // 'en', 'si', 'ta'
  final UserType userType; // 'user' or 'organizer'
  
  // Trust & verification fields for organizers
  final bool isVerified;
  final bool isPhoneVerified;
  final bool isEmailVerified;
  final String? businessName;
  final String? businessRegistration;
  final String? businessAddress;
  final double averageRating;
  final int totalReviews;
  final int totalEventsHosted;
  final int totalTicketsSold;
  final bool hasVerificationBadge;
  final DateTime? verificationDate;
  final String? verificationDocumentUrl;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.trustScore = 0,
    required this.createdAt,
    this.phoneNumber,
    this.preferredLanguage = 'en',
    this.userType = UserType.user,
    this.isVerified = false,
    this.isPhoneVerified = false,
    this.isEmailVerified = false,
    this.businessName,
    this.businessRegistration,
    this.businessAddress,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.totalEventsHosted = 0,
    this.totalTicketsSold = 0,
    this.hasVerificationBadge = false,
    this.verificationDate,
    this.verificationDocumentUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
      trustScore: map['trustScore'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      phoneNumber: map['phoneNumber'],
      preferredLanguage: map['preferredLanguage'] ?? 'en',
      userType:
          map['userType'] == 'organizer' ? UserType.organizer : UserType.user,
      isVerified: map['isVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      isEmailVerified: map['isEmailVerified'] ?? false,
      businessName: map['businessName'],
      businessRegistration: map['businessRegistration'],
      businessAddress: map['businessAddress'],
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      totalEventsHosted: map['totalEventsHosted'] ?? 0,
      totalTicketsSold: map['totalTicketsSold'] ?? 0,
      hasVerificationBadge: map['hasVerificationBadge'] ?? false,
      verificationDate: (map['verificationDate'] as Timestamp?)?.toDate(),
      verificationDocumentUrl: map['verificationDocumentUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'trustScore': trustScore,
      'createdAt': Timestamp.fromDate(createdAt),
      'phoneNumber': phoneNumber,
      'preferredLanguage': preferredLanguage,
      'userType': userType.name,
      'isVerified': isVerified,
      'isPhoneVerified': isPhoneVerified,
      'isEmailVerified': isEmailVerified,
      'businessName': businessName,
      'businessRegistration': businessRegistration,
      'businessAddress': businessAddress,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'totalEventsHosted': totalEventsHosted,
      'totalTicketsSold': totalTicketsSold,
      'hasVerificationBadge': hasVerificationBadge,
      'verificationDate': verificationDate != null ? Timestamp.fromDate(verificationDate!) : null,
      'verificationDocumentUrl': verificationDocumentUrl,
    };
  }

  bool get isOrganizer => userType == UserType.organizer;
  bool get isUser => userType == UserType.user;
}
