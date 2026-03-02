/// OrderRepositoryImpl — in-memory implementation of [OrderRepository].
/// Orders are kept in-process for now; can be replaced with remote/local
/// persistence without changing any domain or presentation code.
library;

import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final List<OrderEntity> _orders = [];

  @override
  Future<List<OrderEntity>> getOrders() async => List.unmodifiable(_orders);

  @override
  Future<OrderEntity?> getOrderById(String id) async =>
      _orders.where((o) => o.id == id).firstOrNull;

  @override
  Future<void> saveOrder(OrderEntity order) async {
    _orders.insert(0, order);
  }

  @override
  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index < 0) return;
    final old = _orders[index];
    _orders[index] = OrderEntity(
      id: old.id,
      orderNumber: old.orderNumber,
      status: status,
      items: old.items,
      subtotal: old.subtotal,
      deliveryFee: old.deliveryFee,
      serviceFee: old.serviceFee,
      total: old.total,
      currencyCode: old.currencyCode,
      placedAt: old.placedAt,
      estimatedDelivery: old.estimatedDelivery,
      deliveryAddress: old.deliveryAddress,
      paymentMethod: old.paymentMethod,
      courierName: old.courierName,
      arrivingInMins: old.arrivingInMins,
    );
  }
}
