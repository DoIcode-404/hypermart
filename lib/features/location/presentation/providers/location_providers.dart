/// Location Riverpod providers — wires LocationRepository into the widget tree.
///
/// Clean Architecture compliance:
///   presentation → domain (LocationRepository) ← data (LocationRepositoryImpl)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/geocoding_service.dart';
import '../../data/datasources/location_service.dart';
import '../../data/repositories/location_repository_impl.dart';
import '../../domain/entities/delivery_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../controllers/location_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infrastructure providers (data layer wiring)
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton [LocationService] instance.
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// Singleton [GeocodingService] instance.
final geocodingServiceProvider = Provider<GeocodingService>((ref) {
  final service = GeocodingService();
  ref.onDispose(service.dispose);
  return service;
});

/// Singleton [LocationRepository] — presentation accesses data through this.
final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(
    locationService: ref.watch(locationServiceProvider),
    geocodingService: ref.watch(geocodingServiceProvider),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Feature providers
// ─────────────────────────────────────────────────────────────────────────────

/// The main location controller — manages permission + selection flow.
final locationControllerProvider =
    StateNotifierProvider<LocationController, LocationControllerState>((ref) {
      return LocationController(
        locationService: ref.watch(locationServiceProvider),
        geocodingService: ref.watch(geocodingServiceProvider),
      );
    });

/// Provides the currently saved delivery location (nullable).
/// Screens can watch this to display the current delivery area.
final savedDeliveryLocationProvider = FutureProvider<DeliveryLocation?>((
  ref,
) async {
  return ref.watch(locationRepositoryProvider).getSavedLocation();
});
