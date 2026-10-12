import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/delivery_info.dart';
import '../services/product_service.dart';
import '../services/review_service.dart';
import '../theme/app_theme.dart';

class ProductReviewsScreen extends StatefulWidget {
  final ProductMap product;

  const ProductReviewsScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  int _selectedStarFilter = 0; // 0 = All

  double _reviewRating(Map<String, dynamic> r) =>
      double.tryParse('${r['rating'] ?? 0}') ?? 0;

  String _reviewText(Map<String, dynamic> r, String key) =>
      (r[key] ?? '').toString();

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
    bool isSubmitting = false;

    final ratingLabels = ['Poor', 'Fair', 'Average', 'Good', 'Excellent'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Write a Product Review',
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
                        'Tap stars to rate:',
                        textAlign: TextAlign.center,
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
                            iconSize: 38,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
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
                      Center(
                        child: Text(
                          ratingLabels[selectedRating.toInt() - 1],
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Your Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.primaryBlue),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: commentController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Your Review',
                          hintText: 'Describe your experience with this baby product...',
                          alignLabelWithHint: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your feedback';
                          }
                          if (value.trim().length < 4) {
                            return 'Review must be at least 4 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    setModalState(() => isSubmitting = true);

                                    final ok = await ReviewService.instance.addReview(
                                      productId: widget.product.id,
                                      userName: nameController.text,
                                      rating: selectedRating,
                                      comment: commentController.text,
                                    );

                                    if (!context.mounted) return;
                                    Navigator.pop(modalContext);

                                    ScaffoldMessenger.of(this.context).showSnackBar(
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
                                                    : 'Could not publish your review. Please try again.',
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
                                },
                          icon: isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.rate_review_rounded, size: 20),
                          label: Text(
                            isSubmitting ? 'Submitting...' : 'Submit Review',
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
      appBar: AppBar(
        title: const Text('Customer Reviews'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: ReviewService.instance.watchReviews(product.id),
          builder: (context, snapshot) {
            final reviews = snapshot.data ?? [];
            final totalCount = reviews.length;
            final double avgRating = totalCount > 0
                ? (reviews.fold<double>(0, (s, r) => s + _reviewRating(r)) / totalCount)
                : product.rating;

            final filteredReviews = _selectedStarFilter == 0
                ? reviews
                : reviews.where((r) => _reviewRating(r).round() == _selectedStarFilter).toList();

            return Column(
              children: [
                // Product Banner Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  color: AppColors.surface,
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(product.imageUrl, fit: BoxFit.cover)
                              : const Icon(Icons.child_care, color: AppColors.primaryBlue),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Brand: ${product.brand}',
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
                ),
                const Divider(height: 1, color: AppColors.border),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating Summary Card
                        _buildRatingSummaryCard(avgRating, totalCount, reviews),
                        const SizedBox(height: 20),

                        // Star Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: [
                              _buildFilterChip(0, 'All (${reviews.length})'),
                              const SizedBox(width: 8),
                              _buildFilterChip(5, '5 ★'),
                              const SizedBox(width: 8),
                              _buildFilterChip(4, '4 ★'),
                              const SizedBox(width: 8),
                              _buildFilterChip(3, '3 ★'),
                              const SizedBox(width: 8),
                              _buildFilterChip(2, '2 ★'),
                              const SizedBox(width: 8),
                              _buildFilterChip(1, '1 ★'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Reviews List
                        if (filteredReviews.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.rate_review_outlined,
                                  size: 48,
                                  color: AppColors.secondaryText,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _selectedStarFilter == 0
                                      ? 'No reviews yet'
                                      : 'No $_selectedStarFilter-star reviews',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Be the first to share your thoughts with other parents!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.secondaryText,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredReviews.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final review = filteredReviews[index];
                              return _buildReviewTile(review);
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                // Write Review Action Button at Bottom
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _showWriteReviewModal,
                    icon: const Icon(Icons.rate_review_rounded, size: 20),
                    label: const Text(
                      'Write a Review',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterChip(int starCount, String label) {
    final isSelected = _selectedStarFilter == starCount;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primaryBlue,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.primaryText,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 13,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primaryBlue : AppColors.border,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedStarFilter = starCount;
          });
        }
      },
    );
  }

  Widget _buildRatingSummaryCard(double rating, int totalCount, List<Map<String, dynamic>> reviews) {
    double starShare(int star) {
      if (totalCount == 0) return 0;
      final count = reviews.where((r) => _reviewRating(r).round() == star).length;
      return count / totalCount;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating.floor()
                        ? Icons.star_rounded
                        : (index < rating ? Icons.star_half_rounded : Icons.star_border_rounded),
                    color: AppColors.warning,
                    size: 18,
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                '$totalCount Reviews',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildStarBar(5, starShare(5)),
                _buildStarBar(4, starShare(4)),
                _buildStarBar(3, starShare(3)),
                _buildStarBar(2, starShare(2)),
                _buildStarBar(1, starShare(1)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStarBar(int star, double share) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Row(
        children: [
          Text(
            '$star',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(width: 3),
          const Icon(Icons.star_rounded, size: 13, color: AppColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: share,
                backgroundColor: AppColors.border,
                color: AppColors.primaryBlue,
                minHeight: 7,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewTile(Map<String, dynamic> review) {
    final userName = _reviewText(review, 'userName');
    final rating = _reviewRating(review);
    final comment = _reviewText(review, 'comment');
    final date = _reviewText(review, 'date');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.12),
                child: Text(
                  userName.isEmpty ? '?' : userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryText,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < rating.floor() ? Icons.star_rounded : Icons.star_border_rounded,
                          size: 14,
                          color: AppColors.warning,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              comment,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppColors.primaryText,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
