import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../theme/app_theme.dart';
import 'order_tracking_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final OrderModel order;

  const OrderDetailsScreen({
    super.key,
    required this.order,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Order ${order.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CURRENT STATUS HEADER CARD
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.local_shipping_rounded,
                              color: AppColors.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Status',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order.status.displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Estimated Delivery: ${order.estimatedDelivery}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              minimumSize: const Size(90, 36),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderTrackingScreen(order: order),
                                ),
                              );
                            },
                            child: const Text(
                              'Track',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PURCHASED ITEMS
                    const Text(
                      'Purchased Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: order.items.map((item) {
                          final product = item.product;
                          return Padding(
                            padding: const EdgeInsets.all(14.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    color: AppColors.inputBackground,
                                    child: Image.network(
                                      product.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                          child: const Icon(
                                            Icons.child_care_rounded,
                                            color: AppColors.primaryBlue,
                                            size: 24,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryText,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Qty: ${item.quantity} x \$${product.price.toStringAsFixed(2)}',
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
                                  '\$${item.totalPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // DELIVERY INFORMATION
                    const Text(
                      'Delivery Information',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Recipient', order.recipientName),
                          const SizedBox(height: 8),
                          _buildDetailRow('Phone Number', order.phone),
                          const SizedBox(height: 8),
                          _buildDetailRow('Address', order.deliveryAddress),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PAYMENT & TOTAL SUMMARY
                    const Text(
                      'Payment Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('Subtotal', '\$${order.subtotal.toStringAsFixed(2)}'),
                          const SizedBox(height: 8),
                          _buildSummaryRow(
                            'Delivery Fee',
                            order.deliveryFee == 0 ? 'FREE' : '\$${order.deliveryFee.toStringAsFixed(2)}',
                          ),
                          const SizedBox(height: 8),
                          _buildSummaryRow('Payment Method', order.paymentMethod),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Divider(height: 1, color: AppColors.border),
                          ),
                          _buildSummaryRow(
                            'Total Amount',
                            '\$${order.total.toStringAsFixed(2)}',
                            isBold: true,
                            valueColor: AppColors.primaryBlue,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Track Delivery Button
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderTrackingScreen(order: order),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map_outlined, size: 20),
                  label: const Text(
                    'Track Delivery Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 15 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? AppColors.primaryText : AppColors.secondaryText,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: valueColor ?? AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
