import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class UserDataProvider extends ChangeNotifier {
  String? _email;
  String? _fullName;
  String? _location;
  String? _phone;
  bool _isLoggedIn = false;
  UserType _userType = UserType.user;

  // Getters
  String? get email => _email;
  String? get fullName => _fullName;
  String? get location => _location;
  String? get phone => _phone;
  bool get isLoggedIn => _isLoggedIn;
  UserType get userType => _userType;

  // Register user
  void registerUser({
    required String email,
    required String fullName,
    required String phone,
    required String location,
    UserType userType = UserType.user,
  }) {
    _email = email;
    _fullName = fullName;
    _phone = phone;
    _location = location;
    _userType = userType;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Login user (with existing data or new data)
  void loginUser({
    required String email,
    String? fullName,
    String? phone,
    String? location,
  }) {
    _email = email;
    if (fullName != null) _fullName = fullName;
    if (phone != null) _phone = phone;
    if (location != null) _location = location;
    _isLoggedIn = true;
    notifyListeners();
  }

  // Logout user
  void logoutUser() {
    _email = null;
    _fullName = null;
    _phone = null;
    _location = null;
    _isLoggedIn = false;
    notifyListeners();
  }

  // Update user data
  void updateUserData({
    String? fullName,
    String? phone,
    String? location,
  }) {
    if (fullName != null) _fullName = fullName;
    if (phone != null) _phone = phone;
    if (location != null) _location = location;
    notifyListeners();
  }
}
