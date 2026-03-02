/// GoRouter configuration — defines all application routes.
/// Delegates to feature-specific route branches.
///
/// Provided as a Riverpod provider so the entire app and deep-links
/// share a single router instance.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/routing/route_names.dart';
import '../features/auth/presentation/screens/otp_verification_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';
import '../features/auth/presentation/screens/sign_in_screen.dart';
import '../features/auth/presentation/screens/sign_up_screen.dart';
import '../features/cart/domain/entities/cart_item_entity.dart';
import '../features/cart/presentation/screens/cart_screen.dart';
import '../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../features/onboarding/presentation/screens/splash_screen.dart';
import '../features/orders/presentation/screens/checkout_screen.dart';
import '../features/orders/presentation/screens/map_picker_screen.dart';
import '../features/orders/presentation/screens/order_confirmation_screen.dart';
import '../features/orders/presentation/screens/order_details_screen.dart';
import '../features/orders/presentation/screens/order_tracking_map_screen.dart';
import '../features/orders/presentation/screens/orders_screen.dart';
import '../features/products/presentation/screens/product_details_screen.dart';
import '../features/products/presentation/screens/product_list_screen.dart';
import '../features/location/presentation/screens/confirm_location_screen.dart';
import '../features/location/presentation/screens/location_permission_screen.dart';
import '../features/wishlist/presentation/screens/wishlist_screen.dart';
import 'main_shell_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Navigator key — useful for navigation outside the widget tree.
// ─────────────────────────────────────────────────────────────────────────────
final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

// ─────────────────────────────────────────────────────────────────────────────
// Riverpod Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Single GoRouter instance — consumed in [HyperMartApp] via `ref.watch`.
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    debugLogDiagnostics: true,
    routes: _routes,
    errorBuilder: _errorBuilder,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Navigator keys for shell branches
// ─────────────────────────────────────────────────────────────────────────────
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellHome',
);
final _shellNavigatorCartKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellCart',
);
final _shellNavigatorOrdersKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellOrders',
);
final _shellNavigatorProfileKey = GlobalKey<NavigatorState>(
  debugLabel: 'shellProfile',
);

// ─────────────────────────────────────────────────────────────────────────────
// Route definitions
// ─────────────────────────────────────────────────────────────────────────────

final List<RouteBase> _routes = [
  // ── Splash ───────────────────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.splash,
    name: RouteNames.splash,
    builder: (context, state) => const SplashScreen(),
  ),

  // ── Onboarding ───────────────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.onboarding,
    name: RouteNames.onboarding,
    builder: (context, state) => const OnboardingScreen(),
  ),

  // ── Auth ─────────────────────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.signIn,
    name: RouteNames.signIn,
    builder: (context, state) => const SignInScreen(),
  ),
  GoRoute(
    path: RoutePaths.signUp,
    name: RouteNames.signUp,
    builder: (context, state) => const SignUpScreen(),
  ),
  GoRoute(
    path: RoutePaths.otpVerification,
    name: RouteNames.otpVerification,
    builder: (context, state) {
      final phoneNumber = state.extra as String? ?? '';
      return OtpVerificationScreen(phoneNumber: phoneNumber);
    },
  ),

  // ── Location ─────────────────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.locationPermission,
    name: RouteNames.locationPermission,
    builder: (context, state) => const LocationPermissionScreen(),
  ),
  GoRoute(
    path: RoutePaths.confirmLocation,
    name: RouteNames.confirmLocation,
    builder: (context, state) {
      final useGps = state.extra as bool? ?? false;
      return ConfirmLocationScreen(useGps: useGps);
    },
  ),

  // ── Main Shell (Bottom Nav) ──────────────────────────────────────────────
  StatefulShellRoute.indexedStack(
    builder:
        (context, state, navigationShell) =>
            MainShellScreen(navigationShell: navigationShell),
    branches: [
      // Tab 0 — Home
      StatefulShellBranch(
        navigatorKey: _shellNavigatorHomeKey,
        routes: [
          GoRoute(
            path: RoutePaths.home,
            name: RouteNames.home,
            builder: (context, state) => const ProductListScreen(),
          ),
        ],
      ),

      // Tab 1 — Cart
      StatefulShellBranch(
        navigatorKey: _shellNavigatorCartKey,
        routes: [
          GoRoute(
            path: RoutePaths.cart,
            name: RouteNames.cart,
            builder: (context, state) => const CartScreen(),
          ),
        ],
      ),

      // Tab 2 — Orders
      StatefulShellBranch(
        navigatorKey: _shellNavigatorOrdersKey,
        routes: [
          GoRoute(
            path: RoutePaths.orders,
            name: RouteNames.orders,
            builder: (context, state) => const OrdersScreen(),
          ),
        ],
      ),

      // Tab 3 — Profile
      StatefulShellBranch(
        navigatorKey: _shellNavigatorProfileKey,
        routes: [
          GoRoute(
            path: RoutePaths.profile,
            name: RouteNames.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  ),

  // ── Product Details (outside shell — full-screen) ────────────────────────
  GoRoute(
    path: RoutePaths.productList,
    name: RouteNames.productList,
    builder: (context, state) => const ProductListScreen(),
  ),
  GoRoute(
    path: RoutePaths.productDetails,
    name: RouteNames.productDetails,
    builder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      return ProductDetailsScreen(productId: id);
    },
  ),

  // ── Checkout ─────────────────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.checkout,
    name: RouteNames.checkout,
    builder: (context, state) => const CheckoutScreen(),
  ),

  // ── Order Confirmation ───────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.orderConfirmation,
    name: RouteNames.orderConfirmation,
    builder: (context, state) {
      final extra = state.extra as Map<String, dynamic>? ?? {};
      final items = extra['items'] as List<CartItemEntity>? ?? [];
      final total = extra['total'] as int? ?? 0;
      final currencyCode = extra['currencyCode'] as String? ?? 'NPR';
      return OrderConfirmationScreen(
        items: items,
        total: total,
        currencyCode: currencyCode,
      );
    },
  ),

  // ── Wishlist ─────────────────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.wishlist,
    name: RouteNames.wishlist,
    builder: (context, state) => const WishlistScreen(),
  ),

  // ── Order Details & Tracking (outside shell) ─────────────────────────────
  GoRoute(
    path: RoutePaths.orderDetails,
    name: RouteNames.orderDetails,
    builder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      return OrderDetailsScreen(orderId: id);
    },
  ),
  GoRoute(
    path: RoutePaths.orderTracking,
    name: RouteNames.orderTracking,
    builder: (context, state) {
      final id = state.pathParameters['id'] ?? '';
      return OrderTrackingMapScreen(orderId: id);
    },
  ),

  // ── Map picker ───────────────────────────────────────────────────────────
  GoRoute(
    path: RoutePaths.mapPicker,
    name: RouteNames.mapPicker,
    builder: (context, state) => const MapPickerScreen(),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Error page
// ─────────────────────────────────────────────────────────────────────────────

Widget _errorBuilder(BuildContext context, GoRouterState state) {
  return Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(
      child: Text(
        '404 — ${state.uri} not found',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    ),
  );
}
