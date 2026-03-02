/// GetOrdersUseCase — retrieves order history.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrdersUseCase implements UseCase<List<OrderEntity>, NoParams> {
  const GetOrdersUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<List<OrderEntity>> call(NoParams params) => _repository.getOrders();
}
