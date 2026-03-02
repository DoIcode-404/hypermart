/// UpdateCartQuantityUseCase — changes quantity for a specific cart item.
library;

import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class UpdateCartQuantityParams {
  const UpdateCartQuantityParams({
    required this.productId,
    required this.variantId,
    required this.quantity,
  });
  final String productId;
  final String variantId;
  final int quantity;
}

class UpdateCartQuantityUseCase
    implements UseCase<void, UpdateCartQuantityParams> {
  const UpdateCartQuantityUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<void> call(UpdateCartQuantityParams params) => _repository
      .updateQuantity(params.productId, params.variantId, params.quantity);
}
