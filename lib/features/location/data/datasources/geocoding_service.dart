/// Nominatim-based geocoding service — reverse geocode + search for Nepal.
library;

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../domain/entities/delivery_location.dart';

/// Service that uses OpenStreetMap Nominatim API for geocoding.
///
/// All queries are bounded to Nepal to keep results relevant.
class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://nominatim.openstreetmap.org';

  static const _headers = {
    'Accept': 'application/json',
    'User-Agent': 'HyperMart-Flutter/1.0',
  };

  /// Nepal bounding box for viewbox queries: west,south,east,north.
  static const _nepalViewbox = '80.058,26.347,88.201,30.447';

  /// Reverse geocode [lat],[lng] → [DeliveryLocation].
  Future<DeliveryLocation> reverseGeocode(double lat, double lng) async {
    final uri = Uri.parse(
      '$_baseUrl/reverse?lat=$lat&lon=$lng&format=json&addressdetails=1&zoom=18',
    );

    try {
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode != 200) {
        return _fallbackLocation(lat, lng);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final address = data['address'] as Map<String, dynamic>? ?? {};

      final areaName = _extractAreaName(address);
      final fullAddress = data['display_name'] as String? ?? '';

      return DeliveryLocation(
        latitude: lat,
        longitude: lng,
        areaName: areaName,
        fullAddress: _cleanAddress(fullAddress),
      );
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
      return _fallbackLocation(lat, lng);
    }
  }

  /// Search for places in Nepal matching [query].
  ///
  /// Returns up to 5 results bounded to Nepal.
  Future<List<DeliveryLocation>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(
      '$_baseUrl/search?q=${Uri.encodeComponent(query)}'
      '&format=json&addressdetails=1&limit=5'
      '&viewbox=$_nepalViewbox&bounded=1'
      '&countrycodes=np',
    );

    try {
      final response = await _client.get(uri, headers: _headers);
      if (response.statusCode != 200) return [];

      final results = jsonDecode(response.body) as List<dynamic>;

      return results.map((item) {
        final map = item as Map<String, dynamic>;
        final address = map['address'] as Map<String, dynamic>? ?? {};
        return DeliveryLocation(
          latitude: double.tryParse(map['lat']?.toString() ?? '') ?? 0,
          longitude: double.tryParse(map['lon']?.toString() ?? '') ?? 0,
          areaName: _extractAreaName(address),
          fullAddress: _cleanAddress(map['display_name'] as String? ?? ''),
        );
      }).toList();
    } catch (e) {
      debugPrint('Place search error: $e');
      return [];
    }
  }

  /// Extract the most relevant area name from Nominatim address components.
  String _extractAreaName(Map<String, dynamic> address) {
    // Try progressively broader area names.
    return address['suburb'] as String? ??
        address['neighbourhood'] as String? ??
        address['city_district'] as String? ??
        address['city'] as String? ??
        address['town'] as String? ??
        address['village'] as String? ??
        address['municipality'] as String? ??
        address['county'] as String? ??
        address['state'] as String? ??
        'Nepal';
  }

  /// Remove the trailing ", Nepal" duplication and trim.
  String _cleanAddress(String raw) {
    // Nominatim sometimes returns very long addresses; trim trailing country.
    return raw.replaceAll(RegExp(r',\s*Nepal$'), ', Nepal').trim();
  }

  DeliveryLocation _fallbackLocation(double lat, double lng) {
    return DeliveryLocation(
      latitude: lat,
      longitude: lng,
      areaName: 'Unknown Area',
      fullAddress: '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
    );
  }

  void dispose() => _client.close();
}
