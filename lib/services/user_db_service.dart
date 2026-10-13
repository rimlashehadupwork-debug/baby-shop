import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class UserDbService {
  UserDbService._();

  static final UserDbService instance = UserDbService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Ensures user document exists in Firestore under `users/{uid}`.
  /// If missing, generates document setting `isCustomVerified: false` (or `true` if `admin@gmail.com`).
  Future<void> ensureUserDocument(User user, {String name = ''}) async {
    final uid = user.uid;
    final email = (user.email ?? '').toLowerCase();

    try {
      final docRef = _firestore.collection('users').doc(uid);
      final docSnap = await docRef.get();

      final bool isAdminEmail = email == 'admin@gmail.com';

      if (!docSnap.exists) {
        final userName = name.trim().isNotEmpty
            ? name.trim()
            : (user.displayName ?? (email.isNotEmpty ? email.split('@').first : 'User'));

        await docRef.set({
          'uid': uid,
          'email': email,
          'name': userName,
          'role': isAdminEmail ? 'admin' : 'user',
          'isCustomVerified': isAdminEmail, // false for regular users, true for admin@gmail.com
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final data = docSnap.data();
        if (data != null && !data.containsKey('isCustomVerified')) {
          await docRef.update({
            'isCustomVerified': isAdminEmail,
          });
        }
      }
    } catch (e) {
      debugPrint('USER DB SERVICE ERROR: $e');
    }
  }

  /// Sets `isCustomVerified: true` for specified user UID in Firestore
  Future<void> markUserCustomVerified(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'isCustomVerified': true,
        'verifiedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('MARK CUSTOM VERIFIED ERROR: $e');
      rethrow;
    }
  }
}
