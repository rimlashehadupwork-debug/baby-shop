import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class ReviewService {
  ReviewService._();

  static final ReviewService instance = ReviewService._();

  static const String table = 'reviews';

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    final l = d.toLocal();
    return '${l.day.toString().padLeft(2, '0')} ${_months[l.month - 1]} ${l.year}';
  }

  List<Map<String, dynamic>> _parse(Object? raw) {
    if (raw is! Map) return [];
    final rows = <Map<String, dynamic>>[];
    raw.forEach((key, value) {
      if (value is! Map) return;
      final m = value.map<String, dynamic>((k, v) => MapEntry(k.toString(), v));
      m['id'] = key.toString();
      m['date'] = _formatDate((m['createdAt'] ?? '').toString());
      rows.add(m);
    });
    rows.sort((a, b) =>
        (b['createdAt'] ?? '').toString().compareTo((a['createdAt'] ?? '').toString()));
    return rows;
  }

  Stream<List<Map<String, dynamic>>> watchReviews(String productId) {
    return FirebaseDatabase.instance
        .ref('$table/$productId')
        .onValue
        .map((event) => _parse(event.snapshot.value));
  }

  Future<bool> addReview({
    required String productId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || productId.isEmpty) return false;

    try {
      final ref = FirebaseDatabase.instance.ref('$table/$productId').push();
      await ref.set({
        'userId': user.uid,
        'userName': userName.trim().isEmpty ? 'Anonymous Parent' : userName.trim(),
        'rating': rating,
        'comment': comment.trim(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('REVIEW SAVE ERROR: $e');
      return false;
    }

    await _syncProductRating(productId);
    return true;
  }

  Future<void> _syncProductRating(String productId) async {
    try {
      final snap = await FirebaseDatabase.instance.ref('$table/$productId').get();
      final list = _parse(snap.value);
      if (list.isEmpty) return;
      final sum = list.fold<double>(
        0,
            (s, r) => s + (double.tryParse('${r['rating'] ?? 0}') ?? 0),
      );
      final avg = double.parse((sum / list.length).toStringAsFixed(1));
      await FirebaseDatabase.instance.ref('products/$productId').update({
        'rating': avg,
        'reviewCount': list.length,
      });
    } catch (e) {
      debugPrint('REVIEW RATING SYNC ERROR: $e');
    }
  }
}