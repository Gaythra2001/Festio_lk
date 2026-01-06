import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  final String id;
  final String eventId;
  final Map<String, String> localizedTitle;
  final Map<String, String> localizedMessage;
  final List<String> languages;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime createdAt;
  final String status; // draft, scheduled, active, completed

  PromotionModel({
    required this.id,
    required this.eventId,
    required this.localizedTitle,
    required this.localizedMessage,
    required this.languages,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    this.status = 'draft',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'eventId': eventId,
        'localizedTitle': localizedTitle,
        'localizedMessage': localizedMessage,
        'languages': languages,
        'imageUrl': imageUrl,
        'startDate': Timestamp.fromDate(startDate),
        'endDate': Timestamp.fromDate(endDate),
        'createdAt': Timestamp.fromDate(createdAt),
        'status': status,
      };

  factory PromotionModel.fromMap(Map<String, dynamic> map) => PromotionModel(
        id: map['id'] ?? '',
        eventId: map['eventId'] ?? '',
        localizedTitle: Map<String, String>.from(map['localizedTitle'] ?? {}),
        localizedMessage: Map<String, String>.from(map['localizedMessage'] ?? {}),
        languages: List<String>.from(map['languages'] ?? []),
        imageUrl: map['imageUrl'],
        startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
        createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        status: map['status'] ?? 'draft',
      );
}
