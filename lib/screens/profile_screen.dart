import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'feedback_screen.dart';
import 'help_support_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Sarah Khan';
  String userEmail = 'sarah@example.com';

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.surface,
          titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
          contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
          title: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withValues(alpha: 0.12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Are you sure you want to logout?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
          content: const Text(
            'You will be signed out from your account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondaryText,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.secondaryText,
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _showInfoSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () {
                _showInfoSnackBar('Notifications feature coming soon');
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // User Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar Area
                    Stack(
                      children: [
                        Container(
                          width: 68,
                          height: 68,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accentBlue.withValues(alpha: 0.4),
                                AppColors.secondaryPink.withValues(alpha: 0.4),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: CircleAvatar(
                              radius: 31,
                              backgroundColor: AppColors.surface,
                              child: Icon(
                                Icons.person_rounded,
                                size: 36,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    // User Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            userEmail,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit Quick Icon
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.primaryBlue,
                        size: 20,
                      ),
                      onPressed: () async {
                        final result = await Navigator.pushNamed(context, '/edit-profile');
                        if (result != null && result is Map<String, String>) {
                          setState(() {
                            if (result.containsKey('name')) userName = result['name']!;
                            if (result.containsKey('email')) userEmail = result['email']!;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Small BabyShopHub Branding Strip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    BabyShopHubLogo(
                      iconSize: 20,
                      showText: false,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'BabyShopHub Member Account',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Section Items Card
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                    _buildMenuItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal Information',
                      subtitle: 'Name, email & phone number',
                      onTap: () async {
                        final result = await Navigator.pushNamed(context, '/edit-profile');
                        if (result != null && result is Map<String, String>) {
                          setState(() {
                            if (result.containsKey('name')) userName = result['name']!;
                            if (result.containsKey('email')) userEmail = result['email']!;
                          });
                        }
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.shopping_bag_outlined,
                      title: 'My Orders',
                      subtitle: 'Order history & active tracking',
                      onTap: () {
                        _showInfoSnackBar('Order history feature will be in the Orders module');
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Delivery Addresses',
                      subtitle: 'Manage saved delivery locations',
                      onTap: () {
                        Navigator.pushNamed(context, '/addresses');
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.payment_outlined,
                      title: 'Payment Methods',
                      subtitle: 'Saved cards & payment options',
                      onTap: () {
                        Navigator.pushNamed(context, '/payment-methods');
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'FAQs, contact care & support guide',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HelpSupportScreen(),
                          ),
                        );
                      },
                    ),
                    _buildDivider(),
                    _buildMenuItem(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Feedback',
                      subtitle: 'Share your shopping experience',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FeedbackScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
              const SizedBox(height: 28),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 20),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: _showLogoutDialog,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primaryBlue,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.secondaryText,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: AppColors.secondaryText,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      indent: 64,
      endIndent: 18,
      color: AppColors.border,
    );
  }
}
