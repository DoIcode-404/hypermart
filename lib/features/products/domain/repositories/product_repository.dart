/// ProductRepository — abstract contract for product data operations.
library;

import '../entities/collection_entity.dart';
import '../entities/product_entity.dart';

/// Implemented by [ProductRepositoryImpl] in the data layer.
abstract interface class ProductRepository {
  /// Fetches all top-level collections (categories).
  Future<List<CollectionEntity>> getCollections();

  /// Fetches a paginated list of products.
  Future<List<ProductEntity>> getProducts({int take = 20, int skip = 0});

  /// Fetches products belonging to a collection by [slug].
  Future<List<ProductEntity>> getProductsByCollection(
    String slug, {
    int take = 20,
    int skip = 0,
  });

  /// Full-text product search.
  Future<List<ProductEntity>> searchProducts(
    String term, {
    int take = 20,
    int skip = 0,
  });

  /// Fetches a single product by its [id]. Returns null if not found.
  Future<ProductEntity?> getProductById(String id);
}
