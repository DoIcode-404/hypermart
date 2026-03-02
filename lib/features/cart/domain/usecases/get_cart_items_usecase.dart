/// GetCartItemsUseCase — retrieves all items currently in the cart.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartItemsUseCase implements UseCase<List<CartItemEntity>, NoParams> {
  const GetCartItemsUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<List<CartItemEntity>> call(NoParams params) =>
      _repository.getCartItems();
}
