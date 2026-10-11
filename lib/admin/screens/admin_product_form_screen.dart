import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/category_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../services/firebase_supabase_service.dart';
import '../widgets/admin_widgets.dart';

class AdminProductFormScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  const AdminProductFormScreen({super.key, this.product});

  @override
  State<AdminProductFormScreen> createState() => _AdminProductFormScreenState();
}

class _AdminProductFormScreenState extends State<AdminProductFormScreen> {
  static const _table = 'products';
  static const _bucket = 'products';

  final _formKey = GlobalKey<FormState>();
  final _service = FirebaseSupabaseService();
  final _picker = ImagePicker();

  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  String? _category;
  bool _saving = false;

  String _existingUrl = '';
  Uint8List? _pickedBytes;
  String _pickedName = '';
  String? _pickedMime;
  String? _imageError;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    String s(String key) => (p?[key] ?? '').toString();

    _existingUrl = s('imageUrl');
    _nameController = TextEditingController(text: s('name'));
    _brandController = TextEditingController(text: s('brand'));
    _descriptionController = TextEditingController(text: s('description'));
    final price = double.tryParse(s('price'));
    _priceController = TextEditingController(
        text: price != null ? price.toStringAsFixed(2) : '');
    _stockController = TextEditingController(text: p != null ? s('stock') : '');

    final names = CategoryService.instance.categories.map((c) => c.name).toList();
    _category = names.contains(s('categoryName')) ? s('categoryName') : null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        imageQuality: 85,
      );
      if (file == null) return;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      debugPrint(
          '[IMAGE PICK] name=${file.name}, mime=${file.mimeType}, bytes=${bytes.length}');
      setState(() {
        _pickedBytes = bytes;
        _pickedName = file.name;
        _pickedMime = file.mimeType;
        _imageError = null;
      });
    } catch (e, st) {
      debugPrint('❌ IMAGE PICK FAILED');
      debugPrint('ERROR TYPE: ${e.runtimeType}');
      debugPrint('ERROR: $e');
      debugPrint('STACK:\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('Image pick failed: $e')));
    }
  }

  String get _pickedExtension {
    final dot = _pickedName.lastIndexOf('.');
    return dot == -1 ? '.jpg' : _pickedName.substring(dot);
  }

  Future<void> _save() async {
    if (_saving) return;

    final formOk = _formKey.currentState!.validate();
    final hasImage = _pickedBytes != null || _existingUrl.isNotEmpty;
    setState(() => _imageError = hasImage ? null : 'Product image is required');
    if (!formOk || !hasImage) return;

    setState(() => _saving = true);

    String step = 'START';
    try {
      String imageUrl = _existingUrl;
      if (_pickedBytes != null) {
        step = 'SUPABASE UPLOAD';
        debugPrint(
            '[$step] bytes=${_pickedBytes!.length}, ext=$_pickedExtension, mime=$_pickedMime, bucket=$_bucket');
        imageUrl = await _service.uploadFile(
          bytes: _pickedBytes!,
          bucketName: _bucket,
          extension: _pickedExtension,
          contentType: _pickedMime,
        );
        debugPrint('[$step] OK url=$imageUrl');
      }

      step = 'PREPARE DATA';
      final category =
      CategoryService.instance.categories.firstWhere((c) => c.name == _category);
      final price = double.parse(_priceController.text.trim());
      final stock = int.parse(_stockController.text.trim());
      final old = widget.product;

      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'categoryId': category.id,
        'categoryName': category.name,
        'price': price,
        'imageUrl': imageUrl,
        'description': _descriptionController.text.trim(),
        'stock': stock,
      };

      if (old == null) {
        step = 'RTDB CREATE';
        debugPrint('[$step] table=$_table');
        await _service.create(tableName: _table, data: {
          ...data,
          'images': [imageUrl],
          'features': [],
          'rating': 0,
          'reviewCount': 0,
          'isFeatured': false,
          'createdAt': DateTime.now().toIso8601String(),
        });
        debugPrint('[$step] OK');
      } else {
        step = 'RTDB UPDATE';
        final oldOriginal = double.tryParse('${old['originalPrice'] ?? ''}');
        final keepOriginal = oldOriginal != null && oldOriginal > price;

        final oldImages = old['images'];
        final extraImages =
        (oldImages is List) ? oldImages.skip(1).toList() : [];

        debugPrint('[$step] id=${old['id']}');
        await _service.update(
          tableName: _table,
          id: old['id'].toString(),
          data: {
            ...data,
            'images': [imageUrl, ...extraImages],
            'originalPrice': keepOriginal ? oldOriginal : null,
          },
        );
        debugPrint('[$step] OK');
      }

      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context, true);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
              content: Text(_isEdit ? 'Product updated' : 'Product added')),
        );
    } catch (e, st) {
      debugPrint('❌ SAVE FAILED at step: $step');
      debugPrint('ERROR TYPE: ${e.runtimeType}');
      debugPrint('ERROR: $e');
      debugPrint('STACK:\n$st');

      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Failed at [$step]: $e'),
            duration: const Duration(seconds: 8),
          ),
        );
    }
  }

  Widget _imagePreview() {
    const size = 120.0;
    if (_pickedBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.memory(_pickedBytes!,
            width: size, height: size, fit: BoxFit.cover),
      );
    }
    return AdminThumb(url: _existingUrl, size: size);
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
                          Center(child: _imagePreview()),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: _saving ? null : _pickImage,
                            icon: const Icon(Icons.photo_library_outlined,
                                size: 20),
                            label: Text(
                              (_pickedBytes != null || _existingUrl.isNotEmpty)
                                  ? 'Change Image'
                                  : 'Choose Image',
                            ),
                          ),
                          if (_imageError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _imageError!,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.error),
                            ),
                          ],
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
                              if (v.length < 3) {
                                return 'Name must be at least 3 characters';
                              }
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
                            items: CategoryService.instance.categories
                                .map((c) => DropdownMenuItem<String>(
                              value: c.name,
                              child: Text(c.name),
                            ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _category = value),
                            validator: (value) => value == null
                                ? 'Please select a category'
                                : null,
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
                                  keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                                  validator: (value) {
                                    final v =
                                    double.tryParse(value?.trim() ?? '');
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