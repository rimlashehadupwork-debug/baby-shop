import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../widgets/admin_widgets.dart';
import 'admin_order_details_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  OrderStatus? _filter; // null = all orders

  @override
  Widget build(BuildContext context) {
    return AdminLoader(
      load: adminSimulatedLoad,
      skeletonHeight: 130,
      builder: (context) => ValueListenableBuilder<List<OrderModel>>(
        valueListenable: OrderService.instance.ordersNotifier,
        builder: (context, all, _) {
          final orders =
              _filter == null ? all : all.where((o) => o.status == _filter).toList();

          return Column(
            children: [
              SizedBox(
                height: 62,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                  children: [
                    _chip('All', null),
                    for (final s in OrderStatus.values) _chip(s.displayName, s),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${orders.length} ${orders.length == 1 ? 'order' : 'orders'}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: orders.isEmpty
                    ? AdminEmptyState(
                        icon: Icons.receipt_long_outlined,
                        title: all.isEmpty ? 'No orders yet' : 'No orders in this status',
                        message: all.isEmpty
                            ? 'Customer orders will appear here once they are placed.'
                            : 'Choose another status to see more orders.',
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: orders.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) => _buildItem(orders[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chip(String label, OrderStatus? value) {
    final selected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        selectedColor: AppColors.primaryBlue,
        backgroundColor: AppColors.surface,
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected ? Colors.white : AppColors.primaryText,
        ),
        onSelected: (_) => setState(() => _filter = value),
      ),
    );
  }

  Widget _buildItem(OrderModel order) {
    final itemCount = order.items.fold<int>(0, (sum, i) => sum + i.quantity);

    return AdminCard(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AdminOrderDetailsScreen(orderId: order.id),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.id,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(
                label: order.status.displayName,
                color: orderStatusColor(order.status),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 16, color: AppColors.secondaryText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  order.recipientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.shopping_bag_outlined,
                  size: 16, color: AppColors.secondaryText),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
                  style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                ),
              ),
            ],
          ),
          const Divider(height: 22),
          Row(
            children: [
              Expanded(
                child: Text(
                  order.date,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatMoney(order.total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
