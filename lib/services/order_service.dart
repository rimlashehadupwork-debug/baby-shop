import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import 'delivery_info.dart';
import 'product_service.dart';
import 'user_session.dart';

class OrderService {
  static final OrderService instance = OrderService._internal();

  OrderService._internal() {
    FirebaseAuth.instance.authStateChanges().listen((_) => reload());
  }

  static const String table = 'orders';

  final ValueNotifier<List<OrderModel>> ordersNotifier =
  ValueNotifier<List<OrderModel>>([]);

  StreamSubscription<DatabaseEvent>? _sub;

  List<OrderModel> get orders => List.unmodifiable(ordersNotifier.value);

  int _generation = 0;

  Future<bool> _isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    if ((user.email ?? '').toLowerCase() == 'admin@gmail.com') return true;
    try {
      final snap = await FirebaseDatabase.instance
          .ref('users/${user.uid}/role')
          .get();
      return snap.value?.toString() == 'admin';
    } catch (e) {
      return false;
    }
  }

  Future<void> _listen() async {
    final generation = ++_generation;
    await _sub?.cancel();
    _sub = null;

    final admin = await _isAdmin();
    if (generation != _generation) return;

    final root = FirebaseDatabase.instance.ref(table);
    final Query query =
    admin ? root : root.orderByChild('userId').equalTo(UserSession.key);

    _sub = query.onValue.listen(
          (event) {
        ordersNotifier.value = _parse(event.snapshot.value);
      },
      onError: (Object e) {
        debugPrint('ORDERS STREAM ERROR: $e');
      },
    );
  }

  void reload() {
    ordersNotifier.value = [];
    _listen();
  }

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _two(int n) => n.toString().padLeft(2, '0');

  String _formatDate(dynamic iso) {
    final d = DateTime.tryParse((iso ?? '').toString());
    if (d == null) return '';
    final hour12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '${d.day} ${_months[d.month - 1]} ${d.year}, ${_two(hour12)}:${_two(d.minute)} $period';
  }

  double _num(dynamic v) => double.tryParse('${v ?? 0}') ?? 0;

  OrderStatus _statusFrom(dynamic v) {
    final name = (v ?? '').toString();
    for (final s in OrderStatus.values) {
      if (s.name == name) return s;
    }
    return OrderStatus.placed;
  }

  Map<String, dynamic> _itemToMap(CartItemModel item) {
    final p = item.product;
    return {
      'productId': p.id,
      'name': p.name,
      'brand': p.brand,
      'categoryName': p.categoryName,
      'imageUrl': p.imageUrl,
      'price': p.price,
      'quantity': item.quantity,
    };
  }

  OrderModel _fromMap(Map<String, dynamic> m) {
    final items = <CartItemModel>[];
    final rawItems = m['items'];
    final entries = rawItems is List
        ? rawItems
        : (rawItems is Map ? rawItems.values.toList() : <dynamic>[]);

    for (final e in entries) {
      if (e is Map) {
        final row = e.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
        final product = <String, dynamic>{
          'id': row['productId'],
          'name': row['name'],
          'brand': row['brand'],
          'categoryName': row['categoryName'],
          'imageUrl': row['imageUrl'],
          'price': row['price'],
        };
        final qty = int.tryParse('${row['quantity'] ?? 1}') ?? 1;
        items.add(CartItemModel(product: product, quantity: qty));
      }
    }

    return OrderModel(
      id: (m['orderCode'] ?? '').toString(),
      date: _formatDate(m['createdAt']),
      status: _statusFrom(m['status']),
      items: items,
      subtotal: _num(m['subtotal']),
      deliveryFee: _num(m['deliveryFee']),
      total: _num(m['total']),
      recipientName: (m['recipientName'] ?? '').toString(),
      phone: (m['phone'] ?? '').toString(),
      deliveryAddress: (m['deliveryAddress'] ?? '').toString(),
      paymentMethod: (m['paymentMethod'] ?? '').toString(),
      estimatedDelivery: (m['estimatedDelivery'] ?? '').toString(),
    );
  }

  List<OrderModel> _parse(Object? raw) {
    final rows = <MapEntry<String, OrderModel>>[];
    if (raw is Map) {
      raw.forEach((key, value) {
        if (value is Map) {
          final m = value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
          rows.add(MapEntry((m['createdAt'] ?? '').toString(), _fromMap(m)));
        }
      });
    }
    rows.sort((a, b) => b.key.compareTo(a.key));
    return rows.map((e) => e.value).toList();
  }

  Future<void> addOrder(OrderModel order) async {
    final info = DeliveryInfo.instance;
    final data = <String, dynamic>{
      'userId': UserSession.key,
      'orderCode': order.id,
      'status': order.status.name,
      'createdAt': DateTime.now().toIso8601String(),
      'subtotal': order.subtotal,
      'deliveryFee': order.deliveryFee,
      'total': order.total,
      'recipientName': info.name.isNotEmpty ? info.name : order.recipientName,
      'phone': info.phone.isNotEmpty ? info.phone : order.phone,
      'deliveryAddress':
      info.address.isNotEmpty ? info.address : order.deliveryAddress,
      'paymentMethod': order.paymentMethod,
      'estimatedDelivery': order.estimatedDelivery,
      'items': order.items.map(_itemToMap).toList(),
    };

    ordersNotifier.value = [
      _fromMap(data),
      ...ordersNotifier.value.where((o) => o.id != order.id),
    ];

    try {
      final root = FirebaseDatabase.instance.ref(table);
      final key = UserSession.safeKey(order.id.replaceAll('#', ''));
      final ref = key.isEmpty ? root.push() : root.child(key);
      await ref.set(data);
    } catch (e) {
      debugPrint('ORDER SAVE ERROR: $e');
      return;
    }

    await _reduceStock(order.items);
  }

  Future<void> _reduceStock(List<CartItemModel> items) async {
    for (final item in items) {
      try {
        await FirebaseDatabase.instance
            .ref('products/${item.product.id}/stock')
            .runTransaction((value) {
          final current = int.tryParse('${value ?? 0}') ?? 0;
          final next = current - item.quantity;
          return Transaction.success(next < 0 ? 0 : next);
        });
      } catch (e) {
        debugPrint('STOCK UPDATE ERROR: $e');
      }
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final key = UserSession.safeKey(orderId.replaceAll('#', ''));
      await FirebaseDatabase.instance
          .ref('$table/$key')
          .update({'status': status.name});
    } catch (e) {
      debugPrint('ORDER STATUS ERROR: $e');
    }
  }
}