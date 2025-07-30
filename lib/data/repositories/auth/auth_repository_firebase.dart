import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_credentials.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/utils/result.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/domain/models/user.dart' as app_user;

final authRepositoryProvider = Provider<AuthRepositoryFirebase>((ref) {
  return AuthRepositoryFirebase(authService: ref.read(authServiceProvider));
});

class AuthRepositoryFirebase extends AuthRepository {
  AuthRepositoryFirebase({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;
  final _log = Logger(printer: PrefixedLogPrinter('AuthRepositoryFirebase'));

  @override
  Future<Result<bool>> isAuthenticated() async {
    final isAuthenticated = await _authService.isAuthenticated();
    return Result.success(isAuthenticated);
  }

  @override
  Future<Result<app_user.User>> signIn(
    AuthType authType, {
    AuthCredentials? credentials,
  }) async {
    switch (authType) {
      case AuthType.google:
        try {
          User? user = await _authService.signInGoogle();
          if (user == null) {
            _log.e('Failed to sign in with Google');
            return Result.failure('Failed to sign in with Google');
          }
          return Result.success(app_user.User.fromFirebaseUser(user));
        } catch (e) {
          _log.e('Error during Google sign-in: $e');
          return Result.failure(e.toString());
        }
      case AuthType.email:
        if (credentials is! EmailCredentials) {
          _log.e('Email credentials required for email authentication');
          return Result.failure(
            'Email credentials required for email authentication',
          );
        }
        try {
          User? user;
          if (credentials.isSignUp) {
            user = await _authService.createUserWithEmailAndPassword(
              email: credentials.email,
              password: credentials.password,
            );
          } else {
            user = await _authService.signInWithEmailAndPassword(
              email: credentials.email,
              password: credentials.password,
            );
          }
          if (user == null) {
            _log.e('Failed to authenticate with email');
            return Result.failure('Failed to authenticate with email');
          }
          return Result.success(app_user.User.fromFirebaseUser(user));
        } catch (e) {
          _log.e('Error during email authentication: $e');
          return Result.failure(e.toString());
        }
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authService.signOut();
      _log.i('User signed out successfully.');
      return Result.success(null);
    } catch (e) {
      _log.e('Failed to sign out user: $e');
      return Result.failure('Failed to sign out user');
    }
  }

  @override
  Result<app_user.User> getCurrentUser() {
    final user = _authService.getCurrentUser();
    if (user == null) {
      _log.w('No user is currently signed in.');
      return Result.failure('No user is currently signed in.');
    }
    return Result.success(app_user.User.fromFirebaseUser(user));
  }
}
