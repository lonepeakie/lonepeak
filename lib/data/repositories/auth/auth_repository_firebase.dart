import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/app_user.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/data/repositories/result.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service.dart';
import 'package:lonepeak/utils/log_printer.dart';

class AuthRepositoryFirebase extends AuthRepository {
  AuthRepositoryFirebase({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;
  final _log = Logger(printer: PrefixedLogPrinter('AuthRepositoryFirebase'));

  @override
  Future<bool> isAuthenticated(AuthType authType) async {
    switch (authType) {
      case AuthType.google:
        final isAuthenticated = await _authService.isAuthenticatedGoogle();
        return isAuthenticated;
    }
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
  Future<bool> signOut(AuthType authType) async {
    switch (authType) {
      case AuthType.google:
        final result = await _authService.signOutGoogle();
        if (result) {}
        return result;
    }
  }

  @override
  Future<AppUser?> getCurrentUser(AuthType authType) async {
    switch (authType) {
      case AuthType.google:
        final user = await _authService.getCurrentUserGoogle();
        if (user == null) {
          _log.w('No user is currently signed in.');
          return null;
        }
        return AppUser.fromUser(user);
    }
  }
}
