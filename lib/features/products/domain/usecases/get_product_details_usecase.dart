/// GetProductDetailsUseCase — fetches a single product by ID.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductDetailsUseCase implements UseCase<ProductEntity?, String> {
  const GetProductDetailsUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<ProductEntity?> call(String id) => _repository.getProductById(id);
}
