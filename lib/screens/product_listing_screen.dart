import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../theme/app_theme.dart';
import '../widgets/product_tile.dart';
import 'product_details_screen.dart';

class ProductListingScreen extends StatefulWidget {
  final String? selectedCategory;

  const ProductListingScreen({
    super.key,
    this.selectedCategory,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  late String _currentCategory;
  String _sortBy = 'Popularity';

  List<String> get _categories => [
    'All',
    ...CategoryService.instance.categories.map((c) => c.name),
  ];

  @override
  void initState() {
    super.initState();
    _currentCategory = widget.selectedCategory ?? 'All';
    CategoryService.instance.notifier.addListener(_onCategoriesChanged);
  }

  @override
  void dispose() {
    CategoryService.instance.notifier.removeListener(_onCategoriesChanged);
    super.dispose();
  }

  void _onCategoriesChanged() {
    if (mounted) setState(() {});
  }

  List<ProductMap> _applyFilters(List<ProductMap> all) {
    List<ProductMap> list = List<ProductMap>.of(all);

    if (_currentCategory != 'All') {
      final target = _currentCategory.toLowerCase();
      list = list.where((p) => p.categoryName.toLowerCase() == target).toList();
    }

    if (_sortBy == 'Price: Low to High') {
      list.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortBy == 'Price: High to Low') {
      list.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortBy == 'Highest Rated') {
      list.sort((a, b) => b.rating.compareTo(a.rating));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _currentCategory == 'All' ? 'All Infant Products' : _currentCategory,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ProductsStreamBuilder(
          builder: (context, allProducts) {
            final products = _applyFilters(allProducts);

            return Column(
              children: [
                Container(
                  height: 52,
                  color: AppColors.surface,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = cat == _currentCategory;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: FilterChip(
                          selected: isSelected,
                          label: Text(cat),
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.primaryText,
                          ),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.inputBackground,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppColors.primaryBlue : AppColors.border,
                            ),
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _currentCategory = cat;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${products.length} Products Available',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondaryText,
                        ),
                      ),
                      PopupMenuButton<String>(
                        initialValue: _sortBy,
                        onSelected: (value) {
                          setState(() {
                            _sortBy = value;
                          });
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'Popularity',
                            child: Text('Sort by: Popularity'),
                          ),
                          const PopupMenuItem(
                            value: 'Highest Rated',
                            child: Text('Sort by: Highest Rated'),
                          ),
                          const PopupMenuItem(
                            value: 'Price: Low to High',
                            child: Text('Sort by: Price: Low to High'),
                          ),
                          const PopupMenuItem(
                            value: 'Price: High to Low',
                            child: Text('Sort by: Price: High to Low'),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.sort_rounded, size: 16, color: AppColors.primaryBlue),
                              const SizedBox(width: 4),
                              Text(
                                _sortBy,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const Icon(Icons.arrow_drop_down_rounded, size: 18, color: AppColors.secondaryText),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: products.isEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          size: 60,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No products found in this category',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                        if (_currentCategory != 'All') ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(160, 42),
                            ),
                            onPressed: () {
                              setState(() {
                                _currentCategory = 'All';
                              });
                            },
                            child: const Text('Show All Products'),
                          ),
                        ],
                      ],
                    ),
                  )
                      : GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return ProductTile(
                        product: product,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailsScreen(product: product),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}