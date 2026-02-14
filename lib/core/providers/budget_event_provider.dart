import 'package:flutter/material.dart';
import '../models/budget_event_model.dart';

class BudgetEventProvider with ChangeNotifier {
  BudgetEventModel? _event;
  bool _isLoading = false;

  BudgetEventModel? get event => _event;
  bool get isLoading => _isLoading;

  // Create / Customize Event
  void createEvent({
    required String title,
    required String category,
    required String location,
    required String date,
    required double budget,
    required int guests,
    required String description,
  }) {
    _isLoading = true;
    notifyListeners();

    _event = BudgetEventModel(
      title: title,
      category: category,
      location: location,
      date: date,
      budget: budget,
      guests: guests,
      description: description,
    );

    _isLoading = false;
    notifyListeners();
  }

  // Clear event (optional)
  void clearEvent() {
    _event = null;
    notifyListeners();
  }
}
