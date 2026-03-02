/// Checkout screen — step indicator, shipping address, delivery time,
/// payment method, order summary, place order CTA.
/// Matches the HyperMart checkout design.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../location/presentation/providers/location_providers.dart';
import '../../domain/entities/address_entity.dart';
import '../providers/order_providers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payment method enum
// ─────────────────────────────────────────────────────────────────────────────

enum PaymentMethod {
  card('Credit / Debit Card', Icons.credit_card),
  wallet('HyperWallet', Icons.account_balance_wallet_outlined),
  cod('Cash on Delivery', Icons.local_atm_outlined);

  const PaymentMethod(this.label, this.icon);
  final String label;
  final IconData icon;
}

// ─────────────────────────────────────────────────────────────────────────────
// Checkout Screen
// ─────────────────────────────────────────────────────────────────────────────

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  int _selectedDayIndex = 0;
  int _selectedTimeIndex = 0;
  PaymentMethod _selectedPayment = PaymentMethod.card;

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartControllerProvider);
    final subtotal = ref.watch(cartSubtotalProvider);
    final itemCount = ref.watch(cartItemCountProvider);
    final currencyCode =
        cartItems.isNotEmpty ? cartItems.first.currencyCode : 'NPR';

    const deliveryFee = 29900; // Rs. 299
    const discount = 0;
    final tax = (subtotal * 5 / 100).round();
    final total = subtotal + deliveryFee - discount + tax;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          'Checkout',
          style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // ── Step indicator ──────────────────────────────
                  const _StepIndicator(currentStep: 1),

                  const SizedBox(height: 24),

                  // ── Shipping Address ───────────────────────────
                  _ShippingAddressSection(
                    onChangeTap: () {
                      context.pushNamed(
                        RouteNames.confirmLocation,
                        extra: false,
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // ── Delivery Time ──────────────────────────────
                  _DeliveryTimeSection(
                    selectedDayIndex: _selectedDayIndex,
                    selectedTimeIndex: _selectedTimeIndex,
                    onDayChanged: (i) => setState(() => _selectedDayIndex = i),
                    onTimeChanged:
                        (i) => setState(() => _selectedTimeIndex = i),
                  ),

                  const SizedBox(height: 24),

                  // ── Payment Method ─────────────────────────────
                  _PaymentMethodSection(
                    selected: _selectedPayment,
                    onChanged: (m) => setState(() => _selectedPayment = m),
                  ),

                  const SizedBox(height: 24),

                  // ── Order Summary ──────────────────────────────
                  _OrderSummaryCard(
                    itemCount: itemCount,
                    subtotal: subtotal,
                    deliveryFee: deliveryFee,
                    discount: discount,
                    total: total,
                    currencyCode: currencyCode,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // ── Bottom CTA ───────────────────────────────────────
          _PlaceOrderBar(
            total: total,
            currencyCode: currencyCode,
            onPlace: () {
              final items = ref.read(cartControllerProvider);

              // Build address from saved location if available.
              final location =
                  ref.read(savedDeliveryLocationProvider).valueOrNull;
              final address =
                  location != null
                      ? AddressEntity(
                        label: location.areaName,
                        address: location.fullAddress,
                        latitude: location.latitude,
                        longitude: location.longitude,
                      )
                      : null;

              // Register the order in the orders screen.
              ref
                  .read(orderControllerProvider.notifier)
                  .placeOrder(
                    cartItems: items,
                    total: total,
                    currencyCode: currencyCode,
                    address: address,
                    paymentMethod: _selectedPayment.label,
                  );

              // Clear cart after recording the order.
              ref.read(cartControllerProvider.notifier).clearCart();

              context.pushNamed(
                RouteNames.orderConfirmation,
                extra: {
                  'items': items,
                  'total': total,
                  'currencyCode': currencyCode,
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Step Indicator
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});
  final int currentStep; // 0=Cart, 1=Checkout, 2=Payment

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: [
          _stepCircle(0, 'Cart'),
          _connector(0),
          _stepCircle(1, 'Checkout'),
          _connector(1),
          _stepCircle(2, 'Payment'),
        ],
      ),
    );
  }

  Widget _stepCircle(int step, String label) {
    final isCompleted = step < currentStep;
    final isActive = step == currentStep;
    final isFuture = step > currentStep;

    Color bg, fg;
    Widget child;

    if (isCompleted) {
      bg = AppColors.primary;
      fg = AppColors.textWhite;
      child = const Icon(Icons.check, size: 16, color: AppColors.textWhite);
    } else if (isActive) {
      bg = AppColors.primary;
      fg = AppColors.textWhite;
      child = Text(
        '${step + 1}',
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textWhite,
        ),
      );
    } else {
      bg = AppColors.surfaceLight;
      fg = AppColors.textTertiary;
      child = Text(
        '${step + 1}',
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: fg),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
          child: Center(child: child),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isFuture ? FontWeight.w500 : FontWeight.w600,
            color: isFuture ? AppColors.textTertiary : AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _connector(int afterStep) {
    final filled = afterStep < currentStep;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
          height: 2.5,
          color: filled ? AppColors.primary : AppColors.surfaceLight,
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Shipping Address
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ShippingAddressSection extends ConsumerWidget {
  const _ShippingAddressSection({required this.onChangeTap});
  final VoidCallback onChangeTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(savedDeliveryLocationProvider);
    final locationName = locationAsync.when(
      data: (loc) => loc?.areaName ?? 'Select address',
      loading: () => 'Loading...',
      error: (_, __) => 'Select address',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shipping Address',
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
              ),
              GestureDetector(
                onTap: onChangeTap,
                child: Text(
                  'Change',
                  style: AppTextStyles.link.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceLight, width: 1.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.home,
                            size: 18,
                            color: AppColors.textPrimary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Home',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        locationName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 80,
                    height: 64,
                    color: AppColors.surfaceLight,
                    child: const Icon(
                      Icons.map_outlined,
                      size: 32,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Delivery Time
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _DeliveryTimeSection extends StatelessWidget {
  const _DeliveryTimeSection({
    required this.selectedDayIndex,
    required this.selectedTimeIndex,
    required this.onDayChanged,
    required this.onTimeChanged,
  });

  final int selectedDayIndex;
  final int selectedTimeIndex;
  final ValueChanged<int> onDayChanged;
  final ValueChanged<int> onTimeChanged;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(3, (i) => now.add(Duration(days: i)));
    final dayLabels = ['Today', 'Tomorrow', _weekdayName(days[2].weekday)];
    final timeSlots = ['09:00 - 12:00', '13:00 - 17:00'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delivery Time',
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),

          // Day chips.
          Row(
            children: List.generate(3, (i) {
              final d = days[i];
              final sel = i == selectedDayIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: _chip(
                  topLine: dayLabels[i],
                  bottomLine: '${_monthName(d.month)} ${d.day}',
                  selected: sel,
                  onTap: () => onDayChanged(i),
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Time chips.
          Row(
            children: List.generate(timeSlots.length, (i) {
              final sel = i == selectedTimeIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: GestureDetector(
                  onTap: () => onTimeChanged(i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primaryLight : AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel ? AppColors.primary : AppColors.surfaceLight,
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      timeSlots[i],
                      style: AppTextStyles.bodyMedium.copyWith(
                        color:
                            sel ? AppColors.primary : AppColors.textSecondary,
                        fontWeight: sel ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _chip({
    required String topLine,
    required String bottomLine,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.surfaceLight,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(
              topLine,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              bottomLine,
              style: AppTextStyles.caption.copyWith(
                color: selected ? AppColors.primary : AppColors.textTertiary,
                fontSize: 11,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _weekdayName(int wd) {
    const names = [
      '',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return names[wd];
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
// Payment Method
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _PaymentMethodSection extends StatelessWidget {
  const _PaymentMethodSection({
    required this.selected,
    required this.onChanged,
  });

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Method',
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          ...PaymentMethod.values.map((m) => _paymentTile(m)),
        ],
      ),
    );
  }

  Widget _paymentTile(PaymentMethod method) {
    final isSel = method == selected;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => onChanged(method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSel ? AppColors.primary : AppColors.surfaceLight,
              width: isSel ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                method.icon,
                size: 22,
                color: isSel ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  method.label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSel ? AppColors.primary : AppColors.textTertiary,
                    width: 2,
                  ),
                ),
                child:
                    isSel
                        ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Order Summary Card
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.itemCount,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.currencyCode,
  });

  final int itemCount;
  final int subtotal;
  final int deliveryFee;
  final int discount;
  final int total;
  final String currencyCode;

  String _fmt(int minor) {
    final a = minor / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${a.toStringAsFixed(a.truncateToDouble() == a ? 0 : 2)}';
    }
    return '\$${a.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: AppTextStyles.headlineMedium.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          _row('Subtotal ($itemCount items)', _fmt(subtotal)),
          const SizedBox(height: 8),
          _row('Delivery Fee', _fmt(deliveryFee)),
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _row(
              'Discount',
              '-${_fmt(discount)}',
              valueColor: AppColors.success,
            ),
          ],
          const SizedBox(height: 12),
          // Dashed divider approximation.
          Row(
            children: List.generate(
              30,
              (i) => Expanded(
                child: Container(
                  height: 1,
                  color: i.isEven ? AppColors.surfaceLight : Colors.transparent,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order Total',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                _fmt(total),
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 20,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {Color? valueColor}) {
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
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Place Order Bar
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _PlaceOrderBar extends StatelessWidget {
  const _PlaceOrderBar({
    required this.total,
    required this.currencyCode,
    required this.onPlace,
  });

  final int total;
  final String currencyCode;
  final VoidCallback onPlace;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: onPlace,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Place Order', style: AppTextStyles.buttonLarge),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By placing your order, you agree to our Terms of Service',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                letterSpacing: 0,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
