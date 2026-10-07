import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/product_model.dart';
import '../theme/app_theme.dart';
import '../widgets/product_card.dart';
import 'product_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final bool showAppBar;

  const SearchScreen({
    super.key,
    this.showAppBar = true,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// One simple search across product name, brand and category.
  /// Every word typed must appear somewhere in those three fields.
  List<ProductModel> get _searchResults {
    final terms = _query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();

    if (terms.isEmpty) return MockData.products;

    return MockData.products.where((p) {
      final haystack =
      '${p.name} ${p.brand} ${p.categoryName}'.toLowerCase();
      return terms.every(haystack.contains);
    }).toList();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => _query = '');
  }

  @override
  Widget build(BuildContext context) {
    final results = _searchResults;
    final hasQuery = _query.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.showAppBar
          ? AppBar(
        title: const Text('Search'),
      )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: TextField(
                controller: _searchController,
                autofocus: widget.showAppBar,
                textInputAction: TextInputAction.search,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.primaryText,
                ),
                decoration: InputDecoration(
                  hintText: 'Search products, brands or categories...',
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.secondaryText,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                    tooltip: 'Clear',
                    icon: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.secondaryText,
                    ),
                    onPressed: _clearSearch,
                  )
                      : null,
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),

            // Results heading
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasQuery ? 'Search Results' : 'All Products',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                    ),
                  ),
                  Text(
                    '${results.length} ${results.length == 1 ? 'item' : 'items'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            // Results or empty state
            Expanded(
              child: results.isEmpty
                  ? Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: AppColors.softBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 44,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'No products found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'We couldn\'t find anything for "${_query.trim()}".\nTry a different keyword or browse our categories.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.secondaryText,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(200, 48),
                        ),
                        onPressed: _clearSearch,
                        child: const Text('Clear Search'),
                      ),
                    ],
                  ),
                ),
              )
                  : GridView.builder(
                physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.58,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                ),
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final product = results[index];
                  return ProductCard(
                    product: product,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductDetailsScreen(product: product),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}