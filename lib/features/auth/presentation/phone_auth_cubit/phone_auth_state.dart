import 'package:equatable/equatable.dart';

enum PhoneAuthStatus {
  initial,
  loading,
  codeSent,
  success,
  failure,
}

class PhoneAuthState extends Equatable {
  final PhoneAuthStatus status;
  final String? verificationId;
  final String? errorMessage;
  final String? phoneNumber;

  const PhoneAuthState({
    required this.status,
    this.verificationId,
    this.errorMessage,
    this.phoneNumber,
  });

  const PhoneAuthState.initial() : this(status: PhoneAuthStatus.initial);

  PhoneAuthState copyWith({
    PhoneAuthStatus? status,
    String? verificationId,
    String? errorMessage,
    String? phoneNumber,
  }) {
    return PhoneAuthState(
      status: status ?? this.status,
      verificationId: verificationId ?? this.verificationId,
      errorMessage: errorMessage ?? this.errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  @override
  List<Object?> get props => [status, verificationId, errorMessage, phoneNumber];
}
