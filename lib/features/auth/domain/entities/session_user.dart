import 'package:equatable/equatable.dart';

class SessionUser extends Equatable {
  const SessionUser({
    required this.uid,
    this.phoneNumber,
  });

  final String uid;
  final String? phoneNumber;

  @override
  List<Object?> get props => [uid, phoneNumber];
}
