/// SearchProductsUseCase — full-text product search.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class SearchProductsParams {
  const SearchProductsParams({
    required this.term,
    this.take = 20,
    this.skip = 0,
  });
  final String term;
  final int take;
  final int skip;
}

class SearchProductsUseCase
    implements UseCase<List<ProductEntity>, SearchProductsParams> {
  const SearchProductsUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<List<ProductEntity>> call(SearchProductsParams params) => _repository
      .searchProducts(params.term, take: params.take, skip: params.skip);
}
