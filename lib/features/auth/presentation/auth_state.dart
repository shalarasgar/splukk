part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user,
    this.profile,
    this.errorMessage,
    this.verificationId,
  });

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthState.authenticated({
    required SessionUser user,
    required UserProfile profile,
  }) : this._(
          status: AuthStatus.authenticated,
          user: user,
          profile: profile,
        );

  const AuthState.verifyingPhone()
      : this._(status: AuthStatus.verifyingPhone);

  const AuthState.codeSent({required String verificationId})
      : this._(
          status: AuthStatus.codeSent,
          verificationId: verificationId,
        );

  const AuthState.failure(String message)
      : this._(
          status: AuthStatus.failure,
          errorMessage: message,
        );

  final AuthStatus status;
  final SessionUser? user;
  final UserProfile? profile;
  final String? errorMessage;
  final String? verificationId;

  @override
  List<Object?> get props =>
      [status, user, profile, errorMessage, verificationId];
}

enum AuthStatus {
  unauthenticated,
  verifyingPhone,
  codeSent,
  authenticated,
  failure,
}
