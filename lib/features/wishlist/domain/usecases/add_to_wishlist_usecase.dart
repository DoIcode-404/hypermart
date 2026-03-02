/// AddToWishlistUseCase — adds a product to the user's wishlist.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/wishlist_item_entity.dart';
import '../repositories/wishlist_repository.dart';

class AddToWishlistUseCase implements UseCase<void, WishlistItemEntity> {
  const AddToWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<void> call(WishlistItemEntity params) => _repository.addItem(params);
}
