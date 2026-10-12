import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class ReviewService {
  ReviewService._();

  static final ReviewService instance = ReviewService._();

  static const String table = 'product_reviews';

  static const List<String> _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  String _formatDate(String iso) {
    final d = DateTime.tryParse(iso);
    if (d == null) return 'Recently';
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
      final dateStr = (m['timestamp'] ?? m['createdAt'] ?? '').toString();
      m['date'] = _formatDate(dateStr);
      rows.add(m);
    });
    rows.sort((a, b) {
      final tA = (a['timestamp'] ?? a['createdAt'] ?? '').toString();
      final tB = (b['timestamp'] ?? b['createdAt'] ?? '').toString();
      return tB.compareTo(tA);
    });
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
      final now = DateTime.now().toIso8601String();
      await ref.set({
        'userId': user.uid,
        'userName': userName.trim().isEmpty ? 'Anonymous Parent' : userName.trim(),
        'rating': rating,
        'comment': comment.trim(),
        'timestamp': now,
        'createdAt': now,
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

  Future<bool> rateSeller({
    required String productId,
    required String sellerName,
    required double rating,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || productId.isEmpty || sellerName.isEmpty) return false;

    try {
      final safeSellerName = sellerName.replaceAll(RegExp(r'[.#$\[\]/]'), '_');
      final ref = FirebaseDatabase.instance.ref('seller_ratings/$safeSellerName').push();
      final now = DateTime.now().toIso8601String();
      await ref.set({
        'userId': user.uid,
        'rating': rating,
        'timestamp': now,
      });

      final snap = await FirebaseDatabase.instance.ref('seller_ratings/$safeSellerName').get();
      if (snap.exists && snap.value is Map) {
        final map = snap.value as Map;
        double sum = 0;
        int count = 0;
        map.forEach((k, v) {
          if (v is Map) {
            final r = double.tryParse('${v['rating'] ?? 0}') ?? 0;
            if (r > 0) {
              sum += r;
              count++;
            }
          }
        });
        if (count > 0) {
          final avgSellerRating = double.parse((sum / count).toStringAsFixed(1));
          await FirebaseDatabase.instance.ref('products/$productId').update({
            'sellerRating': avgSellerRating,
            'sellerRatingCount': count,
          });
        }
      }
      return true;
    } catch (e) {
      debugPrint('SELLER RATING ERROR: $e');
      return false;
    }
  }
}
