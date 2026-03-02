/// LocationRepository — abstract contract for location operations.
library;

import '../entities/delivery_location.dart';

/// Implemented by [LocationRepositoryImpl] in the data layer.
abstract interface class LocationRepository {
  /// Checks whether location permission is granted.
  Future<bool> isPermissionGranted();

  /// Requests location permission from the OS. Returns true if granted.
  Future<bool> requestPermission();

  /// Returns the device's current GPS position as a [DeliveryLocation].
  Future<DeliveryLocation> getCurrentLocation();

  /// Reverse geocodes [lat]/[lng] to a [DeliveryLocation].
  Future<DeliveryLocation> reverseGeocode(double lat, double lng);

  /// Searches for places matching [query] within Nepal.
  Future<List<DeliveryLocation>> searchPlaces(String query);

  /// Returns the last saved delivery location (null if none saved).
  Future<DeliveryLocation?> getSavedLocation();

  /// Persists [location] as the current delivery area.
  Future<void> saveLocation(DeliveryLocation location);
}
