import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../services/firebase_supabase_service.dart';
import '../widgets/admin_widgets.dart';
import 'admin_product_form_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  static const _table = 'products';

  final _service = FirebaseSupabaseService();
  final _searchController = TextEditingController();
  String _query = '';

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _all = []; // har map mein 'id' bhi hai

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final raw = await _service.read(tableName: _table);
      final list = <Map<String, dynamic>>[];
      if (raw is Map) {
        raw.forEach((key, value) {
          if (value is Map) {
            list.add({...Map<String, dynamic>.from(value), 'id': key.toString()});
          }
        });
      }
      if (!mounted) return;
      setState(() {
        _all = list;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _openForm([Map<String, dynamic>? product]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AdminProductFormScreen(product: product),
      ),
    );
    if (changed == true && mounted) _load(silent: true);
  }

  Future<void> _delete(Map<String, dynamic> product) async {
    final confirmed = await showAdminConfirm(
      context,
      title: 'Delete product?',
      message:
      '"${product['name'] ?? ''}" will be removed from the catalog. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;

    try {
      await _service.deleteById(tableName: _table, id: product['id']);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Product deleted')));
      _load(silent: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final terms = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (terms.isEmpty) return _all;
    return _all.where((p) {
      final haystack =
      '${p['name'] ?? ''} ${p['brand'] ?? ''} ${p['categoryName'] ?? ''}'
          .toLowerCase();
      return terms.every(haystack.contains);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 40, color: AppColors.error),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.secondaryText)),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () => _load(), child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final products = _filtered;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: 'Search by name, brand or category...',
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.secondaryText),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                tooltip: 'Clear',
                icon: const Icon(Icons.close_rounded,
                    size: 20, color: AppColors.secondaryText),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              )
                  : null,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${products.length} ${products.length == 1 ? 'product' : 'products'}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _openForm(),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Add Product'),
              ),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _load(silent: true),
            child: products.isEmpty
                ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: 360,
                  child: AdminEmptyState(
                    icon: Icons.inventory_2_outlined,
                    title: _all.isEmpty
                        ? 'No products yet'
                        : 'No products found',
                    message: _all.isEmpty
                        ? 'Add your first product to start building the catalog.'
                        : 'Try a different name, brand or category.',
                    actionLabel: _all.isEmpty ? 'Add Product' : null,
                    onAction: _all.isEmpty ? () => _openForm() : null,
                  ),
                ),
              ],
            )
                : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: products.length,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _buildItem(products[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItem(Map<String, dynamic> product) {
    final name = (product['name'] ?? 'Unnamed').toString();
    final brand = (product['brand'] ?? '').toString();
    final category = (product['categoryName'] ?? '').toString();
    final imageUrl = (product['imageUrl'] ?? '').toString();
    final price = double.tryParse('${product['price'] ?? 0}') ?? 0;
    final stock = int.tryParse('${product['stock'] ?? 0}') ?? 0;

    final Color statusColor;
    final String statusLabel;
    if (stock <= 0) {
      statusColor = AppColors.error;
      statusLabel = 'Out of Stock';
    } else if (stock <= 5) {
      statusColor = AppColors.warning;
      statusLabel = 'Low Stock';
    } else {
      statusColor = AppColors.success;
      statusLabel = 'In Stock';
    }

    return AdminCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminThumb(url: imageUrl, size: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$brand  •  $category',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                formatMoney(price),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Stock: $stock',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
              StatusBadge(label: statusLabel, color: statusColor),
            ],
          ),
          const SizedBox(height: 4),
          const Divider(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _openForm(product),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Edit'),
                ),
              ),
              Container(width: 1, height: 22, color: AppColors.border),
              Expanded(
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  onPressed: () => _delete(product),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}