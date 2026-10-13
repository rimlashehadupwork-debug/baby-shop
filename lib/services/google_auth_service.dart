import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'user_db_service.dart';

class GoogleAuthService {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  // Web Client ID from google-services.json required for idToken generation
  static const String _webClientId =
      '688118988830-9m6so6pm8slh1er7pqiirihhgvmrh92o.apps.googleusercontent.com';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    serverClientId: kIsWeb ? null : _webClientId,
    scopes: ['email', 'profile'],
  );

  /// Triggers Google Sign-In flow, extracts tokens, authenticates with FirebaseAuth,
  /// and syncs user profile node `users/{uid}` in Firebase Realtime Database & Firestore.
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // 1. Trigger account selector overlay
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        debugPrint('Google Sign-In: Cancelled by user.');
        return null;
      }

      // 2. Extract authentication tokens
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      debugPrint('Google Sign-In Token Extracted: idToken=${googleAuth.idToken != null}');

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

        // Ensure user document exists in Firestore with `isCustomVerified: false` (or `true` if admin@gmail.com)
        await UserDbService.instance.ensureUserDocument(user, name: userName);

        // Sync profile in Firebase Realtime Database at `users/{uid}`
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
    } on PlatformException catch (e) {
      final fullError = 'PlatformException(${e.code}, ${e.message}, ${e.details})';
      debugPrint('GOOGLE SIGN-IN PLATFORM EXCEPTION: $fullError');
      rethrow;
    } catch (e, stack) {
      debugPrint('GOOGLE SIGN-IN SERVICE ERROR: $e');
      debugPrint('GOOGLE SIGN-IN EXCEPTION DETAILS: $e\n$stack');
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
