/// API endpoint constants — GraphQL endpoint URL, API keys, timeouts.
library;

abstract final class ApiConstants {
  /// Hyperce shop GraphQL endpoint.
  static const String shopApiUrl = 'https://admin.hyperce.io/shop-api';

  /// Default request timeout.
  static const Duration timeout = Duration(seconds: 15);

  /// Default currency code from the API.
  static const String defaultCurrency = 'NPR';
}
