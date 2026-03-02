/// WishlistToggleButton — heart icon toggle used across product cards/details.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../providers/wishlist_providers.dart';

class WishlistToggleButton extends ConsumerWidget {
  const WishlistToggleButton({
    required this.product,
    this.size = 18.0,
    super.key,
  });

  final ProductEntity product;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWishlisted = ref.watch(isInWishlistProvider(product.id));

    return GestureDetector(
      onTap: () {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              added
                  ? '${product.name} added to wishlist'
                  : '${product.name} removed from wishlist',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: size + 14,
        height: size + 14,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(
          isWishlisted ? Icons.favorite : Icons.favorite_border,
          size: size,
          color: isWishlisted ? AppColors.primary : AppColors.textTertiary,
        ),
      ),
    );
  }
}
