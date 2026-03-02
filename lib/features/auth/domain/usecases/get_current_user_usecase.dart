/// GetCurrentUserUseCase — retrieves the currently signed-in user.
library;

import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// Returns the current [UserEntity] or null if not authenticated.
class GetCurrentUserUseCase implements UseCase<UserEntity?, NoParams> {
  const GetCurrentUserUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<UserEntity?> call(NoParams params) => _repository.getCurrentUser();
}
