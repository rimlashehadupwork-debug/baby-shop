import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class OrderService {
  static final OrderService instance = OrderService._internal();

  OrderService._internal() {
    _initMockOrders();
  }

  final List<OrderModel> _orders = [];
  final ValueNotifier<List<OrderModel>> ordersNotifier = ValueNotifier([]);

  List<OrderModel> get orders => List.unmodifiable(_orders);

  void _initMockOrders() {
    if (MockData.products.length >= 4) {
      _orders.addAll([
        OrderModel(
          id: '#BSH-84920',
          date: '12 Oct 2024, 09:30 AM',
          status: OrderStatus.outForDelivery,
          items: [
            CartItemModel(product: MockData.products[0], quantity: 2), // Pampers
            CartItemModel(product: MockData.products[3], quantity: 1), // Gerber Puree
          ],
          subtotal: 75.97,
          deliveryFee: 0.0,
          total: 75.97,
          recipientName: 'Sarah Khan',
          phone: '+1 (555) 234-5678',
          deliveryAddress: '123 Palm Avenue, Suite 4B, New York, NY 10001',
          paymentMethod: 'Demo Credit Card (Visa **** 4242)',
          estimatedDelivery: 'Today by 3:30 PM',
        ),
        OrderModel(
          id: '#BSH-72109',
          date: '10 Oct 2024, 02:15 PM',
          status: OrderStatus.shipped,
          items: [
            CartItemModel(product: MockData.products[6], quantity: 1), // Carter's Onesies
            CartItemModel(product: MockData.products[9], quantity: 1), // Fisher-Price Gym
          ],
          subtotal: 62.98,
          deliveryFee: 0.0,
          total: 62.98,
          recipientName: 'Sarah Khan',
          phone: '+1 (555) 234-5678',
          deliveryAddress: '123 Palm Avenue, Suite 4B, New York, NY 10001',
          paymentMethod: 'Cash on Delivery',
          estimatedDelivery: 'Tomorrow, 11:00 AM',
        ),
        OrderModel(
          id: '#BSH-61845',
          date: '28 Sep 2024, 11:00 AM',
          status: OrderStatus.delivered,
          items: [
            CartItemModel(product: MockData.products[12], quantity: 2), // Philips Avent Glass Bottles
          ],
          subtotal: 43.98,
          deliveryFee: 4.99,
          total: 48.97,
          recipientName: 'Sarah Khan',
          phone: '+1 (555) 234-5678',
          deliveryAddress: '123 Palm Avenue, Suite 4B, New York, NY 10001',
          paymentMethod: 'Demo Mobile Wallet',
          estimatedDelivery: 'Delivered on 30 Sep 2024',
        ),
      ]);
      ordersNotifier.value = List.unmodifiable(_orders);
    }
  }

  void addOrder(OrderModel order) {
    _orders.insert(0, order);
    ordersNotifier.value = List.unmodifiable(_orders);
  }

  void updateOrderStatus(String orderId, OrderStatus status) {
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      _orders[index] = _orders[index].copyWith(status: status);
      ordersNotifier.value = List.unmodifiable(_orders);
    }
  }
}
