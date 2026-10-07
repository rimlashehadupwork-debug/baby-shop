import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';
import '../services/admin_product_service.dart';
import '../widgets/admin_widgets.dart';
import 'admin_product_form_screen.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final _service = AdminProductService.instance;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openForm([ProductModel? product]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AdminProductFormScreen(product: product)),
    );
  }

  Future<void> _delete(ProductModel product) async {
    final confirmed = await showAdminConfirm(
      context,
      title: 'Delete product?',
      message: '"${product.name}" will be removed from the catalog. This cannot be undone.',
      confirmLabel: 'Delete',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    _service.deleteProduct(product.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Product deleted')));
  }

  List<ProductModel> _filter(List<ProductModel> all) {
    final terms = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (terms.isEmpty) return all;
    return all.where((p) {
      final haystack = '${p.name} ${p.brand} ${p.categoryName}'.toLowerCase();
      return terms.every(haystack.contains);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AdminLoader(
      load: adminSimulatedLoad,
      builder: (context) => ValueListenableBuilder<List<ProductModel>>(
        valueListenable: _service.productsNotifier,
        builder: (context, all, _) {
          final products = _filter(all);

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
                child: products.isEmpty
                    ? AdminEmptyState(
                        icon: Icons.inventory_2_outlined,
                        title: all.isEmpty ? 'No products yet' : 'No products found',
                        message: all.isEmpty
                            ? 'Add your first product to start building the catalog.'
                            : 'Try a different name, brand or category.',
                        actionLabel: all.isEmpty ? 'Add Product' : null,
                        onAction: all.isEmpty ? () => _openForm() : null,
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                        itemCount: products.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _buildItem(products[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(ProductModel product) {
    final stock = _service.stockOf(product.id);
    final status = _service.statusOf(product.id);
    final statusColor = switch (status) {
      StockStatus.inStock => AppColors.success,
      StockStatus.lowStock => AppColors.warning,
      StockStatus.outOfStock => AppColors.error,
    };
    final statusLabel = switch (status) {
      StockStatus.inStock => 'In Stock',
      StockStatus.lowStock => 'Low Stock',
      StockStatus.outOfStock => 'Out of Stock',
    };

    return AdminCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminThumb(url: product.imageUrl, size: 60),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
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
                      '${product.brand}  •  ${product.categoryName}',
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
                formatMoney(product.price),
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
