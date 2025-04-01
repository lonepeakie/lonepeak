import 'package:firebase_auth/firebase_auth.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_client_google.dart';

class AuthClient {
  final AuthClientGoogle _authClientGoogle;

  AuthClient() : _authClientGoogle = AuthClientGoogle();

  Future<bool> isAuthenticatedGoogle() async {
    return await _authClientGoogle.isAuthenticated();
  }

  Future<User?> signInGoogle() async {
    return await _authClientGoogle.signIn();
  }

  Future<bool> signOutGoogle() async {
    return await _authClientGoogle.signOut();
  }
}
