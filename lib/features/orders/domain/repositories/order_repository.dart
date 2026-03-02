/// OrderRepository — abstract contract for order operations.
library;

import '../entities/order_entity.dart';

/// Implemented by [OrderRepositoryImpl] in the data layer.
/// Current implementation is in-memory; extend for remote persistence.
abstract interface class OrderRepository {
  /// Returns all orders (most recent first).
  Future<List<OrderEntity>> getOrders();

  /// Returns a single order by [id], or null if not found.
  Future<OrderEntity?> getOrderById(String id);

  /// Saves a newly placed order.
  Future<void> saveOrder(OrderEntity order);

  /// Updates the status of an existing order.
  Future<void> updateOrderStatus(String id, OrderStatus status);
}
