import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';

class CategoryService {
  CategoryService._() {
    _listen();
  }

  static final CategoryService instance = CategoryService._();

  static const String table = 'categories';

  static const Map<String, IconData> iconOptions = {
    'child_care': Icons.child_care_rounded,
    'rice_bowl': Icons.rice_bowl_rounded,
    'checkroom': Icons.checkroom_rounded,
    'toys': Icons.toys_rounded,
    'sanitizer': Icons.sanitizer_rounded,
    'bed': Icons.bed_rounded,
    'bathtub': Icons.bathtub_rounded,
    'stroller': Icons.stroller_rounded,
    'medical': Icons.medical_services_rounded,
    'category': Icons.category_rounded,
  };

  static const Map<String, Color> colorOptions = {
    'blue': AppColors.primaryBlue,
    'pink': AppColors.secondaryPink,
    'sky': AppColors.accentBlue,
    'orange': AppColors.warning,
    'green': AppColors.success,
    'red': AppColors.error,
  };

  static String iconKeyFor(IconData icon) {
    for (final e in iconOptions.entries) {
      if (e.value == icon) return e.key;
    }
    return 'category';
  }

  static String colorKeyFor(Color color) {
    for (final e in colorOptions.entries) {
      if (e.value == color) return e.key;
    }
    return 'blue';
  }

  final ValueNotifier<List<CategoryModel>> notifier =
  ValueNotifier<List<CategoryModel>>(MockData.categories);

  List<CategoryModel> get categories => notifier.value;

  void _listen() {
    try {
      FirebaseDatabase.instance.ref(table).onValue.listen(
            (event) {
          final parsed = _parse(event.snapshot.value);
          notifier.value = parsed.isEmpty ? MockData.categories : parsed;
        },
        onError: (e) => debugPrint('CATEGORIES STREAM ERROR: $e'),
      );
    } catch (e) {
      debugPrint('CATEGORIES LISTEN ERROR: $e');
    }
  }

  List<CategoryModel> _parse(Object? raw) {
    if (raw is! Map) return [];
    final rows = <MapEntry<int, CategoryModel>>[];
    raw.forEach((key, value) {
      if (value is! Map) return;
      final name = (value['name'] ?? '').toString().trim();
      if (name.isEmpty) return;
      rows.add(MapEntry(
        int.tryParse('${value['order'] ?? 0}') ?? 0,
        CategoryModel(
          id: key.toString(),
          name: name,
          icon: iconOptions[(value['icon'] ?? '').toString()] ??
              Icons.category_rounded,
          description: (value['description'] ?? '').toString(),
          itemCount: 0,
          badgeColor: colorOptions[(value['color'] ?? '').toString()] ??
              AppColors.primaryBlue,
        ),
      ));
    });
    rows.sort((a, b) {
      final c = a.key.compareTo(b.key);
      return c != 0 ? c : a.value.name.compareTo(b.value.name);
    });
    return rows.map((e) => e.value).toList();
  }

  String _slug(String name) => name
      .trim()
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');

  Future<void> save({
    String? id,
    required String name,
    required String iconKey,
    required String colorKey,
    required String description,
    int order = 0,
  }) async {
    final key = (id != null && id.isNotEmpty) ? id : _slug(name);
    await FirebaseDatabase.instance.ref('$table/$key').set({
      'name': name.trim(),
      'icon': iconKey,
      'color': colorKey,
      'description': description.trim(),
      'order': order,
    });
  }

  Future<void> delete(String id) async {
    await FirebaseDatabase.instance.ref('$table/$id').remove();
  }

  Future<void> seedDefaults() async {
    var i = 0;
    for (final c in MockData.categories) {
      await save(
        id: c.id,
        name: c.name,
        iconKey: iconKeyFor(c.icon),
        colorKey: colorKeyFor(c.badgeColor),
        description: c.description,
        order: i++,
      );
    }
  }
}