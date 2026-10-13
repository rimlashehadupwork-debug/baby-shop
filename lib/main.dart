import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_placeholder_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/edit_profile_screen.dart';
import 'screens/delivery_addresses_screen.dart';
import 'screens/add_edit_address_screen.dart';
import 'screens/payment_methods_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/user_notifications_screen.dart';
import 'screens/email_otp_request_screen.dart';
import 'screens/verify_email_screen.dart';
import 'widgets/auth_wrapper.dart';

import 'admin/screens/admin_shell.dart';
import 'firebase_options.dart';

void main() async {
  // Sabse pehle bindings
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase (databaseURL firebase_options.dart se aayega)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Supabase
  await Supabase.initialize(
    url: 'https://kaavtwqgyvipayvjyttu.supabase.co',
    anonKey: 'sb_publishable_s0uKcNfdZQG_1vqhn6uFpQ_2G59uO56',
  );

  runApp(const BabyShopHubApp());
}

class BabyShopHubApp extends StatelessWidget {
  const BabyShopHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BabyShopHub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        '/auth': (context) => const AuthWrapper(),
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/verify-email': (context) => const VerifyEmailScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomePlaceholderScreen(),
        '/cart': (context) => const CartScreen(),
        '/checkout': (context) => const CheckoutScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/edit-profile': (context) => const EditProfileScreen(),
        '/addresses': (context) => const DeliveryAddressesScreen(),
        '/add-edit-address': (context) => const AddEditAddressScreen(),
        '/payment-methods': (context) => const PaymentMethodsScreen(),
        '/help-support': (context) => const HelpSupportScreen(),
        '/feedback': (context) => const FeedbackScreen(),
        '/notifications': (context) => const UserNotificationsScreen(),
        '/otp-request': (context) => const EmailOtpRequestScreen(),

        // Admin panel routes
        '/admin': (context) => const AdminShell(),
      },
    );
  }
}
