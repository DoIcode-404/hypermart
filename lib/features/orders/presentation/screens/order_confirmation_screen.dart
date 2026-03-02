/// Order confirmation screen — success illustration, order number,
/// estimated delivery, first item preview, track/home buttons.
/// Matches the HyperMart order confirmation design.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    required this.items,
    required this.total,
    required this.currencyCode,
    super.key,
  });

  final List<CartItemEntity> items;
  final int total;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    // Generate fake order number and estimated delivery (+1 day).
    final orderNumber =
        '#HM-${(10000 + math.Random().nextInt(90000)).toString()}';
    final estimatedDelivery = DateTime.now().add(const Duration(days: 1));
    final estLabel =
        '${_monthName(estimatedDelivery.month)} ${estimatedDelivery.day}, ${estimatedDelivery.year}';

    final firstItem = items.isNotEmpty ? items.first : null;
    final otherCount = items.length > 1 ? items.length - 1 : 0;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'Order Confirmation',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      // ── Success illustration ────────────────────────
                      _SuccessIcon(),

                      const SizedBox(height: 28),

                      Text(
                        'Order Placed Successfully!',
                        style: AppTextStyles.headlineMedium.copyWith(
                          fontSize: 22,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Your order has been confirmed and will be\ndelivered soon. Thank you for shopping with\nHyperMart!',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 32),

                      // ── Order details card ──────────────────────────
                      _OrderDetailsCard(
                        orderNumber: orderNumber,
                        estimatedDelivery: estLabel,
                        firstItem: firstItem,
                        otherCount: otherCount,
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // ── Bottom buttons ──────────────────────────────────────
            _BottomButtons(
              onTrackOrder: () {
                // Navigate to orders tab.
                context.goNamed(RouteNames.orders);
              },
              onBackToHome: () {
                context.goNamed(RouteNames.home);
              },
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return names[m];
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Success Icon
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SuccessIcon extends StatefulWidget {
  @override
  State<_SuccessIcon> createState() => _SuccessIconState();
}

class _SuccessIconState extends State<_SuccessIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnim.value,
          child: Transform.scale(scale: _scaleAnim.value, child: child),
        );
      },
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 8,
            ),
          ],
        ),
        child: const Icon(Icons.check, size: 56, color: AppColors.textWhite),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Order Details Card
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _OrderDetailsCard extends StatelessWidget {
  const _OrderDetailsCard({
    required this.orderNumber,
    required this.estimatedDelivery,
    required this.firstItem,
    required this.otherCount,
  });

  final String orderNumber;
  final String estimatedDelivery;
  final CartItemEntity? firstItem;
  final int otherCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceLight, width: 1.5),
      ),
      child: Column(
        children: [
          // Order number + estimated delivery.
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORDER NUMBER',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        letterSpacing: 1.0,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      orderNumber,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'ESTIMATED DELIVERY',
                      style: AppTextStyles.caption.copyWith(
                        fontSize: 10,
                        letterSpacing: 1.0,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      estimatedDelivery,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (firstItem != null) ...[
            const SizedBox(height: 14),
            const Divider(height: 1, color: AppColors.surfaceLight),
            const SizedBox(height: 14),

            // First item preview.
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 56,
                    height: 56,
                    color: AppColors.surfaceLight,
                    child:
                        firstItem!.imageUrl != null
                            ? Image.network(
                              firstItem!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => const Icon(
                                    Icons.image_outlined,
                                    color: AppColors.textTertiary,
                                  ),
                            )
                            : const Icon(
                              Icons.image_outlined,
                              color: AppColors.textTertiary,
                            ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem!.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (otherCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '+ $otherCount other items',
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12,
                            letterSpacing: 0,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Bottom Buttons
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _BottomButtons extends StatelessWidget {
  const _BottomButtons({
    required this.onTrackOrder,
    required this.onBackToHome,
  });

  final VoidCallback onTrackOrder;
  final VoidCallback onBackToHome;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Track Order button.
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onTrackOrder,
              icon: const Icon(Icons.local_shipping_outlined, size: 22),
              label: const Text('Track Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textWhite,
                textStyle: AppTextStyles.buttonLarge,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Back to Home button.
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton(
              onPressed: onBackToHome,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: BorderSide.none,
                backgroundColor: AppColors.surfaceLight,
                textStyle: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Back to Home',
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
