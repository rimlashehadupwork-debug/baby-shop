import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../theme/app_theme.dart';
import 'order_details_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  final bool showAppBar;

  const OrderHistoryScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final orderService = OrderService.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              title: const Text(
                'My Orders',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: ValueListenableBuilder<List<OrderModel>>(
        valueListenable: orderService.ordersNotifier,
        builder: (context, orders, child) {
          if (orders.isEmpty) {
            return SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          size: 56,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No Orders Placed Yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'When you purchase baby products, your order status and delivery history will appear here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.secondaryText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderDetailsScreen(order: order),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Order ID & Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.id,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                _buildStatusBadge(order.status),
                              ],
                            ),
                            const SizedBox(height: 6),

                            // Order Date
                            Text(
                              order.date,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12.0),
                              child: Divider(height: 1, color: AppColors.border),
                            ),

                            // Purchased Items Thumbnails & Names
                            Row(
                              children: [
                                // Item Image Thumbnails Row
                                SizedBox(
                                  height: 48,
                                  child: Row(
                                    children: order.items.take(3).map((item) {
                                      return Container(
                                        width: 48,
                                        height: 48,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.border),
                                          color: AppColors.inputBackground,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(9),
                                          child: Image.network(
                                            item.product.imageUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.child_care_rounded,
                                                color: AppColors.primaryBlue,
                                                size: 24,
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                if (order.items.length > 3)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.inputBackground,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '+${order.items.length - 3} more',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ),

                                const Spacer(),

                                // Total Price & View Details
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text(
                                      'Order Total',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                    Text(
                                      '\$${order.total.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryBlue,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.secondaryText,
                                  size: 20,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg = AppColors.primaryBlue.withValues(alpha: 0.12);
    Color text = AppColors.primaryBlue;

    if (status == OrderStatus.delivered) {
      bg = AppColors.success.withValues(alpha: 0.12);
      text = AppColors.success;
    } else if (status == OrderStatus.outForDelivery) {
      bg = AppColors.warning.withValues(alpha: 0.15);
      text = AppColors.warning;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: text,
        ),
      ),
    );
  }
}
