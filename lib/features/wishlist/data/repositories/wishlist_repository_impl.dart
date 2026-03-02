/// WishlistRepositoryImpl — implements domain WishlistRepository.
library;

import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_local_data_source.dart';
import '../mappers/wishlist_item_mapper.dart';

class WishlistRepositoryImpl implements WishlistRepository {
  WishlistRepositoryImpl({required WishlistLocalDataSource dataSource})
    : _dataSource = dataSource;

  final WishlistLocalDataSource _dataSource;

  @override
  Future<List<WishlistItemEntity>> getWishlistItems() async {
    final models = await _dataSource.getWishlistItems();
    return models.map(WishlistItemMapper.toEntity).toList();
  }

  @override
  Future<void> addItem(WishlistItemEntity item) async {
    final models = await _dataSource.getWishlistItems();
    final alreadyPresent = models.any((m) => m.productId == item.productId);
    if (alreadyPresent) return;
    models.add(WishlistItemMapper.toModel(item));
    await _dataSource.saveWishlistItems(models);
  }

  @override
  Future<void> removeItem(String productId) async {
    final models = await _dataSource.getWishlistItems();
    final updated = models.where((m) => m.productId != productId).toList();
    await _dataSource.saveWishlistItems(updated);
  }

  @override
  Future<bool> isInWishlist(String productId) async {
    final models = await _dataSource.getWishlistItems();
    return models.any((m) => m.productId == productId);
  }
}
