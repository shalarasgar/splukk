part of 'auth_bloc.dart';

enum AuthFlowIntent { login, registerConsumer, registerFarmer }

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthSignOutRequested extends AuthEvent {
  const AuthSignOutRequested();
}

class AuthVippsLoginRequested extends AuthEvent {
  const AuthVippsLoginRequested();
}

class AuthProfileUpdated extends AuthEvent {
  const AuthProfileUpdated(this.profile, {this.logoLocalPath});

  final UserProfile profile;
  final String? logoLocalPath;

  @override
  List<Object?> get props => [profile, logoLocalPath];
}
