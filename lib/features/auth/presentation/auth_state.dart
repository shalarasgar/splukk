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

  const AuthState.updating()
      : this._(status: AuthStatus.updating);

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

  AuthState copyWith({
    AuthStatus? status,
    SessionUser? user,
    UserProfile? profile,
    String? errorMessage,
    String? verificationId,
  }) {
    return AuthState._(
      status: status ?? this.status,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
      verificationId: verificationId ?? this.verificationId,
    );
  }
}

enum AuthStatus {
  unauthenticated,
  verifyingPhone,
  codeSent,
  authenticated,
  updating,
  failure,
}
