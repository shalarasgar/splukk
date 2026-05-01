import 'package:flutter_appauth/flutter_appauth.dart';

import '../../domain/repositories/social_auth_repository.dart';
import '../services/vipps_auth_service.dart';

class SocialAuthRepositoryImpl implements SocialAuthRepository {

  final VippsAuthService _vippsAuthService;

  SocialAuthRepositoryImpl({
    
    required VippsAuthService vippsAuthService,
  })  :
        _vippsAuthService = vippsAuthService;

  

  @override
  Future<AuthorizationResponse?> signInWithVipps() {
    return _vippsAuthService.login();
  }
}
