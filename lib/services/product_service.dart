import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

typedef ProductMap = Map<String, dynamic>;

dynamic _deepConvert(dynamic value) {
  if (value is Map) {
    return value.map<String, dynamic>(
          (k, v) => MapEntry(k.toString(), _deepConvert(v)),
    );
  }
  if (value is List) {
    return value.map(_deepConvert).toList();
  }
  return value;
}

List<ProductMap> _parseProducts(Object? raw) {
  final result = <ProductMap>[];
  if (raw == null) return result;

  if (raw is Map) {
    raw.forEach((key, value) {
      if (value is Map) {
        final item = Map<String, dynamic>.from(_deepConvert(value) as Map);
        item['id'] = key.toString();
        result.add(item);
      }
    });
  } else if (raw is List) {
    for (var i = 0; i < raw.length; i++) {
      final value = raw[i];
      if (value is Map) {
        final item = Map<String, dynamic>.from(_deepConvert(value) as Map);
        item['id'] = i.toString();
        result.add(item);
      }
    }
  }

  result.sort((a, b) => (b['createdAt'] ?? '')
      .toString()
      .compareTo((a['createdAt'] ?? '').toString()));
  return result;
}

class ProductService {
  ProductService._();
  static final ProductService instance = ProductService._();

  static const String table = 'products';

  Stream<List<ProductMap>> watchProducts() {
    return FirebaseDatabase.instance
        .ref(table)
        .onValue
        .map((event) => _parseProducts(event.snapshot.value));
  }

  static int countInCategory(List<ProductMap> products, String categoryName) {
    final target = categoryName.toLowerCase();
    return products
        .where((p) => p.categoryName.toLowerCase() == target)
        .length;
  }
}

extension ProductMapX on Map<String, dynamic> {
  String _s(String key) => (this[key] ?? '').toString();

  double _d(String key) => double.tryParse(_s(key)) ?? 0;

  int _i(String key) {
    final asInt = int.tryParse(_s(key));
    if (asInt != null) return asInt;
    return double.tryParse(_s(key))?.toInt() ?? 0;
  }

  bool _b(String key) => this[key] == true || _s(key).toLowerCase() == 'true';

  String get id => _s('id');
  String get name => _s('name');
  String get brand => _s('brand');
  String get categoryId => _s('categoryId');
  String get categoryName => _s('categoryName');
  String get description => _s('description');
  String get imageUrl => _s('imageUrl');

  double get price => _d('price');

  double? get originalPrice {
    final v = double.tryParse(_s('originalPrice'));
    if (v == null || v <= price) return null;
    return v;
  }

  double get rating => _d('rating');
  int get reviewCount => _i('reviewCount');
  int get stock => _i('stock');
  bool get isFeatured => _b('isFeatured');

  List<String> get images {
    final raw = this['images'];
    final list = <String>[];
    if (raw is List) {
      for (final e in raw) {
        final s = (e ?? '').toString();
        if (s.isNotEmpty) list.add(s);
      }
    }
    if (list.isEmpty && imageUrl.isNotEmpty) list.add(imageUrl);
    return list;
  }

  List<String> get features {
    final raw = this['features'];
    if (raw is! List) return [];
    return raw
        .map((e) => (e ?? '').toString())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  List<Map<String, dynamic>> get reviews {
    final raw = this['reviews'];
    final items = raw is List
        ? raw
        : (raw is Map ? raw.values.toList() : <dynamic>[]);
    return items
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  String get sellerName {
    final v = _s('sellerName');
    return v.isEmpty ? 'Baby Shop Hub' : v;
  }

  double get sellerRating => _d('sellerRating');
  int get sellerRatingCount => _i('sellerRatingCount');

  bool get sellerIsVerified =>
      containsKey('sellerIsVerified') ? _b('sellerIsVerified') : true;
}

class ProductsStreamBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, List<ProductMap> products)
  builder;

  const ProductsStreamBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductMap>>(
      stream: ProductService.instance.watchProducts(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint('PRODUCTS STREAM ERROR: ${snapshot.error}');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.cloud_off_rounded,
                    size: 56,
                    color: AppColors.secondaryText,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Could not load products',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${snapshot.error}',
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryBlue),
          );
        }

        return builder(context, snapshot.data!);
      },
    );
  }
}