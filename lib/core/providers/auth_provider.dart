import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/mock_auth_service.dart';
import '../config/app_config.dart';

class AuthProvider with ChangeNotifier {
  final AuthService? _authService = useFirebase ? AuthService() : null;
  final MockAuthService? _mockAuthService = useFirebase ? null : MockAuthService();
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    if (useFirebase && _authService != null) {
      _authService!.authStateChanges.listen((firebaseUser) async {
        if (firebaseUser != null) {
          _user = await _authService!.getUserData();
        } else {
          _user = null;
        }
        notifyListeners();
      });
    } else if (_mockAuthService != null) {
      // For mock, set initial user state
      _user = _mockAuthService!.currentUser;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (useFirebase && _authService != null) {
        _user = await _authService!.signInWithEmailAndPassword(email, password);
      } else if (_mockAuthService != null) {
        _user = await _mockAuthService!.signInWithEmailAndPassword(email, password);
      }
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String email, String password, String displayName) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (useFirebase && _authService != null) {
        _user = await _authService!.registerWithEmailAndPassword(email, password, displayName);
      } else if (_mockAuthService != null) {
        _user = await _mockAuthService!.registerWithEmailAndPassword(email, password, displayName);
      }
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    if (useFirebase && _authService != null) {
      await _authService!.signOut();
    } else if (_mockAuthService != null) {
      await _mockAuthService!.signOut();
    }
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? preferredLanguage,
  }) async {
    if (useFirebase && _authService != null) {
      await _authService!.updateUserProfile(
        displayName: displayName,
        photoUrl: photoUrl,
        phoneNumber: phoneNumber,
        preferredLanguage: preferredLanguage,
      );
      _user = await _authService!.getUserData();
    } else if (_mockAuthService != null) {
      // Mock mode - just update local user
      if (_user != null) {
        _user = UserModel(
          id: _user!.id,
          email: _user!.email,
          displayName: displayName ?? _user!.displayName,
          photoUrl: photoUrl ?? _user!.photoUrl,
          phoneNumber: phoneNumber ?? _user!.phoneNumber,
          preferredLanguage: preferredLanguage ?? _user!.preferredLanguage,
          trustScore: _user!.trustScore,
          createdAt: _user!.createdAt,
        );
      }
    }
    notifyListeners();
  }
}

