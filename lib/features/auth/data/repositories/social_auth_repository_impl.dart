import 'package:flutter_appauth/flutter_appauth.dart';

import '../../domain/repositories/social_auth_repository.dart';
import '../../domain/services/vipps_auth_service.dart';

class SocialAuthRepositoryImpl implements SocialAuthRepository {

  final IVippsAuthService _vippsAuthService;

  SocialAuthRepositoryImpl({
    required IVippsAuthService vippsAuthService,
  })  : _vippsAuthService = vippsAuthService;

  

  @override
  Future<AuthorizationResponse?> signInWithVipps() {
    return _vippsAuthService.login();
  }
}
