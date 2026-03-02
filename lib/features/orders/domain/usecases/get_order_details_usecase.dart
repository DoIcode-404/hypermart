/// GetOrderDetailsUseCase — fetches full details for a single order.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderDetailsUseCase implements UseCase<OrderEntity?, String> {
  const GetOrderDetailsUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<OrderEntity?> call(String id) => _repository.getOrderById(id);
}
