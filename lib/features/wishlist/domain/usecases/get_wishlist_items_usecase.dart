/// GetWishlistItemsUseCase — retrieves all wishlisted products.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/wishlist_item_entity.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistItemsUseCase
    implements UseCase<List<WishlistItemEntity>, NoParams> {
  const GetWishlistItemsUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<List<WishlistItemEntity>> call(NoParams params) =>
      _repository.getWishlistItems();
}
