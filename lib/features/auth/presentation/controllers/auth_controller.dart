/// AuthController — Riverpod AsyncNotifier managing phone auth state.
/// Exposes sendCode, verifyCode, resendCode; rebuilds UI on state change.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/phone_auth_service.dart';
import '../../domain/entities/phone_auth_state.dart';
import '../providers/auth_providers.dart';

/// Riverpod provider for [PhoneAuthController].
final phoneAuthControllerProvider =
    StateNotifierProvider<PhoneAuthController, PhoneAuthState>((ref) {
      final service = ref.watch(phoneAuthServiceProvider);
      return PhoneAuthController(service);
    });

/// Controller that bridges [PhoneAuthService] ↔ UI.
///
/// Listens to the service's state stream and mirrors it into the
/// Riverpod [StateNotifier] state so widgets can `ref.watch` it.
class PhoneAuthController extends StateNotifier<PhoneAuthState> {
  PhoneAuthController(this._service) : super(const PhoneAuthInitial()) {
    _service.stateStream.listen((newState) {
      if (mounted) state = newState;
    });
  }

  final PhoneAuthService _service;

  /// Kick off phone number verification.
  /// [phoneNumber] must be E.164 format, e.g. "+15551234567".
  Future<void> sendCode(String phoneNumber) async {
    await _service.sendCode(phoneNumber);
  }

  /// Verify the 4/6-digit OTP code.
  Future<void> verifyCode(String smsCode) async {
    await _service.verifyCode(smsCode);
  }

  /// Resend the SMS code.
  Future<void> resendCode() async {
    await _service.resendCode();
  }

  /// Reset back to initial state (e.g. when user navigates back).
  void reset() {
    state = const PhoneAuthInitial();
  }
}
