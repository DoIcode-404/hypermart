/// WishlistController — Riverpod StateNotifier managing wishlist state.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';

class WishlistController extends StateNotifier<List<WishlistItemEntity>> {
  final WishlistRepository _repository;

  WishlistController(this._repository) : super([]) {
    _load();
  }

  /// Load persisted items from the repository on initialisation.
  Future<void> _load() async {
    final items = await _repository.getWishlistItems();
    if (mounted) state = items;
  }

  /// Add a product to the wishlist.
  void addItem(WishlistItemEntity item) {
    if (isInWishlist(item.productId)) return;
    state = [...state, item];
    _repository.addItem(item); // fire-and-forget persistence
  }

  /// Remove a product from the wishlist.
  void removeItem(String productId) {
    state = state.where((e) => e.productId != productId).toList();
    _repository.removeItem(productId); // fire-and-forget persistence
  }

  /// Toggle wishlist status. Returns true if added, false if removed.
  bool toggleItem(WishlistItemEntity item) {
    if (isInWishlist(item.productId)) {
      removeItem(item.productId);
      return false;
    }
    addItem(item);
    return true;
  }

  /// Check if a product is wishlisted.
  bool isInWishlist(String productId) {
    return state.any((e) => e.productId == productId);
  }

  /// Clear entire wishlist.
  void clearAll() {
    final toRemove = List<WishlistItemEntity>.from(state);
    state = [];
    for (final item in toRemove) {
      _repository.removeItem(item.productId); // fire-and-forget
    }
  }
}
