import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/auth_domain.dart';

void _logPhoneAuth(String message, {Object? error, StackTrace? stackTrace}) {
  developer.log(
    message,
    name: 'splukk.phone_auth',
    error: error,
    stackTrace: stackTrace,
  );
}

class PhoneAuthRepositoryImpl implements PhoneAuthRepository {
  PhoneAuthRepositoryImpl({firebase_auth.FirebaseAuth? auth})
      : _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  final firebase_auth.FirebaseAuth _auth;

  @override
  SessionUser? get currentUser {
    final u = _auth.currentUser;
    if (u == null) return null;
    return SessionUser(uid: u.uid, phoneNumber: u.phoneNumber);
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _auth.signOut();
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> startVerifyPhoneNumber(
    String phoneNumber, {
    required Future<void> Function(SessionUser user) verificationCompleted,
    required void Function(String message) verificationFailed,
    required void Function(String verificationId) codeSent,
    required void Function(String verificationId) codeAutoRetrievalTimeout,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (credential) async {
        try {
          final result = await _auth.signInWithCredential(credential);
          final u = result.user!;
          await verificationCompleted(
            SessionUser(uid: u.uid, phoneNumber: u.phoneNumber),
          );
        } catch (e, st) {
          _logPhoneAuth(
            'verifyPhoneNumber verificationCompleted: signInWithCredential failed',
            error: e,
            stackTrace: st,
          );
          verificationFailed(
            e is firebase_auth.FirebaseAuthException
                ? (e.message ?? e.code)
                : e.toString(),
          );
        }
      },
      verificationFailed: (e) {
        _logPhoneAuth(
          'verifyPhoneNumber verificationFailed (after reCAPTCHA / send SMS): '
          'code=${e.code} message=${e.message}',
          error: e,
        );
        verificationFailed(e.message ?? 'Telefon doğrulama hatası');
      },
      codeSent: (verificationId, resendToken) {
        _logPhoneAuth(
          'verifyPhoneNumber codeSent: verificationId length=${verificationId.length}',
        );
        codeSent(verificationId);
      },
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      );
      return const Right(null);
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SessionUser>> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final credential = firebase_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );
      final result = await _auth.signInWithCredential(credential);
      final u = result.user!;
      return Right(SessionUser(uid: u.uid, phoneNumber: u.phoneNumber));
    } on firebase_auth.FirebaseAuthException catch (e) {
      _logPhoneAuth(
        'signInWithSmsCode failed: code=${e.code} message=${e.message}',
        error: e,
      );
      return Left(AuthFailure(e.message ?? 'Kod hatalı'));
    } catch (e) {
      return Left(AuthFailure(e.toString()));
    }
  }
}
