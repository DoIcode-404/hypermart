/// LocationController — manages permission requests and location selection.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/geocoding_service.dart';
import '../../data/datasources/location_service.dart';
import '../../domain/entities/delivery_location.dart';

/// Composite state for the location controller.
class LocationControllerState {
  const LocationControllerState({
    this.isLoading = false,
    this.permissionGranted = false,
    this.currentLocation,
    this.searchResults = const [],
    this.isSearching = false,
    this.error,
  });

  final bool isLoading;
  final bool permissionGranted;
  final DeliveryLocation? currentLocation;
  final List<DeliveryLocation> searchResults;
  final bool isSearching;
  final String? error;

  LocationControllerState copyWith({
    bool? isLoading,
    bool? permissionGranted,
    DeliveryLocation? currentLocation,
    List<DeliveryLocation>? searchResults,
    bool? isSearching,
    String? error,
  }) {
    return LocationControllerState(
      isLoading: isLoading ?? this.isLoading,
      permissionGranted: permissionGranted ?? this.permissionGranted,
      currentLocation: currentLocation ?? this.currentLocation,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
      error: error,
    );
  }
}

class LocationController extends StateNotifier<LocationControllerState> {
  LocationController({
    required LocationService locationService,
    required GeocodingService geocodingService,
  }) : _locationService = locationService,
       _geocodingService = geocodingService,
       super(const LocationControllerState());

  final LocationService _locationService;
  final GeocodingService _geocodingService;

  /// Request location permission from OS.
  Future<bool> requestPermission() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final granted = await _locationService.requestPermission();
      state = state.copyWith(isLoading: false, permissionGranted: granted);
      return granted;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Permission request failed: $e',
      );
      return false;
    }
  }

  /// Check if permission is already granted.
  Future<void> checkPermission() async {
    final granted = await _locationService.isPermissionGranted();
    state = state.copyWith(permissionGranted: granted);
  }

  /// Get current device position and reverse geocode it.
  Future<DeliveryLocation> getCurrentLocationWithAddress() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final position = await _locationService.getCurrentPosition();
      final location = await _geocodingService.reverseGeocode(
        position.latitude,
        position.longitude,
      );
      state = state.copyWith(isLoading: false, currentLocation: location);
      return location;
    } catch (e) {
      debugPrint('getCurrentLocationWithAddress error: $e');
      state = state.copyWith(isLoading: false);
      return DeliveryLocation.kathmandu;
    }
  }

  /// Reverse geocode a specific lat/lng (e.g. when user drags map pin).
  Future<DeliveryLocation> reverseGeocode(double lat, double lng) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final location = await _geocodingService.reverseGeocode(lat, lng);
      state = state.copyWith(isLoading: false, currentLocation: location);
      return location;
    } catch (e) {
      state = state.copyWith(isLoading: false);
      return DeliveryLocation(
        latitude: lat,
        longitude: lng,
        areaName: 'Unknown',
        fullAddress: '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
      );
    }
  }

  /// Search for places in Nepal.
  Future<void> searchPlaces(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(searchResults: [], isSearching: false);
      return;
    }
    state = state.copyWith(isSearching: true);
    try {
      final results = await _geocodingService.searchPlaces(query);
      if (mounted) {
        state = state.copyWith(searchResults: results, isSearching: false);
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(searchResults: [], isSearching: false);
      }
    }
  }

  /// Clear search results.
  void clearSearch() {
    state = state.copyWith(searchResults: [], isSearching: false);
  }

  /// Save the confirmed delivery location.
  Future<void> confirmLocation(DeliveryLocation location) async {
    await _locationService.saveLocation(location);
    state = state.copyWith(currentLocation: location);
  }
}
