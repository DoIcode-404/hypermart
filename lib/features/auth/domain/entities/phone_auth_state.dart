/// Phone auth state — tracks the Firebase phone verification flow.
/// Pure Dart: no firebase_auth imports (data layer maps FirebaseUser → UserEntity).
library;

import 'user_entity.dart';

/// Sealed class representing the phone auth verification state.
sealed class PhoneAuthState {
  const PhoneAuthState();
}

/// Initial state — no verification in progress.
class PhoneAuthInitial extends PhoneAuthState {
  const PhoneAuthInitial();
}

/// Sending the SMS code.
class PhoneAuthSending extends PhoneAuthState {
  const PhoneAuthSending();
}

/// SMS code sent — awaiting user input.
class PhoneAuthCodeSent extends PhoneAuthState {
  const PhoneAuthCodeSent({
    required this.verificationId,
    required this.phoneNumber,
    this.resendToken,
  });

  final String verificationId;
  final String phoneNumber;
  final int? resendToken;
}

/// Verifying the OTP.
class PhoneAuthVerifying extends PhoneAuthState {
  const PhoneAuthVerifying();
}

/// Verification succeeded — user is signed in.
class PhoneAuthSuccess extends PhoneAuthState {
  const PhoneAuthSuccess({required this.user});

  /// Domain user — mapped from FirebaseAuth.User in the data layer.
  final UserEntity user;
}

/// Something went wrong.
class PhoneAuthError extends PhoneAuthState {
  const PhoneAuthError({required this.message});

  final String message;
}
