import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final int trustScore;
  final DateTime createdAt;
  final String? phoneNumber;
  final String preferredLanguage; // 'en', 'si', 'ta'

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.trustScore = 0,
    required this.createdAt,
    this.phoneNumber,
    this.preferredLanguage = 'en',
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
    };
  }
}

