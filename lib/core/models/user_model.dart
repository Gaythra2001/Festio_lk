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
    };
  }

  bool get isOrganizer => userType == UserType.organizer;
  bool get isUser => userType == UserType.user;
}
