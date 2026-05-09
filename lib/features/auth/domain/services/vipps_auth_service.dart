import 'package:flutter_appauth/flutter_appauth.dart';

/// Interface for Vipps OAuth 2.0 service.
abstract class IVippsAuthService {
  /// Initiates Vipps OAuth login flow
  /// Returns authorization code that needs to be exchanged for tokens on backend
  Future<AuthorizationResponse?> login();

  /// Exchanges authorization code for tokens
  Future<void> exchangeCodeForTokens(String code);

  /// Fetches user info from Vipps using access token
  Future<Map<String, dynamic>> fetchUserInfo(String accessToken);
}
