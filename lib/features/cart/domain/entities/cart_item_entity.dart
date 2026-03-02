/// CartItemEntity — domain representation of a cart line item.
library;

class CartItemEntity {
  const CartItemEntity({
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

  /// Price in minor units (paisa).
  final int price;
  final String currencyCode;
  final int quantity;
  final String? imageUrl;

  /// Subtitle like weight or variant name.
  final String? subtitle;

  /// Line total in minor units.
  int get lineTotal => price * quantity;

  String get formattedPrice {
    final amount = price / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  String get formattedLineTotal {
    final amount = lineTotal / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  CartItemEntity copyWith({int? quantity}) {
    return CartItemEntity(
      productId: productId,
      variantId: variantId,
      name: name,
      price: price,
      currencyCode: currencyCode,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
      subtitle: subtitle,
    );
  }
}
