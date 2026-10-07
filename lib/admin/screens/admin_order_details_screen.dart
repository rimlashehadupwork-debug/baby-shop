import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../widgets/admin_widgets.dart';

class AdminOrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const AdminOrderDetailsScreen({super.key, required this.orderId});

  Future<void> _changeStatus(BuildContext context, OrderModel order) async {
    OrderStatus selected = order.status;

    final result = await showModalBottomSheet<OrderStatus>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Update Order Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.id,
                  style: const TextStyle(fontSize: 13, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 12),
                for (final status in OrderStatus.values)
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    onTap: () => setSheetState(() => selected = status),
                    leading: Icon(
                      selected == status
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: selected == status
                          ? AppColors.primaryBlue
                          : AppColors.secondaryText,
                    ),
                    title: Text(
                      status.displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            selected == status ? FontWeight.w700 : FontWeight.w500,
                        color: AppColors.primaryText,
                      ),
                    ),
                    trailing: status == order.status
                        ? const Text(
                            'Current',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.secondaryText,
                            ),
                          )
                        : null,
                  ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Update Status',
                  onPressed: () => Navigator.pop(sheetContext, selected),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (result == null || result == order.status || !context.mounted) return;

    OrderService.instance.updateOrderStatus(order.id, result);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('${order.id} marked as ${result.displayName}')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Order Details')),
      body: SafeArea(
        child: ValueListenableBuilder<List<OrderModel>>(
          valueListenable: OrderService.instance.ordersNotifier,
          builder: (context, orders, _) {
            OrderModel? order;
            for (final o in orders) {
              if (o.id == orderId) order = o;
            }
            if (order == null) {
              return const AdminEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'Order not found',
                message: 'This order may no longer exist.',
              );
            }
            final current = order;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Summary + status
                    AdminCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  current.id,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                              ),
                              StatusBadge(
                                label: current.status.displayName,
                                color: orderStatusColor(current.status),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            current.date,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 14),
                          OutlinedButton.icon(
                            onPressed: () => _changeStatus(context, current),
                            icon: const Icon(Icons.sync_alt_rounded, size: 18),
                            label: const Text('Update Status'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Customer
                    AdminCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AdminSectionHeader(title: 'Customer'),
                          const SizedBox(height: 6),
                          AdminInfoRow(label: 'Name', value: current.recipientName),
                          AdminInfoRow(label: 'Phone', value: current.phone),
                          AdminInfoRow(label: 'Payment', value: current.paymentMethod),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Items
                    AdminCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AdminSectionHeader(title: 'Ordered Products'),
                          const SizedBox(height: 10),
                          for (final item in current.items)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: Row(
                                children: [
                                  AdminThumb(url: item.product.imageUrl, size: 52),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.product.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryText,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          'Qty ${item.quantity}  ×  ${formatMoney(item.product.price)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    formatMoney(item.totalPrice),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const Divider(height: 20),
                          _totalRow('Subtotal', formatMoney(current.subtotal)),
                          _totalRow(
                            'Delivery',
                            current.deliveryFee == 0
                                ? 'Free'
                                : formatMoney(current.deliveryFee),
                          ),
                          const SizedBox(height: 4),
                          _totalRow('Total', formatMoney(current.total), bold: true),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Delivery
                    AdminCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AdminSectionHeader(title: 'Delivery Information'),
                          const SizedBox(height: 6),
                          AdminInfoRow(label: 'Address', value: current.deliveryAddress),
                          AdminInfoRow(
                            label: 'Estimated',
                            value: current.estimatedDelivery,
                          ),
                          AdminInfoRow(
                            label: 'Status',
                            value: current.status.displayName,
                          ),
                        ],
                      ),
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

  Widget _totalRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: bold ? 15 : 13.5,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
              color: bold ? AppColors.primaryText : AppColors.secondaryText,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: bold ? 17 : 13.5,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}
