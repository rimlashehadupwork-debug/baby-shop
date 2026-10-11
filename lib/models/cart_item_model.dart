import '../services/product_service.dart';

class CartItemModel {
  final ProductMap product;
  final int quantity;

  const CartItemModel({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.price * quantity;

  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}