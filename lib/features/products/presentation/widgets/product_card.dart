/// ProductCard — compact product tile for grid display.
/// Shows image, category badge, wishlist button, name, weight, price, add button.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    required this.product,
    this.isWishlisted = false,
    this.onTap,
    this.onAddToCart,
    this.onToggleWishlist,
    super.key,
  });

  final ProductEntity product;
  final bool isWishlisted;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onToggleWishlist;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image section ────────────────────────────────────
            _buildImageSection(),

            // ── Info section ─────────────────────────────────────
            Expanded(child: _buildInfoSection()),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        // Product image.
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 1.2,
            child:
                product.imageUrl != null
                    ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                    : _placeholder(),
          ),
        ),

        // Category badge (top-left).
        if (product.categoryTag != null && product.categoryTag!.isNotEmpty)
          Positioned(
            bottom: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _badgeColor(product.categoryTag!),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                product.categoryTag!,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

        // Wishlist heart (top-right).
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onToggleWishlist,
            child: Container(
              width: 32,
              height: 32,
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
                size: 18,
                color:
                    isWishlisted ? AppColors.primary : AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name.
          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),

          // Weight / description.
          Text(
            product.weight ?? product.description,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 0,
              fontSize: 11,
            ),
          ),

          const Spacer(),

          // Price row + add button.
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.formattedPrice,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (product.hasDiscount)
                      Text(
                        product.formattedOriginalPrice!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                          letterSpacing: 0,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),

              // Add to cart button.
              GestureDetector(
                onTap: onAddToCart,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.textWhite,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.surfaceLight,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 40,
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Color _badgeColor(String tag) {
    return switch (tag.toUpperCase()) {
      'ORGANIC' => const Color(0xFF16A34A),
      'DEAL' => AppColors.primary,
      'DAIRY' => const Color(0xFF2563EB),
      'SNACKS' => const Color(0xFFD97706),
      'FRUITS' => const Color(0xFF16A34A),
      _ => AppColors.primary,
    };
  }
}
