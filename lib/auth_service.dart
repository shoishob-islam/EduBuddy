import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'user_model.dart';
import 'notification_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService? _notificationService;

  AuthService([this._notificationService]);

  // Stream of auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current user
  User? get currentUser => _auth.currentUser;

  // Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user data: $e');
      return null;
    }
  }

  // Stream of user data
  Stream<UserModel?> userDataStream(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    });
  }

  // Sign In
  Future<UserModel?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) return null;

      // Update last login
      await _firestore.collection('users').doc(user.uid).update({
        'lastLogin': Timestamp.now(),
      });

      // Save device token for push notifications
      await _notificationService?.saveDeviceToken(user.uid);

      return getUserData(user.uid);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update profile
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? photoUrl,
    String? branch,
    String? year,
    String? college,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (branch != null) updates['branch'] = branch;
    if (year != null) updates['year'] = year;
    if (college != null) updates['college'] = college;

    await _firestore.collection('users').doc(uid).update(updates);

    if (name != null) {
      await _auth.currentUser?.updateDisplayName(name);
    }
  }

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Try again later.';
      default:
        return 'Authentication error: ${e.message}';
    }
  }
}
