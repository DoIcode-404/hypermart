/// Wishlist screen — displays favorited products in a filterable grid.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../providers/wishlist_providers.dart';
import '../widgets/wishlist_item_tile.dart';

class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allItems = ref.watch(wishlistControllerProvider);
    final available = allItems.where((e) => e.inStock).toList();
    final priceDrop = <WishlistItemEntity>[];

    final tabItems = [allItems, available, priceDrop];

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: Text(
          'My Wishlist',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
        ),
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 24),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildTabBar(
            allItems.length,
            available.length,
            priceDrop.length,
          ),
        ),
      ),
      body:
          allItems.isEmpty
              ? _buildEmptyState()
              : TabBarView(
                controller: _tabController,
                children: tabItems.map((items) => _buildGrid(items)).toList(),
              ),
    );
  }

  Widget _buildTabBar(int allCount, int availableCount, int priceDropCount) {
    return Container(
      color: AppColors.surface,
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
        unselectedLabelStyle: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          fontSize: 13,
        ),
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        dividerHeight: 0,
        tabs: [
          Tab(text: 'All Items ($allCount)'),
          Tab(text: 'Available ($availableCount)'),
          Tab(text: 'Price Drop ($priceDropCount)'),
        ],
      ),
    );
  }

  Widget _buildGrid(List<WishlistItemEntity> items) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_none,
              size: 48,
              color: AppColors.textTertiary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 12),
            Text(
              'No items in this category',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.62,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return WishlistItemTile(
          item: item,
          onRemove: () {
            ref
                .read(wishlistControllerProvider.notifier)
                .removeItem(item.productId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} removed from wishlist'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          onAddToCart: () {
            ref
                .read(cartControllerProvider.notifier)
                .addItem(
                  CartItemEntity(
                    productId: item.productId,
                    variantId: item.variantId ?? '',
                    name: item.name,
                    price: item.price,
                    currencyCode: item.currencyCode,
                    quantity: 1,
                    imageUrl: item.imageUrl,
                    subtitle: item.subtitle,
                  ),
                );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${item.name} added to cart'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: AppColors.textTertiary.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'Your wishlist is empty',
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 18,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Browse products and tap the heart to\nsave your favourites here.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
