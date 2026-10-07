import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartService {
  static final CartService instance = CartService._internal();

  CartService._internal() {
    // Populate with 2 initial mock cart items for realistic demo
    if (MockData.products.length >= 2) {
      _items.add(CartItemModel(product: MockData.products[0], quantity: 2));
      _items.add(CartItemModel(product: MockData.products[3], quantity: 1));
      itemsNotifier.value = List.unmodifiable(_items);
    }
  }

  final List<CartItemModel> _items = [];
  final ValueNotifier<List<CartItemModel>> itemsNotifier = ValueNotifier([]);

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  double get deliveryFee => subtotal > 0 ? (subtotal >= 50.0 ? 0.0 : 4.99) : 0.0;

  double get total => subtotal + deliveryFee;

  void addItem(ProductModel product, [int quantity = 1]) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItemModel(product: product, quantity: quantity));
    }
    _notify();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    _notify();
  }

  void incrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity += 1;
      _notify();
    }
  }

  void decrementQuantity(String productId) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      _notify();
    }
  }

  void clearCart() {
    _items.clear();
    _notify();
  }

  void _notify() {
    itemsNotifier.value = List.unmodifiable(_items);
  }
}
