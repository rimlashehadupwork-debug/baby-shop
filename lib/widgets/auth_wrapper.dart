import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../admin/screens/admin_shell.dart';
import '../screens/home_placeholder_screen.dart';
import '../screens/login_screen.dart';
import '../screens/verify_email_screen.dart';
import '../theme/app_theme.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          );
        }

        final user = snapshot.data;

        // 1. Not logged in -> Show LoginScreen
        if (user == null) {
          return const LoginScreen();
        }

        // Google accounts are inherently pre-verified
        final isGoogleUser = user.providerData.any((p) => p.providerId == 'google.com');

        // 2. Logged in via standard email/password but email not verified -> Show VerifyEmailScreen
        if (!user.emailVerified && !isGoogleUser) {
          return const VerifyEmailScreen();
        }

        // 3. Logged in & pre-verified -> Route to AdminShell or HomePlaceholderScreen
        final userEmail = (user.email ?? '').toLowerCase();
        if (userEmail == 'admin@gmail.com') {
          return const AdminShell();
        }

        return StreamBuilder<DatabaseEvent>(
          stream: FirebaseDatabase.instance.ref('users/${user.uid}').onValue,
          builder: (context, dbSnapshot) {
            if (dbSnapshot.hasData && dbSnapshot.data!.snapshot.value != null) {
              final val = dbSnapshot.data!.snapshot.value;
              if (val is Map) {
                final role = (val['role'] ?? 'user').toString();
                if (role == 'admin') {
                  return const AdminShell();
                }
              }
            }
            return const HomePlaceholderScreen();
          },
        );
      },
    );
  }
}
