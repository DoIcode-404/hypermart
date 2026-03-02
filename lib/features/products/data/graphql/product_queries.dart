/// GraphQL query strings for product listing (paginated) and product details.
library;

abstract final class ProductQueries {
  /// Fetch paginated products with optional collection filter.
  static String products({int take = 20, int skip = 0}) => '''
{
  products(options: { take: $take, skip: $skip }) {
    totalItems
    items {
      id
      name
      slug
      description
      featuredAsset {
        preview
        source
      }
      variants {
        id
        name
        priceWithTax
        price
        currencyCode
      }
      facetValues {
        name
        facet {
          name
        }
      }
      collections {
        id
        name
        slug
      }
    }
  }
}
''';

  /// Fetch products by collection slug.
  static String productsByCollection(
    String collectionSlug, {
    int take = 20,
    int skip = 0,
  }) => '''
{
  search(input: {
    collectionSlug: "$collectionSlug",
    take: $take,
    skip: $skip,
    groupByProduct: true
  }) {
    totalItems
    items {
      productId
      productName
      slug
      productAsset {
        preview
      }
      price {
        ... on SinglePrice {
          value
        }
        ... on PriceRange {
          min
          max
        }
      }
      currencyCode
    }
  }
}
''';

  /// Fetch collections (categories).
  static const String collections = '''
{
  collections(options: { topLevelOnly: true, take: 20 }) {
    totalItems
    items {
      id
      name
      slug
      featuredAsset {
        preview
      }
    }
  }
}
''';

  /// Search products by term.
  static String searchProducts(String term, {int take = 20, int skip = 0}) =>
      '''
{
  search(input: {
    term: "${term.replaceAll('"', '\\"')}",
    take: $take,
    skip: $skip,
    groupByProduct: true
  }) {
    totalItems
    items {
      productId
      productName
      slug
      productAsset {
        preview
      }
      price {
        ... on SinglePrice {
          value
        }
        ... on PriceRange {
          min
          max
        }
      }
      currencyCode
    }
  }
}
''';

  /// Fetch a single product by ID with full details.
  static String productById(String id) => '''
{
  product(id: "$id") {
    id
    name
    slug
    description
    featuredAsset {
      preview
      source
    }
    assets {
      id
      preview
      source
    }
    variants {
      id
      name
      sku
      priceWithTax
      price
      currencyCode
      stockLevel
    }
    facetValues {
      name
      code
      facet {
        name
        code
      }
    }
    collections {
      id
      name
      slug
    }
    optionGroups {
      id
      name
      code
      options {
        id
        name
        code
      }
    }
  }
}
''';
}
