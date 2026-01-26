import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';
import '../services/firestore_service.dart';
import '../services/mock_firestore_service.dart';
import '../config/app_config.dart';

class BookingProvider with ChangeNotifier {
  final FirestoreService? _firestoreService = useFirebase ? FirestoreService() : null;
  final MockFirestoreService? _mockFirestoreService = useFirebase ? null : MockFirestoreService();
  
  List<BookingModel> _bookings = [];
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  List<BookingModel> get upcomingBookings => _bookings
      .where((b) => b.status == BookingStatus.upcoming)
      .toList();
  List<BookingModel> get pastBookings => _bookings
      .where((b) => b.status == BookingStatus.past)
      .toList();
  List<BookingModel> get cancelledBookings => _bookings
      .where((b) => b.status == BookingStatus.cancelled)
      .toList();
  bool get isLoading => _isLoading;

  void loadBookings(String userId) {
    if (useFirebase && _firestoreService != null) {
      _firestoreService!.getUserBookings(userId).listen((bookings) {
        _bookings = bookings;
        notifyListeners();
      });
    } else if (_mockFirestoreService != null) {
      _mockFirestoreService!.getUserBookings(userId).listen((bookings) {
        _bookings = bookings;
        notifyListeners();
      });
    }
  }

  Future<bool> createBooking(BookingModel booking) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (useFirebase && _firestoreService != null) {
        await _firestoreService!.createBooking(booking);
      } else if (_mockFirestoreService != null) {
        await _mockFirestoreService!.createBooking(booking);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error creating booking: $e');
      return false;
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    if (useFirebase && _firestoreService != null) {
      await _firestoreService!.updateBookingStatus(bookingId, BookingStatus.cancelled);
    } else if (_mockFirestoreService != null) {
      await _mockFirestoreService!.updateBookingStatus(bookingId, BookingStatus.cancelled);
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    if (useFirebase && _firestoreService != null) {
      await _firestoreService!.deleteBooking(bookingId);
    } else if (_mockFirestoreService != null) {
      await _mockFirestoreService!.deleteBooking(bookingId);
    }
  }
}

