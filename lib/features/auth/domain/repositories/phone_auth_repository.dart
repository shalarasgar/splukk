import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/session_user.dart';

abstract class PhoneAuthRepository {
  SessionUser? get currentUser;

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, void>> startVerifyPhoneNumber(
    String phoneNumber, {
    required Future<void> Function(SessionUser user) verificationCompleted,
    required void Function(String message) verificationFailed,
    required void Function(String verificationId) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  });

  Future<Either<Failure, SessionUser>> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  });
}
