/// ProductMapper — converts raw GraphQL JSON → ProductEntity.
library;

import '../../domain/entities/product_entity.dart';

abstract final class ProductMapper {
  /// Map a single product JSON from the `products` query.
  static ProductEntity fromProductJson(Map<String, dynamic> json) {
    final variants = json['variants'] as List<dynamic>? ?? [];
    final firstVariant =
        variants.isNotEmpty ? variants.first as Map<String, dynamic> : null;

    final facetValues = json['facetValues'] as List<dynamic>? ?? [];
    final collections = json['collections'] as List<dynamic>? ?? [];

    // Derive a category tag from facet values or collections.
    String? categoryTag;
    if (facetValues.isNotEmpty) {
      categoryTag =
          (facetValues.first as Map<String, dynamic>)['name'] as String?;
    } else if (collections.isNotEmpty) {
      categoryTag =
          (collections.first as Map<String, dynamic>)['name'] as String?;
    }

    final featuredAsset = json['featuredAsset'] as Map<String, dynamic>?;

    // Gather all asset image URLs.
    final assets = json['assets'] as List<dynamic>? ?? [];
    final imageUrls =
        assets
            .map(
              (a) => _fixImageUrl(
                (a as Map<String, dynamic>)['preview'] as String?,
              ),
            )
            .whereType<String>()
            .toList();
    // Fallback: if no assets list but featuredAsset exists, use it.
    if (imageUrls.isEmpty && featuredAsset?['preview'] != null) {
      final url = _fixImageUrl(featuredAsset!['preview'] as String);
      if (url != null) imageUrls.add(url);
    }

    return ProductEntity(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: _stripHtml(json['description'] as String? ?? ''),
      imageUrl: _fixImageUrl(featuredAsset?['preview'] as String?),
      imageUrls: imageUrls,
      price: firstVariant?['priceWithTax'] as int? ?? 0,
      currencyCode: firstVariant?['currencyCode'] as String? ?? 'NPR',
      categoryTag: categoryTag?.toUpperCase(),
      variantId: firstVariant?['id']?.toString(),
      stockLevel: firstVariant?['stockLevel'] as String?,
      variants: _mapVariants(variants),
      optionGroups: _mapOptionGroups(
        json['optionGroups'] as List<dynamic>? ?? [],
      ),
      facetValues: _mapFacetValues(facetValues),
      collectionNames:
          collections
              .map((c) => (c as Map<String, dynamic>)['name'] as String? ?? '')
              .where((n) => n.isNotEmpty)
              .toList(),
    );
  }

  /// Map a search result item JSON.
  static ProductEntity fromSearchJson(Map<String, dynamic> json) {
    final productAsset = json['productAsset'] as Map<String, dynamic>?;
    final priceData = json['price'] as Map<String, dynamic>?;

    int price = 0;
    if (priceData != null) {
      // SinglePrice has 'value', PriceRange has 'min'.
      price = priceData['value'] as int? ?? priceData['min'] as int? ?? 0;
    }

    final imageUrl = _fixImageUrl(productAsset?['preview'] as String?);

    return ProductEntity(
      id: json['productId']?.toString() ?? '',
      name: json['productName'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      imageUrl: imageUrl,
      imageUrls: imageUrl != null ? [imageUrl] : [],
      price: price,
      currencyCode: json['currencyCode'] as String? ?? 'NPR',
    );
  }

  /// Map a list of product JSON objects.
  static List<ProductEntity> fromProductListJson(List<dynamic> items) {
    return items
        .map((e) => fromProductJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Map a list of search result JSON objects.
  static List<ProductEntity> fromSearchListJson(List<dynamic> items) {
    return items.map((e) => fromSearchJson(e as Map<String, dynamic>)).toList();
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  static List<ProductVariant> _mapVariants(List<dynamic> raw) {
    return raw.map((v) {
      final m = v as Map<String, dynamic>;
      return ProductVariant(
        id: m['id']?.toString() ?? '',
        name: m['name'] as String? ?? '',
        priceWithTax: m['priceWithTax'] as int? ?? 0,
        currencyCode: m['currencyCode'] as String? ?? 'NPR',
        sku: m['sku'] as String?,
        stockLevel: m['stockLevel'] as String?,
      );
    }).toList();
  }

  static List<ProductOptionGroup> _mapOptionGroups(List<dynamic> raw) {
    return raw.map((g) {
      final m = g as Map<String, dynamic>;
      final options =
          (m['options'] as List<dynamic>? ?? []).map((o) {
            final om = o as Map<String, dynamic>;
            return ProductOption(
              id: om['id']?.toString() ?? '',
              name: om['name'] as String? ?? '',
              code: om['code'] as String? ?? '',
            );
          }).toList();
      return ProductOptionGroup(
        id: m['id']?.toString() ?? '',
        name: m['name'] as String? ?? '',
        code: m['code'] as String? ?? '',
        options: options,
      );
    }).toList();
  }

  static List<ProductFacetValue> _mapFacetValues(List<dynamic> raw) {
    return raw.map((f) {
      final m = f as Map<String, dynamic>;
      final facet = m['facet'] as Map<String, dynamic>? ?? {};
      return ProductFacetValue(
        name: m['name'] as String? ?? '',
        code: m['code'] as String? ?? '',
        facetName: facet['name'] as String? ?? '',
        facetCode: facet['code'] as String? ?? '',
      );
    }).toList();
  }

  /// Strip HTML tags from description text.
  static String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '').trim();
  }

  /// Upgrade http:// image URLs to https:// for Android cleartext safety.
  static String? _fixImageUrl(String? url) {
    if (url == null) return null;
    if (url.startsWith('http://')) {
      return url.replaceFirst('http://', 'https://');
    }
    return url;
  }
}
