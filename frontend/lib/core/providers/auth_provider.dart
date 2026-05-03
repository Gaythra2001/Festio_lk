import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/mock_auth_service.dart';
import '../config/app_config.dart';

class AuthProvider with ChangeNotifier {
  final AuthService? _authService = useFirebase ? AuthService() : null;
  final MockAuthService? _mockAuthService =
      useFirebase ? null : MockAuthService();
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitializing = true; // Track initial Firebase session restoration

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _init();
  }

  void _init() {
    if (useFirebase && _authService != null) {
      // First, check if there's already a logged-in user (restored from Firebase session)
      if (_authService!.currentUser != null) {
        _loadUserData().then((_) {
          _isInitializing = false;
          notifyListeners();
        });
      } else {
        _isInitializing = false;
        notifyListeners();
      }
      
      // Then listen to future auth state changes
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
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<void> _loadUserData() async {
    if (useFirebase && _authService != null && _authService!.currentUser != null) {
      _user = await _authService!.getUserData();
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (useFirebase && _authService != null) {
        _user = await _authService!.signInWithEmailAndPassword(email, password);
      } else if (_mockAuthService != null) {
        _user =
            await _mockAuthService!.signInWithEmailAndPassword(email, password);
      }
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      debugPrint('Auth error: $e'); // Added logging
      _isLoading = false;
      notifyListeners();
      rethrow; // Rethrow to show specific error in UI
    }
  }

  Future<bool> register(
      String email, String password, String displayName,
      {String userType = 'user',
      String? phoneNumber,
      String? businessName,
      String? businessRegistration,
      String? businessAddress}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (useFirebase && _authService != null) {
        _user = await _authService!.registerWithEmailAndPassword(
            email, password, displayName,
            userType: userType,
            phoneNumber: phoneNumber,
            businessName: businessName,
            businessRegistration: businessRegistration,
            businessAddress: businessAddress);
      } else if (_mockAuthService != null) {
        _user = await _mockAuthService!
            .registerWithEmailAndPassword(email, password, displayName);
      }
      _isLoading = false;
      notifyListeners();
      return _user != null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow; // Rethrow to show specific error in UI
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

  Future<String?> getAuthToken() async {
    if (useFirebase && _authService != null) {
      return await _authService!.getAuthToken();
    } else if (_mockAuthService != null) {
      return 'mock-token';
    }
    return null;
  }
}
