/// Cart Riverpod providers.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/datasources/cart_local_data_source.dart';
import '../../data/repositories/cart_repository_impl.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../controllers/cart_controller.dart';

/// SharedPreferences instance (must be overridden at app startup).
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

/// Cart local data source provider.
final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSource(prefs: ref.watch(sharedPreferencesProvider));
});

/// Cart repository provider.
final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl(dataSource: ref.watch(cartLocalDataSourceProvider));
});

/// Cart controller (list of cart items).
final cartControllerProvider =
    StateNotifierProvider<CartController, List<CartItemEntity>>((ref) {
      return CartController(ref.watch(cartRepositoryProvider));
    });

/// Total item count for badge display.
final cartItemCountProvider = Provider<int>((ref) {
  final items = ref.watch(cartControllerProvider);
  return items.fold(0, (sum, item) => sum + item.quantity);
});

/// Subtotal in minor units.
final cartSubtotalProvider = Provider<int>((ref) {
  final items = ref.watch(cartControllerProvider);
  return items.fold(0, (sum, item) => sum + item.lineTotal);
});
