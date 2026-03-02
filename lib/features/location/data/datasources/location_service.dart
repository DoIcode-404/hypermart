/// Location service — GPS position, permission handling, persistence.
library;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/delivery_location.dart';

/// Service for device location access and delivery-location persistence.
class LocationService {
  LocationService({SharedPreferences? prefs}) : _prefs = prefs;

  SharedPreferences? _prefs;

  static const _storageKey = 'delivery_location';

  Future<SharedPreferences> get _preferences async =>
      _prefs ??= await SharedPreferences.getInstance();

  // ── Permission ──────────────────────────────────────────────────────────

  /// Check if location permission is currently granted.
  Future<bool> isPermissionGranted() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Request location permission from the OS.
  /// Returns `true` if granted.
  Future<bool> requestPermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      // Can't request again — user must enable in settings.
      return false;
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  /// Whether the location service (GPS) is enabled on the device.
  Future<bool> isLocationServiceEnabled() async {
    return Geolocator.isLocationServiceEnabled();
  }

  // ── GPS Position ────────────────────────────────────────────────────────

  /// Get device's current position.
  ///
  /// Falls back to Kathmandu default if anything fails.
  Future<Position> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (e) {
      debugPrint('getCurrentPosition error: $e');
      // Return Kathmandu as fallback.
      return Position(
        latitude: DeliveryLocation.defaultLat,
        longitude: DeliveryLocation.defaultLng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
    }
  }

  // ── Persistence ─────────────────────────────────────────────────────────

  /// Save the selected delivery location to SharedPreferences.
  Future<void> saveLocation(DeliveryLocation location) async {
    final prefs = await _preferences;
    await prefs.setString(_storageKey, location.encode());
  }

  /// Load the previously saved delivery location, or `null` if none.
  Future<DeliveryLocation?> getSavedLocation() async {
    final prefs = await _preferences;
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return DeliveryLocation.decode(raw);
    } catch (e) {
      debugPrint('Failed to decode saved location: $e');
      return null;
    }
  }

  /// Clear the saved delivery location.
  Future<void> clearLocation() async {
    final prefs = await _preferences;
    await prefs.remove(_storageKey);
  }
}
