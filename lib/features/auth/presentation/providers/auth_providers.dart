/// Auth Riverpod providers — wires auth services and repositories.
///
/// Clean Architecture compliance:
///   presentation → domain (AuthRepository) ← data (AuthRepositoryImpl)
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/google_auth_service.dart';
import '../../data/datasources/phone_auth_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/phone_auth_state.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../controllers/google_auth_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Domain Repository
// ─────────────────────────────────────────────────────────────────────────────

/// [AuthRepository] — presentation layer uses this for auth state / sign-out.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// Stream of domain [UserEntity] auth state changes (null = signed out).
final authStateProvider = StreamProvider<UserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// ─────────────────────────────────────────────────────────────────────────────
// Firebase Auth instance (kept for legacy listeners, e.g. profile screen)
// ─────────────────────────────────────────────────────────────────────────────

/// Raw [FirebaseAuth] instance — prefer [authStateProvider] where possible.
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

/// Stream of raw Firebase auth state — legacy use only.
/// Prefer [authStateProvider] (returns [UserEntity]) in new code.
final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

// ─────────────────────────────────────────────────────────────────────────────
// Phone Auth Service
// ─────────────────────────────────────────────────────────────────────────────

/// [PhoneAuthService] singleton — manages the verify-phone flow.
final phoneAuthServiceProvider = Provider<PhoneAuthService>((ref) {
  final service = PhoneAuthService();
  ref.onDispose(service.dispose);
  return service;
});

/// Reactive stream of [PhoneAuthState] emitted by the service.
final phoneAuthStateProvider = StreamProvider<PhoneAuthState>((ref) {
  return ref.watch(phoneAuthServiceProvider).stateStream;
});

// ─────────────────────────────────────────────────────────────────────────────
// Google Auth
// ─────────────────────────────────────────────────────────────────────────────

/// [GoogleAuthService] singleton.
final googleAuthServiceProvider = Provider<GoogleAuthService>((ref) {
  return GoogleAuthService();
});

/// [GoogleAuthController] — drives the Google sign-in button.
final googleAuthControllerProvider =
    StateNotifierProvider<GoogleAuthController, AsyncValue<UserEntity?>>((ref) {
      final service = ref.watch(googleAuthServiceProvider);
      return GoogleAuthController(service);
    });
