/// Home / Product listing screen — delivery header, search, category chips,
/// popular deals grid, promo banner. Matches the HyperMart home design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../location/presentation/providers/location_providers.dart';
import '../../../wishlist/domain/entities/wishlist_item_entity.dart';
import '../../../wishlist/presentation/providers/wishlist_providers.dart';
import '../providers/product_providers.dart';
import '../widgets/product_card.dart';

class ProductListScreen extends ConsumerWidget {
  const ProductListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Delivery header ────────────────────────────────
            SliverToBoxAdapter(child: _DeliveryHeader()),

            // ── Search bar ─────────────────────────────────────
            const SliverToBoxAdapter(child: _SearchBar()),

            // ── Category chips ─────────────────────────────────
            const SliverToBoxAdapter(child: _CategoryChips()),

            // ── Popular Deals header ───────────────────────────
            const SliverToBoxAdapter(child: _SectionHeader()),

            // ── Product grid ───────────────────────────────────
            const _ProductGrid(),

            // ── Promo banner ───────────────────────────────────
            const SliverToBoxAdapter(child: _PromoBanner()),

            // Bottom spacing for bottom nav.
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Delivery Header
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DeliveryHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(savedDeliveryLocationProvider);
    final locationName = locationAsync.when(
      data: (loc) => loc?.areaName ?? 'Select Location',
      loading: () => 'Loading...',
      error: (_, __) => 'Select Location',
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // Delivery location.
          Expanded(
            child: GestureDetector(
              onTap:
                  () => context.pushNamed(
                    RouteNames.confirmLocation,
                    extra: false,
                  ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DELIVERY TO',
                    style: AppTextStyles.caption.copyWith(
                      fontSize: 11,
                      color: AppColors.textTertiary,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          locationName,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Wishlist icon with badge.
          Consumer(
            builder: (context, ref, _) {
              final wishlistCount = ref.watch(wishlistItemCountProvider);
              return _buildIconButton(
                icon: Icons.favorite_border,
                badgeCount: wishlistCount,
                onTap: () => context.pushNamed(RouteNames.wishlist),
              );
            },
          ),

          const SizedBox(width: 8),

          // Profile avatar — shows user photo when signed in.
          Consumer(
            builder: (context, ref, _) {
              final user = ref.watch(authStateProvider).valueOrNull;
              final photoUrl = user?.photoUrl;
              return GestureDetector(
                onTap: () => context.goNamed(RouteNames.profile),
                child: ClipOval(
                  child: Container(
                    width: 40,
                    height: 40,
                    color: AppColors.surfaceLight,
                    child:
                        photoUrl != null
                            ? CachedNetworkImage(
                              imageUrl: photoUrl,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              placeholder:
                                  (_, __) => const Icon(
                                    Icons.person,
                                    color: AppColors.textSecondary,
                                    size: 22,
                                  ),
                              errorWidget:
                                  (_, __, ___) => const Icon(
                                    Icons.person,
                                    color: AppColors.textSecondary,
                                    size: 22,
                                  ),
                            )
                            : const Icon(
                              Icons.person,
                              color: AppColors.textSecondary,
                              size: 22,
                            ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 24),
          ),
          if (badgeCount > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(
                      color: AppColors.textWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Search Bar
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Search field.
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceLight, width: 1.5),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.search,
                    color: AppColors.textTertiary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Search fresh products...',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Filter button.
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.tune, color: AppColors.textWhite, size: 22),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Category Chips
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  static const _categoryIcons = <String, IconData>{
    'all': Icons.grid_view_rounded,
    'fruits': Icons.apple,
    'snacks': Icons.cookie,
    'dairy': Icons.local_drink,
    'fragrances': Icons.spa,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider);
    final selectedSlug = ref.watch(selectedCollectionProvider);

    return SizedBox(
      height: 44,
      child: collectionsAsync.when(
        data: (collections) {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemCount: collections.length + 1, // +1 for "All"
            itemBuilder: (context, index) {
              if (index == 0) {
                return _chip(
                  ref: ref,
                  label: 'All',
                  icon: Icons.grid_view_rounded,
                  isSelected: selectedSlug == null,
                  onTap:
                      () =>
                          ref.read(selectedCollectionProvider.notifier).state =
                              null,
                );
              }
              final col = collections[index - 1];
              final icon =
                  _categoryIcons[col.slug.toLowerCase()] ?? Icons.category;
              return _chip(
                ref: ref,
                label: col.name,
                icon: icon,
                isSelected: selectedSlug == col.slug,
                onTap:
                    () =>
                        ref.read(selectedCollectionProvider.notifier).state =
                            col.slug,
              );
            },
          );
        },
        loading:
            () => const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _chip({
    required WidgetRef ref,
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border:
              isSelected
                  ? null
                  : Border.all(color: AppColors.surfaceLight, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.textWhite : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.textWhite : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Section Header
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SectionHeader extends StatelessWidget {
  const _SectionHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Popular Deals',
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
          ),
          Text('View All', style: AppTextStyles.link.copyWith(fontSize: 14)),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Product Grid
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSlug = ref.watch(selectedCollectionProvider);
    final productsAsync = ref.watch(filteredProductsProvider(selectedSlug));

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No products found',
                  style: TextStyle(color: AppColors.textTertiary),
                ),
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.62,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              final product = products[index];
              return Consumer(
                builder: (context, ref, _) {
                  final isWishlisted = ref.watch(
                    isInWishlistProvider(product.id),
                  );
                  return ProductCard(
                    product: product,
                    isWishlisted: isWishlisted,
                    onTap:
                        () => context.pushNamed(
                          RouteNames.productDetails,
                          pathParameters: {'id': product.id},
                        ),
                    onAddToCart: () {
                      ref
                          .read(cartControllerProvider.notifier)
                          .addItem(
                            CartItemEntity(
                              productId: product.id,
                              variantId: product.variantId ?? '',
                              name: product.name,
                              price: product.price,
                              currencyCode: product.currencyCode,
                              quantity: 1,
                              imageUrl: product.imageUrl,
                              subtitle: product.weight ?? product.categoryTag,
                            ),
                          );
                      ScaffoldMessenger.of(context).clearSnackBars();
                      AppSnackBar.show(
                        context,
                        '${product.name} added to cart',
                        type: SnackBarType.success,
                        actionLabel: 'VIEW',
                        onAction: () => context.goNamed(RouteNames.cart),
                      );
                    },
                    onToggleWishlist: () {
                      final item = WishlistItemEntity(
                        productId: product.id,
                        name: product.name,
                        price: product.price,
                        currencyCode: product.currencyCode,
                        imageUrl: product.imageUrl,
                        subtitle: product.weight ?? product.categoryTag,
                        variantId: product.variantId,
                        stockLevel: product.stockLevel,
                      );
                      final added = ref
                          .read(wishlistControllerProvider.notifier)
                          .toggleItem(item);
                      AppSnackBar.show(
                        context,
                        added
                            ? '${product.name} added to wishlist'
                            : '${product.name} removed from wishlist',
                        type:
                            added
                                ? SnackBarType.wishlistAdd
                                : SnackBarType.wishlistRemove,
                      );
                    },
                  );
                },
              );
            }, childCount: products.length),
          ),
        );
      },
      loading:
          () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(48),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      error:
          (error, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 40,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Failed to load products',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      error.toString(),
                      style: AppTextStyles.caption,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Promo Banner
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '25% Discount',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textWhite,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'On your first fresh order',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textWhite.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'CLAIM NOW',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.shopping_bag_rounded,
              size: 64,
              color: AppColors.textWhite.withValues(alpha: 0.25),
            ),
          ],
        ),
      ),
    );
  }
}
