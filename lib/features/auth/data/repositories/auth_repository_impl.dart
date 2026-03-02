/// AuthRepositoryImpl — implements domain AuthRepository.
library;

import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

/// Concrete implementation that wraps [FirebaseAuth].
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({FirebaseAuth? auth})
    : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    return user == null ? null : _toEntity(user);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _auth.authStateChanges().map(
      (user) => user == null ? null : _toEntity(user),
    );
  }

  UserEntity _toEntity(User user) => UserEntity(
    uid: user.uid,
    phoneNumber: user.phoneNumber ?? '',
    displayName: user.displayName,
    email: user.email,
    photoUrl: user.photoURL,
    isEmailVerified: user.emailVerified,
  );
}
