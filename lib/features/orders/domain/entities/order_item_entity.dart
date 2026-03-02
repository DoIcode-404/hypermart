/// OrderItemEntity — domain representation of a single order line item.
library;

class OrderItemEntity {
  const OrderItemEntity({
    required this.productId,
    required this.variantId,
    required this.name,
    required this.price,
    required this.currencyCode,
    required this.quantity,
    this.imageUrl,
    this.subtitle,
  });

  final String productId;
  final String variantId;
  final String name;

  /// Price in minor units.
  final int price;
  final String currencyCode;
  final int quantity;
  final String? imageUrl;
  final String? subtitle;

  int get lineTotal => price * quantity;

  String get formattedLineTotal {
    final amount = lineTotal / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }
}
