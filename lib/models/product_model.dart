class ProductReview {
  final String id;
  final String userName;
  final double rating;
  final String date;
  final String comment;

  const ProductReview({
    required this.id,
    required this.userName,
    required this.rating,
    required this.date,
    required this.comment,
  });
}

class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String categoryId;
  final String categoryName;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> images;
  final String description;
  final List<String> features;
  final bool isFeatured;
  final List<ProductReview> reviews;
  final String sellerName;
  final double sellerRating;
  final int sellerRatingCount;
  final bool sellerIsVerified;

  const ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.images,
    required this.description,
    required this.features,
    required this.isFeatured,
    required this.reviews,
    this.sellerName = 'BabyShopHub Official Store',
    this.sellerRating = 4.9,
    this.sellerRatingCount = 1250,
    this.sellerIsVerified = true,
  });
}
