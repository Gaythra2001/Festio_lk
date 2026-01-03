import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
      return await _getUserData(credential.user?.uid);
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  Future<UserModel?> registerWithEmailAndPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
        
        final userModel = UserModel(
          id: credential.user!.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userModel.toMap());

        return userModel;
      }
      return null;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserModel?> _getUserData(String? uid) async {
    if (uid == null) return null;

    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
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

