/// DeliveryLocation entity — represents a user-selected delivery address.
library;

import 'dart:convert';

class DeliveryLocation {
  const DeliveryLocation({
    required this.latitude,
    required this.longitude,
    required this.areaName,
    required this.fullAddress,
    this.additionalInfo = '',
  });

  final double latitude;
  final double longitude;

  /// Short area name, e.g. "Kathmandu", "Bhaktapur".
  final String areaName;

  /// Full formatted address from reverse geocoding.
  final String fullAddress;

  /// Optional house number / floor / landmark added by user.
  final String additionalInfo;

  /// Nepal bounding box — used to constrain the map.
  static const double nepalMinLat = 26.347;
  static const double nepalMaxLat = 30.447;
  static const double nepalMinLng = 80.058;
  static const double nepalMaxLng = 88.201;

  /// Default center: Kathmandu.
  static const double defaultLat = 27.7172;
  static const double defaultLng = 85.3240;

  static const DeliveryLocation kathmandu = DeliveryLocation(
    latitude: defaultLat,
    longitude: defaultLng,
    areaName: 'Kathmandu',
    fullAddress: 'Kathmandu, Bagmati Province, Nepal',
  );

  DeliveryLocation copyWith({
    double? latitude,
    double? longitude,
    String? areaName,
    String? fullAddress,
    String? additionalInfo,
  }) {
    return DeliveryLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      areaName: areaName ?? this.areaName,
      fullAddress: fullAddress ?? this.fullAddress,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'areaName': areaName,
    'fullAddress': fullAddress,
    'additionalInfo': additionalInfo,
  };

  factory DeliveryLocation.fromJson(Map<String, dynamic> json) {
    return DeliveryLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      areaName: json['areaName'] as String? ?? '',
      fullAddress: json['fullAddress'] as String? ?? '',
      additionalInfo: json['additionalInfo'] as String? ?? '',
    );
  }

  String encode() => jsonEncode(toJson());

  static DeliveryLocation decode(String source) =>
      DeliveryLocation.fromJson(jsonDecode(source) as Map<String, dynamic>);

  @override
  String toString() => 'DeliveryLocation($areaName, $fullAddress)';
}
