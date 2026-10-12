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
  String profilePicture = '';
  String email = '';
  bool isLoading = false;

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      name = '';
      phone = '';
      address = '';
      profilePicture = '';
      email = '';
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    notifyListeners();

    email = user.email ?? '';

    final ref = _ref;
    if (ref != null) {
      try {
        final snap = await ref.get();
        final value = snap.value;
        if (value is Map) {
          final data = Map<String, dynamic>.from(value as Map);
          name = (data['name'] ?? '').toString();
          phone = (data['phone'] ?? '').toString();
          address = (data['address'] ?? '').toString();
          profilePicture = (data['profilePicture'] ?? data['photoUrl'] ?? '').toString();
          if (email.isEmpty) {
            email = (data['email'] ?? '').toString();
          }
        }
      } catch (e) {
        debugPrint('DELIVERY INFO LOAD ERROR: $e');
      }
    }

    if (name.isEmpty) name = user.displayName ?? '';
    if (profilePicture.isEmpty) profilePicture = user.photoURL ?? '';

    isLoading = false;
    notifyListeners();
  }

  Future<void> save({
    required String name,
    required String phone,
    required String address,
    String? profilePicture,
  }) async {
    this.name = name.trim();
    this.phone = phone.trim();
    this.address = address.trim();
    if (profilePicture != null) {
      this.profilePicture = profilePicture.trim();
    }
    notifyListeners();

    final ref = _ref;
    if (ref == null) return;

    try {
      final Map<String, dynamic> updates = {
        'name': this.name,
        'phone': this.phone,
        'address': this.address,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (profilePicture != null) {
        updates['profilePicture'] = this.profilePicture;
      }
      await ref.update(updates);
    } catch (e) {
      debugPrint('DELIVERY INFO SAVE ERROR: $e');
      rethrow;
    }
  }
}