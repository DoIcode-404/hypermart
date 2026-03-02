/// CartController — Riverpod StateNotifier managing cart item list.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';

class CartController extends StateNotifier<List<CartItemEntity>> {
  final CartRepository _repository;

  CartController(this._repository) : super([]) {
    _load();
  }

  /// Load persisted items from the repository on initialisation.
  Future<void> _load() async {
    final items = await _repository.getCartItems();
    if (mounted) state = items;
  }

  /// Add a product to cart. If already present, increment quantity.
  Future<void> addItem(CartItemEntity item) async {
    final index = state.indexWhere(
      (e) => e.productId == item.productId && e.variantId == item.variantId,
    );
    if (index >= 0) {
      final existing = state[index];
      final updated = existing.copyWith(
        quantity: existing.quantity + item.quantity,
      );
      state = [...state]..[index] = updated;
    } else {
      state = [...state, item];
    }
    await _repository.addItem(item);
  }

  /// Update quantity for a specific item.
  Future<void> updateQuantity(
    String productId,
    String variantId,
    int quantity,
  ) async {
    if (quantity <= 0) {
      await removeItem(productId, variantId);
      return;
    }
    state = [
      for (final item in state)
        if (item.productId == productId && item.variantId == variantId)
          item.copyWith(quantity: quantity)
        else
          item,
    ];
    await _repository.updateQuantity(productId, variantId, quantity);
  }

  /// Remove an item from cart.
  Future<void> removeItem(String productId, String variantId) async {
    state =
        state
            .where(
              (e) => !(e.productId == productId && e.variantId == variantId),
            )
            .toList();
    await _repository.removeItem(productId, variantId);
  }

  /// Clear all items.
  Future<void> clearCart() async {
    state = [];
    await _repository.clearCart();
  }

  /// Total number of items (sum of quantities).
  int get totalItemCount => state.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal in minor units.
  int get subtotal => state.fold(0, (sum, item) => sum + item.lineTotal);
}
