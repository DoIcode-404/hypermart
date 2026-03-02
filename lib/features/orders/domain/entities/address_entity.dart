/// AddressEntity — domain model for delivery address with coordinates.
library;

class AddressEntity {
  const AddressEntity({
    required this.label,
    required this.address,
    this.latitude,
    this.longitude,
  });

  final String label;
  final String address;
  final double? latitude;
  final double? longitude;
}
