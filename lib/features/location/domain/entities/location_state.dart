/// Location state — sealed hierarchy for the location flow.
library;

import './delivery_location.dart';

sealed class LocationState {
  const LocationState();
}

class LocationInitial extends LocationState {
  const LocationInitial();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationPermissionGranted extends LocationState {
  const LocationPermissionGranted();
}

class LocationPermissionDenied extends LocationState {
  const LocationPermissionDenied();
}

class LocationSelected extends LocationState {
  const LocationSelected({required this.location});
  final DeliveryLocation location;
}

class LocationError extends LocationState {
  const LocationError({required this.message});
  final String message;
}
