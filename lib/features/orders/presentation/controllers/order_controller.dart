/// OrderController — manages the list of placed orders, backed by OrderRepository.
library;

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/cart/domain/entities/cart_item_entity.dart';
import '../../domain/entities/address_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderController extends StateNotifier<List<OrderEntity>> {
  final OrderRepository _repository;

  OrderController(this._repository) : super([]) {
    _load();
  }

  /// Load persisted orders from repository on initialisation.
  Future<void> _load() async {
    final orders = await _repository.getOrders();
    if (mounted) state = orders;
  }

  /// Convert cart items into a new OrderEntity and persist it.
  Future<void> placeOrder({
    required List<CartItemEntity> cartItems,
    required int total,
    required String currencyCode,
    AddressEntity? address,
    String? paymentMethod,
  }) async {
    final rng = math.Random();
    final orderNum = '#HM-${80000 + rng.nextInt(9999)}';
    final now = DateTime.now();
    final orderItems =
        cartItems
            .map(
              (c) => OrderItemEntity(
                productId: c.productId,
                variantId: c.variantId,
                name: c.name,
                price: c.price,
                currencyCode: c.currencyCode,
                quantity: c.quantity,
                imageUrl: c.imageUrl,
                subtitle: c.subtitle,
              ),
            )
            .toList();

    final subtotal = cartItems.fold<int>(0, (s, i) => s + i.lineTotal);
    final deliveryFee = subtotal > 50000 ? 0 : 29900;
    final serviceFee = (subtotal * 0.05).round();

    final order = OrderEntity(
      id: rng.nextInt(999999).toString(),
      orderNumber: orderNum,
      status: OrderStatus.pending,
      items: orderItems,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      serviceFee: serviceFee,
      total: total,
      currencyCode: currencyCode,
      placedAt: now,
      estimatedDelivery: now.add(const Duration(days: 1)),
      deliveryAddress:
          address ??
          const AddressEntity(
            label: 'Home Address',
            address: 'Kathmandu, Nepal',
          ),
      paymentMethod: paymentMethod ?? 'Cash on Delivery',
    );

    state = [order, ...state];
    await _repository.saveOrder(order);
  }
}
