/// Root widget — MaterialApp.router wrapped with ProviderScope.
/// Applies global theme, router config, and locale settings.
library;

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

/// The root application widget.
///
/// Uses [ConsumerWidget] so it can read Riverpod providers
/// (e.g. router, theme mode) directly.
class HyperMartApp extends ConsumerWidget {
  const HyperMartApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'HyperMart',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      // DevicePreview hooks
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
    );
  }
}
