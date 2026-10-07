import 'cart_item_model.dart';

enum OrderStatus {
  placed,
  processing,
  shipped,
  outForDelivery,
  delivered;

  String get displayName {
    switch (this) {
      case OrderStatus.placed:
        return 'Order Placed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  int get stepIndex {
    switch (this) {
      case OrderStatus.placed:
        return 0;
      case OrderStatus.processing:
        return 1;
      case OrderStatus.shipped:
        return 2;
      case OrderStatus.outForDelivery:
        return 3;
      case OrderStatus.delivered:
        return 4;
    }
  }
}

extension OrderStatusExtension on OrderStatus {
  String get displayName => this.displayName;
  int get stepIndex => this.stepIndex;
}

class OrderModel {
  final String id;
  final String date;
  final OrderStatus status;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String recipientName;
  final String phone;
  final String deliveryAddress;
  final String paymentMethod;
  final String estimatedDelivery;

  OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.recipientName,
    required this.phone,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.estimatedDelivery,
  });

  OrderModel copyWith({
    String? id,
    String? date,
    OrderStatus? status,
    List<CartItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    String? recipientName,
    String? phone,
    String? deliveryAddress,
    String? paymentMethod,
    String? estimatedDelivery,
  }) {
    return OrderModel(
      id: id ?? this.id,
      date: date ?? this.date,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
    );
  }
}
