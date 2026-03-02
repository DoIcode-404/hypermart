/// GoogleAuthController — Riverpod StateNotifier for Google sign-in flow.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/google_auth_service.dart';
import '../../domain/entities/user_entity.dart';

class GoogleAuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  GoogleAuthController(this._service) : super(const AsyncData(null));

  final GoogleAuthService _service;

  /// Trigger the Google sign-in flow.
  Future<void> signIn() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.signIn());
  }

  /// Reset back to the idle state (e.g. after error snackbar shown).
  void reset() => state = const AsyncData(null);
}
