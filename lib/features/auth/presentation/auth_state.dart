part of 'auth_bloc.dart';

class AuthState extends Equatable {
  const AuthState._({
    required this.status,
    this.user,
    this.profile,
    this.errorMessage,
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

  const AuthState.updating()
      : this._(status: AuthStatus.updating);

  const AuthState.failure(String message)
      : this._(
          status: AuthStatus.failure,
          errorMessage: message,
        );

  final AuthStatus status;
  final SessionUser? user;
  final UserProfile? profile;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, user, profile, errorMessage];

  AuthState copyWith({
    AuthStatus? status,
    SessionUser? user,
    UserProfile? profile,
    String? errorMessage,
  }) {
    return AuthState._(
      status: status ?? this.status,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

enum AuthStatus {
  unauthenticated,
  authenticated,
  updating,
  failure,
}
