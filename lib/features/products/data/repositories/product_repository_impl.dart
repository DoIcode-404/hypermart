/// ProductRepositoryImpl — implements domain ProductRepository.
/// Delegates to [ProductRemoteDataSource] and maps raw JSON → entities.
library;

import '../../domain/entities/collection_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../mappers/product_mapper.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl({required ProductRemoteDataSource dataSource})
    : _dataSource = dataSource;

  final ProductRemoteDataSource _dataSource;

  @override
  Future<List<CollectionEntity>> getCollections() async {
    final items = await _dataSource.getCollections();
    return items.map((e) {
      final map = e as Map<String, dynamic>;
      final asset = map['featuredAsset'] as Map<String, dynamic>?;
      return CollectionEntity(
        id: map['id']?.toString() ?? '',
        name: map['name'] as String? ?? '',
        slug: map['slug'] as String? ?? '',
        imageUrl: asset?['preview'] as String?,
      );
    }).toList();
  }

  @override
  Future<List<ProductEntity>> getProducts({int take = 20, int skip = 0}) async {
    final data = await _dataSource.getProducts(take: take, skip: skip);
    final items = data['items'] as List<dynamic>;
    return ProductMapper.fromProductListJson(items);
  }

  @override
  Future<List<ProductEntity>> getProductsByCollection(
    String slug, {
    int take = 20,
    int skip = 0,
  }) async {
    final data = await _dataSource.getProductsByCollection(
      slug,
      take: take,
      skip: skip,
    );
    final items = data['items'] as List<dynamic>;
    return ProductMapper.fromSearchListJson(items);
  }

  @override
  Future<List<ProductEntity>> searchProducts(
    String term, {
    int take = 20,
    int skip = 0,
  }) async {
    final data = await _dataSource.searchProducts(term, take: take, skip: skip);
    final items = data['items'] as List<dynamic>;
    return ProductMapper.fromSearchListJson(items);
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    final data = await _dataSource.getProductById(id);
    if (data == null) return null;
    return ProductMapper.fromProductJson(data);
  }
}
