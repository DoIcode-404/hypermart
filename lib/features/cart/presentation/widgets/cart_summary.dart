/// CartSummary — order total breakdown: subtotal, delivery fee, tax, grand total.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({
    required this.subtotal,
    required this.currencyCode,
    this.deliveryFee = 0,
    this.taxPercent = 5,
    super.key,
  });

  /// Subtotal in minor units.
  final int subtotal;
  final String currencyCode;

  /// Delivery fee in minor units.
  final int deliveryFee;

  /// Tax percentage (default 5%).
  final int taxPercent;

  int get _tax => (subtotal * taxPercent / 100).round();
  int get _total => subtotal + deliveryFee + _tax;

  String _fmt(int minorUnits) {
    final amount = minorUnits / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
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
          Text(
            'Order Summary',
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 14),
          _row('Subtotal', _fmt(subtotal)),
          const SizedBox(height: 8),
          _row('Delivery Fee', deliveryFee > 0 ? _fmt(deliveryFee) : 'Free'),
          const SizedBox(height: 8),
          _row('Tax ($taxPercent%)', _fmt(_tax)),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.surfaceLight),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 17),
              ),
              Text(
                _fmt(_total),
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 17,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
