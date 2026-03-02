/// OrderEntity — domain representation of a placed order.
library;

import 'order_item_entity.dart';
import 'address_entity.dart';

enum OrderStatus {
  pending,
  preparing,
  onTheWay,
  delivered,
  cancelled;

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.onTheWay:
        return 'On the way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive =>
      this == OrderStatus.pending ||
      this == OrderStatus.preparing ||
      this == OrderStatus.onTheWay;
}

class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.serviceFee,
    required this.total,
    required this.currencyCode,
    required this.placedAt,
    required this.estimatedDelivery,
    this.deliveryAddress,
    this.paymentMethod,
    this.courierName,
    this.arrivingInMins,
  });

  final String id;
  final String orderNumber;
  final OrderStatus status;
  final List<OrderItemEntity> items;

  /// All amounts in minor units (paisa).
  final int subtotal;
  final int deliveryFee;
  final int serviceFee;
  final int total;
  final String currencyCode;

  final DateTime placedAt;
  final DateTime estimatedDelivery;

  final AddressEntity? deliveryAddress;
  final String? paymentMethod;
  final String? courierName;
  final int? arrivingInMins;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  String _fmt(int minorUnits) {
    final amount = minorUnits / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  String get formattedSubtotal => _fmt(subtotal);
  String get formattedDeliveryFee =>
      deliveryFee == 0 ? 'FREE' : _fmt(deliveryFee);
  String get formattedServiceFee => _fmt(serviceFee);
  String get formattedTotal => _fmt(total);
}
