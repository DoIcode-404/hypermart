/// OrderTimeline — horizontal step indicator showing order progress stages.
library;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_entity.dart';

class OrderTimeline extends StatelessWidget {
  const OrderTimeline({required this.status, super.key});

  final OrderStatus status;

  static const _steps = [
    (OrderStatus.pending, Icons.check_circle, 'PLACED'),
    (OrderStatus.preparing, Icons.check_circle, 'PREPARING'),
    (OrderStatus.onTheWay, Icons.local_shipping_rounded, 'ON THE\nWAY'),
    (OrderStatus.delivered, Icons.inventory_2_rounded, 'DELIVERED'),
  ];

  int get _currentIndex {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.preparing:
        return 1;
      case OrderStatus.onTheWay:
        return 2;
      case OrderStatus.delivered:
        return 3;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (status == OrderStatus.cancelled) {
      return _CancelledTimeline();
    }
    final current = _currentIndex;
    return Row(
      children: List.generate(_steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIndex = (i + 1) ~/ 2;
          final isCompleted = stepIndex <= current;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? AppColors.primary : const Color(0xFFE5E7EB),
            ),
          );
        }
        final stepIndex = i ~/ 2;
        final isDone = stepIndex < current;
        final isActive = stepIndex == current;
        return _StepNode(
          icon: _steps[stepIndex].$2,
          label: _steps[stepIndex].$3,
          isDone: isDone,
          isActive: isActive,
        );
      }),
    );
  }
}

class _StepNode extends StatelessWidget {
  const _StepNode({
    required this.icon,
    required this.label,
    required this.isDone,
    required this.isActive,
  });

  final IconData icon;
  final String label;
  final bool isDone;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final Color circleBg;
    final Color iconColor;
    final Color labelColor;

    if (isDone || isActive) {
      circleBg = AppColors.primary;
      iconColor = Colors.white;
      labelColor = AppColors.primary;
    } else {
      circleBg = const Color(0xFFE5E7EB);
      iconColor = const Color(0xFF9CA3AF);
      labelColor = const Color(0xFF9CA3AF);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                isActive
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.transparent,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: circleBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: labelColor,
            letterSpacing: 0.4,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _CancelledTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFFEE2E2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.cancel_rounded,
            size: 20,
            color: AppColors.error,
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Order Cancelled',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }
}
