import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
  });

  int? get _discountPercent {
    final original = product.originalPrice;
    if (original == null || original <= product.price) return null;
    return (((original - product.price) / original) * 100).round();
  }

  void _addToCart(BuildContext context) {
    if (onAddToCart != null) {
      onAddToCart!();
      return;
    }
    CartService.instance.addItem(product);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text('Added ${product.name} to cart'),
        backgroundColor: AppColors.primaryText,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final discount = _discountPercent;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.7)),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.softBlue.withValues(alpha: 0.5),
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 30,
                                color: AppColors.primaryBlue.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.brand,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryBlue.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (discount != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryPink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '-$discount%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Info
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                        const SizedBox(width: 3),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Flexible(
                          child: Text(
                            '(${product.reviewCount})',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 11, color: AppColors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '\$${product.price.toStringAsFixed(2)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              if (product.originalPrice != null)
                                Text(
                                  '\$${product.originalPrice!.toStringAsFixed(2)}',
                                  maxLines: 1,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Semantics(
                          button: true,
                          label: 'Add ${product.name} to cart',
                          child: InkWell(
                            onTap: () => _addToCart(context),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.primaryBlue,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
