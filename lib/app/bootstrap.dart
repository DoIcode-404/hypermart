/// App bootstrap — initializes services, providers, and runs the app.
/// Called from main.dart. Sets up ProviderScope, error handlers, etc.
///
/// WHY bootstrap() exists:
/// ──────────────────────
/// 1. **WidgetsFlutterBinding.ensureInitialized()** — MUST be called before
///    any plugin (SharedPreferences, Hive, Firebase, GoogleMaps, etc.) is used.
///    Without it, platform channels are not ready and plugin calls crash.
///
/// 2. **Centralised async init** — Services like local DB, secure storage,
///    Firebase, or environment config need to resolve BEFORE the widget tree
///    renders. bootstrap() is the single place to `await` all of them.
///
/// 3. **Global error handling** — Flutter & Dart errors (FlutterError.onError,
///    PlatformDispatcher.onError) are overridden here so no crash goes
///    unlogged, even before the first frame is painted.
///
/// 4. **Orientation / status-bar config** — SystemChrome calls belong here,
///    not scattered across widgets.
///
/// 5. **Testability** — Extracting setup from `main()` lets integration tests
///    call bootstrap() with mocked overrides without touching the entry point.
library;

import 'dart:async';

import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/cart/presentation/providers/cart_providers.dart'
    show sharedPreferencesProvider;
import '../firebase_options.dart';
import 'app.dart';

/// Single entry-point that initialises the entire application.
///
/// Sequence:
/// ```
/// main() → bootstrap()
///   1. ensureInitialized
///   2. lock orientation
///   3. set up error observers
///   4. (await) init async services  ← extend here
///   5. runApp inside ProviderScope
/// ```
Future<void> bootstrap() async {
  // ── 1. Ensure Flutter binding is ready ──────────────────────────────────
  WidgetsFlutterBinding.ensureInitialized();

  // ── 2. Lock orientation (optional — remove if landscape is needed) ─────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── 3. Global error handling ───────────────────────────────────────────
  // Catches errors that happen inside the Flutter framework (e.g. build/layout).
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    // TODO: forward to Crashlytics / Sentry
    debugPrint('⚠️ FlutterError: ${details.exceptionAsString()}');
  };

  // ── 4. Async service init (extend as needed) ──────────────────────────
  // Initialize Firebase — required before using any Firebase service.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize SharedPreferences for cart & wishlist local persistence.
  final sharedPreferences = await SharedPreferences.getInstance();

  // ── 5. Run the app inside Riverpod's ProviderScope ────────────────────
  runApp(
    DevicePreview(
      enabled: kDebugMode,
      builder:
          (_) => ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(sharedPreferences),
            ],
            observers: [if (kDebugMode) _RiverpodLogger()],
            child: const HyperMartApp(),
          ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Whether the app is running in debug mode.
const bool kDebugMode = bool.fromEnvironment('dart.vm.product') == false;

/// Simple Riverpod observer that logs provider lifecycle events in debug mode.
class _RiverpodLogger extends ProviderObserver {
  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    debugPrint(
      '[Riverpod] ✅ CREATED  ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint(
      '[Riverpod] 🔄 UPDATED  ${provider.name ?? provider.runtimeType}',
    );
  }

  @override
  void didDisposeProvider(
    ProviderBase<Object?> provider,
    ProviderContainer container,
  ) {
    debugPrint(
      '[Riverpod] 🗑️ DISPOSED ${provider.name ?? provider.runtimeType}',
    );
  }
}
