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

class AuthPhoneRequested extends AuthEvent {
  const AuthPhoneRequested(
    this.phoneNumber, {
    required this.intent,
    this.fullName,
    this.farmName,
    this.farmCountry,
    this.farmState,
    this.farmCity,
    this.farmPostalCode,
    this.farmStreet,
    this.farmStreetNumber,
    this.logoLocalPath,
  });

  final String phoneNumber;
  final AuthFlowIntent intent;
  final String? fullName;
  final String? farmName;
  final String? farmCountry;
  final String? farmState;
  final String? farmCity;
  final String? farmPostalCode;
  final String? farmStreet;
  final String? farmStreetNumber;
  final String? logoLocalPath;

  @override
  List<Object?> get props => [
        phoneNumber,
        intent,
        fullName,
        farmName,
        farmCountry,
        farmState,
        farmCity,
        farmPostalCode,
        farmStreet,
        farmStreetNumber,
        logoLocalPath,
      ];
}

class AuthSmsCodeSubmitted extends AuthEvent {
  const AuthSmsCodeSubmitted(this.smsCode);

  final String smsCode;

  @override
  List<Object?> get props => [smsCode];
}

class AuthAfterPhoneVerified extends AuthEvent {
  const AuthAfterPhoneVerified(this.user);

  final SessionUser user;

  @override
  List<Object?> get props => [user];
}

class AuthFlowCancelled extends AuthEvent {
  const AuthFlowCancelled();
}

class AuthVerificationCodeSent extends AuthEvent {
  const AuthVerificationCodeSent(this.verificationId);

  final String verificationId;

  @override
  List<Object?> get props => [verificationId];
}

class AuthVerificationFailed extends AuthEvent {
  const AuthVerificationFailed(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
