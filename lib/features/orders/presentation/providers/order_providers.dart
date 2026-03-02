/// Order Riverpod providers — wires controller into the widget tree.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/order_repository_impl.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../controllers/order_controller.dart';

/// Order repository provider (in-memory store).
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl();
});

/// Main order list provider.
final orderControllerProvider =
    StateNotifierProvider<OrderController, List<OrderEntity>>(
      (ref) => OrderController(ref.watch(orderRepositoryProvider)),
    );

/// All active orders (pending / preparing / on-the-way).
final activeOrdersProvider = Provider<List<OrderEntity>>((ref) {
  return ref
      .watch(orderControllerProvider)
      .where((o) => o.status.isActive)
      .toList();
});

/// Past orders (delivered + cancelled).
final pastOrdersProvider = Provider<List<OrderEntity>>((ref) {
  return ref
      .watch(orderControllerProvider)
      .where((o) => !o.status.isActive)
      .toList();
});

/// Ongoing-only (preparing + on-the-way, not pending).
final ongoingOrdersProvider = Provider<List<OrderEntity>>((ref) {
  return ref
      .watch(orderControllerProvider)
      .where(
        (o) =>
            o.status == OrderStatus.preparing ||
            o.status == OrderStatus.onTheWay,
      )
      .toList();
});

/// Completed (delivered).
final completedOrdersProvider = Provider<List<OrderEntity>>((ref) {
  return ref
      .watch(orderControllerProvider)
      .where((o) => o.status == OrderStatus.delivered)
      .toList();
});

/// Cancelled orders.
final cancelledOrdersProvider = Provider<List<OrderEntity>>((ref) {
  return ref
      .watch(orderControllerProvider)
      .where((o) => o.status == OrderStatus.cancelled)
      .toList();
});

/// Get a single order by id.
final orderByIdProvider = Provider.family<OrderEntity?, String>((ref, id) {
  return ref
      .watch(orderControllerProvider)
      .where((o) => o.id == id)
      .firstOrNull;
});
