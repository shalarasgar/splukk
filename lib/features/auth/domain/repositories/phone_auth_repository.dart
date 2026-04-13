import '../entities/session_user.dart';

abstract class PhoneAuthRepository {
  SessionUser? get currentUser;

  Future<void> signOut();

  Future<void> startVerifyPhoneNumber(
    String phoneNumber, {
    required Future<void> Function(SessionUser user) verificationCompleted,
    required void Function(String message) verificationFailed,
    required void Function(String verificationId) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  });

  Future<SessionUser> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  });
}
