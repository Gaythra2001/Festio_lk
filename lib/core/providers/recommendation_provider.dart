import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../services/ai/recommendation_engine.dart';

class RecommendationProvider with ChangeNotifier {
  final RecommendationEngine _engine = RecommendationEngine();
  
  List<EventModel> _recommendations = [];
  bool _isLoading = false;

  List<EventModel> get recommendations => _recommendations;
  bool get isLoading => _isLoading;

  Future<void> loadRecommendations({
    required UserModel user,
    required List<EventModel> allEvents,
    required List<BookingModel> userBookings,
    required Map<String, List<BookingModel>> allUserBookings,
    String? searchQuery,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      _recommendations = _engine.getHybridRecommendations(
        user,
        allEvents,
        userBookings,
        allUserBookings,
        searchQuery,
      );
    } catch (e) {
      debugPrint('Error loading recommendations: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}

