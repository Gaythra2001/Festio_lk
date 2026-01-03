import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  upcoming,
  past,
  cancelled,
}

class BookingModel {
  final String id;
  final String eventId;
  final String userId;
  final String eventTitle;
  final DateTime eventDate;
  final String eventLocation;
  final String? eventImageUrl;
  final BookingStatus status;
  final DateTime bookedAt;
  final int numberOfTickets;
  final double? totalPrice;
  final String? qrCodeUrl;

  BookingModel({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.eventTitle,
    required this.eventDate,
    required this.eventLocation,
    this.eventImageUrl,
    required this.status,
    required this.bookedAt,
    this.numberOfTickets = 1,
    this.totalPrice,
    this.qrCodeUrl,
  });

  factory BookingModel.fromMap(Map<String, dynamic> map, String id) {
    return BookingModel(
      id: id,
      eventId: map['eventId'] ?? '',
      userId: map['userId'] ?? '',
      eventTitle: map['eventTitle'] ?? '',
      eventDate: (map['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      eventLocation: map['eventLocation'] ?? '',
      eventImageUrl: map['eventImageUrl'],
      status: _parseStatus(map['status']),
      bookedAt: (map['bookedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      numberOfTickets: map['numberOfTickets'] ?? 1,
      totalPrice: (map['totalPrice'] as num?)?.toDouble(),
      qrCodeUrl: map['qrCodeUrl'],
    );
  }

  static BookingStatus _parseStatus(dynamic status) {
    if (status is String) {
      switch (status) {
        case 'upcoming':
          return BookingStatus.upcoming;
        case 'past':
          return BookingStatus.past;
        case 'cancelled':
          return BookingStatus.cancelled;
        default:
          return BookingStatus.upcoming;
      }
    }
    return BookingStatus.upcoming;
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'userId': userId,
      'eventTitle': eventTitle,
      'eventDate': Timestamp.fromDate(eventDate),
      'eventLocation': eventLocation,
      'eventImageUrl': eventImageUrl,
      'status': status.name,
      'bookedAt': Timestamp.fromDate(bookedAt),
      'numberOfTickets': numberOfTickets,
      'totalPrice': totalPrice,
      'qrCodeUrl': qrCodeUrl,
    };
  }
}

