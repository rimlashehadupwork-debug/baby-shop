import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import 'product_service.dart';
import 'user_session.dart';

class CartService {
  CartService._() {
    FirebaseAuth.instance.authStateChanges().listen((_) => reload());
  }

  static final CartService instance = CartService._();

  static const String table = 'carts';
  static const double freeDeliveryThreshold = 50.0;
  static const double standardDeliveryFee = 4.99;

  final ValueNotifier<List<CartItemModel>> itemsNotifier =
      ValueNotifier<List<CartItemModel>>([]);

  DatabaseReference get _ref =>
      FirebaseDatabase.instance.ref('$table/${UserSession.key}');

  List<CartItemModel> get items => itemsNotifier.value;

  bool get isEmpty => items.isEmpty;

  int get itemCount => items.fold<int>(0, (totalCount, item) => totalCount + item.quantity);

  double get subtotal =>
      items.fold<double>(0, (totalSum, item) => totalSum + item.totalPrice);

  double get deliveryFee {
    if (items.isEmpty) return 0;
    return subtotal >= freeDeliveryThreshold ? 0 : standardDeliveryFee;
  }

  double get total => subtotal + deliveryFee;

  /// Checks if the active user account is suspended.
  /// If suspended, clears the local cart immediately and returns true.
  Future<bool> checkSuspendedGuard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final docSnap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (docSnap.exists && docSnap.data() != null) {
        final status = (docSnap.data()?['accountStatus'] ?? 'active').toString().toLowerCase();
        if (status == 'suspended') {
          clearCart(); // Immediately wipe local cart
          return true;
        }
      }
    } catch (e) {
      debugPrint('SUSPENDED GUARD CHECK ERROR: $e');
    }
    return false;
  }

  Map<String, dynamic> _toRow(CartItemModel item) {
    final p = item.product;
    return {
      'productId': p.id,
      'name': p.name,
      'brand': p.brand,
      'categoryName': p.categoryName,
      'imageUrl': p.imageUrl,
      'price': p.price,
      'originalPrice': p.originalPrice,
      'stock': p.stock,
      'quantity': item.quantity,
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  CartItemModel? _fromRow(String key, dynamic raw) {
    if (raw is! Map) return null;
    final row = raw.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
    final product = <String, dynamic>{
      'id': (row['productId'] ?? key).toString(),
      'name': row['name'],
      'brand': row['brand'],
      'categoryName': row['categoryName'],
      'imageUrl': row['imageUrl'],
      'price': row['price'],
      'originalPrice': row['originalPrice'],
      'stock': row['stock'],
    };
    final qty = int.tryParse('${row['quantity'] ?? 1}') ?? 1;
    return CartItemModel(product: product, quantity: qty < 1 ? 1 : qty);
  }

  void _saveRow(CartItemModel item) {
    _ref.child(item.product.id).set(_toRow(item)).catchError((Object e) {
      debugPrint('CART SAVE ERROR: $e');
    });
  }

  Future<void> load() async {
    try {
      final snap = await _ref.get();
      final loaded = <CartItemModel>[];
      final value = snap.value;
      if (value is Map) {
        value.forEach((k, v) {
          final item = _fromRow(k.toString(), v);
          if (item != null) loaded.add(item);
        });
      }
      final merged = List<CartItemModel>.of(items);
      for (final item in loaded) {
        if (!merged.any((m) => m.product.id == item.product.id)) {
          merged.add(item);
        }
      }
      itemsNotifier.value = merged;
    } catch (e) {
      debugPrint('CART LOAD ERROR: $e');
    }
  }

  Future<void> reload() async {
    itemsNotifier.value = [];
    await load();
  }

  int _indexOf(String productId) =>
      items.indexWhere((item) => item.product.id == productId);

  bool addItem(ProductMap product) {
    if (product.stock <= 0) return false;

    final list = List<CartItemModel>.of(items);
    final index = list.indexWhere((item) => item.product.id == product.id);
    late final CartItemModel changed;

    if (index == -1) {
      changed = CartItemModel(product: product, quantity: 1);
      list.add(changed);
    } else {
      final current = list[index];
      if (current.quantity + 1 > product.stock) return false;
      changed = current.copyWith(quantity: current.quantity + 1);
      list[index] = changed;
    }

    itemsNotifier.value = list;
    _saveRow(changed);
    return true;
  }

  void removeItem(String productId) {
    itemsNotifier.value =
        items.where((item) => item.product.id != productId).toList();
    _ref.child(productId).remove().catchError((Object e) {
      debugPrint('CART REMOVE ERROR: $e');
    });
  }

  bool incrementQuantity(String productId) {
    final index = _indexOf(productId);
    if (index == -1) return false;

    final current = items[index];
    if (current.quantity + 1 > current.product.stock) return false;

    final changed = current.copyWith(quantity: current.quantity + 1);
    final list = List<CartItemModel>.of(items);
    list[index] = changed;
    itemsNotifier.value = list;
    _saveRow(changed);
    return true;
  }

  void decrementQuantity(String productId) {
    final index = _indexOf(productId);
    if (index == -1) return;

    final current = items[index];
    if (current.quantity <= 1) return;

    final changed = current.copyWith(quantity: current.quantity - 1);
    final list = List<CartItemModel>.of(items);
    list[index] = changed;
    itemsNotifier.value = list;
    _saveRow(changed);
  }

  void clear() {
    itemsNotifier.value = [];
    _ref.remove().catchError((Object e) {
      debugPrint('CART CLEAR ERROR: $e');
    });
  }

  void clearCart() => clear();
}
