import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final String? titleSi; // Sinhala title
  final String? titleTa; // Tamil title
  final String? descriptionSi; // Sinhala description
  final String? descriptionTa; // Tamil description
  final DateTime startDate;
  final DateTime endDate;
  final String location;
  final String? locationSi;
  final String? locationTa;
  final String category;
  final List<String> tags;
  final String organizerId;
  final String organizerName;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final bool isApproved;
  final bool isSpam;
  final double spamScore;
  final int trustScore;
  final DateTime submittedAt;
  final DateTime? approvedAt;
  final String status; // pending, approved, rejected
  final String? rejectionReason;
  final int? maxAttendees;
  final double? ticketPrice;
  final String? ticketUrl;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.titleSi,
    this.titleTa,
    this.descriptionSi,
    this.descriptionTa,
    required this.startDate,
    required this.endDate,
    required this.location,
    this.locationSi,
    this.locationTa,
    required this.category,
    this.tags = const [],
    required this.organizerId,
    required this.organizerName,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.isApproved = false,
    this.isSpam = false,
    this.spamScore = 0.0,
    this.trustScore = 0,
    required this.submittedAt,
    this.approvedAt,
    String? status,
    this.rejectionReason,
    this.maxAttendees,
    this.ticketPrice,
    this.ticketUrl,
  }) : status = status ?? (isApproved ? 'approved' : 'pending');

  factory EventModel.fromMap(Map<String, dynamic> map, String id) {
    final bool approvedFlag = map['isApproved'] ?? false;
    final String resolvedStatus =
        (map['status'] as String?) ?? (approvedFlag ? 'approved' : 'pending');
    final dynamic rawImageUrl = map['imageUrl'] ?? map['image_url'];
    return EventModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      titleSi: map['titleSi'],
      titleTa: map['titleTa'],
      descriptionSi: map['descriptionSi'],
      descriptionTa: map['descriptionTa'],
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      location: map['location'] ?? '',
      locationSi: map['locationSi'],
      locationTa: map['locationTa'],
      category: map['category'] ?? 'Other',
      tags: List<String>.from(map['tags'] ?? []),
      organizerId: map['organizerId'] ?? '',
      organizerName: map['organizerName'] ?? '',
      imageUrl: rawImageUrl is String ? rawImageUrl : rawImageUrl?.toString(),
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
      isApproved: approvedFlag,
      isSpam: map['isSpam'] ?? false,
      spamScore: (map['spamScore'] as num?)?.toDouble() ?? 0.0,
      trustScore: map['trustScore'] ?? 0,
      submittedAt:
          (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (map['approvedAt'] as Timestamp?)?.toDate(),
      status: resolvedStatus,
      rejectionReason: map['rejectionReason'],
      maxAttendees: map['maxAttendees'],
      ticketPrice: (map['ticketPrice'] as num?)?.toDouble(),
      ticketUrl: map['ticketUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'titleSi': titleSi,
      'titleTa': titleTa,
      'descriptionSi': descriptionSi,
      'descriptionTa': descriptionTa,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'location': location,
      'locationSi': locationSi,
      'locationTa': locationTa,
      'category': category,
      'tags': tags,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'imageUrl': imageUrl,
      'image_url': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
      'isApproved': isApproved,
      'isSpam': isSpam,
      'spamScore': spamScore,
      'trustScore': trustScore,
      'submittedAt': Timestamp.fromDate(submittedAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'status': status,
      'rejectionReason': rejectionReason,
      'maxAttendees': maxAttendees,
      'ticketPrice': ticketPrice,
      'ticketUrl': ticketUrl,
    };
  }
}
