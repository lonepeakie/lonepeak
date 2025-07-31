import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service_email.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service_google.dart';
import 'package:lonepeak/utils/log_printer.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

class AuthService {
  final AuthServiceGoogle _authServiceGoogle;
  final AuthServiceEmail _authServiceEmail;
  final _log = Logger(printer: PrefixedLogPrinter('AuthService'));

  AuthService()
    : _authServiceGoogle = AuthServiceGoogle(),
      _authServiceEmail = AuthServiceEmail();

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
        _log.i('Current user: ${currentUser.email}');
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

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _authServiceEmail.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await _authServiceEmail.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<bool> signOut() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
      _log.i('User signed out successfully.');
      return true;
    } catch (e, stackTrace) {
      _log.e('Error signing out: $e\nStackTrace: $stackTrace');
      return false;
    }
  }

  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();
}
