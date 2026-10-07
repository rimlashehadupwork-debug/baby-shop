import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  late List<ProductReview> _reviews;
  late double _currentRating;
  late int _currentReviewCount;

  @override
  void initState() {
    super.initState();
    _reviews = List.from(widget.product.reviews);
    _currentRating = widget.product.rating;
    _currentReviewCount = widget.product.reviewCount;
  }

  void _addToCart() {
    CartService.instance.addItem(widget.product);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Added "${widget.product.name}" to cart!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _addNewReview(String name, double rating, String comment) {
    final newReview = ProductReview(
      id: 'rev_${DateTime.now().millisecondsSinceEpoch}',
      userName: name.trim().isEmpty ? 'Anonymous Parent' : name.trim(),
      rating: rating,
      date: 'Just now',
      comment: comment.trim(),
    );

    setState(() {
      _reviews.insert(0, newReview);
      _currentReviewCount += 1;
      final totalSum = _reviews.fold<double>(0, (sum, r) => sum + r.rating);
      _currentRating = totalSum / _reviews.length;
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text('Thank you! Your review has been published.'),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showWriteReviewModal() {
    double selectedRating = 5.0;
    final nameController = TextEditingController(text: 'Sarah Khan');
    final commentController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modal Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Write a Review',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Interactive Star Picker
                      const Text(
                        'Your Rating',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          final starValue = (index + 1).toDouble();
                          return IconButton(
                            iconSize: 36,
                            icon: Icon(
                              starValue <= selectedRating
                                  ? Icons.star_rounded
                                  : Icons.star_border_rounded,
                              color: AppColors.warning,
                            ),
                            onPressed: () {
                              setModalState(() {
                                selectedRating = starValue;
                              });
                            },
                          );
                        }),
                      ),
                      const SizedBox(height: 16),

                      // Name Field
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          hintText: 'Enter your name',
                          prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Review Text Field
                      TextFormField(
                        controller: commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Your Review',
                          hintText: 'Share your experience with this baby product...',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your review feedback';
                          }
                          if (value.trim().length < 5) {
                            return 'Review must be at least 5 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Submit Review Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              Navigator.pop(modalContext);
                              _addNewReview(
                                nameController.text,
                                selectedRating,
                                commentController.text,
                              );
                            }
                          },
                          icon: const Icon(Icons.rate_review_rounded, size: 18),
                          label: const Text(
                            'Submit Review',
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          product.brand,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Images Gallery
                    Stack(
                      children: [
                        Container(
                          height: 280,
                          width: double.infinity,
                          color: AppColors.surface,
                          child: PageView.builder(
                            itemCount: product.images.length,
                            onPageChanged: (index) {
                              setState(() {
                                _selectedImageIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Image.network(
                                product.images[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.primaryBlue.withValues(alpha: 0.08),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.child_care_rounded,
                                          size: 64,
                                          color: AppColors.primaryBlue,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          product.name,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primaryBlue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        // Category Tag Badge
                        Positioned(
                          top: 16,
                          left: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              product.categoryName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        // Page Indicators
                        if (product.images.length > 1)
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                product.images.length,
                                (index) => Container(
                                  width: _selectedImageIndex == index ? 20 : 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(horizontal: 3),
                                  decoration: BoxDecoration(
                                    color: _selectedImageIndex == index
                                        ? AppColors.primaryBlue
                                        : AppColors.border,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    // Main Info Container
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Brand & Name
                          Text(
                            product.brand.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: AppColors.secondaryPink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Price & Rating Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '\$${product.price.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.primaryBlue,
                                        ),
                                      ),
                                      if (product.originalPrice != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '\$${product.originalPrice!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            decoration: TextDecoration.lineThrough,
                                            color: AppColors.secondaryText,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                              // Rating Chip
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      color: AppColors.warning,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _currentRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryText,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '($_currentReviewCount)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 20),

                          // SELLER RATING & INFO CARD
                          const Text(
                            'Seller Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildSellerCard(product),
                          const SizedBox(height: 24),

                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 20),

                          // Description Section
                          const Text(
                            'Product Description',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            product.description,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.secondaryText,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // Key Features
                          if (product.features.isNotEmpty) ...[
                            const Text(
                              'Key Highlights',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Column(
                              children: product.features.map((feature) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.check_circle_rounded,
                                        size: 18,
                                        color: AppColors.primaryBlue,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: AppColors.primaryText,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                          ],

                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 20),

                          // CUSTOMER REVIEWS SECTION
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Customer Reviews',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size(120, 36),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  side: const BorderSide(color: AppColors.primaryBlue),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _showWriteReviewModal,
                                icon: const Icon(Icons.rate_review_outlined, size: 16),
                                label: const Text(
                                  'Write Review',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Overall Rating Summary Box
                          _buildRatingSummarySection(_currentRating, _currentReviewCount),
                          const SizedBox(height: 16),

                          // Individual Customer Reviews List
                          if (_reviews.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text(
                                'No customer reviews yet. Be the first to share your thoughts!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                              ),
                            )
                          else
                            Column(
                              children: _reviews.map((review) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppColors.border),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.02),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 16,
                                                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.15),
                                                child: Text(
                                                  review.userName.substring(0, 1).toUpperCase(),
                                                  style: const TextStyle(
                                                    color: AppColors.primaryBlue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                review.userName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: AppColors.primaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            review.date,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: AppColors.secondaryText,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: List.generate(5, (starIndex) {
                                          return Icon(
                                            starIndex < review.rating.floor()
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            size: 16,
                                            color: AppColors.warning,
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        review.comment,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.primaryText,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Bar with Add to Cart Button
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
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Total Price',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryText,
                          ),
                        ),
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _addToCart,
                      icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                      label: const Text(
                        'Add to Cart',
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
      ),
    );
  }

  Widget _buildSellerCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Store Icon Badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.primaryBlue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),

              // Seller Name & Verified Badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            product.sellerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (product.sellerIsVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.primaryBlue,
                            size: 16,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 15,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          product.sellerRating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${product.sellerRatingCount} ratings)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Seller Credibility Highlights Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _SellerBadgeItem(
                  icon: Icons.thumb_up_alt_outlined,
                  label: '99% Positive',
                ),
                _SellerBadgeItem(
                  icon: Icons.local_shipping_outlined,
                  label: 'Fast Delivery',
                ),
                _SellerBadgeItem(
                  icon: Icons.verified_user_outlined,
                  label: '100% Genuine',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummarySection(double rating, int reviewCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Rating Score Big Display
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.floor()
                        ? Icons.star_rounded
                        : (index < rating ? Icons.star_half_rounded : Icons.star_border_rounded),
                    color: AppColors.warning,
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                '$reviewCount Reviews',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),

          // Star Progress Bars
          Expanded(
            child: Column(
              children: [
                _buildStarProgressBar(5, 0.85),
                _buildStarProgressBar(4, 0.12),
                _buildStarProgressBar(3, 0.02),
                _buildStarProgressBar(2, 0.01),
                _buildStarProgressBar(1, 0.00),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarProgressBar(int starNumber, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Text(
            '$starNumber',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, size: 12, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: percentage,
                backgroundColor: AppColors.border,
                color: AppColors.primaryBlue,
                minHeight: 6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerBadgeItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SellerBadgeItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.primaryBlue),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryText,
          ),
        ),
      ],
    );
  }
}
