import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final bool showAppBar;

  const CartScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _cartService = CartService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? AppBar(
              title: const Text(
                'Shopping Cart',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          : null,
      body: ValueListenableBuilder<List<CartItemModel>>(
        valueListenable: _cartService.itemsNotifier,
        builder: (context, items, child) {
          if (items.isEmpty) {
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
                          Icons.shopping_cart_outlined,
                          size: 56,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Your Shopping Cart is Empty',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Browse our categories to discover diapers, organic food, apparel, and toys for your baby.',
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
            child: Column(
              children: [
                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final product = item.product;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
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
                            // Product Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 72,
                                height: 72,
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
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Product Details & Quantity
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
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
                                      ),
                                      // Remove Item Action
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: AppColors.error,
                                          size: 20,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          _cartService.removeItem(product.id);
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.brand,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.secondaryText,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Price & Quantity Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '\$${item.totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),

                                      // Quantity Controls
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.inputBackground,
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: AppColors.border),
                                        ),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                _cartService.decrementQuantity(product.id);
                                              },
                                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Icon(Icons.remove, size: 16, color: AppColors.primaryText),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(
                                                '${item.quantity}',
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.primaryText,
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                _cartService.incrementQuantity(product.id);
                                              },
                                              borderRadius: const BorderRadius.horizontal(right: Radius.circular(10)),
                                              child: const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                child: Icon(Icons.add, size: 16, color: AppColors.primaryText),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Order Summary Card & Checkout Button
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Subtotal',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          Text(
                            '\$${_cartService.subtotal.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Delivery Fee',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                            ),
                          ),
                          Text(
                            _cartService.deliveryFee == 0
                                ? 'FREE'
                                : '\$${_cartService.deliveryFee.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _cartService.deliveryFee == 0
                                  ? AppColors.success
                                  : AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Divider(height: 1, color: AppColors.border),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          Text(
                            '\$${_cartService.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Primary Button: Proceed to Checkout
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CheckoutScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                          label: const Text(
                            'Proceed to Checkout',
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
              ],
            ),
          );
        },
      ),
    );
  }
}
