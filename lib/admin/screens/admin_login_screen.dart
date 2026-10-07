import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';
import '../services/admin_auth_service.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_isLoading) return;
    setState(() => _errorMessage = null);

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    final ok = AdminAuthService.instance.login(
      _emailController.text,
      _passwordController.text,
    );

    if (ok) {
      setState(() => _isLoading = false);
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Invalid admin email or password. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const BabyShopHubLogo(iconSize: 56, fontSize: 26),
                    const SizedBox(height: 28),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.softBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.lock_outline_rounded,
                                size: 14, color: AppColors.primaryBlue),
                            SizedBox(width: 6),
                            Text(
                              'Secure admin access',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Admin Portal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryText,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Sign in to manage products, users and orders.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                    ),
                    const SizedBox(height: 28),
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    CustomTextField(
                      label: 'Admin Email',
                      hintText: 'admin@babyshophub.com',
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: 'Password',
                      hintText: 'Enter your password',
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outlined,
                      obscureText: _isPasswordObscured,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: _handleLogin,
                      suffixIcon: IconButton(
                        tooltip: _isPasswordObscured ? 'Show password' : 'Hide password',
                        icon: Icon(
                          _isPasswordObscured
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppColors.secondaryText,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _isPasswordObscured = !_isPasswordObscured),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 28),
                    PrimaryButton(
                      text: 'Login',
                      isLoading: _isLoading,
                      onPressed: _handleLogin,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                        child: const Text(
                          'Back to customer app',
                          style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
