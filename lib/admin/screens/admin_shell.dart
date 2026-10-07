import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../services/admin_auth_service.dart';
import '../widgets/admin_widgets.dart';
import 'admin_dashboard_screen.dart';
import 'admin_orders_screen.dart';
import 'admin_products_screen.dart';
import 'admin_users_screen.dart';

/// Admin Panel container: header, profile/logout menu and admin navigation.
/// Completely separate from the customer bottom navigation.
class AdminShell extends StatefulWidget {
  const AdminShell({super.key});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  static const List<String> _titles = [
    'Admin Dashboard',
    'Product Management',
    'User Management',
    'Order Management',
  ];

  @override
  void initState() {
    super.initState();
    // Simple guard: direct visits without logging in go back to Admin Login.
    if (!AdminAuthService.instance.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/admin-login');
        }
      });
    }
  }

  Future<void> _logout() async {
    final confirmed = await showAdminConfirm(
      context,
      title: 'Log out?',
      message: 'You will be signed out of the Admin Portal.',
      confirmLabel: 'Log Out',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    AdminAuthService.instance.logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/admin-login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      AdminDashboardScreen(onNavigate: (i) => setState(() => _index = i)),
      const AdminProductsScreen(),
      const AdminUsersScreen(),
      const AdminOrdersScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 68,
        centerTitle: false,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            const BabyShopHubLogo(iconSize: 22, showText: false),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'BabyShopHub Admin',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                      letterSpacing: 0.2,
                    ),
                  ),
                  Text(
                    _titles[_index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Admin account',
            offset: const Offset(0, 48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (value) {
              if (value == 'logout') _logout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AdminAuthService.adminName,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Text(
                      AdminAuthService.adminEmail,
                      style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, size: 20, color: AppColors.error),
                    SizedBox(width: 10),
                    Text('Log out', style: TextStyle(color: AppColors.error)),
                  ],
                ),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: CircleAvatar(
                radius: 19,
                backgroundColor: AppColors.softBlue,
                child: Text(
                  initialsOf(AdminAuthService.adminName),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: IndexedStack(
            index: _index,
            sizing: StackFit.expand,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryText.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2_rounded),
                label: 'Products',
              ),
              NavigationDestination(
                icon: Icon(Icons.people_outline_rounded),
                selectedIcon: Icon(Icons.people_rounded),
                label: 'Users',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Orders',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
