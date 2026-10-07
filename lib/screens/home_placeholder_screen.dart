import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_logo.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';
import 'categories_screen.dart';
import 'order_history_screen.dart';
import 'product_details_screen.dart';
import 'product_listing_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomePlaceholderScreen extends StatefulWidget {
  const HomePlaceholderScreen({super.key});

  @override
  State<HomePlaceholderScreen> createState() => _HomePlaceholderScreenState();
}

typedef HomeScreen = HomePlaceholderScreen;

class _HomePlaceholderScreenState extends State<HomePlaceholderScreen> {
  int _selectedIndex = 0;
  final _cartService = CartService.instance;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeView(context),
      const CategoriesScreen(showAppBar: false),
      const CartScreen(showAppBar: false),
      const OrderHistoryScreen(showAppBar: false),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryText.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _onItemTapped,
            elevation: 0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.grid_view_outlined),
                selectedIcon: Icon(Icons.grid_view_rounded),
                label: 'Categories',
              ),
              NavigationDestination(
                icon: _cartNavIcon(Icons.shopping_cart_outlined),
                selectedIcon: _cartNavIcon(Icons.shopping_cart_rounded),
                label: 'Cart',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Orders',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _cartNavIcon(IconData icon) {
    return ValueListenableBuilder<List<CartItemModel>>(
      valueListenable: _cartService.itemsNotifier,
      builder: (context, items, child) {
        final count = _cartService.itemCount;
        return Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          backgroundColor: AppColors.secondaryPink,
          child: Icon(icon),
        );
      },
    );
  }

  Widget _sectionHeader(String title, String actionLabel, VoidCallback onAction) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 12, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              letterSpacing: -0.2,
            ),
          ),
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _openProduct(BuildContext context, ProductModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProductDetailsScreen(product: product)),
    );
  }

  Widget _buildHomeView(BuildContext context) {
    final featuredProducts = MockData.products.where((p) => p.isFeatured).toList();
    final categories = MockData.categories;
    final popularProducts = MockData.products;

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // HEADER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const BabyShopHubLogo(iconSize: 24, fontSize: 20, isVertical: false),
                  Material(
                    color: AppColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: InkWell(
                      onTap: () => setState(() => _selectedIndex = 2),
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(11),
                        child: _cartNavIcon(Icons.shopping_cart_outlined),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GREETING
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Everything your baby needs',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryText,
                      letterSpacing: -0.5,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Trusted essentials, delivered with care.',
                    style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                  ),
                ],
              ),
            ),
          ),

          // SEARCH
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Material(
                color: AppColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SearchScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: AppColors.secondaryText, size: 22),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search products, brands or categories',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 14, color: AppColors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // BANNER
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.accentBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'New arrivals for\nlittle ones',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Diapers, food, clothing & more',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ProductListingScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppColors.primaryBlue,
                              minimumSize: const Size(0, 40),
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Shop Now'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.shopping_bag_rounded,
                        size: 34,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // CATEGORIES
          SliverToBoxAdapter(
            child: _sectionHeader(
              'Categories',
              'See All',
              () => setState(() => _selectedIndex = 1),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 98,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return SizedBox(
                    width: 82,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductListingScreen(
                              selectedCategory: category.name,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: category.badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(category.icon, color: category.badgeColor, size: 26),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // FEATURED
          SliverToBoxAdapter(
            child: _sectionHeader(
              'Recommended for You',
              'View All',
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductListingScreen()),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 292,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                itemCount: featuredProducts.length,
                itemBuilder: (context, index) {
                  final product = featuredProducts[index];
                  return Container(
                    width: 172,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: ProductCard(
                      product: product,
                      onTap: () => _openProduct(context, product),
                    ),
                  );
                },
              ),
            ),
          ),

          // POPULAR
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Products',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryText,
                      letterSpacing: -0.2,
                    ),
                  ),
                  Text(
                    '${popularProducts.length} items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.58,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = popularProducts[index];
                  return ProductCard(
                    product: product,
                    onTap: () => _openProduct(context, product),
                  );
                },
                childCount: popularProducts.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}
