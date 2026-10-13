import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Triggers Google Sign-In flow, extracts tokens, authenticates with FirebaseAuth,
  /// and syncs user profile node `users/{uid}` in Firebase Realtime Database.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger account selector overlay
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User cancelled sign-in
        return null;
      }

      // 2. Extract authentication tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create Firebase credential using extracted tokens
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Authenticate securely with FirebaseAuth
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        final String uid = user.uid;
        final String userEmail = (user.email ?? googleUser.email).toLowerCase();
        final String userName = user.displayName ?? googleUser.displayName ?? 'Google User';

        // 5. Sync profile in Firebase Realtime Database at `users/{uid}`
        final DatabaseReference userRef = FirebaseDatabase.instance.ref('users/$uid');
        final DataSnapshot snapshot = await userRef.get();

        if (!snapshot.exists || snapshot.value == null) {
          final String role = userEmail == 'admin@gmail.com' ? 'admin' : 'user';
          await userRef.set({
            'uid': uid,
            'name': userName,
            'email': userEmail,
            'role': role,
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      }

      return userCredential;
    } catch (e) {
      debugPrint('GOOGLE SIGN-IN SERVICE ERROR: $e');
      rethrow;
    }
  }

  /// Signs out from Google and Firebase
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint('GOOGLE SIGN-OUT ERROR: $e');
    }
  }
}
