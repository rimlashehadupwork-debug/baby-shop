import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordObscured = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 1000));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success snackbar and navigate back to Login screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(child: Text('Account created successfully! Please login.')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );

        Navigator.pushReplacementNamed(context, '/login');
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
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo at top
                  const BabyShopHubLogo(
                    iconSize: 48,
                    fontSize: 24,
                  ),
                  const SizedBox(height: 28),

                  // Heading
                  Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join us and start shopping for your little one',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Full Name Field
                  CustomTextField(
                    label: 'Full Name',
                    hintText: 'Enter your full name',
                    controller: _fullNameController,
                    prefixIcon: Icons.person_outlined,
                    keyboardType: TextInputType.name,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Full name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Please enter a valid name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Email Address Field
                  CustomTextField(
                    label: 'Email Address',
                    hintText: 'you@example.com',
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

                  // Password Field
                  CustomTextField(
                    label: 'Password',
                    hintText: 'Create a password',
                    controller: _passwordController,
                    prefixIcon: Icons.lock_outlined,
                    obscureText: _isPasswordObscured,
                    textInputAction: TextInputAction.done,
                    onEditingComplete: _handleRegister,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppColors.secondaryText,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordObscured = !_isPasswordObscured;
                        });
                      },
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

                  // Create Account Button
                  PrimaryButton(
                    text: 'Create Account',
                    isLoading: _isLoading,
                    backgroundColor: AppColors.secondaryPink,
                    onPressed: _handleRegister,
                  ),
                  const SizedBox(height: 24),

                  // Already have an account? Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        child: const Text(
                          'Login',
                          style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
