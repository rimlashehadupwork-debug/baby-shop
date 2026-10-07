import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../services/admin_product_service.dart';
import '../services/admin_user_service.dart';
import '../widgets/admin_widgets.dart';
import 'admin_order_details_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  /// Switches the admin navigation tab (0 Dashboard, 1 Products, 2 Users, 3 Orders).
  final ValueChanged<int> onNavigate;

  const AdminDashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService.instance;
    final productService = AdminProductService.instance;
    final userService = AdminUserService.instance;

    return AnimatedBuilder(
      animation: Listenable.merge([
        orderService.ordersNotifier,
        productService.productsNotifier,
        userService.usersNotifier,
      ]),
      builder: (context, _) {
        final orders = orderService.orders;
        final pending = orders.where((o) => o.status != OrderStatus.delivered).length;
        final recent = orders.take(3).toList();
        final lowStock = productService.lowStockCount;
        final outOfStock = productService.outOfStockCount;

        return ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            const Text(
              'Welcome back, Admin',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Here is an overview of your store.',
              style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
            ),
            const SizedBox(height: 20),

            // Summary cards
            LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final columns = constraints.maxWidth >= 640 ? 4 : 2;
                final cardWidth =
                    (constraints.maxWidth - spacing * (columns - 1)) / columns;
                final cards = [
                  _SummaryCard(
                    icon: Icons.people_rounded,
                    color: AppColors.primaryBlue,
                    value: '${userService.users.length}',
                    label: 'Total Users',
                    caption: 'Registered customers',
                    onTap: () => onNavigate(2),
                  ),
                  _SummaryCard(
                    icon: Icons.inventory_2_rounded,
                    color: const Color(0xFF2BA3C7),
                    value: '${productService.products.length}',
                    label: 'Total Products',
                    caption: 'In your catalog',
                    onTap: () => onNavigate(1),
                  ),
                  _SummaryCard(
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.success,
                    value: '${orders.length}',
                    label: 'Total Orders',
                    caption: 'All time',
                    onTap: () => onNavigate(3),
                  ),
                  _SummaryCard(
                    icon: Icons.pending_actions_rounded,
                    color: AppColors.warning,
                    value: '$pending',
                    label: 'Pending Orders',
                    caption: 'Not yet delivered',
                    onTap: () => onNavigate(3),
                  ),
                ];
                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: [
                    for (final card in cards) SizedBox(width: cardWidth, child: card),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Recent orders
            AdminSectionHeader(
              title: 'Recent Orders',
              actionLabel: 'View All',
              onAction: () => onNavigate(3),
            ),
            const SizedBox(height: 8),
            if (recent.isEmpty)
              const AdminCard(
                child: Text(
                  'No orders yet. New orders will appear here.',
                  style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
                ),
              )
            else
              for (final order in recent)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AdminCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminOrderDetailsScreen(orderId: order.id),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: AppColors.softBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.receipt_long_rounded,
                              size: 20, color: AppColors.primaryBlue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.id,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.recipientName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
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
            const SizedBox(height: 18),

            // Inventory alert
            const AdminSectionHeader(title: 'Inventory'),
            const SizedBox(height: 8),
            AdminCard(
              onTap: () => onNavigate(1),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: ((lowStock + outOfStock) > 0
                              ? AppColors.warning
                              : AppColors.success)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      (lowStock + outOfStock) > 0
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline_rounded,
                      size: 22,
                      color: (lowStock + outOfStock) > 0
                          ? AppColors.warning
                          : AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (lowStock + outOfStock) > 0
                              ? 'Stock needs attention'
                              : 'All products are well stocked',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        if ((lowStock + outOfStock) > 0) ...[
                          const SizedBox(height: 2),
                          Text(
                            '$lowStock low stock  •  $outOfStock out of stock',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.secondaryText),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  final String caption;
  final VoidCallback onTap;

  const _SummaryCard({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.caption,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AdminCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 16),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
                letterSpacing: -0.5,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.5, color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
