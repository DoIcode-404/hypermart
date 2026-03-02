/// SearchPlacesUseCase — searches for delivery locations by name.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/delivery_location.dart';
import '../repositories/location_repository.dart';

class SearchPlacesUseCase implements UseCase<List<DeliveryLocation>, String> {
  const SearchPlacesUseCase(this._repository);

  final LocationRepository _repository;

  @override
  Future<List<DeliveryLocation>> call(String query) =>
      _repository.searchPlaces(query);
}
