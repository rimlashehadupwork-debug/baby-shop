import 'package:flutter/material.dart';
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
import 'admin/screens/admin_login_screen.dart';
import 'admin/screens/admin_shell.dart';

void main() {
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
      initialRoute: '/admin-login', 
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
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

        // Admin panel routes
        '/admin-login': (context) => const AdminLoginScreen(),
        '/admin': (context) => const AdminShell(),
      },
    );
  }
}
