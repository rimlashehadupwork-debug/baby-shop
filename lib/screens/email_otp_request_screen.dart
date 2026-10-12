import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/otp_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';
import 'email_otp_verify_screen.dart';

class EmailOtpRequestScreen extends StatefulWidget {
  const EmailOtpRequestScreen({super.key});

  @override
  State<EmailOtpRequestScreen> createState() => _EmailOtpRequestScreenState();
}

class _EmailOtpRequestScreenState extends State<EmailOtpRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  // ---------------------------------------------------------------------------
  // EmailJS Configuration Keys
  // ---------------------------------------------------------------------------
  static const String _emailJsServiceId = 'service_6lo5m3s';
  static const String _emailJsTemplateId = 'template_yal4era';
  static const String _emailJsPublicKey = 'uydawCyuJJOSfoiUb';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Helper Function: Sends the 6-digit OTP directly to user's email via EmailJS API
  Future<bool> sendOtpViaEmailJS(String userEmail, String otpCode) async {
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    debugPrint('==================================================');
    debugPrint('DEBUG OTP GENERATED FOR $userEmail: [$otpCode]');
    debugPrint('==================================================');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'service_id': _emailJsServiceId,
          'template_id': _emailJsTemplateId,
          'user_id': _emailJsPublicKey,
          'template_params': {
            'to_email': userEmail,
            'user_email': userEmail,
            'otp_code': otpCode,
            'passcode': otpCode,
          },
        }),
      );

      debugPrint('EmailJS Response Status Code: ${response.statusCode}');
      debugPrint('EmailJS Response Body: ${response.body}');

      if (response.statusCode == 200) {
        debugPrint('EmailJS SUCCESS: OTP sent to $userEmail');
        return true;
      } else {
        debugPrint('EmailJS ERROR [${response.statusCode}]: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('EmailJS Exception Caught: $e');
      debugPrint('StackTrace: $stackTrace');
      return false;
    }
  }

  /// Button Action: Generates 6-digit OTP, invokes EmailJS, & navigates to verification
  Future<void> _handleSendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();

    // 1. Generate 6-digit OTP
    final random = Random();
    final otpCode = (100000 + random.nextInt(900000)).toString();

    // 2. Save OTP to Realtime Database & trigger EmailJS
    final code = await OtpAuthService.instance.generateAndSendOtp(
      email,
      serviceId: _emailJsServiceId,
      templateId: _emailJsTemplateId,
      publicKey: _emailJsPublicKey,
    ) ?? otpCode;

    // Call client-side EmailJS directly
    await sendOtpViaEmailJS(email, code);

    if (!mounted) return;
    setState(() => _isLoading = false);

    // Show SnackBar with Debug OTP banner as failsafe
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.mark_email_read_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('Verification code sent to $email'),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'DEBUG OTP: $code',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.yellowAccent,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );

    // Navigate to OTP Verification Screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmailOtpVerifyScreen(
          email: email,
          generatedOtpCode: code,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const BabyShopHubLogo(
                    iconSize: 52,
                    fontSize: 26,
                  ),
                  const SizedBox(height: 32),

                  const Text(
                    'Email OTP Sign-In',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Enter your registered email address to receive a secure 6-digit verification code.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Input Field
                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'you@example.com',
                    controller: _emailController,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _handleSendOtp,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email address is required';
                      }
                      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // Send OTP Button
                  PrimaryButton(
                    text: 'Send OTP Code',
                    isLoading: _isLoading,
                    onPressed: _handleSendOtp,
                  ),
                  const SizedBox(height: 24),

                  // Back to Password Login
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      icon: const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.primaryBlue),
                      label: const Text(
                        'Login with Password instead',
                        style: TextStyle(
                          color: AppColors.primaryBlue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
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
