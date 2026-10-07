import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../services/admin_user_service.dart';
import '../widgets/admin_widgets.dart';
import 'admin_order_details_screen.dart';

class AdminUserDetailsScreen extends StatelessWidget {
  final String userId;

  const AdminUserDetailsScreen({super.key, required this.userId});

  Future<void> _toggleStatus(BuildContext context, AdminUser user) async {
    final service = AdminUserService.instance;
    final suspending = user.status == AdminUserStatus.active;
    final confirmed = await showAdminConfirm(
      context,
      title: suspending ? 'Suspend account?' : 'Activate account?',
      message: suspending
          ? '${user.name} will no longer be able to use their account.'
          : '${user.name} will regain access to their account.',
      confirmLabel: suspending ? 'Suspend' : 'Activate',
      destructive: suspending,
    );
    if (!confirmed || !context.mounted) return;
    service.setStatus(
      user.id,
      suspending ? AdminUserStatus.suspended : AdminUserStatus.active,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(suspending ? 'Account suspended' : 'Account activated'),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final service = AdminUserService.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('User Details')),
      body: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            service.usersNotifier,
            OrderService.instance.ordersNotifier,
          ]),
          builder: (context, _) {
            final user = service.byId(userId);
            if (user == null) {
              return const AdminEmptyState(
                icon: Icons.person_off_outlined,
                title: 'User not found',
                message: 'This account may no longer exist.',
              );
            }
            final active = user.status == AdminUserStatus.active;
            final orders = service.ordersFor(user);

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    AdminCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 34,
                            backgroundColor: AppColors.softBlue,
                            child: Text(
                              initialsOf(user.name),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          StatusBadge(
                            label: active ? 'Active' : 'Suspended',
                            color: active ? AppColors.success : AppColors.error,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    AdminCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AdminSectionHeader(title: 'Account Information'),
                          const SizedBox(height: 6),
                          AdminInfoRow(label: 'Full Name', value: user.name),
                          AdminInfoRow(label: 'Email', value: user.email),
                          AdminInfoRow(label: 'Phone', value: user.phone),
                          AdminInfoRow(label: 'Address', value: user.address),
                          AdminInfoRow(label: 'Joined', value: user.joined),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    AdminCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AdminSectionHeader(title: 'Activity'),
                          const SizedBox(height: 6),
                          AdminInfoRow(label: 'Last active', value: user.lastActive),
                          AdminInfoRow(
                            label: 'Orders placed',
                            value: '${service.orderCount(user)}',
                          ),
                          AdminInfoRow(
                            label: 'Total spent',
                            value: formatMoney(service.totalSpent(user)),
                          ),
                          AdminInfoRow(
                            label: 'Open inquiries',
                            value: user.openInquiries == 0
                                ? 'None'
                                : '${user.openInquiries}',
                          ),
                        ],
                      ),
                    ),

                    if (orders.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const AdminSectionHeader(title: 'Recent Orders'),
                      const SizedBox(height: 8),
                      for (final order in orders)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: AdminCard(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AdminOrderDetailsScreen(orderId: order.id),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.id,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        order.date,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.secondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatMoney(order.total),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    StatusBadge(
                                      label: order.status.displayName,
                                      color: orderStatusColor(order.status),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],

                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: active ? AppColors.error : AppColors.success,
                        side: BorderSide(
                          color: active ? AppColors.error : AppColors.success,
                        ),
                      ),
                      onPressed: () => _toggleStatus(context, user),
                      icon: Icon(
                        active ? Icons.block_rounded : Icons.check_circle_outline_rounded,
                        size: 20,
                      ),
                      label: Text(active ? 'Suspend Account' : 'Activate Account'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
