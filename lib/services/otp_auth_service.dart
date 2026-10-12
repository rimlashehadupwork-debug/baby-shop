import 'dart:convert';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class OtpAuthService {
  OtpAuthService._();

  static final OtpAuthService instance = OtpAuthService._();

  static String safeEmail(String email) =>
      email.trim().toLowerCase().replaceAll(RegExp(r'[.#$\[\]/]'), '_');

  /// Sends 6-digit OTP directly to user's inbox using EmailJS REST API
  Future<bool> sendOtpViaEmailJS({
    required String userEmail,
    required String otpCode,
    String serviceId = 'service_6lo5m3s',
    String templateId = 'template_yal4era',
    String publicKey = 'uydawCyuJJOSfoiUb',
  }) async {
    if (serviceId == 'YOUR_SERVICE_ID') {
      debugPrint('EmailJS Notice: Using demo/placeholder keys. Update with your real EmailJS credentials.');
      return true;
    }

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': publicKey,
          'template_params': {
            'to_email': userEmail,
            'user_email': userEmail,
            'otp_code': otpCode,
            'passcode': otpCode,
          },
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('EmailJS: OTP email sent successfully to $userEmail');
        return true;
      } else {
        debugPrint('EmailJS error [${response.statusCode}]: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('EmailJS exception: $e');
      return false;
    }
  }

  /// Generates a 6-digit OTP code, saves it in Realtime DB, and emails via EmailJS
  Future<String?> generateAndSendOtp(
    String email, {
    String serviceId = 'service_6lo5m3s',
    String templateId = 'template_yal4era',
    String publicKey = 'uydawCyuJJOSfoiUb',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) return null;

    try {
      final random = Random();
      final code = (100000 + random.nextInt(900000)).toString();

      final now = DateTime.now();
      final expiresAt = now.add(const Duration(minutes: 5));

      final key = safeEmail(cleanEmail);

      await FirebaseDatabase.instance.ref('email_otps/$key').set({
        'email': cleanEmail,
        'code': code,
        'createdAt': now.toIso8601String(),
        'expiresAt': expiresAt.toIso8601String(),
      });

      // Send via EmailJS API
      await sendOtpViaEmailJS(
        userEmail: cleanEmail,
        otpCode: code,
        serviceId: serviceId,
        templateId: templateId,
        publicKey: publicKey,
      );

      debugPrint('OTP Generated for $cleanEmail: $code (expires at $expiresAt)');
      return code;
    } catch (e) {
      debugPrint('OTP GENERATE ERROR: $e');
      return null;
    }
  }

  /// Verifies entered OTP code against stored code in `email_otps/{safeEmail}`
  Future<Map<String, dynamic>> verifyOtpAndAuthenticate({
    required String email,
    required String enteredCode,
    String fullName = '',
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final key = safeEmail(cleanEmail);

    try {
      final snap = await FirebaseDatabase.instance.ref('email_otps/$key').get();
      if (!snap.exists || snap.value == null) {
        return {
          'success': false,
          'message': 'No OTP found for this email. Please request a new code.',
        };
      }

      final data = Map<String, dynamic>.from(snap.value as Map);
      final storedCode = (data['code'] ?? '').toString();
      final expiresAtStr = (data['expiresAt'] ?? '').toString();
      final expiresAt = DateTime.tryParse(expiresAtStr) ?? DateTime.now();

      // Check Expiry
      if (DateTime.now().isAfter(expiresAt)) {
        return {
          'success': false,
          'message': 'The OTP code has expired. Please request a new code.',
        };
      }

      // Check Code Match
      if (storedCode.trim() != enteredCode.trim()) {
        return {
          'success': false,
          'message': 'Invalid OTP code. Please check and try again.',
        };
      }

      // Code matched! Delete OTP entry
      await FirebaseDatabase.instance.ref('email_otps/$key').remove();

      // Determine default role
      final role = (cleanEmail == 'admin@gmail.com' || cleanEmail.contains('admin'))
          ? 'admin'
          : 'user';

      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null || currentUser.email?.toLowerCase() != cleanEmail) {
        try {
          final dummyPassword = 'OtpPass_${key.length > 8 ? key.substring(0, 8) : key}!';
          try {
            final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: cleanEmail,
              password: dummyPassword,
            );
            currentUser = cred.user;
          } catch (_) {
            final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: cleanEmail,
              password: dummyPassword,
            );
            currentUser = cred.user;
          }
        } catch (e) {
          debugPrint('Firebase Auth Error during OTP sign-in: $e');
        }
      }

      final uid = currentUser?.uid ?? key;

      // 1. Save or update user profile
      final userRef = FirebaseDatabase.instance.ref('users/$uid');
      final userSnap = await userRef.get();

      String userRole = role;

      if (!userSnap.exists) {
        final userName = fullName.trim().isNotEmpty
            ? fullName.trim()
            : cleanEmail.split('@').first;
        await userRef.set({
          'uid': uid,
          'name': userName,
          'email': cleanEmail,
          'role': role,
          'createdAt': DateTime.now().toIso8601String(),
        });
      } else {
        if (userSnap.value is Map) {
          final uData = Map<String, dynamic>.from(userSnap.value as Map);
          userRole = (uData['role'] ?? role).toString();
        }
      }

      // 2. Create in-app login notification in Realtime Database
      try {
        final notifRef = FirebaseDatabase.instance.ref('notifications').push();
        await notifRef.set({
          'title': 'Email OTP Login Successful',
          'body': 'Welcome back! You signed in securely to BabyShopHub via Email OTP.',
          'targetType': 'specific',
          'targetUserId': uid,
          'timestamp': DateTime.now().toIso8601String(),
          'createdAt': DateTime.now().toIso8601String(),
        });
      } catch (notifErr) {
        debugPrint('Notification creation error: $notifErr');
      }

      return {
        'success': true,
        'role': userRole,
        'email': cleanEmail,
        'uid': uid,
        'message': 'OTP verified & logged in successfully!',
      };
    } catch (e) {
      debugPrint('VERIFY OTP ERROR: $e');
      return {
        'success': false,
        'message': 'An error occurred during verification: ${e.toString()}',
      };
    }
  }
}
