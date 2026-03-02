/// RequestLocationPermissionUseCase — asks OS for location permission.
library;

import '../../../../core/usecases/usecase.dart';
import '../repositories/location_repository.dart';

class RequestLocationPermissionUseCase implements UseCase<bool, NoParams> {
  const RequestLocationPermissionUseCase(this._repository);

  final LocationRepository _repository;

  @override
  Future<bool> call(NoParams params) => _repository.requestPermission();
}
