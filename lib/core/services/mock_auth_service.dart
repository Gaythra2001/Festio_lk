import '../models/user_model.dart';

/// Mock authentication service for demo mode (no Firebase required)
class MockAuthService {
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock login - accepts any email/password
    _currentUser = UserModel(
      id: 'mock_user_123',
      email: email,
      displayName: email.split('@')[0],
      createdAt: DateTime.now(),
      trustScore: 50,
    );
    _isAuthenticated = true;
    return _currentUser;
  }

  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    _currentUser = UserModel(
      id: 'mock_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
      trustScore: 0,
    );
    _isAuthenticated = true;
    return _currentUser;
  }

  Future<void> signOut() async {
    _currentUser = null;
    _isAuthenticated = false;
  }

  Stream<UserModel?> get authStateChanges {
    // Return a stream that emits the current user
    return Stream.value(_currentUser);
  }
}

