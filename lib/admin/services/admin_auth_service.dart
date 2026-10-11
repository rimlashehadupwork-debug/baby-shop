import 'package:firebase_auth/firebase_auth.dart';
import '../../services/delivery_info.dart';

class AdminAuthService {
  AdminAuthService._();

  static final AdminAuthService instance = AdminAuthService._();

  User? get _user => FirebaseAuth.instance.currentUser;

  bool get isLoggedIn => _user != null;

  String get email => _user?.email ?? '';

  String get name {
    final saved = DeliveryInfo.instance.name.trim();
    if (saved.isNotEmpty) return saved;
    final display = (_user?.displayName ?? '').trim();
    if (display.isNotEmpty) return display;
    final mail = email;
    if (mail.contains('@')) return mail.split('@').first;
    return 'Admin';
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }
}