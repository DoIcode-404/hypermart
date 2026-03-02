/// ClearCartUseCase — empties the entire cart (e.g., after order placed).
library;

import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase implements UseCase<void, NoParams> {
  const ClearCartUseCase(this._repository);

  final CartRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.clearCart();
}
