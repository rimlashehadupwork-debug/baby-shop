import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _timer;
  Timer? _cooldownTimer;

  bool _isEmailSent = false;
  bool _canResend = true;
  int _cooldownRemaining = 60;
  bool _isRedirecting = false;

  User? get _currentUser => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkInitialVerificationStatus();
  }

  Future<void> _checkInitialVerificationStatus() async {
    final user = _currentUser;
    if (user == null) return;

    await user.reload();
    if (FirebaseAuth.instance.currentUser?.emailVerified == true) {
      _redirectToDashboard();
      return;
    }

    // Send verification email on screen load
    _sendVerificationEmail();

    // Start 3-second polling loop
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      await _checkEmailVerified();
    });
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await user.reload();
      final reloadedUser = FirebaseAuth.instance.currentUser;
      if (reloadedUser != null && reloadedUser.emailVerified) {
        _timer?.cancel();
        _cooldownTimer?.cancel();
        _redirectToDashboard();
      }
    } catch (e) {
      debugPrint('Error reloading user email verification status: $e');
    }
  }

  Future<void> _redirectToDashboard() async {
    if (_isRedirecting || !mounted) return;
    setState(() => _isRedirecting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).pushReplacementNamed('/login');
      return;
    }

    String role = 'user';
    try {
      final snap = await FirebaseDatabase.instance.ref('users/${user.uid}').get();
      if (snap.exists && snap.value is Map) {
        final data = Map<String, dynamic>.from(snap.value as Map);
        role = (data['role'] ?? 'user').toString();
      }
    } catch (e) {
      debugPrint('Error checking user role on email verification redirect: $e');
    }

    final email = (user.email ?? '').toLowerCase();
    final bool isAdmin = role == 'admin' || email == 'admin@gmail.com';

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(child: Text('Email verified successfully! Welcome to BabyShopHub.')),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );

    if (isAdmin) {
      Navigator.of(context).pushReplacementNamed('/admin');
    } else {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        setState(() {
          _isEmailSent = true;
        });
        _startCooldownTimer();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'Error sending verification email'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('Verification email error: $e');
    }
  }

  void _startCooldownTimer() {
    setState(() {
      _canResend = false;
      _cooldownRemaining = 60;
    });

    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownRemaining > 0) {
        if (mounted) {
          setState(() => _cooldownRemaining--);
        }
      } else {
        timer.cancel();
        if (mounted) {
          setState(() => _canResend = true);
        }
      }
    });
  }

  Future<void> _handleResendEmail() async {
    if (!_canResend) return;

    await _sendVerificationEmail();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(child: Text('Verification link resent to your email inbox!')),
            ],
          ),
          backgroundColor: AppColors.primaryBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _handleLogout() async {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _currentUser?.email ?? 'your email address';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const BabyShopHubLogo(
                  iconSize: 56,
                  fontSize: 26,
                ),
                const SizedBox(height: 36),

                // Animated Envelope Badge
                Center(
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.mark_email_unread_rounded,
                      size: 48,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Heading
                const Text(
                  'Verify Your Email Address',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),

                // Explanation
                const Text(
                  'We have sent a verification link to your email:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 8),

                // Email Chip
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.email_outlined, color: AppColors.primaryBlue, size: 18),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            userEmail,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Please open your email client, tap the verification link, and return here. This screen will update automatically once verified.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 28),

                // Auto Polling Status Indicator
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Checking verification status in real-time...',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Resend Email Button with Cooldown
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _canResend ? AppColors.primaryBlue : AppColors.border,
                      foregroundColor: _canResend ? Colors.white : AppColors.secondaryText,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _canResend ? _handleResendEmail : null,
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      _canResend
                          ? 'Resend Verification Email'
                          : 'Resend in ${_cooldownRemaining}s',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Logout Button
                Center(
                  child: TextButton.icon(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                    label: const Text(
                      'Cancel & Sign Out',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
