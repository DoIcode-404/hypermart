/// SignOutUseCase — signs out the current user.
library;

import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Clears the active session for all auth providers.
class SignOutUseCase implements UseCase<void, NoParams> {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  @override
  Future<void> call(NoParams params) => _repository.signOut();
}
