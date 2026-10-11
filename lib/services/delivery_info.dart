import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class DeliveryInfo extends ChangeNotifier {
  DeliveryInfo._() {
    FirebaseAuth.instance.authStateChanges().listen((_) => load());
  }

  static final DeliveryInfo instance = DeliveryInfo._();

  String name = '';
  String phone = '';
  String address = '';

  bool get isComplete =>
      name.trim().isNotEmpty &&
          phone.trim().isNotEmpty &&
          address.trim().isNotEmpty;

  DatabaseReference? get _ref {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return FirebaseDatabase.instance.ref('users/${user.uid}');
  }

  Future<void> load() async {
    name = '';
    phone = '';
    address = '';

    final user = FirebaseAuth.instance.currentUser;
    final ref = _ref;

    if (user != null && ref != null) {
      try {
        final snap = await ref.get();
        final value = snap.value;
        if (value is Map) {
          name = (value['name'] ?? '').toString();
          phone = (value['phone'] ?? '').toString();
          address = (value['address'] ?? '').toString();
        }
      } catch (e) {
        debugPrint('DELIVERY INFO LOAD ERROR: $e');
      }
      if (name.isEmpty) name = user.displayName ?? '';
    }

    notifyListeners();
  }

  Future<void> save({
    required String name,
    required String phone,
    required String address,
  }) async {
    this.name = name.trim();
    this.phone = phone.trim();
    this.address = address.trim();
    notifyListeners();

    final ref = _ref;
    if (ref == null) return;

    try {
      await ref.update({
        'name': this.name,
        'phone': this.phone,
        'address': this.address,
      });
    } catch (e) {
      debugPrint('DELIVERY INFO SAVE ERROR: $e');
    }
  }
}