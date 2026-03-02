/// Cart screen — displays cart items, quantities, order summary, checkout CTA.
/// Matches the HyperMart cart design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/cart_providers.dart';
import '../widgets/cart_item_tile.dart';
import '../widgets/cart_summary.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartControllerProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final currencyCode =
        cartItems.isNotEmpty ? cartItems.first.currencyCode : 'NPR';

    // Delivery fee: 299 paisa = Rs.2.99 (free if cart empty).
    const deliveryFee = 29900; // Rs. 299

    final tax = (subtotal * 5 / 100).round();
    final total = subtotal + (cartItems.isNotEmpty ? deliveryFee : 0) + tax;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'My Cart',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            TextButton(
              onPressed: () {
                ref.read(cartControllerProvider.notifier).clearCart();
              },
              child: Text(
                'Clear All',
                style: AppTextStyles.link.copyWith(fontSize: 14),
              ),
            ),
        ],
      ),
      body:
          cartItems.isEmpty
              ? _emptyState()
              : Column(
                children: [
                  const Divider(height: 1, color: AppColors.surfaceLight),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.only(top: 10, bottom: 16),
                      children: [
                        // Cart item tiles.
                        ...cartItems.map(
                          (item) => CartItemTile(
                            item: item,
                            onQuantityChanged: (qty) {
                              ref
                                  .read(cartControllerProvider.notifier)
                                  .updateQuantity(
                                    item.productId,
                                    item.variantId,
                                    qty,
                                  );
                            },
                            onRemove: () {
                              ref
                                  .read(cartControllerProvider.notifier)
                                  .removeItem(item.productId, item.variantId);
                            },
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Order summary.
                        CartSummary(
                          subtotal: subtotal,
                          currencyCode: currencyCode,
                          deliveryFee: deliveryFee,
                        ),
                      ],
                    ),
                  ),

                  // Bottom bar: Total + Checkout button.
                  _BottomBar(
                    total: total,
                    currencyCode: currencyCode,
                    onCheckout: () {
                      context.pushNamed(RouteNames.checkout);
                    },
                  ),
                ],
              ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textTertiary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started',
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.total,
    required this.currencyCode,
    required this.onCheckout,
  });

  final int total;
  final String currencyCode;
  final VoidCallback onCheckout;

  String get _formatted {
    final amount = total / 100;
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
                  'TOTAL PRICE',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textTertiary,
                    letterSpacing: 0.8,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatted,
                  style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: GestureDetector(
                onTap: onCheckout,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Checkout', style: AppTextStyles.buttonLarge),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward,
                        color: AppColors.textWhite,
                        size: 20,
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
