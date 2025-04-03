import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service_google.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final AuthServiceGoogle _authServiceGoogle;

  AuthService() : _authServiceGoogle = AuthServiceGoogle();

  Future<bool> isAuthenticatedGoogle() async {
    return await _authServiceGoogle.isAuthenticated();
  }

  Future<User?> getCurrentUserGoogle() async {
    return await _authServiceGoogle.getCurrentUser();
  }

  Future<User?> signInGoogle() async {
    return await _authServiceGoogle.signIn();
  }

  Future<bool> signOutGoogle() async {
    return await _authServiceGoogle.signOut();
  }
}
