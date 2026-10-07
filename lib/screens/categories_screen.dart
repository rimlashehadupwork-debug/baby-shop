import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/category_model.dart';
import '../theme/app_theme.dart';
import 'product_listing_screen.dart';

class CategoriesScreen extends StatelessWidget {
  final bool showAppBar;

  const CategoriesScreen({
    super.key,
    this.showAppBar = true,
  });

  void _onCategorySelect(BuildContext context, CategoryModel category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListingScreen(
          selectedCategory: category.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = MockData.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: showAppBar
          ? AppBar(
              title: const Text('Infant Product Categories'),
            )
          : null,
      body: SafeArea(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _onCategorySelect(context, category),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Category Icon Container
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: category.badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            category.icon,
                            color: category.badgeColor,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Title and Description
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    category.name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryText,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: category.badgeColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '${category.itemCount} items',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: category.badgeColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                category.description,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.secondaryText,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Action Icon
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.secondaryText,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
