import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class SuspendedScreen extends StatelessWidget {
  final String email;

  const SuspendedScreen({
    super.key,
    this.email = '',
  });

  Future<void> _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = email.isNotEmpty
        ? email
        : (FirebaseAuth.instance.currentUser?.email ?? 'Your Account');

    return PopScope(
      canPop: false, // Prevents back button navigation
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BabyShopHubLogo(
                    iconSize: 56,
                    fontSize: 26,
                  ),
                  const SizedBox(height: 36),

                  // Lockout Badge Icon
                  Center(
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.error.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.block_rounded,
                        size: 52,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Lockout Title
                  const Text(
                    'Account Suspended',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.error,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // User Email Chip
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        userEmail,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Suspension Warning Box
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.error.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: const [
                        Text(
                          'Your account has been suspended by the administrator. You are permanently restricted from shopping, checking out, or using this application.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 14),
                        Text(
                          'If you believe this is an error or would like to appeal, please contact support@babyshophub.com.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.secondaryText,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Logout & Switch Account Button
                  SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _handleLogout(context),
                      icon: const Icon(Icons.logout_rounded, size: 20),
                      label: const Text(
                        'Sign Out & Switch Account',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
