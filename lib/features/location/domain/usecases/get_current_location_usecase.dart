/// GetCurrentLocationUseCase — returns the device's current GPS location.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/delivery_location.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocationUseCase implements UseCase<DeliveryLocation, NoParams> {
  const GetCurrentLocationUseCase(this._repository);

  final LocationRepository _repository;

  @override
  Future<DeliveryLocation> call(NoParams params) =>
      _repository.getCurrentLocation();
}
