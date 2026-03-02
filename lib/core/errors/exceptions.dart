/// Custom exception classes thrown in the data layer.
/// Repository implementations catch these and map them to [Failure] subtypes.
library;

/// Thrown when a remote API request fails (non-2xx, GraphQL errors, timeouts).
class ServerException implements Exception {
  const ServerException([this.message = 'Server error']);
  final String message;
  @override
  String toString() => 'ServerException: $message';
}

/// Thrown when reading or writing local storage (SharedPreferences) fails.
class CacheException implements Exception {
  const CacheException([this.message = 'Cache error']);
  final String message;
  @override
  String toString() => 'CacheException: $message';
}

/// Thrown when a network call fails due to connectivity.
class NetworkException implements Exception {
  const NetworkException([this.message = 'Network unavailable']);
  final String message;
  @override
  String toString() => 'NetworkException: $message';
}

/// Thrown by auth operations (wrong OTP, revoked token, etc.).
class AuthException implements Exception {
  const AuthException([this.message = 'Authentication error']);
  final String message;
  @override
  String toString() => 'AuthException: $message';
}
