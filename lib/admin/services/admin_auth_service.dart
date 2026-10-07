/// Demo admin authentication (no backend in this project).
/// Demo credentials:  admin@babyshophub.com  /  Admin@123
class AdminAuthService {
  static final AdminAuthService instance = AdminAuthService._internal();
  AdminAuthService._internal();

  static const String adminEmail = 'admin@babyshophub.com';
  static const String _adminPassword = 'Admin@123';
  static const String adminName = 'Admin';

  bool _loggedIn = false;
  bool get isLoggedIn => _loggedIn;

  bool login(String email, String password) {
    final ok = email.trim().toLowerCase() == adminEmail && password == _adminPassword;
    _loggedIn = ok;
    return ok;
  }

  void logout() {
    _loggedIn = false;
  }
}
