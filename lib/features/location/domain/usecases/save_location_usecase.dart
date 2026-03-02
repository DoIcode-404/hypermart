/// SaveLocationUseCase — persists the user-selected delivery location.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/delivery_location.dart';
import '../repositories/location_repository.dart';

class SaveLocationUseCase implements UseCase<void, DeliveryLocation> {
  const SaveLocationUseCase(this._repository);

  final LocationRepository _repository;

  @override
  Future<void> call(DeliveryLocation location) =>
      _repository.saveLocation(location);
}
