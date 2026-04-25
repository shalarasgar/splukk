import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract class SocialAuthRepository {
  Future<GoogleSignInAccount?> signInWithGoogle();
  Future<AuthorizationResponse?> signInWithVipps();
}
