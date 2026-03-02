/// Product Riverpod providers — wires ProductRepository → products/collections state.
///
/// Clean Architecture compliance:
///   presentation → domain (ProductRepository) ← data (ProductRepositoryImpl)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/product_remote_data_source.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/collection_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Infrastructure providers (data layer wiring — kept here for DI purposes)
// ─────────────────────────────────────────────────────────────────────────────

/// Singleton remote data source.
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  final ds = ProductRemoteDataSource();
  ref.onDispose(ds.dispose);
  return ds;
});

/// Singleton [ProductRepository] — presentation accesses data through this.
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    dataSource: ref.watch(productRemoteDataSourceProvider),
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Feature providers — all use [productRepositoryProvider]
// ─────────────────────────────────────────────────────────────────────────────

/// Fetches all top-level collections for the category chips.
final collectionsProvider = FutureProvider<List<CollectionEntity>>((ref) async {
  return ref.watch(productRepositoryProvider).getCollections();
});

/// Fetches all products (first page).
final productsProvider = FutureProvider<List<ProductEntity>>((ref) async {
  return ref.watch(productRepositoryProvider).getProducts(take: 20);
});

/// Fetches products filtered by collection slug.
/// Provide `null` for "All" (no filter).
final filteredProductsProvider =
    FutureProvider.family<List<ProductEntity>, String?>((ref, slug) async {
      final repo = ref.watch(productRepositoryProvider);
      if (slug == null || slug.isEmpty) {
        return repo.getProducts(take: 20);
      }
      return repo.getProductsByCollection(slug, take: 20);
    });

/// Searches products by term.
final searchProductsProvider =
    FutureProvider.family<List<ProductEntity>, String>((ref, term) async {
      if (term.trim().isEmpty) return [];
      return ref
          .watch(productRepositoryProvider)
          .searchProducts(term, take: 20);
    });

/// Currently selected collection slug (null = "All").
final selectedCollectionProvider = StateProvider<String?>((ref) => null);

/// Fetch a single product by ID — full details including variants, options, assets.
final productDetailProvider = FutureProvider.family<ProductEntity?, String>((
  ref,
  id,
) async {
  return ref.watch(productRepositoryProvider).getProductById(id);
});
