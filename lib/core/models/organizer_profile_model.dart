import 'package:cloud_firestore/cloud_firestore.dart';

class OrganizerProfileModel {
  final String userId;
  final String organizerName;
  final String? profileDescription;
  final String? profileImageUrl;
  final String? websiteUrl;
  final String? socialMediaUrls; // JSON string of social media links
  final String businessType; // 'solo', 'company', 'npo'
  final String? businessRegistrationNumber;
  final String? taxId;
  final String businessAddress;
  final String? city;
  final String? country;
  final String? phoneNumber;
  final bool isVerified;
  final bool isPhoneVerified;
  final String verificationStatus; // 'pending', 'verified', 'rejected', 'unverified'
  final DateTime? verificationDate;
  final String? verificationNotes;
  
  // Trust & credibility metrics
  final double averageRating;
  final int totalReviews;
  final int totalEventsHosted;
  final int totalAttendees;
  final int totalTicketsSold;
  final double totalRevenue;
  final int upcomingEvents;
  
  // Compliance & safety
  final bool acceptedTerms;
  final bool acceptedPrivacyPolicy;
  final List<String> verificationDocuments; // Document URLs
  final String? bankAccountVerified; // 'pending', 'verified', 'failed'
  
  // Communication & support
  final int responseTime; // in minutes
  final double responseRating;
  final int cancellationRate; // percentage
  
  final DateTime createdAt;
  final DateTime updatedAt;

  OrganizerProfileModel({
    required this.userId,
    required this.organizerName,
    this.profileDescription,
    this.profileImageUrl,
    this.websiteUrl,
    this.socialMediaUrls,
    this.businessType = 'solo',
    this.businessRegistrationNumber,
    this.taxId,
    required this.businessAddress,
    this.city,
    this.country,
    this.phoneNumber,
    this.isVerified = false,
    this.isPhoneVerified = false,
    this.verificationStatus = 'unverified',
    this.verificationDate,
    this.verificationNotes,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.totalEventsHosted = 0,
    this.totalAttendees = 0,
    this.totalTicketsSold = 0,
    this.totalRevenue = 0.0,
    this.upcomingEvents = 0,
    this.acceptedTerms = false,
    this.acceptedPrivacyPolicy = false,
    this.verificationDocuments = const [],
    this.bankAccountVerified,
    this.responseTime = 0,
    this.responseRating = 0.0,
    this.cancellationRate = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrganizerProfileModel.fromMap(Map<String, dynamic> map, String userId) {
    return OrganizerProfileModel(
      userId: userId,
      organizerName: map['organizerName'] ?? '',
      profileDescription: map['profileDescription'],
      profileImageUrl: map['profileImageUrl'],
      websiteUrl: map['websiteUrl'],
      socialMediaUrls: map['socialMediaUrls'],
      businessType: map['businessType'] ?? 'solo',
      businessRegistrationNumber: map['businessRegistrationNumber'],
      taxId: map['taxId'],
      businessAddress: map['businessAddress'] ?? '',
      city: map['city'],
      country: map['country'],
      phoneNumber: map['phoneNumber'],
      isVerified: map['isVerified'] ?? false,
      isPhoneVerified: map['isPhoneVerified'] ?? false,
      verificationStatus: map['verificationStatus'] ?? 'unverified',
      verificationDate: (map['verificationDate'] as Timestamp?)?.toDate(),
      verificationNotes: map['verificationNotes'],
      averageRating: (map['averageRating'] ?? 0.0).toDouble(),
      totalReviews: map['totalReviews'] ?? 0,
      totalEventsHosted: map['totalEventsHosted'] ?? 0,
      totalAttendees: map['totalAttendees'] ?? 0,
      totalTicketsSold: map['totalTicketsSold'] ?? 0,
      totalRevenue: (map['totalRevenue'] ?? 0.0).toDouble(),
      upcomingEvents: map['upcomingEvents'] ?? 0,
      acceptedTerms: map['acceptedTerms'] ?? false,
      acceptedPrivacyPolicy: map['acceptedPrivacyPolicy'] ?? false,
      verificationDocuments:
          List<String>.from(map['verificationDocuments'] ?? []),
      bankAccountVerified: map['bankAccountVerified'],
      responseTime: map['responseTime'] ?? 0,
      responseRating: (map['responseRating'] ?? 0.0).toDouble(),
      cancellationRate: map['cancellationRate'] ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'organizerName': organizerName,
      'profileDescription': profileDescription,
      'profileImageUrl': profileImageUrl,
      'websiteUrl': websiteUrl,
      'socialMediaUrls': socialMediaUrls,
      'businessType': businessType,
      'businessRegistrationNumber': businessRegistrationNumber,
      'taxId': taxId,
      'businessAddress': businessAddress,
      'city': city,
      'country': country,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'isPhoneVerified': isPhoneVerified,
      'verificationStatus': verificationStatus,
      'verificationDate': verificationDate != null
          ? Timestamp.fromDate(verificationDate!)
          : null,
      'verificationNotes': verificationNotes,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'totalEventsHosted': totalEventsHosted,
      'totalAttendees': totalAttendees,
      'totalTicketsSold': totalTicketsSold,
      'totalRevenue': totalRevenue,
      'upcomingEvents': upcomingEvents,
      'acceptedTerms': acceptedTerms,
      'acceptedPrivacyPolicy': acceptedPrivacyPolicy,
      'verificationDocuments': verificationDocuments,
      'bankAccountVerified': bankAccountVerified,
      'responseTime': responseTime,
      'responseRating': responseRating,
      'cancellationRate': cancellationRate,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  // Helper methods for trust indicators
  bool get isTrustworthy =>
      isVerified &&
      isPhoneVerified &&
      averageRating >= 4.0 &&
      totalEventsHosted >= 5 &&
      cancellationRate < 10;

  bool get isNewOrganizer => totalEventsHosted < 3;

  bool get hasGoodRating => averageRating >= 4.0;

  bool get hasResponsiveBusiness => responseRating >= 4.5 && responseTime < 24;

  String getTrustBadgeText() {
    if (isVerified && averageRating >= 4.5) {
      return 'Verified & Highly Rated';
    }
    if (isVerified) {
      return 'Verified Organizer';
    }
    if (averageRating >= 4.5) {
      return 'Highly Rated';
    }
    if (isNewOrganizer) {
      return 'New Organizer';
    }
    return 'Organizer';
  }
}
