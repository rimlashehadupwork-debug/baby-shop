import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/delivery_info.dart';
import '../services/product_service.dart';
import '../services/review_service.dart';
import '../theme/app_theme.dart';
import 'product_reviews_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductMap product;

  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  late List<Map<String, dynamic>> _reviews;
  late double _currentRating;
  late int _currentReviewCount;

  StreamSubscription<List<Map<String, dynamic>>>? _reviewsSub;

  @override
  void initState() {
    super.initState();
    _reviews = List<Map<String, dynamic>>.of(widget.product.reviews);
    _currentRating = widget.product.rating;
    _currentReviewCount = widget.product.reviewCount;

    final productId = widget.product.id;
    if (productId.isNotEmpty) {
      _reviewsSub = ReviewService.instance.watchReviews(productId).listen(
        (list) {
          if (!mounted || list.isEmpty) return;
          final sum = list.fold<double>(0, (s, r) => s + _reviewRating(r));
          setState(() {
            _reviews = list;
            _currentReviewCount = list.length;
            _currentRating = sum / list.length;
          });
        },
        onError: (e) => debugPrint('REVIEWS STREAM ERROR: $e'),
      );
    }
  }

  @override
  void dispose() {
    _reviewsSub?.cancel();
    super.dispose();
  }

  double _reviewRating(Map<String, dynamic> r) =>
      double.tryParse('${r['rating'] ?? 0}') ?? 0;

  String _reviewText(Map<String, dynamic> r, String key) =>
      (r[key] ?? '').toString();

  void _addToCart() {
    final product = widget.product;
    final added = CartService.instance.addItem(product);
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final String message;
    if (added) {
      message = 'Added "${product.name}" to cart!';
    } else if (product.stock <= 0) {
      message = '"${product.name}" is out of stock';
    } else {
      message = 'Only ${product.stock} available in stock';
    }

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              added ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: added ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _addNewReview(String name, double rating, String comment) async {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    if (FirebaseAuth.instance.currentUser == null) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Please login to write a review'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final ok = await ReviewService.instance.addReview(
      productId: widget.product.id,
      userName: name,
      rating: rating,
      comment: comment,
    );

    if (!mounted) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                ok
                    ? 'Thank you! Your review has been published.'
                    : 'Could not publish your review. Try again.',
              ),
            ),
          ],
        ),
        backgroundColor: ok ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showWriteReviewModal() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login to write a review'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    double selectedRating = 5.0;
    final nameController = TextEditingController(
      text: DeliveryInfo.instance.name.isNotEmpty
          ? DeliveryInfo.instance.name
          : (user.displayName ?? ''),
    );
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
                          if (value.trim().length < 4) {
                            return 'Review must be at least 4 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
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

  void _showRateSellerModal() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please login to rate the seller'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    double sellerRating = 5.0;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rate Seller: ${widget.product.sellerName}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'How was your experience with this seller?',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = (index + 1).toDouble();
                      return IconButton(
                        iconSize: 40,
                        icon: Icon(
                          starValue <= sellerRating
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: AppColors.warning,
                        ),
                        onPressed: () {
                          setModalState(() {
                            sellerRating = starValue;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(modalContext);
                        final ok = await ReviewService.instance.rateSeller(
                          productId: widget.product.id,
                          sellerName: widget.product.sellerName,
                          rating: sellerRating,
                        );
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? 'Thank you for rating ${widget.product.sellerName}!'
                                  : 'Could not submit seller rating.',
                            ),
                            backgroundColor: ok ? AppColors.success : AppColors.error,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      child: const Text(
                        'Submit Seller Rating',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _imageFallback(ProductMap product) {
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
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final images = product.images;
    final original = product.originalPrice;

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
                    Stack(
                      children: [
                        Container(
                          height: 280,
                          width: double.infinity,
                          color: AppColors.surface,
                          child: images.isEmpty
                              ? _imageFallback(product)
                              : PageView.builder(
                                  itemCount: images.length,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _selectedImageIndex = index;
                                    });
                                  },
                                  itemBuilder: (context, index) {
                                    return Image.network(
                                      images[index],
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, progress) {
                                        if (progress == null) return child;
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primaryBlue,
                                          ),
                                        );
                                      },
                                      errorBuilder: (context, error, stackTrace) {
                                        return _imageFallback(product);
                                      },
                                    );
                                  },
                                ),
                        ),
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
                        if (images.length > 1)
                          Positioned(
                            bottom: 12,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                images.length,
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

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  if (original != null) ...[
                                    const SizedBox(width: 8),
                                    Text(
                                      '\$${original.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        decoration: TextDecoration.lineThrough,
                                        color: AppColors.secondaryText,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
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
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                product.stock > 0
                                    ? Icons.check_circle_outline_rounded
                                    : Icons.cancel_outlined,
                                size: 16,
                                color: product.stock > 0
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                product.stock > 0
                                    ? '${product.stock} in stock'
                                    : 'Out of stock',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: product.stock > 0
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Seller Information',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: _showRateSellerModal,
                                icon: const Icon(Icons.star_outline_rounded, size: 16, color: AppColors.primaryBlue),
                                label: const Text(
                                  'Rate Seller',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildSellerCard(product),
                          const SizedBox(height: 24),

                          const Divider(height: 1, color: AppColors.border),
                          const SizedBox(height: 20),

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
                              Row(
                                children: [
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(100, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      side: const BorderSide(color: AppColors.primaryBlue),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ProductReviewsScreen(product: product),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.list_alt_rounded, size: 15),
                                    label: const Text(
                                      'View All',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryBlue,
                                      minimumSize: const Size(100, 36),
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                    onPressed: _showWriteReviewModal,
                                    icon: const Icon(Icons.rate_review_outlined, size: 15),
                                    label: const Text(
                                      'Write Review',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          _buildRatingSummarySection(_currentRating, _currentReviewCount),
                          const SizedBox(height: 16),

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
                              children: _reviews.take(3).map((review) {
                                final userName = _reviewText(review, 'userName');
                                final rating = _reviewRating(review);
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
                                                  userName.isEmpty
                                                      ? '?'
                                                      : userName.substring(0, 1).toUpperCase(),
                                                  style: const TextStyle(
                                                    color: AppColors.primaryBlue,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Text(
                                                userName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                  color: AppColors.primaryText,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            _reviewText(review, 'date'),
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
                                            starIndex < rating.floor()
                                                ? Icons.star_rounded
                                                : Icons.star_border_rounded,
                                            size: 16,
                                            color: AppColors.warning,
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _reviewText(review, 'comment'),
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
                          if (_reviews.length > 3)
                            Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ProductReviewsScreen(product: product),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                                label: Text('See All ${_reviews.length} Reviews'),
                              ),
                            ),
                        ],
                      ),
                    ),
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
                      onPressed: product.stock <= 0 ? null : _addToCart,
                      icon: const Icon(Icons.shopping_cart_outlined, size: 20),
                      label: Text(
                        product.stock <= 0 ? 'Out of Stock' : 'Add to Cart',
                        style: const TextStyle(
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

  Widget _buildSellerCard(ProductMap product) {
    final hasSellerRating =
        product.sellerRating > 0 || product.sellerRatingCount > 0;

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
                    if (hasSellerRating) ...[
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.inputBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
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

  double _starShare(int star) {
    if (_reviews.isEmpty) return 0;
    final count = _reviews.where((r) => _reviewRating(r).round() == star).length;
    return count / _reviews.length;
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
          Expanded(
            child: Column(
              children: [
                _buildStarProgressBar(5, _starShare(5)),
                _buildStarProgressBar(4, _starShare(4)),
                _buildStarProgressBar(3, _starShare(3)),
                _buildStarProgressBar(2, _starShare(2)),
                _buildStarProgressBar(1, _starShare(1)),
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
