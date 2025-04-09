import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/app_user.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/utils/result.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service.dart';
import 'package:lonepeak/utils/log_printer.dart';

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
  Future<Result<AppUser>> signIn(AuthType authType) async {
    switch (authType) {
      case AuthType.google:
        try {
          User? user = await _authService.signInGoogle();
          if (user == null) {
            _log.e('Failed to sign in with Google');
            return Result.failure('Failed to sign in with Google');
          }
          return Result.success(AppUser.fromUser(user));
        } catch (e) {
          _log.e('Error during Google sign-in: $e');
          return Result.failure(e.toString());
        }
    }
  }

  @override
  Future<Result<void>> signOut(AuthType authType) async {
    switch (authType) {
      case AuthType.google:
        final result = await _authService.signOutGoogle();
        if (result) {
          _log.i('User signed out successfully.');
          return Result.success(null);
        } else {
          _log.e('Failed to sign out user.');
          return Result.failure('Failed to sign out user');
        }
    }
  }

  @override
  Future<Result<AppUser>> getCurrentUser() async {
    final user = await _authService.getCurrentUser();
    if (user == null) {
      _log.w('No user is currently signed in.');
      return Result.failure('No user is currently signed in.');
    }
    return Result.success(AppUser.fromUser(user));
  }
}
