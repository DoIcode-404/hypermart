/// GetSavedLocationUseCase — loads the last persisted delivery location.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/delivery_location.dart';
import '../repositories/location_repository.dart';

class GetSavedLocationUseCase implements UseCase<DeliveryLocation?, NoParams> {
  const GetSavedLocationUseCase(this._repository);

  final LocationRepository _repository;

  @override
  Future<DeliveryLocation?> call(NoParams params) =>
      _repository.getSavedLocation();
}
