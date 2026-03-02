/// IsInWishlistUseCase — checks if a specific product is wishlisted.
library;

import '../../../../core/usecases/usecase.dart';
import '../repositories/wishlist_repository.dart';

class IsInWishlistUseCase implements UseCase<bool, String> {
  const IsInWishlistUseCase(this._repository);

  final WishlistRepository _repository;

  @override
  Future<bool> call(String productId) => _repository.isInWishlist(productId);
}
