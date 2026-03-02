/// GetProductsByCollectionUseCase — fetches products filtered by collection slug.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsByCollectionParams {
  const GetProductsByCollectionParams({
    required this.slug,
    this.take = 20,
    this.skip = 0,
  });
  final String slug;
  final int take;
  final int skip;
}

class GetProductsByCollectionUseCase
    implements UseCase<List<ProductEntity>, GetProductsByCollectionParams> {
  const GetProductsByCollectionUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<List<ProductEntity>> call(GetProductsByCollectionParams params) =>
      _repository.getProductsByCollection(
        params.slug,
        take: params.take,
        skip: params.skip,
      );
}
