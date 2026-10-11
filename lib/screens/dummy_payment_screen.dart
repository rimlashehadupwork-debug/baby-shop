import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../services/cart_service.dart';
import '../services/delivery_info.dart';
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
  String _selectedMethod = 'card';
  bool _isProcessing = false;

  String get _methodLabel {
    switch (_selectedMethod) {
      case 'card':
        return 'Demo Credit Card (Visa **** 4242)';
      case 'cod':
        return 'Cash on Delivery';
      default:
        return 'Demo Mobile Wallet';
    }
  }

  void _processDummyPayment() {
    if (_isProcessing) return;

    final cartItems = List<CartItemModel>.from(CartService.instance.items);
    if (cartItems.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Your cart is empty')));
      return;
    }

    setState(() => _isProcessing = true);

    Timer(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      final info = DeliveryInfo.instance;
      final total = widget.totalAmount;
      final method = _methodLabel;

      final newOrder = OrderModel(
        id: '#BSH-${10000 + (DateTime.now().millisecondsSinceEpoch % 89999)}',
        date: 'Just now',
        status: OrderStatus.placed,
        items: cartItems,
        subtotal: CartService.instance.subtotal,
        deliveryFee: CartService.instance.deliveryFee,
        total: total,
        recipientName: info.name,
        phone: info.phone,
        deliveryAddress: info.address,
        paymentMethod: method,
        estimatedDelivery: 'Estimated in 2-3 Days',
      );

      OrderService.instance.addOrder(newOrder);
      CartService.instance.clearCart();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => OrderConfirmationScreen(
            totalAmount: total,
            paymentMethod: method,
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
                    const Text(
                      'Select Demo Payment Method',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildPaymentOption(
                      id: 'card',
                      title: 'Demo Credit / Debit Card',
                      subtitle: 'Visa, Mastercard or Express (Simulation)',
                      icon: Icons.credit_card_rounded,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      id: 'cod',
                      title: 'Cash on Delivery',
                      subtitle: 'Pay with cash upon delivery',
                      icon: Icons.payments_outlined,
                    ),
                    const SizedBox(height: 10),
                    _buildPaymentOption(
                      id: 'wallet',
                      title: 'Demo Mobile Wallet',
                      subtitle: 'Instant digital wallet payment',
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(height: 24),
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
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
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
          onTap: () => setState(() => _selectedMethod = id),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primaryBlue.withValues(alpha: 0.12)
                  : AppColors.inputBackground,
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
              if (value != null) setState(() => _selectedMethod = value);
            },
          ),
        ),
      ),
    );
  }
}