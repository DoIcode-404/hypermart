/// Route name/path constants — avoids magic strings across features.
library;

abstract final class RoutePaths {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign-in';
  static const String signUp = '/sign-up';
  static const String otpVerification = '/otp-verification';
  static const String home = '/home';
  static const String productList = '/products';
  static const String productDetails = '/products/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String wishlist = '/wishlist';
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:id';
  static const String orderTracking = '/orders/:id/tracking';
  static const String mapPicker = '/map-picker';
  static const String locationPermission = '/location-permission';
  static const String confirmLocation = '/confirm-location';
  static const String categories = '/categories';
  static const String profile = '/profile';
}

abstract final class RouteNames {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String signIn = 'sign-in';
  static const String signUp = 'sign-up';
  static const String otpVerification = 'otp-verification';
  static const String home = 'home';
  static const String productList = 'product-list';
  static const String productDetails = 'product-details';
  static const String cart = 'cart';
  static const String checkout = 'checkout';
  static const String orderConfirmation = 'order-confirmation';
  static const String wishlist = 'wishlist';
  static const String orders = 'orders';
  static const String orderDetails = 'order-details';
  static const String orderTracking = 'order-tracking';
  static const String mapPicker = 'map-picker';
  static const String locationPermission = 'location-permission';
  static const String confirmLocation = 'confirm-location';
  static const String categories = 'categories';
  static const String profile = 'profile';
}
