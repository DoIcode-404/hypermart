/// Base UseCase contract.
/// All domain use cases extend [UseCase<Type, Params>].
/// For use cases that take no parameters, pass [NoParams].
library;

/// Every use case must implement this interface.
///
/// ```dart
/// class GetProductsUseCase extends UseCase<List<ProductEntity>, NoParams> {
///   @override
///   Future<List<ProductEntity>> call(NoParams params) => _repo.getProducts();
/// }
/// ```
abstract interface class UseCase<Type, Params> {
  Future<Type> call(Params params);
}

/// Sentinel type for use cases that require no input parameters.
final class NoParams {
  const NoParams();
}
