import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../../models/category_model.dart';
import '../../models/order_model.dart';
import '../../services/category_service.dart';
import '../../services/delivery_info.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../theme/app_theme.dart';
import '../services/admin_auth_service.dart';
import '../widgets/admin_widgets.dart';
import 'admin_order_details_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final ValueChanged<int> onNavigate;

  const AdminDashboardScreen({super.key, required this.onNavigate});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const int _lowStockThreshold = 10;

  late final Stream<List<ProductMap>> _productsStream;
  late final Stream<DatabaseEvent> _usersStream;

  @override
  void initState() {
    super.initState();
    _productsStream = ProductService.instance.watchProducts().asBroadcastStream();
    _usersStream = FirebaseDatabase.instance.ref('users').onValue;
    DeliveryInfo.instance.load();
  }

  List<Map<String, dynamic>> _parseUsers(Object? raw) {
    final list = <Map<String, dynamic>>[];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is Map) {
          final m = value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
          m['id'] = key.toString();
          list.add(m);
        }
      });
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductMap>>(
      stream: _productsStream,
      builder: (context, productSnap) {
        return StreamBuilder<DatabaseEvent>(
          stream: _usersStream,
          builder: (context, userSnap) {
            return ValueListenableBuilder<List<OrderModel>>(
              valueListenable: OrderService.instance.ordersNotifier,
              builder: (context, orders, _) {
                return ValueListenableBuilder<List<CategoryModel>>(
                  valueListenable: CategoryService.instance.notifier,
                  builder: (context, categories, _) {
                    return _buildBody(
                      context,
                      products: productSnap.data ?? const <ProductMap>[],
                      productsLoading: !productSnap.hasData,
                      users: _parseUsers(userSnap.data?.snapshot.value),
                      usersLoading: !userSnap.hasData,
                      orders: orders,
                      categories: categories,
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context, {
        required List<ProductMap> products,
        required bool productsLoading,
        required List<Map<String, dynamic>> users,
        required bool usersLoading,
        required List<OrderModel> orders,
        required List<CategoryModel> categories,
      }) {
    final customers =
    users.where((u) => (u['role'] ?? 'user').toString() != 'admin').toList();
    final suspended = customers
        .where((u) => (u['status'] ?? 'active').toString() == 'suspended')
        .length;

    final pending = orders.where((o) => o.status != OrderStatus.delivered).length;
    final revenue = orders.fold<double>(0, (sum, o) => sum + o.total);
    final average = orders.isEmpty ? 0.0 : revenue / orders.length;
    final recent = orders.take(5).toList();

    final outOfStock = products.where((p) => p.stock <= 0).toList();
    final lowStock = products
        .where((p) => p.stock > 0 && p.stock <= _lowStockThreshold)
        .toList();
    final attention = [...outOfStock, ...lowStock]
      ..sort((a, b) => a.stock.compareTo(b.stock));

    final soldQty = <String, int>{};
    final soldItem = <String, _SoldProduct>{};
    for (final order in orders) {
      for (final item in order.items) {
        final key = item.product.id.isNotEmpty ? item.product.id : item.product.name;
        soldQty[key] = (soldQty[key] ?? 0) + item.quantity;
        soldItem[key] = _SoldProduct(
          name: item.product.name,
          imageUrl: item.product.imageUrl,
        );
      }
    }
    final topKeys = soldQty.keys.toList()
      ..sort((a, b) => soldQty[b]!.compareTo(soldQty[a]!));

    String v(bool loading, String value) => loading ? '…' : value;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        ListenableBuilder(
          listenable: DeliveryInfo.instance,
          builder: (context, _) => Text(
            'Welcome back, ${AdminAuthService.instance.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
              letterSpacing: -0.4,
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Live overview of your store.',
          style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final columns = constraints.maxWidth >= 640 ? 3 : 2;
            final cardWidth =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            final cards = [
              _SummaryCard(
                icon: Icons.payments_rounded,
                color: AppColors.success,
                value: formatMoney(revenue),
                label: 'Total Revenue',
                caption: 'Avg ${formatMoney(average)} / order',
                onTap: () => widget.onNavigate(3),
              ),
              _SummaryCard(
                icon: Icons.receipt_long_rounded,
                color: AppColors.primaryBlue,
                value: '${orders.length}',
                label: 'Total Orders',
                caption: 'All time',
                onTap: () => widget.onNavigate(3),
              ),
              _SummaryCard(
                icon: Icons.pending_actions_rounded,
                color: AppColors.warning,
                value: '$pending',
                label: 'Pending Orders',
                caption: 'Not yet delivered',
                onTap: () => widget.onNavigate(3),
              ),
              _SummaryCard(
                icon: Icons.inventory_2_rounded,
                color: const Color(0xFF2BA3C7),
                value: v(productsLoading, '${products.length}'),
                label: 'Total Products',
                caption: 'In your catalog',
                onTap: () => widget.onNavigate(1),
              ),
              _SummaryCard(
                icon: Icons.people_rounded,
                color: AppColors.primaryBlue,
                value: v(usersLoading, '${customers.length}'),
                label: 'Total Users',
                caption: suspended > 0 ? '$suspended suspended' : 'Registered customers',
                onTap: () => widget.onNavigate(2),
              ),
              _SummaryCard(
                icon: Icons.warning_amber_rounded,
                color: attention.isEmpty ? AppColors.success : AppColors.error,
                value: v(productsLoading, '${attention.length}'),
                label: 'Stock Alerts',
                caption: '${outOfStock.length} out  •  ${lowStock.length} low',
                onTap: () => widget.onNavigate(1),
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
        const AdminSectionHeader(title: 'Orders by Status'),
        const SizedBox(height: 8),
        AdminCard(
          child: Column(
            children: [
              for (final status in OrderStatus.values)
                _statusRow(
                  status,
                  orders.where((o) => o.status == status).length,
                  orders.length,
                ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        AdminSectionHeader(
          title: 'Recent Orders',
          actionLabel: 'View All',
          onAction: () => widget.onNavigate(3),
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
              child: _orderTile(context, order),
            ),
        const SizedBox(height: 18),
        AdminSectionHeader(
          title: 'Stock Alerts',
          actionLabel: 'Manage',
          onAction: () => widget.onNavigate(1),
        ),
        const SizedBox(height: 8),
        if (attention.isEmpty)
          AdminCard(
            child: Row(
              children: [
                const Icon(Icons.check_circle_outline_rounded,
                    color: AppColors.success),
                const SizedBox(width: 12),
                Text(
                  productsLoading
                      ? 'Loading inventory…'
                      : 'All products are well stocked',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
          )
        else
          for (final p in attention.take(5))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AdminCard(
                onTap: () => widget.onNavigate(1),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    AdminThumb(url: p.imageUrl, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
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
                            p.categoryName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: p.stock <= 0 ? 'Out of stock' : '${p.stock} left',
                      color: p.stock <= 0 ? AppColors.error : AppColors.warning,
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 18),
        const AdminSectionHeader(title: 'Top Selling Products'),
        const SizedBox(height: 8),
        if (topKeys.isEmpty)
          const AdminCard(
            child: Text(
              'Sales data will appear after the first order.',
              style: TextStyle(fontSize: 13, color: AppColors.secondaryText),
            ),
          )
        else
          AdminCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              children: [
                for (var i = 0; i < topKeys.take(5).length; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 22,
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ),
                        AdminThumb(url: soldItem[topKeys[i]]!.imageUrl, size: 40),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            soldItem[topKeys[i]]!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ),
                        Text(
                          '${soldQty[topKeys[i]]} sold',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        const AdminSectionHeader(title: 'Products by Category'),
        const SizedBox(height: 8),
        AdminCard(
          child: Column(
            children: [
              for (final c in categories)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: c.badgeColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(c.icon, size: 18, color: c.badgeColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          c.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      Text(
                        '${ProductService.countInCategory(products, c.name)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statusRow(OrderStatus status, int count, int total) {
    final color = orderStatusColor(status);
    final share = total == 0 ? 0.0 : count / total;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            child: Text(
              status.displayName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: share,
                minHeight: 8,
                backgroundColor: AppColors.border,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 28,
            child: Text(
              '$count',
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderTile(BuildContext context, OrderModel order) {
    return AdminCard(
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
    );
  }
}

class _SoldProduct {
  final String name;
  final String imageUrl;

  const _SoldProduct({required this.name, required this.imageUrl});
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
                fontSize: 28,
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