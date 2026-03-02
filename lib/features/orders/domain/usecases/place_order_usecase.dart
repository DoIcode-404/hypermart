/// PlaceOrderUseCase — saves a new order entity.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class PlaceOrderUseCase implements UseCase<void, OrderEntity> {
  const PlaceOrderUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<void> call(OrderEntity order) => _repository.saveOrder(order);
}
