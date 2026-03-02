/// AuthRepository — abstract contract for authentication operations.
library;

import '../entities/user_entity.dart';

/// Abstract interface implemented by [AuthRepositoryImpl] in the data layer.
abstract interface class AuthRepository {
  /// Returns the currently signed-in user, or null if not authenticated.
  Future<UserEntity?> getCurrentUser();

  /// Signs out the current user from all providers.
  Future<void> signOut();

  /// Stream of auth state changes (emits null on sign-out).
  Stream<UserEntity?> get authStateChanges;
}
