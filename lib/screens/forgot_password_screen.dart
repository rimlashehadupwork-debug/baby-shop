import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate network request delay
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmitted = true;
        });
      }
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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _isSubmitted ? _buildConfirmationState() : _buildFormState(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormState() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('forgot_password_form'),
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const BabyShopHubLogo(
            iconSize: 48,
            fontSize: 24,
          ),
          const SizedBox(height: 28),

          // Heading
          Text(
            'Forgot Password',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter your email address below and we will send you instructions to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // Email Field
          CustomTextField(
            label: 'Email Address',
            hintText: 'you@example.com',
            controller: _emailController,
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onEditingComplete: _handleResetPassword,
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

          // Reset Password Button
          PrimaryButton(
            text: 'Reset Password',
            isLoading: _isLoading,
            onPressed: _handleResetPassword,
          ),
          const SizedBox(height: 20),

          // Back to Login Link
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 18, color: AppColors.secondaryText),
              label: const Text(
                'Back to Login',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationState() {
    return Container(
      key: const ValueKey('forgot_password_confirmation'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success Icon Badge
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.12),
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),

          // Confirmation Heading
          const Text(
            'Password Reset Link Sent!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 12),

          // Explanation Message
          Text(
            'We have submitted your password reset request. Please check your email inbox at:',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Email display chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              _emailController.text,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'Follow the instructions in the email to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 28),

          // Back to Login Button
          PrimaryButton(
            text: 'Back to Login',
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
