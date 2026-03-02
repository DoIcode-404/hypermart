/// OrderTile — compact order card for the orders list screen.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/order_entity.dart';
import 'order_status_badge.dart';

class OrderTile extends StatelessWidget {
  const OrderTile({required this.order, super.key});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final firstItem = order.items.isNotEmpty ? order.items.first : null;
    final extraItems = order.items.length - 1;
    final dateStr = _formatDate(order.placedAt);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: image + status + price
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item thumbnail
                if (firstItem?.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      firstItem!.imageUrl!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _PlaceholderImg(),
                    ),
                  )
                else
                  _PlaceholderImg(),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OrderStatusBadge(status: order.status),
                      const SizedBox(height: 6),
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$dateStr • ${order.itemCount} ${order.itemCount == 1 ? 'Item' : 'Items'}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textTertiary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Price
                Text(
                  order.formattedTotal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            if (extraItems > 0) ...[
              const SizedBox(height: 6),
              Text(
                '+ $extraItems more ${extraItems == 1 ? 'item' : 'items'}',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Divider(height: 1, color: Color(0xFFF0EDE9)),
            const SizedBox(height: 12),

            // Action buttons
            _ActionButtons(order: order),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    const months = [
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
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    switch (order.status) {
      case OrderStatus.onTheWay:
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: _PrimaryButton(
                label: 'Track Order',
                icon: Icons.local_shipping_rounded,
                onTap:
                    () => context.pushNamed(
                      RouteNames.orderDetails,
                      pathParameters: {'id': order.id},
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: _OutlineButton(
                label: 'Details',
                onTap:
                    () => context.pushNamed(
                      RouteNames.orderDetails,
                      pathParameters: {'id': order.id},
                    ),
              ),
            ),
          ],
        );

      case OrderStatus.pending:
      case OrderStatus.preparing:
        return _OutlineButton(
          label: 'View Order Details',
          onTap:
              () => context.pushNamed(
                RouteNames.orderDetails,
                pathParameters: {'id': order.id},
              ),
        );

      case OrderStatus.delivered:
        return Row(
          children: [
            Expanded(child: _OutlineButton(label: 'Reorder', onTap: () {})),
            const SizedBox(width: 10),
            Expanded(child: _OutlineButton(label: 'Feedback', onTap: () {})),
          ],
        );

      case OrderStatus.cancelled:
        return _OutlineButton(
          label: 'View Details',
          onTap:
              () => context.pushNamed(
                RouteNames.orderDetails,
                pathParameters: {'id': order.id},
              ),
        );
    }
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({required this.label, required this.onTap, this.icon});

  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onTap,
      icon:
          icon != null
              ? Icon(icon, size: 16, color: Colors.white)
              : const SizedBox.shrink(),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(0, 44),
      ),
    );
  }
}

class _OutlineButton extends StatelessWidget {
  const _OutlineButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: Color(0xFFE5E7EB)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        minimumSize: const Size(0, 44),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _PlaceholderImg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.shopping_bag_rounded,
        size: 32,
        color: AppColors.textTertiary,
      ),
    );
  }
}
