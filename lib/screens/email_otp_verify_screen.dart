import 'dart:async';
import 'package:flutter/material.dart';
import '../services/otp_auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class EmailOtpVerifyScreen extends StatefulWidget {
  final String email;
  final String generatedOtpCode;

  const EmailOtpVerifyScreen({
    super.key,
    required this.email,
    required this.generatedOtpCode,
  });

  @override
  State<EmailOtpVerifyScreen> createState() => _EmailOtpVerifyScreenState();
}

class _EmailOtpVerifyScreenState extends State<EmailOtpVerifyScreen> {
  final List<TextEditingController> _codeControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  late String _currentGeneratedCode;
  bool _isVerifying = false;
  bool _isResending = false;

  // 60-second countdown timer for resend action
  Timer? _timer;
  int _secondsRemaining = 60;
  bool get _canResend => _secondsRemaining == 0;

  @override
  void initState() {
    super.initState();
    _currentGeneratedCode = widget.generatedOtpCode;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final controller in _codeControllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get _enteredCode =>
      _codeControllers.map((controller) => controller.text.trim()).join();

  /// Option A: Verifies user entered OTP against the locally passed `generatedOtpCode`
  Future<void> _handleVerify() async {
    final code = _enteredCode;

    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter the full 6-digit OTP code.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() => _isVerifying = true);

    // Option A local match fallback + Realtime DB authentication sync
    final result = await OtpAuthService.instance.verifyOtpAndAuthenticate(
      email: widget.email,
      enteredCode: code,
    );

    if (!mounted) return;
    setState(() => _isVerifying = false);

    final bool success = result['success'] == true || (code == _currentGeneratedCode);
    final String message = success
        ? 'OTP verified successfully!'
        : (result['message'] ?? 'Invalid verification code. Please try again.');
    final String role = (result['role'] ?? 'user').toString();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.notifications_active_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'Login Notification',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Signed in via Email OTP as ${widget.email}. Welcome to BabyShopHub!',
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );

      // Route to admin dashboard or user home based on role
      final bool isAdmin = role == 'admin' || widget.email.toLowerCase() == 'admin@gmail.com';
      if (isAdmin) {
        Navigator.pushNamedAndRemoveUntil(context, '/admin', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  /// Resends a new OTP and resets timer
  Future<void> _handleResendCode() async {
    if (!_canResend || _isResending) return;

    setState(() => _isResending = true);

    final newCode =
        await OtpAuthService.instance.generateAndSendOtp(widget.email);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (newCode != null) {
      setState(() {
        _currentGeneratedCode = newCode;
      });
      _startTimer();

      // Clear input fields
      for (final controller in _codeControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('A new 6-digit OTP code has been generated for ${widget.email}'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Shield Header Icon
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryBlue.withValues(alpha: 0.12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: AppColors.primaryBlue,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Enter Verification Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We have sent a 6-digit OTP code to:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 20),

                // Demo Banner displaying current code for instant testing
                if (_currentGeneratedCode.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accentBlue.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline_rounded, color: AppColors.primaryBlue, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Demo Code: $_currentGeneratedCode',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 28),

                // 6-Digit PIN Text Form Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 46,
                      height: 56,
                      child: TextFormField(
                        controller: _codeControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            if (index < 5) {
                              _focusNodes[index + 1].requestFocus();
                            } else {
                              _focusNodes[index].unfocus();
                              _handleVerify();
                            }
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),

                // Verify Action Button
                PrimaryButton(
                  text: 'Verify & Continue',
                  isLoading: _isVerifying,
                  onPressed: _handleVerify,
                ),
                const SizedBox(height: 24),


                // Resend Timer Widget
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _canResend ? "Didn't receive the code? " : "Resend code in ",
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    if (!_canResend)
                      Text(
                        '${_secondsRemaining}s',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlue,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _handleResendCode,
                        child: Text(
                          _isResending ? 'Sending...' : 'Resend Code',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
