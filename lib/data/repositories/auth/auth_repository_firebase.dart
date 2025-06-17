import 'package:firebase_auth/firebase_auth.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/utils/result.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service.dart';
import 'package:lonepeak/domain/models/user.dart' as app_user;

class AuthRepositoryFirebase extends AuthRepository {
  AuthRepositoryFirebase({required AuthService authService})
    : _authService = authService;

  final AuthService _authService;

  @override
  Future<Result<bool>> isAuthenticated() async {
    final isAuthenticated = await _authService.isAuthenticated();
    return Result.success(isAuthenticated);
  }

  @override
  Future<Result<app_user.User>> signIn(AuthType authType) async {
    switch (authType) {
      case AuthType.google:
        try {
          User? user = await _authService.signInGoogle();
          if (user == null) {
            return Result.failure('Failed to sign in with Google');
          }
          return Result.success(app_user.User.fromFirebaseUser(user));
        } catch (e) {
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
          return Result.success(null);
        } else {
          return Result.failure('Failed to sign out user');
        }
    }
  }

  @override
  Result<app_user.User> getCurrentUser() {
    final user = _authService.getCurrentUser();
    if (user == null) {
      return Result.failure('No user is currently signed in.');
    }
    return Result.success(app_user.User.fromFirebaseUser(user));
  }

  @override
  Future<Result<app_user.User>> updateProfile(
    String displayName,
    String email,
  ) async {
    try {
      final firebaseUser = await _authService.updateProfile(displayName, email);
      return Result.success(app_user.User.fromFirebaseUser(firebaseUser));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<app_user.User>> refreshUserData() async {
    try {
      final refreshedUser = await _authService.refreshUser();
      return Result.success(app_user.User.fromFirebaseUser(refreshedUser));
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
