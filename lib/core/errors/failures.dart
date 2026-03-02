/// Failure classes — sealed hierarchy returned by repositories.
/// Presentation layer maps these to user-friendly messages.
library;

/// Base sealed class for all domain failures.
sealed class Failure {
  const Failure(this.message);
  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

/// A remote API / Firebase call failed.
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

/// Local storage (SharedPreferences / Hive) read or write failed.
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'A cache error occurred.']);
}

/// Device has no internet connection.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'No internet connection. Please try again.',
  ]);
}

/// Caller passed invalid arguments.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// User is not authenticated.
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed.']);
}

/// Requested resource was not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found.']);
}
