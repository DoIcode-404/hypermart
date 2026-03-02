/// RemoveFromCartUseCase — removes a specific item from the cart.
library;

import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartParams {
  const RemoveFromCartParams({
    required this.productId,
    required this.variantId,
  });
  final String productId;
  final String variantId;
}

class RemoveFromCartUseCase implements UseCase<void, RemoveFromCartParams> {
  const RemoveFromCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<void> call(RemoveFromCartParams params) =>
      _repository.removeItem(params.productId, params.variantId);
}
