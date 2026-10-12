import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../services/delivery_info.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import 'feedback_screen.dart';
import 'help_support_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _info = DeliveryInfo.instance;

  @override
  void initState() {
    super.initState();
    _info.load();
  }

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  String get _email => FirebaseAuth.instance.currentUser?.email ?? 'Guest account';

  Future<void> _navigateToEditProfile() async {
    final result = await Navigator.pushNamed(context, '/edit-profile');
    if (result == true) {
      await _info.load();
    }
  }

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
                    onPressed: () => Navigator.of(dialogContext).pop(),
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
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      Navigator.of(dialogContext).pop();
                      await FirebaseAuth.instance.signOut();
                      navigator.pushNamedAndRemoveUntil('/login', (route) => false);
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

  @override
  Widget build(BuildContext context) {
    final uid = _currentUid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
              onPressed: () => Navigator.pushNamed(context, '/notifications'),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // User Profile Header Card fetching dynamically from users/{uid}
              if (uid.isNotEmpty)
                StreamBuilder<DatabaseEvent>(
                  stream: FirebaseDatabase.instance.ref('users/$uid').onValue,
                  builder: (context, snapshot) {
                    String name = _info.name;
                    String phone = _info.phone;
                    String profilePicture = _info.profilePicture;
                    String email = _email;

                    if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
                      final val = snapshot.data!.snapshot.value;
                      if (val is Map) {
                        final data = Map<String, dynamic>.from(val);
                        final dbName = (data['name'] ?? '').toString();
                        final dbPhone = (data['phone'] ?? '').toString();
                        final dbPic = (data['profilePicture'] ?? data['photoUrl'] ?? '').toString();
                        final dbEmail = (data['email'] ?? '').toString();

                        if (dbName.isNotEmpty) name = dbName;
                        if (dbPhone.isNotEmpty) phone = dbPhone;
                        if (dbPic.isNotEmpty) profilePicture = dbPic;
                        if (dbEmail.isNotEmpty) email = dbEmail;
                      }
                    }

                    if (name.isEmpty) {
                      name = FirebaseAuth.instance.currentUser?.displayName ?? 'Guest User';
                    }

                    return _buildProfileHeaderCard(
                      name: name,
                      email: email,
                      phone: phone,
                      profilePicture: profilePicture,
                    );
                  },
                )
              else
                ListenableBuilder(
                  listenable: _info,
                  builder: (context, _) {
                    return _buildProfileHeaderCard(
                      name: _info.name.isEmpty ? 'Guest User' : _info.name,
                      email: _email,
                      phone: _info.phone,
                      profilePicture: _info.profilePicture,
                    );
                  },
                ),

              const SizedBox(height: 24),

              // Member Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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

              // Menu Options Container
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
                        subtitle: 'Name, email, phone & profile picture',
                        onTap: _navigateToEditProfile,
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.shopping_bag_outlined,
                        title: 'My Orders',
                        subtitle: 'Order history & active tracking',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OrderHistoryScreen(),
                            ),
                          );
                        },
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.location_on_outlined,
                        title: 'Delivery Address',
                        subtitle: 'Manage your delivery location',
                        onTap: () => Navigator.pushNamed(context, '/addresses'),
                      ),
                      _buildDivider(),
                      _buildMenuItem(
                        icon: Icons.payment_outlined,
                        title: 'Payment Methods',
                        subtitle: 'Saved cards & payment options',
                        onTap: () => Navigator.pushNamed(context, '/payment-methods'),
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

  Widget _buildProfileHeaderCard({
    required String name,
    required String email,
    required String phone,
    required String profilePicture,
  }) {
    final hasValidPicture = profilePicture.trim().isNotEmpty &&
        (profilePicture.trim().startsWith('http://') || profilePicture.trim().startsWith('https://'));

    return Container(
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
          // Profile Picture Avatar Frame
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.accentBlue.withValues(alpha: 0.5),
                  AppColors.secondaryPink.withValues(alpha: 0.5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: ClipOval(
                child: hasValidPicture
                    ? Image.network(
                        profilePicture.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildFallbackAvatar(),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      )
                    : _buildFallbackAvatar(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // User Information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.secondaryText,
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Edit Button Icon
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.primaryBlue,
              size: 22,
            ),
            onPressed: _navigateToEditProfile,
            tooltip: 'Edit Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.person_rounded,
          size: 38,
          color: AppColors.primaryBlue,
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
