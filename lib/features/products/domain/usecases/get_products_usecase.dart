/// GetProductsUseCase — fetches paginated product listing.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsParams {
  const GetProductsParams({this.take = 20, this.skip = 0});
  final int take;
  final int skip;
}

class GetProductsUseCase
    implements UseCase<List<ProductEntity>, GetProductsParams> {
  const GetProductsUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<List<ProductEntity>> call(GetProductsParams params) =>
      _repository.getProducts(take: params.take, skip: params.skip);
}
