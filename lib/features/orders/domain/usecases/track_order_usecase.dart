/// TrackOrderUseCase — updates the status of an existing order.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class TrackOrderParams {
  const TrackOrderParams({required this.id, required this.status});
  final String id;
  final OrderStatus status;
}

class TrackOrderUseCase implements UseCase<void, TrackOrderParams> {
  const TrackOrderUseCase(this._repository);

  final OrderRepository _repository;

  @override
  Future<void> call(TrackOrderParams params) =>
      _repository.updateOrderStatus(params.id, params.status);
}
