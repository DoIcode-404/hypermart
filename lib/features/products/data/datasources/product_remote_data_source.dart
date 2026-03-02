/// Product remote data source — executes GraphQL queries via HTTP for product data.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_constants.dart';
import '../graphql/product_queries.dart';

/// Lightweight GraphQL client using plain HTTP.
class ProductRemoteDataSource {
  ProductRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  /// Execute a GraphQL query and return the decoded JSON map.
  Future<Map<String, dynamic>> _query(String query) async {
    final response = await _client
        .post(
          Uri.parse(ApiConstants.shopApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({'query': query}),
        )
        .timeout(ApiConstants.timeout);

    if (response.statusCode != 200) {
      throw Exception('GraphQL request failed: ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (body.containsKey('errors')) {
      final errors = body['errors'] as List<dynamic>;
      throw Exception('GraphQL errors: ${errors.first['message']}');
    }

    return body['data'] as Map<String, dynamic>;
  }

  /// Fetch paginated products.
  Future<Map<String, dynamic>> getProducts({
    int take = 20,
    int skip = 0,
  }) async {
    final data = await _query(ProductQueries.products(take: take, skip: skip));
    return data['products'] as Map<String, dynamic>;
  }

  /// Fetch collections (categories).
  Future<List<dynamic>> getCollections() async {
    final data = await _query(ProductQueries.collections);
    final collections = data['collections'] as Map<String, dynamic>;
    return collections['items'] as List<dynamic>;
  }

  /// Search products by term.
  Future<Map<String, dynamic>> searchProducts(
    String term, {
    int take = 20,
    int skip = 0,
  }) async {
    final data = await _query(
      ProductQueries.searchProducts(term, take: take, skip: skip),
    );
    return data['search'] as Map<String, dynamic>;
  }

  /// Fetch products by collection slug.
  Future<Map<String, dynamic>> getProductsByCollection(
    String collectionSlug, {
    int take = 20,
    int skip = 0,
  }) async {
    final data = await _query(
      ProductQueries.productsByCollection(
        collectionSlug,
        take: take,
        skip: skip,
      ),
    );
    return data['search'] as Map<String, dynamic>;
  }

  /// Fetch a single product by ID.
  Future<Map<String, dynamic>?> getProductById(String id) async {
    final data = await _query(ProductQueries.productById(id));
    return data['product'] as Map<String, dynamic>?;
  }

  void dispose() => _client.close();
}
