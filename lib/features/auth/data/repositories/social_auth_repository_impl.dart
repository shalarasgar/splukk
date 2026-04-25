import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/repositories/social_auth_repository.dart';
import '../services/google_auth_service.dart';
import '../services/vipps_auth_service.dart';

class SocialAuthRepositoryImpl implements SocialAuthRepository {
  final GoogleAuthService _googleAuthService;
  final VippsAuthService _vippsAuthService;

  SocialAuthRepositoryImpl({
    required GoogleAuthService googleAuthService,
    required VippsAuthService vippsAuthService,
  })  : _googleAuthService = googleAuthService,
        _vippsAuthService = vippsAuthService;

  @override
  Future<GoogleSignInAccount?> signInWithGoogle() {
    return _googleAuthService.login();
  }

  @override
  Future<AuthorizationResponse?> signInWithVipps() {
    return _vippsAuthService.login();
  }
}
