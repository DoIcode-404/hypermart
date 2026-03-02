/// Product details screen — image carousel, badges, price,
/// description, color/option pickers, quantity selector, specs, add-to-cart CTA.
/// Matches the HyperMart product details design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_snack_bar.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../wishlist/domain/entities/wishlist_item_entity.dart';
import '../../../wishlist/presentation/providers/wishlist_providers.dart';
import '../../domain/entities/product_entity.dart';
import '../providers/product_providers.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({required this.productId, super.key});

  final String productId;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _currentImageIndex = 0;
  int _quantity = 1;
  final int _selectedVariantIndex = 0;
  final Map<String, int> _selectedOptionIndices = {};

  @override
  Widget build(BuildContext context) {
    final productAsync = ref.watch(productDetailProvider(widget.productId));

    return productAsync.when(
      data: (product) {
        if (product == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Product Details')),
            body: const Center(child: Text('Product not found')),
          );
        }
        return _buildContent(product);
      },
      loading:
          () => Scaffold(
            backgroundColor: AppColors.scaffoldBg,
            appBar: _buildAppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (error, _) => Scaffold(
            appBar: _buildAppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load product',
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
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

  PreferredSizeWidget _buildAppBar([ProductEntity? product]) {
    return AppBar(
      title: const Text('Product Details'),
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      actions: [
        IconButton(icon: const Icon(Icons.share_outlined), onPressed: () {}),
        if (product != null)
          Consumer(
            builder: (context, ref, _) {
              final isWishlisted = ref.watch(isInWishlistProvider(product.id));
              return IconButton(
                icon: Icon(
                  isWishlisted ? Icons.favorite : Icons.favorite_border,
                ),
                color: AppColors.primary,
                onPressed: () {
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
          )
        else
          IconButton(
            icon: const Icon(Icons.favorite_border),
            color: AppColors.primary,
            onPressed: () {},
          ),
      ],
    );
  }

  Widget _buildContent(ProductEntity product) {
    final activeVariant =
        product.variants.isNotEmpty
            ? product.variants[_selectedVariantIndex]
            : null;
    final displayPrice = activeVariant?.priceWithTax ?? product.price;
    final totalPrice = displayPrice * _quantity;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: _buildAppBar(product),
      body: Column(
        children: [
          // Scrollable content.
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Image carousel ──────────────────────────────────
                  _ImageCarousel(
                    imageUrls: product.imageUrls,
                    fallbackUrl: product.imageUrl,
                    currentIndex: _currentImageIndex,
                    onPageChanged:
                        (i) => setState(() => _currentImageIndex = i),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        // ── Badges row ──────────────────────────────────
                        _BadgesRow(product: product),

                        const SizedBox(height: 10),

                        // ── Product name ────────────────────────────────
                        Text(
                          product.name,
                          style: AppTextStyles.headlineMedium.copyWith(
                            fontSize: 22,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // ── Price & rating row ──────────────────────────
                        _PriceRatingRow(
                          product: product,
                          activeVariant: activeVariant,
                        ),

                        const SizedBox(height: 16),

                        const Divider(height: 1, color: AppColors.surfaceLight),

                        const SizedBox(height: 16),

                        // ── Description ─────────────────────────────────
                        if (product.description.isNotEmpty)
                          _DescriptionSection(description: product.description),

                        // ── Option groups (Color, Size, etc.) ───────────
                        if (product.optionGroups.isNotEmpty)
                          _OptionGroupsSection(
                            optionGroups: product.optionGroups,
                            selectedIndices: _selectedOptionIndices,
                            onOptionChanged: (groupCode, index) {
                              setState(() {
                                _selectedOptionIndices[groupCode] = index;
                              });
                            },
                          ),

                        // ── Quantity selector ───────────────────────────
                        _QuantitySelector(
                          quantity: _quantity,
                          onChanged: (q) => setState(() => _quantity = q),
                        ),

                        const SizedBox(height: 16),

                        // ── Specs card (variant-based) ──────────────────
                        if (product.variants.isNotEmpty)
                          _SpecsCard(
                            product: product,
                            selectedVariantIndex: _selectedVariantIndex,
                          ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom bar: Total Price + Add to Cart ─────────────────
          _BottomBar(
            totalPrice: totalPrice,
            currencyCode: product.currencyCode,
            inStock: activeVariant?.inStock ?? product.inStock,
            onAddToCart: () {
              final variant =
                  product.variants.isNotEmpty
                      ? product.variants[_selectedVariantIndex]
                      : null;
              ref
                  .read(cartControllerProvider.notifier)
                  .addItem(
                    CartItemEntity(
                      productId: product.id,
                      variantId: variant?.id ?? product.variantId ?? '',
                      name: product.name,
                      price: variant?.priceWithTax ?? product.price,
                      currencyCode: product.currencyCode,
                      quantity: _quantity,
                      imageUrl: product.imageUrl,
                      subtitle: product.weight ?? product.categoryTag,
                    ),
                  );
              AppSnackBar.show(
                context,
                '${product.name} × $_quantity added to cart',
                type: SnackBarType.success,
                actionLabel: 'VIEW',
                onAction: () => context.goNamed(RouteNames.cart),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Image Carousel
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ImageCarousel extends StatelessWidget {
  const _ImageCarousel({
    required this.imageUrls,
    this.fallbackUrl,
    required this.currentIndex,
    required this.onPageChanged,
  });

  final List<String> imageUrls;
  final String? fallbackUrl;
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final urls =
        imageUrls.isNotEmpty
            ? imageUrls
            : (fallbackUrl != null ? [fallbackUrl!] : <String>[]);

    if (urls.isEmpty) {
      return Container(
        height: 300,
        color: AppColors.surfaceLight,
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 64,
            color: AppColors.textTertiary,
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: urls.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return Container(
                color: AppColors.surfaceLight,
                child: Image.network(
                  urls[index],
                  fit: BoxFit.contain,
                  errorBuilder:
                      (_, __, ___) => const Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: AppColors.textTertiary,
                        ),
                      ),
                ),
              );
            },
          ),
        ),
        if (urls.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(urls.length, (i) {
                final isActive = i == currentIndex;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.dotInactive,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Badges Row
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _BadgesRow extends StatelessWidget {
  const _BadgesRow({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Category / tag badge.
        if (product.categoryTag != null && product.categoryTag!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF16A34A).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              product.categoryTag!,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF16A34A),
                letterSpacing: 0.5,
              ),
            ),
          ),
        if (product.categoryTag != null && product.categoryTag!.isNotEmpty)
          const SizedBox(width: 10),

        // Stock status.
        Icon(
          product.inStock ? Icons.check_circle : Icons.cancel,
          size: 16,
          color: product.inStock ? AppColors.success : AppColors.error,
        ),
        const SizedBox(width: 4),
        Text(
          product.inStock ? 'In Stock' : 'Out of Stock',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: product.inStock ? AppColors.success : AppColors.error,
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Price & Rating Row
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _PriceRatingRow extends StatelessWidget {
  const _PriceRatingRow({required this.product, this.activeVariant});

  final ProductEntity product;
  final ProductVariant? activeVariant;

  @override
  Widget build(BuildContext context) {
    final priceStr = activeVariant?.formattedPrice ?? product.formattedPrice;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Price.
        Text(
          priceStr,
          style: AppTextStyles.headlineLarge.copyWith(
            color: AppColors.primary,
            fontSize: 26,
          ),
        ),
        if (product.hasDiscount) ...[
          const SizedBox(width: 10),
          Text(
            product.formattedOriginalPrice!,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textTertiary,
              decoration: TextDecoration.lineThrough,
              fontSize: 15,
            ),
          ),
        ],

        const Spacer(),

        // Star rating (static placeholder — API doesn't have reviews).
        Row(
          children: [
            ...List.generate(5, (i) {
              return Icon(
                i < 4 ? Icons.star : Icons.star_half,
                size: 18,
                color: const Color(0xFFF59E0B),
              );
            }),
            const SizedBox(width: 4),
            Text(
              '4.5',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Description Section
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DescriptionSection extends StatefulWidget {
  const _DescriptionSection({required this.description});

  final String description;

  @override
  State<_DescriptionSection> createState() => _DescriptionSectionState();
}

class _DescriptionSectionState extends State<_DescriptionSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isLong = widget.description.length > 150;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          _expanded || !isLong
              ? widget.description
              : '${widget.description.substring(0, 150)}...',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        if (isLong)
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? 'Show Less' : 'Read More',
                style: AppTextStyles.link.copyWith(fontSize: 14),
              ),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Option Groups Section (Color / Size / etc.)
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _OptionGroupsSection extends StatelessWidget {
  const _OptionGroupsSection({
    required this.optionGroups,
    required this.selectedIndices,
    required this.onOptionChanged,
  });

  final List<ProductOptionGroup> optionGroups;
  final Map<String, int> selectedIndices;
  final void Function(String groupCode, int index) onOptionChanged;

  // Map known color names to Color objects.
  static final _colorMap = <String, Color>{
    'black': Colors.black,
    'white': Colors.white,
    'grey': Colors.grey,
    'gray': Colors.grey,
    'red': Colors.red,
    'orange': Colors.orange,
    'brown': const Color(0xFF8B4513),
    'blue': Colors.blue,
    'green': Colors.green,
    'pink': Colors.pink,
    'yellow': Colors.yellow,
    'purple': Colors.purple,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          optionGroups.map((group) {
            final isColorGroup =
                group.code.toLowerCase() == 'color' ||
                group.code.toLowerCase() == 'colour';
            final selectedIdx = selectedIndices[group.code] ?? 0;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name.toUpperCase(),
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: List.generate(group.options.length, (i) {
                      final option = group.options[i];
                      final isSelected = i == selectedIdx;

                      if (isColorGroup) {
                        final color =
                            _colorMap[option.code.toLowerCase()] ??
                            _colorMap[option.name.toLowerCase()] ??
                            AppColors.textTertiary;
                        return GestureDetector(
                          onTap: () => onOptionChanged(group.code, i),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: color,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : AppColors.surfaceLight,
                                width: isSelected ? 3 : 1.5,
                              ),
                            ),
                          ),
                        );
                      }

                      // Generic option chip.
                      return GestureDetector(
                        onTap: () => onOptionChanged(group.code, i),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.primary
                                    : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primary
                                      : AppColors.surfaceLight,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            option.name,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color:
                                  isSelected
                                      ? AppColors.textWhite
                                      : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Quantity Selector
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({required this.quantity, required this.onChanged});

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'QUANTITY',
          style: AppTextStyles.caption.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.surfaceLight, width: 1.5),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _qtyButton(Icons.remove, () {
                if (quantity > 1) onChanged(quantity - 1);
              }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$quantity',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              _qtyButton(Icons.add, () => onChanged(quantity + 1)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Icon(icon, size: 20, color: AppColors.textPrimary),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Specs Card
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SpecsCard extends StatelessWidget {
  const _SpecsCard({required this.product, required this.selectedVariantIndex});

  final ProductEntity product;
  final int selectedVariantIndex;

  @override
  Widget build(BuildContext context) {
    final variant = product.variants[selectedVariantIndex];
    final specs = <_SpecItem>[];

    // Variant name.
    if (variant.name.isNotEmpty) {
      specs.add(
        _SpecItem(
          icon: Icons.label_outline,
          label: 'VARIANT',
          value: variant.name,
        ),
      );
    }

    // Stock level.
    specs.add(
      _SpecItem(
        icon: Icons.inventory_2_outlined,
        label: 'STOCK',
        value: (variant.stockLevel ?? 'UNKNOWN').replaceAll('_', ' '),
      ),
    );

    // SKU.
    if (variant.sku != null && variant.sku!.isNotEmpty) {
      specs.add(
        _SpecItem(icon: Icons.qr_code, label: 'SKU', value: variant.sku!),
      );
    }

    // Collections.
    if (product.collectionNames.isNotEmpty) {
      specs.add(
        _SpecItem(
          icon: Icons.category_outlined,
          label: 'CATEGORY',
          value: product.collectionNames.join(', '),
        ),
      );
    }

    // Facet values.
    for (final fv in product.facetValues) {
      specs.add(
        _SpecItem(
          icon: Icons.info_outline,
          label: fv.facetName.toUpperCase(),
          value: fv.name,
        ),
      );
    }

    if (specs.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children:
            specs.take(3).map((s) {
              return Expanded(
                child: Column(
                  children: [
                    Icon(s.icon, size: 24, color: AppColors.primary),
                    const SizedBox(height: 6),
                    Text(
                      s.label,
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.value,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      ),
    );
  }
}

class _SpecItem {
  const _SpecItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Bottom Bar
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.totalPrice,
    required this.currencyCode,
    required this.inStock,
    required this.onAddToCart,
  });

  final int totalPrice;
  final String currencyCode;
  final bool inStock;
  final VoidCallback onAddToCart;

  String get _formattedTotal {
    final amount = totalPrice / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Price',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 0,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formattedTotal,
                  style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: inStock ? onAddToCart : null,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: inStock ? AppColors.primary : AppColors.textTertiary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shopping_cart_outlined,
                        color: AppColors.textWhite,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        inStock ? 'Add to Cart' : 'Out of Stock',
                        style: AppTextStyles.buttonLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
