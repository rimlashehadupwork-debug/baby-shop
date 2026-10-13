import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../admin/screens/admin_shell.dart';
import '../screens/home_placeholder_screen.dart';
import '../screens/login_screen.dart';
import '../screens/verify_email_screen.dart';
import '../services/user_db_service.dart';
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

        final userEmail = (user.email ?? '').toLowerCase();

        // 2. Admin Bypass Exception: admin@gmail.com skips verification entirely
        if (userEmail == 'admin@gmail.com') {
          return const AdminShell();
        }

        // Ensure user document exists in Firestore
        UserDbService.instance.ensureUserDocument(user);

        // 3. Firestore Document StreamBuilder checking `isCustomVerified` boolean value
        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
          builder: (context, docSnapshot) {
            if (docSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: AppColors.background,
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                ),
              );
            }

            if (!docSnapshot.hasData || !docSnapshot.data!.exists) {
              return const VerifyEmailScreen();
            }

            final data = docSnapshot.data!.data();
            final isCustomVerified = data?['isCustomVerified'] == true;
            final role = (data?['role'] ?? 'user').toString();

            // 4. If custom verification is false -> Route to VerifyEmailScreen
            if (!isCustomVerified) {
              return const VerifyEmailScreen();
            }

            // 5. Custom verification is true -> Route to AdminShell or HomePlaceholderScreen
            if (role == 'admin') {
              return const AdminShell();
            }

            return const HomePlaceholderScreen();
          },
        );
      },
    );
  }
}
