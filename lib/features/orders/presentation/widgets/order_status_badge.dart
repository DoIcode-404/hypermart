/// OrderStatusBadge — colored chip showing order status.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({required this.status, super.key});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  static (Color bg, Color fg) _colors(OrderStatus s) {
    switch (s) {
      case OrderStatus.pending:
        return (const Color(0xFFFFF3CD), const Color(0xFF856404));
      case OrderStatus.preparing:
        return (const Color(0xFFFFF3CD), const Color(0xFF856404));
      case OrderStatus.onTheWay:
        return (AppColors.primaryLight, AppColors.primary);
      case OrderStatus.delivered:
        return (const Color(0xFFDCFCE7), AppColors.success);
      case OrderStatus.cancelled:
        return (const Color(0xFFFEE2E2), AppColors.error);
    }
  }
}
