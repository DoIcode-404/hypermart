/// LocationRepositoryImpl — implements domain LocationRepository.
/// Delegates to [LocationService] (GPS/permissions) and [GeocodingService]
/// (geocoding/place search). Both services live in the data layer.
library;

import '../../domain/entities/delivery_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/geocoding_service.dart';
import '../datasources/location_service.dart';

class LocationRepositoryImpl implements LocationRepository {
  const LocationRepositoryImpl({
    required LocationService locationService,
    required GeocodingService geocodingService,
  }) : _locationService = locationService,
       _geocodingService = geocodingService;

  final LocationService _locationService;
  final GeocodingService _geocodingService;

  @override
  Future<bool> isPermissionGranted() => _locationService.isPermissionGranted();

  @override
  Future<bool> requestPermission() => _locationService.requestPermission();

  @override
  Future<DeliveryLocation> getCurrentLocation() async {
    final position = await _locationService.getCurrentPosition();
    return _geocodingService.reverseGeocode(
      position.latitude,
      position.longitude,
    );
  }

  @override
  Future<DeliveryLocation> reverseGeocode(double lat, double lng) =>
      _geocodingService.reverseGeocode(lat, lng);

  @override
  Future<List<DeliveryLocation>> searchPlaces(String query) =>
      _geocodingService.searchPlaces(query);

  @override
  Future<DeliveryLocation?> getSavedLocation() =>
      _locationService.getSavedLocation();

  @override
  Future<void> saveLocation(DeliveryLocation location) =>
      _locationService.saveLocation(location);
}
