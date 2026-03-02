/// AddToCartUseCase — adds a product to the cart or increments quantity.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class AddToCartUseCase implements UseCase<void, CartItemEntity> {
  const AddToCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<void> call(CartItemEntity params) => _repository.addItem(params);
}
