import 'package:flutter_appauth/flutter_appauth.dart';

abstract class SocialAuthRepository {
  Future<AuthorizationResponse?> signInWithVipps();
}
