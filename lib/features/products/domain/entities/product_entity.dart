/// ProductEntity — domain-level product representation.
/// Pure Dart, immutable, no serialization logic.
library;

class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.description = '',
    this.imageUrl,
    this.imageUrls = const [],
    required this.price,
    this.originalPrice,
    required this.currencyCode,
    this.categoryTag,
    this.variantId,
    this.weight,
    this.stockLevel,
    this.variants = const [],
    this.optionGroups = const [],
    this.facetValues = const [],
    this.collectionNames = const [],
  });

  final String id;
  final String name;
  final String slug;
  final String description;
  final String? imageUrl;

  /// All product images (gallery / carousel).
  final List<String> imageUrls;

  /// Price in minor units (e.g. paisa). Divide by 100 for display.
  final int price;

  /// Original (pre-discount) price, if applicable.
  final int? originalPrice;

  final String currencyCode;

  /// Display tag like "ORGANIC", "DEAL", "DAIRY", "SNACKS".
  final String? categoryTag;

  /// The variant ID to use for cart operations.
  final String? variantId;

  /// Weight or size description, e.g. "250g Box", "1kg Bundle".
  final String? weight;

  /// Stock level: "IN_STOCK", "OUT_OF_STOCK", "LOW_STOCK".
  final String? stockLevel;

  /// All product variants.
  final List<ProductVariant> variants;

  /// Option groups (e.g. Color, Size).
  final List<ProductOptionGroup> optionGroups;

  /// Facet values (e.g. ["brand: Nike", "category: Shoes"]).
  final List<ProductFacetValue> facetValues;

  /// Collection names this product belongs to.
  final List<String> collectionNames;

  /// Whether the product is in stock.
  bool get inStock =>
      stockLevel == null ||
      stockLevel == 'IN_STOCK' ||
      stockLevel == 'LOW_STOCK';

  /// Formatted price string (NPR uses whole numbers).
  String get formattedPrice {
    final amount = price / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Formatted original price string.
  String? get formattedOriginalPrice {
    if (originalPrice == null) return null;
    final amount = originalPrice! / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Whether this product has a discount.
  bool get hasDiscount =>
      originalPrice != null && originalPrice! > price && price > 0;
}

/// A product variant (e.g. size/color combination).
class ProductVariant {
  const ProductVariant({
    required this.id,
    required this.name,
    required this.priceWithTax,
    required this.currencyCode,
    this.sku,
    this.stockLevel,
  });

  final String id;
  final String name;
  final int priceWithTax;
  final String currencyCode;
  final String? sku;
  final String? stockLevel;

  bool get inStock =>
      stockLevel == null ||
      stockLevel == 'IN_STOCK' ||
      stockLevel == 'LOW_STOCK';

  String get formattedPrice {
    final amount = priceWithTax / 100;
    if (currencyCode == 'NPR') {
      return 'Rs. ${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';
    }
    return '\$${amount.toStringAsFixed(2)}';
  }
}

/// An option group (e.g. "Color" with options ["red", "blue"]).
class ProductOptionGroup {
  const ProductOptionGroup({
    required this.id,
    required this.name,
    required this.code,
    required this.options,
  });

  final String id;
  final String name;
  final String code;
  final List<ProductOption> options;
}

/// A single option within an option group.
class ProductOption {
  const ProductOption({
    required this.id,
    required this.name,
    required this.code,
  });

  final String id;
  final String name;
  final String code;
}

/// A facet value attached to a product.
class ProductFacetValue {
  const ProductFacetValue({
    required this.name,
    required this.code,
    required this.facetName,
    required this.facetCode,
  });

  final String name;
  final String code;
  final String facetName;
  final String facetCode;
}
