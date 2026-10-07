import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';

enum AdminUserStatus { active, suspended }

class AdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String joined;
  final String address;
  final String lastActive;
  final int baseOrders;
  final double baseSpent;
  final int openInquiries;
  AdminUserStatus status;

  AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.joined,
    required this.address,
    required this.lastActive,
    this.baseOrders = 0,
    this.baseSpent = 0,
    this.openInquiries = 0,
    this.status = AdminUserStatus.active,
  });
}

/// Demo registered-user data for the admin panel.
class AdminUserService {
  static final AdminUserService instance = AdminUserService._internal();

  AdminUserService._internal() {
    usersNotifier.value = List.unmodifiable(_users);
  }

  final List<AdminUser> _users = [
    AdminUser(
      id: 'user_1',
      name: 'Sarah Khan',
      email: 'sarah@example.com',
      phone: '+1 (555) 234-5678',
      joined: '15 Aug 2024',
      address: '123 Palm Avenue, Suite 4B, New York, NY 10001',
      lastActive: 'Today',
      openInquiries: 1,
    ),
    AdminUser(
      id: 'user_2',
      name: 'Ayesha Malik',
      email: 'ayesha.malik@example.com',
      phone: '+92 300 1234567',
      joined: '02 Sep 2024',
      address: 'Block 7, Gulshan-e-Iqbal, Karachi',
      lastActive: 'Yesterday',
      baseOrders: 4,
      baseSpent: 212.40,
    ),
    AdminUser(
      id: 'user_3',
      name: 'Daniel Carter',
      email: 'daniel.carter@example.com',
      phone: '+1 (555) 981-2200',
      joined: '21 Sep 2024',
      address: '48 Maple Street, Austin, TX 73301',
      lastActive: '3 days ago',
      baseOrders: 2,
      baseSpent: 96.50,
    ),
    AdminUser(
      id: 'user_4',
      name: 'Fatima Noor',
      email: 'fatima.noor@example.com',
      phone: '+92 321 7654321',
      joined: '30 Sep 2024',
      address: 'House 12, Street 5, F-8, Islamabad',
      lastActive: 'Today',
      baseOrders: 1,
      baseSpent: 34.99,
      openInquiries: 2,
    ),
    AdminUser(
      id: 'user_5',
      name: 'Michael Brown',
      email: 'michael.brown@example.com',
      phone: '+1 (555) 400-7788',
      joined: '05 Sep 2024',
      address: '9 Lakeview Road, Chicago, IL 60601',
      lastActive: '2 weeks ago',
      baseOrders: 1,
      baseSpent: 28.00,
      status: AdminUserStatus.suspended,
    ),
    AdminUser(
      id: 'user_6',
      name: 'Zainab Ali',
      email: 'zainab.ali@example.com',
      phone: '+92 333 5550101',
      joined: '08 Oct 2024',
      address: 'Flat 3B, Clifton Block 4, Karachi',
      lastActive: 'Today',
    ),
  ];

  final ValueNotifier<List<AdminUser>> usersNotifier = ValueNotifier([]);

  List<AdminUser> get users => List.unmodifiable(_users);

  AdminUser? byId(String id) {
    for (final u in _users) {
      if (u.id == id) return u;
    }
    return null;
  }

  void setStatus(String id, AdminUserStatus status) {
    final user = byId(id);
    if (user == null) return;
    user.status = status;
    usersNotifier.value = List.unmodifiable(_users);
  }

  List<OrderModel> ordersFor(AdminUser user) => OrderService.instance.orders
      .where((o) => o.recipientName == user.name)
      .toList();

  int orderCount(AdminUser user) => user.baseOrders + ordersFor(user).length;

  double totalSpent(AdminUser user) =>
      user.baseSpent + ordersFor(user).fold<double>(0, (sum, o) => sum + o.total);
}
