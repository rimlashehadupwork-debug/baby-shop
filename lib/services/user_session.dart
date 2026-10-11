import 'package:firebase_auth/firebase_auth.dart';

class UserSession {
  UserSession._();

  static String get userId =>
      FirebaseAuth.instance.currentUser?.uid ?? 'guest';

  static String safeKey(String value) =>
      value.replaceAll(RegExp(r'[.#$\[\]/]'), '_');

  static String get key => safeKey(userId.isEmpty ? 'guest' : userId);
}