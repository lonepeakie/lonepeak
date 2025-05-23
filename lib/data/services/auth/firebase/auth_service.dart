import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service_google.dart';
import 'package:lonepeak/utils/log_printer.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final AuthServiceGoogle _authServiceGoogle;
  final _log = Logger(printer: PrefixedLogPrinter('AuthService'));

  AuthService() : _authServiceGoogle = AuthServiceGoogle();

  Future<bool> isAuthenticated() async {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final isSignedIn = currentUser != null;
      _log.i('User is ${isSignedIn ? "authenticated" : "not authenticated"}.');
      return isSignedIn;
    } catch (e, stackTrace) {
      _log.e(
        'Error checking authentication status: $e\nStackTrace: $stackTrace',
      );
      return false;
    }
  }

  User? getCurrentUser() {
    try {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        _log.i('Current user: ${currentUser.displayName}');
      } else {
        _log.w('No user is currently signed in.');
      }
      return currentUser;
    } catch (e, stackTrace) {
      _log.e('Error getting current user: $e\nStackTrace: $stackTrace');
      return null;
    }
  }

  Future<User?> signInGoogle() async {
    return await _authServiceGoogle.signIn();
  }

  Future<bool> signOutGoogle() async {
    return await _authServiceGoogle.signOut();
  }
}
