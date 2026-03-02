/// GetCollectionsUseCase — fetches all top-level product collections.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/collection_entity.dart';
import '../repositories/product_repository.dart';

class GetCollectionsUseCase
    implements UseCase<List<CollectionEntity>, NoParams> {
  const GetCollectionsUseCase(this._repository);

  final ProductRepository _repository;

  @override
  Future<List<CollectionEntity>> call(NoParams params) =>
      _repository.getCollections();
}
