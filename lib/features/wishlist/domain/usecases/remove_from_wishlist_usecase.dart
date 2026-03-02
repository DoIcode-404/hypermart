/// RemoveFromWishlistUseCase — removes a product from the wishlist.
library;

import '../../../../core/usecases/usecase.dart';
import '../repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase implements UseCase<void, String> {
  const RemoveFromWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<void> call(String productId) => _repository.removeItem(productId);
}
