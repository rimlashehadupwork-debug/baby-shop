import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/product_model.dart';
import '../../services/cart_service.dart';

enum StockStatus { inStock, lowStock, outOfStock }

/// Admin product management. Works directly on MockData.products so changes
/// made here are also visible on the customer side.
class AdminProductService {
  static final AdminProductService instance = AdminProductService._internal();

  AdminProductService._internal() {
    const pattern = [45, 120, 8, 64, 0, 30, 18, 92, 6, 55, 72, 25, 40, 10];
    for (var i = 0; i < MockData.products.length; i++) {
      _stock[MockData.products[i].id] = pattern[i % pattern.length];
    }
    productsNotifier.value = List.unmodifiable(MockData.products);
  }

  static const int lowStockThreshold = 10;

  final Map<String, int> _stock = {};
  final ValueNotifier<List<ProductModel>> productsNotifier = ValueNotifier([]);

  List<ProductModel> get products => List.unmodifiable(MockData.products);

  int stockOf(String productId) => _stock[productId] ?? 0;

  StockStatus statusOf(String productId) {
    final stock = stockOf(productId);
    if (stock <= 0) return StockStatus.outOfStock;
    if (stock <= lowStockThreshold) return StockStatus.lowStock;
    return StockStatus.inStock;
  }

  int get lowStockCount =>
      MockData.products.where((p) => statusOf(p.id) == StockStatus.lowStock).length;

  int get outOfStockCount =>
      MockData.products.where((p) => statusOf(p.id) == StockStatus.outOfStock).length;

  String newId() => 'prod_${DateTime.now().millisecondsSinceEpoch}';

  void addProduct(ProductModel product, int stock) {
    MockData.products.insert(0, product);
    _stock[product.id] = stock;
    _notify();
  }

  void updateProduct(ProductModel product, int stock) {
    final index = MockData.products.indexWhere((p) => p.id == product.id);
    if (index < 0) return;
    MockData.products[index] = product;
    _stock[product.id] = stock;
    _notify();
  }

  void deleteProduct(String productId) {
    MockData.products.removeWhere((p) => p.id == productId);
    _stock.remove(productId);
    CartService.instance.removeItem(productId);
    _notify();
  }

  void _notify() {
    productsNotifier.value = List.unmodifiable(MockData.products);
  }
}
