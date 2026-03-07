import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) throw Exception('Authentication returned no user');

      // Try to get the Firestore profile
      final userModel = await _getUserData(user.uid);

      // If Firestore doc is missing, try to create one from Firebase Auth data
      if (userModel == null) {
        final fallback = UserModel(
          id: user.uid,
          email: user.email ?? email,
          displayName: user.displayName ?? email.split('@').first,
          createdAt: DateTime.now(),
          userType: UserType.user, // Default for unknown roles
        );
        
        try {
          await _firestore.collection('users').doc(user.uid).set({
            ...fallback.toMap(),
            'userType': 'user',
            'user_type': 'attendee',
          });
        } catch (e) {
          // Ignore Firestore write issues during sign-in; proceed with fallback object
          print('Warning: Could not create user profile in Firestore: $e');
        }
        
        return fallback;
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      // Give the user a clear, human-readable message
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No account found for this email.');
        case 'wrong-password':
        case 'invalid-credential':
          throw Exception('Incorrect password. Please try again.');
        case 'user-disabled':
          throw Exception('This account has been disabled.');
        case 'too-many-requests':
          throw Exception('Too many attempts. Please try again later.');
        default:
          throw Exception('Sign in failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName, {
    String userType = 'user',
    String? phoneNumber,
    String? businessName,
    String? businessRegistration,
    String? businessAddress,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);

        // Map frontend UserType enum name to backend values
        final backendUserType = userType == 'organizer' ? 'organizer' : 'attendee';

        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          phoneNumber: phoneNumber,
          createdAt: DateTime.now(),
          userType: userType == 'organizer' ? UserType.organizer : UserType.user,
          businessName: businessName,
          businessRegistration: businessRegistration,
          businessAddress: businessAddress,
        );

        // Save to Firestore with userType
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set({
          ...userModel.toMap(),
          'userType': userType, // Persist the role as string
          'user_type': backendUserType, // For backend compatibility
        });

        // Also notify the backend to keep Firestore (via Admin SDK) in sync
        try {
          await http.post(
            Uri.parse('http://localhost:8000/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'password': password,
              'display_name': displayName,
              'user_type': backendUserType,
              'phone_number': phoneNumber,
            }),
          );
        } catch (_) {
          // Backend sync is best-effort
        }

        return userModel;
      }
      throw Exception('Failed to create account. Please try again.');
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> _getUserData(String? uid) async {
    if (uid == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      // If Firestore read fails, return null and let caller handle it
    }
    return null;
  }

  Future<UserModel?> getUserData() async {
    if (currentUser == null) return null;
    return await _getUserData(currentUser!.uid);
  }

  Future<void> updateUserProfile({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    String? preferredLanguage,
  }) async {
    if (currentUser == null) return;

    final updates = <String, dynamic>{};
    if (displayName != null) updates['displayName'] = displayName;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
    if (preferredLanguage != null) updates['preferredLanguage'] = preferredLanguage;

    await _firestore.collection('users').doc(currentUser!.uid).update(updates);
  }
}

