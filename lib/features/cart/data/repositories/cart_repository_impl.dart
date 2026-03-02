/// CartRepositoryImpl — implements domain CartRepository.
/// Local-only persistence; maps exceptions → failures.
library;

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_local_data_source.dart';
import '../mappers/cart_item_mapper.dart';

class CartRepositoryImpl implements CartRepository {
  CartRepositoryImpl({required CartLocalDataSource dataSource})
    : _dataSource = dataSource;

  final CartLocalDataSource _dataSource;

  @override
  Future<List<CartItemEntity>> getCartItems() async {
    final models = await _dataSource.getCartItems();
    return models.map(CartItemMapper.toEntity).toList();
  }

  @override
  Future<void> addItem(CartItemEntity item) async {
    final models = await _dataSource.getCartItems();
    final index = models.indexWhere(
      (m) => m.productId == item.productId && m.variantId == item.variantId,
    );
    if (index >= 0) {
      final existing = models[index];
      models[index] = CartItemMapper.toModel(
        CartItemMapper.toEntity(
          existing,
        ).copyWith(quantity: existing.quantity + item.quantity),
      );
    } else {
      models.add(CartItemMapper.toModel(item));
    }
    await _dataSource.saveCartItems(models);
  }

  @override
  Future<void> updateQuantity(
    String productId,
    String variantId,
    int quantity,
  ) async {
    var models = await _dataSource.getCartItems();
    if (quantity <= 0) {
      models =
          models
              .where(
                (m) => !(m.productId == productId && m.variantId == variantId),
              )
              .toList();
    } else {
      models = [
        for (final m in models)
          if (m.productId == productId && m.variantId == variantId)
            CartItemMapper.toModel(
              CartItemMapper.toEntity(m).copyWith(quantity: quantity),
            )
          else
            m,
      ];
    }
    await _dataSource.saveCartItems(models);
  }

  @override
  Future<void> removeItem(String productId, String variantId) async {
    final models = await _dataSource.getCartItems();
    final updated =
        models
            .where(
              (m) => !(m.productId == productId && m.variantId == variantId),
            )
            .toList();
    await _dataSource.saveCartItems(updated);
  }

  @override
  Future<void> clearCart() => _dataSource.clearCart();
}
