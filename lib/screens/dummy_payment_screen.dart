import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../theme/app_theme.dart';
import 'order_confirmation_screen.dart';

class DummyPaymentScreen extends StatefulWidget {
  final double totalAmount;

  const DummyPaymentScreen({
    super.key,
    required this.totalAmount,
  });

  @override
  State<DummyPaymentScreen> createState() => _DummyPaymentScreenState();
}

class _DummyPaymentScreenState extends State<DummyPaymentScreen> {
  String _selectedMethod = 'card'; // 'card', 'cod', 'wallet'
  bool _isProcessing = false;

  void _processDummyPayment() {
    setState(() {
      _isProcessing = true;
    });

    // Simulate 1.5 seconds dummy payment processing
    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final total = widget.totalAmount;
      final cartItems = List<CartItemModel>.from(CartService.instance.items);

      final newOrder = OrderModel(
        id: '#BSH-${10000 + (DateTime.now().millisecondsSinceEpoch % 89999)}',
        date: 'Just now',
        status: OrderStatus.placed,
        items: cartItems,
        subtotal: CartService.instance.subtotal,
        deliveryFee: CartService.instance.deliveryFee,
        total: total,
        recipientName: 'Sarah Khan',
        phone: '+1 (555) 234-5678',
        deliveryAddress: '123 Palm Avenue, Suite 4B, New York, NY 10001',
        paymentMethod: _selectedMethod == 'card'
            ? 'Demo Credit Card (Visa **** 4242)'
            : (_selectedMethod == 'cod' ? 'Cash on Delivery' : 'Demo Mobile Wallet'),
        estimatedDelivery: 'Estimated in 2-3 Days',
      );

      // Add order to order history and clear cart
      OrderService.instance.addOrder(newOrder);
      CartService.instance.clearCart();

      // Navigate to Order Confirmation
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(
            totalAmount: total,
            paymentMethod: newOrder.paymentMethod,
          ),
        ),
        (route) => route.isFirst,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Demo Payment',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                    // Amount Banner
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Amount to Pay',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${widget.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment Method Options
                    const Text(
                      'Select Demo Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Card Option
                    _buildPaymentOption(
                      id: 'card',
                      title: 'Demo Credit / Debit Card',
                      subtitle: 'Visa, Mastercard or Express (Simulation)',
                      icon: Icons.credit_card_rounded,
                    ),
                    const SizedBox(height: 10),

                    // Cash on Delivery Option
                    _buildPaymentOption(
                      id: 'cod',
                      title: 'Cash on Delivery',
                      subtitle: 'Pay with cash upon delivery',
                      icon: Icons.payments_outlined,
                    ),
                    const SizedBox(height: 10),

                    // Mobile Wallet Option
                    _buildPaymentOption(
                      id: 'wallet',
                      title: 'Demo Mobile Wallet',
                      subtitle: 'Instant digital wallet payment',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 24),

                    // Prefilled Demo Card Form if 'card' selected
                    if (_selectedMethod == 'card') ...[
                      const Text(
                        'Demo Card Details',
                        style: TextStyle(
                          fontSize: 15,
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
                            TextFormField(
                              initialValue: '4242 4242 4242 4242',
                              readOnly: true,
                              decoration: const InputDecoration(
                                labelText: 'Card Number',
                                prefixIcon: Icon(Icons.credit_card_rounded, color: AppColors.primaryBlue),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: '12 / 26',
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Expiry Date',
                                      prefixIcon: Icon(Icons.calendar_today_rounded, color: AppColors.primaryBlue),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    initialValue: '888',
                                    readOnly: true,
                                    obscureText: true,
                                    decoration: const InputDecoration(
                                      labelText: 'CVV / CVC',
                                      prefixIcon: Icon(Icons.lock_outline_rounded, color: AppColors.primaryBlue),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Payment Action
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _isProcessing ? null : _processDummyPayment,
                  child: _isProcessing
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Processing Demo Payment...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Pay \$${widget.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
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

  Widget _buildPaymentOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedMethod == id;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? AppColors.primaryBlue : AppColors.border,
          width: isSelected ? 1.8 : 1,
        ),
      ),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () {
            setState(() {
              _selectedMethod = id;
            });
          },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.12) : AppColors.inputBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isSelected ? AppColors.primaryBlue : AppColors.secondaryText,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
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
        trailing: Radio<String>(
          value: id,
          groupValue: _selectedMethod,
          activeColor: AppColors.primaryBlue,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedMethod = value;
              });
            }
          },
        ),
      ),
    ),
  );
}
}
