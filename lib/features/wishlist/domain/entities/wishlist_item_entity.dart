/// WishlistItemEntity — domain representation of a wishlisted product.
library;

class WishlistItemEntity {
  const WishlistItemEntity({
    required this.productId,
    required this.name,
    required this.price,
    required this.currencyCode,
    this.imageUrl,
    this.subtitle,
    this.variantId,
    this.stockLevel,
  });

  final String productId;
  final String name;
  final int price;
  final String currencyCode;
  final String? imageUrl;
  final String? subtitle;
  final String? variantId;
  final String? stockLevel;

  bool get inStock =>
      stockLevel == null ||
      stockLevel == 'IN_STOCK' ||
      stockLevel == 'LOW_STOCK';

  String get formattedPrice {
    final amount = price / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }
}
