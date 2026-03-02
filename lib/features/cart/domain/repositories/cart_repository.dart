/// CartRepository — abstract contract for cart CRUD operations.
library;

import '../entities/cart_item_entity.dart';

/// Implemented by [CartRepositoryImpl] in the data layer.
/// Persists cart items locally (SharedPreferences).
abstract interface class CartRepository {
  /// Returns all items currently in the cart.
  Future<List<CartItemEntity>> getCartItems();

  /// Adds [item] to the cart. If the same productId+variantId already exists,
  /// the quantities are summed.
  Future<void> addItem(CartItemEntity item);

  /// Sets the quantity for [productId]/[variantId]. Removes the item if ≤ 0.
  Future<void> updateQuantity(String productId, String variantId, int quantity);

  /// Removes the item with [productId]/[variantId].
  Future<void> removeItem(String productId, String variantId);

  /// Removes all items.
  Future<void> clearCart();
}
