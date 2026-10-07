import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/product_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../services/admin_product_service.dart';
import '../widgets/admin_widgets.dart';

/// Add Product (product == null) or Edit Product (product provided).
class AdminProductFormScreen extends StatefulWidget {
  final ProductModel? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AdminProductService.instance;

  late final TextEditingController _imageController;
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  String? _category;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _imageController = TextEditingController(text: p?.imageUrl ?? '');
    _nameController = TextEditingController(text: p?.name ?? '');
    _brandController = TextEditingController(text: p?.brand ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toStringAsFixed(2) : '');
    _stockController =
        TextEditingController(text: p != null ? '${_service.stockOf(p.id)}' : '');
    final names = MockData.categories.map((c) => c.name).toList();
    _category = (p != null && names.contains(p.categoryName)) ? p.categoryName : null;
  }

  @override
  void dispose() {
    _imageController.dispose();
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final category = MockData.categories.firstWhere((c) => c.name == _category);
    final price = double.parse(_priceController.text.trim());
    final stock = int.parse(_stockController.text.trim());
    final imageUrl = _imageController.text.trim();
    final old = widget.product;

    if (old == null) {
      _service.addProduct(
        ProductModel(
          id: _service.newId(),
          name: _nameController.text.trim(),
          brand: _brandController.text.trim(),
          categoryId: category.id,
          categoryName: category.name,
          price: price,
          rating: 0,
          reviewCount: 0,
          imageUrl: imageUrl,
          images: [imageUrl],
          description: _descriptionController.text.trim(),
          features: const [],
          isFeatured: false,
          reviews: const [],
        ),
        stock,
      );
    } else {
      final keepOriginal = old.originalPrice != null && old.originalPrice! > price;
      _service.updateProduct(
        ProductModel(
          id: old.id,
          name: _nameController.text.trim(),
          brand: _brandController.text.trim(),
          categoryId: category.id,
          categoryName: category.name,
          price: price,
          originalPrice: keepOriginal ? old.originalPrice : null,
          rating: old.rating,
          reviewCount: old.reviewCount,
          imageUrl: imageUrl,
          images: [imageUrl, ...old.images.skip(1)],
          description: _descriptionController.text.trim(),
          features: old.features,
          isFeatured: old.isFeatured,
          reviews: old.reviews,
          sellerName: old.sellerName,
          sellerRating: old.sellerRating,
          sellerRatingCount: old.sellerRatingCount,
          sellerIsVerified: old.sellerIsVerified,
        ),
        stock,
      );
    }

    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(_isEdit ? 'Product updated' : 'Product added')),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(_isEdit ? 'Edit Product' : 'Add Product')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image preview
                    AdminCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Product Image',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: AdminThumb(
                              url: _imageController.text.trim(),
                              size: 120,
                            ),
                          ),
                          const SizedBox(height: 16),
                          AdminField(
                            label: 'Image URL',
                            controller: _imageController,
                            hint: 'https://...',
                            keyboardType: TextInputType.url,
                            prefixIcon: Icons.link_rounded,
                            onChanged: (_) => setState(() {}),
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Product image is required';
                              if (!v.startsWith('http://') && !v.startsWith('https://')) {
                                return 'Enter a valid image link (http or https)';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    AdminCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AdminField(
                            label: 'Product Name',
                            controller: _nameController,
                            hint: 'e.g. Pampers Swaddlers Size 2',
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Product name is required';
                              if (v.length < 3) return 'Name must be at least 3 characters';
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          AdminField(
                            label: 'Brand',
                            controller: _brandController,
                            hint: 'e.g. Pampers',
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Brand is required'
                                    : null,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'Category',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<String>(
                            initialValue: _category,
                            isExpanded: true,
                            hint: const Text('Select a category'),
                            decoration: const InputDecoration(),
                            items: MockData.categories
                                .map((c) => DropdownMenuItem<String>(
                                      value: c.name,
                                      child: Text(c.name),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(() => _category = value),
                            validator: (value) =>
                                value == null ? 'Please select a category' : null,
                          ),
                          const SizedBox(height: 18),
                          AdminField(
                            label: 'Description',
                            controller: _descriptionController,
                            hint: 'Describe the product for customers',
                            maxLines: 4,
                            keyboardType: TextInputType.multiline,
                            validator: (value) {
                              final v = value?.trim() ?? '';
                              if (v.isEmpty) return 'Description is required';
                              if (v.length < 10) {
                                return 'Description must be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: AdminField(
                                  label: 'Price',
                                  controller: _priceController,
                                  hint: '0.00',
                                  prefixText: '\$ ',
                                  keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true),
                                  validator: (value) {
                                    final v = double.tryParse(value?.trim() ?? '');
                                    if (v == null) return 'Enter a valid price';
                                    if (v <= 0) return 'Price must be above 0';
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: AdminField(
                                  label: 'Stock Quantity',
                                  controller: _stockController,
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) {
                                    final v = int.tryParse(value?.trim() ?? '');
                                    if (v == null) return 'Enter a whole number';
                                    if (v < 0) return 'Cannot be negative';
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      text: 'Save Product',
                      isLoading: _saving,
                      onPressed: _save,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondaryText,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      onPressed: _saving ? null : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
