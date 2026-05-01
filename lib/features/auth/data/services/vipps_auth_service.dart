import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Vipps OAuth 2.0 service
/// TODO: Replace placeholders with actual credentials from Vipps Developer Portal
class VippsAuthService {
  String get clientId => dotenv.env['VIPPS_CLIENT_ID'] ?? '';

  // TODO: Set to true for production, false for test environment
  static const bool isProduction = false;

  String get subscriptionKey => dotenv.env['VIPPS_SUBSCRIPTION_KEY'] ?? '';

  static String get _authEndpoint {
    if (isProduction) {
      return 'https://api.vipps.no';
    } else {
      return 'https://apitest.vipps.no';
    }
  }

  static const String redirectUrl = 'splukk://callback';
  static const String responseType = 'code';

  /// Initiates Vipps OAuth login flow
  /// Returns authorization code that needs to be exchanged for tokens on backend
  Future<AuthorizationResponse?> login() async {
    final appAuth = const FlutterAppAuth();

    try {
      final result = await appAuth.authorize(
        AuthorizationRequest(
          clientId,
          redirectUrl,
          discoveryUrl: '$_authEndpoint/.well-known/openid-configuration',
          scopes: ['openid', 'name', 'phoneNumber'],
        ),
      );

      return result;
    } catch (e) {
      throw Exception('Vipps login failed: $e');
    }
  }

  /// Exchanges authorization code for tokens
  /// TODO: This should be done on your backend for security
  Future<void> exchangeCodeForTokens(String code) async {
    // TODO: Implement backend call to exchange code for access token
    // POST to: $_authEndpoint/accesstoken
    // Body: grant_type=authorization_code, code=$code, redirect_uri=$redirectUrl
    throw UnimplementedError('Token exchange should be done on backend');
  }

  /// Fetches user info from Vipps using access token
  /// TODO: This should be done on your backend for security
  Future<Map<String, dynamic>> fetchUserInfo(String accessToken) async {
    // TODO: Implement backend call to fetch user info
    // GET to: $_authEndpoint/userinfo
    // Headers: Authorization: Bearer $accessToken
    throw UnimplementedError('User info fetch should be done on backend');
  }
}
