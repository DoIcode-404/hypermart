/// WishlistRepository — abstract contract for wishlist operations.
library;

import '../entities/wishlist_item_entity.dart';

/// Implemented by [WishlistRepositoryImpl] in the data layer.
abstract interface class WishlistRepository {
  /// Returns all wishlisted items.
  Future<List<WishlistItemEntity>> getWishlistItems();

  /// Adds [item]. No-op if already present.
  Future<void> addItem(WishlistItemEntity item);

  /// Removes the item with [productId].
  Future<void> removeItem(String productId);

  /// Returns true if [productId] is in the wishlist.
  Future<bool> isInWishlist(String productId);
}
