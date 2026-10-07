import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final double totalAmount;
  final String paymentMethod;

  const OrderConfirmationScreen({
    super.key,
    required this.totalAmount,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // SUCCESS ICON ANIMATED BADGE
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 64,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ORDER PLACED HEADING
              const Text(
                'Order Placed Successfully!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for shopping at BabyShopHub. Your order is being prepared with care.',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),

              // ORDER INFORMATION CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInfoRow('Order ID', '#BSH-84920'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    _buildInfoRow('Order Date', '12 Oct 2024'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    _buildInfoRow('Payment Method', paymentMethod),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    _buildInfoRow('Delivery Address', '123 Palm Avenue, Suite 4B, NY'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Divider(height: 1, color: AppColors.border),
                    ),
                    _buildInfoRow(
                      'Total Paid',
                      '\$${totalAmount.toStringAsFixed(2)}',
                      isBold: true,
                      valueColor: AppColors.primaryBlue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ACTION BUTTONS: VIEW ORDERS & CONTINUE SHOPPING
              SizedBox(
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
                    // Navigate back to Home
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.receipt_long_rounded, size: 20),
                  label: const Text(
                    'View Orders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  icon: const Icon(Icons.shopping_bag_outlined, size: 20),
                  label: const Text(
                    'Continue Shopping',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: isBold ? 15 : 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? AppColors.primaryText,
            ),
          ),
        ),
      ],
    );
  }
}
