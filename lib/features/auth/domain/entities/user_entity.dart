/// UserEntity — pure-Dart domain representation of the authenticated user.
/// No firebase_auth imports — the data layer maps FirebaseUser → UserEntity.
library;

/// Domain model for an authenticated user.
class UserEntity {
  const UserEntity({
    required this.uid,
    required this.phoneNumber,
    this.displayName,
    this.email,
    this.photoUrl,
    this.isEmailVerified = false,
  });

  final String uid;
  final String phoneNumber;
  final String? displayName;
  final String? email;
  final String? photoUrl;
  final bool isEmailVerified;

  /// Convenience: true when the user has at least a UID.
  bool get isValid => uid.isNotEmpty;

  UserEntity copyWith({
    String? uid,
    String? phoneNumber,
    String? displayName,
    String? email,
    String? photoUrl,
    bool? isEmailVerified,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
    );
  }

  @override
  bool operator ==(Object other) => other is UserEntity && other.uid == uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'UserEntity(uid: $uid, phone: $phoneNumber)';
}
