import 'package:google_sign_in/google_sign_in.dart';

/// Google Sign-In service
/// TODO: Replace placeholders with actual credentials from Google Cloud Console
class GoogleAuthService {
  // TODO: Insert your Google Web Client ID from Google Cloud Console
  static const String webClientId = 'YOUR_GOOGLE_WEB_CLIENT_ID';
  
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: webClientId,
    scopes: ['email', 'profile'],
  );

  /// Initiates Google Sign-In flow
  /// Returns GoogleSignInAccount with user info
  Future<GoogleSignInAccount?> login() async {
    try {
      final GoogleSignInAccount? account = await _googleSignIn.signIn();
      return account;
    } catch (e) {
      throw Exception('Google login failed: $e');
    }
  }

  /// Signs out from Google
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  /// Gets authentication token for backend calls
  /// TODO: This token should be sent to your backend for verification
  Future<GoogleSignInAuthentication?> getAuth() async {
    final GoogleSignInAccount? account = _googleSignIn.currentUser;
    if (account == null) return null;
    
    final GoogleSignInAuthentication auth = await account.authentication;
    return auth;
  }
}
