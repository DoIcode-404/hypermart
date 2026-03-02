/// Wishlist Riverpod providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/wishlist_local_data_source.dart';
import '../../data/repositories/wishlist_repository_impl.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../../../cart/presentation/providers/cart_providers.dart'
    show sharedPreferencesProvider;
import '../controllers/wishlist_controller.dart';

/// Wishlist local data source provider.
final wishlistLocalDataSourceProvider = Provider<WishlistLocalDataSource>((
  ref,
) {
  return WishlistLocalDataSource(prefs: ref.watch(sharedPreferencesProvider));
});

/// Wishlist repository provider.
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  return WishlistRepositoryImpl(
    dataSource: ref.watch(wishlistLocalDataSourceProvider),
  );
});

/// Wishlist controller (list of wishlist items).
final wishlistControllerProvider =
    StateNotifierProvider<WishlistController, List<WishlistItemEntity>>((ref) {
      return WishlistController(ref.watch(wishlistRepositoryProvider));
    });

/// Total wishlist item count.
final wishlistItemCountProvider = Provider<int>((ref) {
  return ref.watch(wishlistControllerProvider).length;
});

/// Check if a specific product is in the wishlist.
final isInWishlistProvider = Provider.family<bool, String>((ref, productId) {
  return ref
      .watch(wishlistControllerProvider)
      .any((e) => e.productId == productId);
});
