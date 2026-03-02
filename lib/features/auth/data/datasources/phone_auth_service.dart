/// Firebase phone auth service — wraps FirebaseAuth phone verification flow.
library;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/phone_auth_state.dart';
import '../../domain/entities/user_entity.dart';

/// Service that encapsulates Firebase Phone Authentication.
///
/// Exposes a [stateStream] that UI layers can listen to for reactive updates,
/// and imperative methods [sendCode] / [verifyCode] / [resendCode].
class PhoneAuthService {
  PhoneAuthService({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  final _stateController = StreamController<PhoneAuthState>.broadcast();

  /// Reactive stream of authentication state changes.
  Stream<PhoneAuthState> get stateStream => _stateController.stream;

  // Cached for resend functionality.
  String? _lastPhoneNumber;
  int? _lastResendToken;
  String? _verificationId;

  /// The current verification ID (needed by the OTP screen).
  String? get verificationId => _verificationId;

  /// Send a verification SMS to [phoneNumber].
  ///
  /// [phoneNumber] must be in E.164 format, e.g. "+15551234567".
  Future<void> sendCode(String phoneNumber) async {
    _lastPhoneNumber = phoneNumber;
    _stateController.add(const PhoneAuthSending());

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _lastResendToken,

        // ── 1. Auto-retrieved on Android ────────────────────────
        verificationCompleted: (PhoneAuthCredential credential) async {
          _stateController.add(const PhoneAuthVerifying());
          try {
            final userCredential = await _auth.signInWithCredential(credential);
            if (userCredential.user != null) {
              _stateController.add(
                PhoneAuthSuccess(user: _toEntity(userCredential.user!)),
              );
            }
          } on FirebaseAuthException catch (e) {
            _stateController.add(
              PhoneAuthError(message: e.message ?? 'Auto-verification failed'),
            );
          }
        },

        // ── 2. Verification failed ─────────────────────────────
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Phone verification failed:');
          debugPrint('  code: ${e.code}');
          debugPrint('  message: ${e.message}');
          debugPrint('  plugin: ${e.plugin}');
          _stateController.add(PhoneAuthError(message: _friendlyError(e)));
        },

        // ── 3. Code sent — move to OTP screen ──────────────────
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _lastResendToken = resendToken;
          _stateController.add(
            PhoneAuthCodeSent(
              verificationId: verificationId,
              phoneNumber: phoneNumber,
              resendToken: resendToken,
            ),
          );
        },

        // ── 4. Auto-retrieval timed out ─────────────────────────
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _stateController.add(PhoneAuthError(message: 'Failed to send code: $e'));
    }
  }

  /// Verify the user-entered [smsCode] against the current verification.
  Future<void> verifyCode(String smsCode) async {
    final vId = _verificationId;
    if (vId == null) {
      _stateController.add(
        const PhoneAuthError(message: 'No verification in progress.'),
      );
      return;
    }

    _stateController.add(const PhoneAuthVerifying());

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: vId,
        smsCode: smsCode,
      );
      final userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        _stateController.add(
          PhoneAuthSuccess(user: _toEntity(userCredential.user!)),
        );
      } else {
        _stateController.add(
          const PhoneAuthError(message: 'Sign-in returned no user.'),
        );
      }
    } on FirebaseAuthException catch (e) {
      _stateController.add(PhoneAuthError(message: _friendlyError(e)));
    } catch (e) {
      _stateController.add(PhoneAuthError(message: 'Verification failed: $e'));
    }
  }

  /// Resend the SMS code to the last phone number.
  Future<void> resendCode() async {
    final phone = _lastPhoneNumber;
    if (phone == null) {
      _stateController.add(
        const PhoneAuthError(message: 'No phone number to resend to.'),
      );
      return;
    }
    await sendCode(phone);
  }

  /// Map Firebase error codes to user-friendly messages.
  String _friendlyError(FirebaseAuthException e) {
    return switch (e.code) {
      'invalid-phone-number' =>
        'The phone number is invalid. Please check and try again.',
      'too-many-requests' => 'Too many attempts. Please try again later.',
      'quota-exceeded' => 'SMS quota exceeded. Please try again later.',
      'invalid-verification-code' =>
        'Invalid code. Please enter the correct code.',
      'session-expired' =>
        'Verification session expired. Please request a new code.',
      _ => e.message ?? 'An unknown error occurred.',
    };
  }

  /// Clean up resources.
  void dispose() {
    _stateController.close();
  }

  /// Map a [firebase_auth.User] to the pure-Dart [UserEntity].
  UserEntity _toEntity(User user) {
    return UserEntity(
      uid: user.uid,
      phoneNumber: user.phoneNumber ?? '',
      displayName: user.displayName,
      email: user.email,
      photoUrl: user.photoURL,
      isEmailVerified: user.emailVerified,
    );
  }
}
