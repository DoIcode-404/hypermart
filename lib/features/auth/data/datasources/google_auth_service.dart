/// GoogleAuthService — wraps google_sign_in + FirebaseAuth credential exchange.
///
/// Platform strategy:
///   Web     → FirebaseAuth.signInWithPopup(GoogleAuthProvider) directly.
///             google_sign_in's signIn() on web only returns an access_token
///             (no idToken), so Firebase credential exchange is impossible.
///   Android/iOS → google_sign_in package + signInWithCredential.
library;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user_entity.dart';

class GoogleAuthService {
  GoogleAuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
    : _auth = auth ?? FirebaseAuth.instance,
      // serverClientId must be null on web (asserted by google_sign_in_web).
      // On Android/iOS it must be the Web Client ID so idToken is non-null.
      _googleSignIn =
          googleSignIn ??
          GoogleSignIn(
            clientId:
                '603658562096-pl0t38qmdia9bds1qolhdv3sfrc8s5eu.apps.googleusercontent.com',
            serverClientId:
                kIsWeb
                    ? null
                    : '603658562096-pl0t38qmdia9bds1qolhdv3sfrc8s5eu.apps.googleusercontent.com',
          );

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  /// Sign in with Google and return the domain [UserEntity].
  ///
  /// Returns `null` if the user dismisses the account picker.
  Future<UserEntity?> signIn() async {
    if (kIsWeb) {
      return _signInWeb();
    }
    return _signInNative();
  }

  /// Web: use FirebaseAuth.signInWithPopup — this is the only reliable way
  /// to get an idToken via Google Sign-In on web with GIS.
  Future<UserEntity?> _signInWeb() async {
    final userCredential = await _auth.signInWithPopup(GoogleAuthProvider());
    return _toEntity(userCredential.user);
  }

  /// Android / iOS: use google_sign_in package → exchange tokens with Firebase.
  Future<UserEntity?> _signInNative() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return _toEntity(userCredential.user);
  }

  /// Sign out from both Google and Firebase.
  Future<void> signOut() async {
    if (kIsWeb) {
      await _auth.signOut();
    } else {
      await Future.wait([_googleSignIn.signOut(), _auth.signOut()]);
    }
  }

  /// Map a nullable [firebase_auth.User] to [UserEntity].
  UserEntity? _toEntity(User? user) {
    if (user == null) return null;
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
