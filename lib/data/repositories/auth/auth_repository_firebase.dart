// lib/data/repositories/auth/auth_repository_firebase.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/utils/result.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service.dart';
import 'package:lonepeak/utils/log_printer.dart';
import 'package:lonepeak/domain/models/user.dart' as app_user;

class AuthRepositoryFirebase extends AuthRepository {
  AuthRepositoryFirebase({required AuthService authService})
      : _authService = authService;

  final AuthService _authService;
  final _log = Logger(printer: PrefixedLogPrinter('AuthRepositoryFirebase'));
  final _firebaseAuth = FirebaseAuth.instance;

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
            _log.e('Failed to sign in with Google');
            return Result.failure('Failed to sign in with Google');
          }
          return Result.success(app_user.User.fromFirebaseUser(user));
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
  Result<app_user.User> getCurrentUser() {
    final user = _authService.getCurrentUser();
    if (user == null) {
      _log.w('No user is currently signed in.');
      return Result.failure('No user is currently signed in.');
    }
    return Result.success(app_user.User.fromFirebaseUser(user));
  }

  // FIX: Implemented the updateProfile method.
  @override
  Future<Result<app_user.User>> updateProfile(
      String displayName, String email) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure("No user is currently signed in.");
      }

      if (displayName != user.displayName) {
        await user.updateDisplayName(displayName);
        _log.i("Display name updated to: $displayName");
      }

      if (email != user.email) {
        await user.verifyBeforeUpdateEmail(email);
        _log.i("Verification email sent to new address: $email");
      }

      await user.reload();
      final updatedUser = _firebaseAuth.currentUser;
      if (updatedUser == null) {
        return Result.failure("Failed to retrieve updated user data.");
      }

      return Result.success(app_user.User.fromFirebaseUser(updatedUser));
    } on FirebaseAuthException catch (e) {
      _log.e("Error updating profile: ${e.code}", error: e);
      // Provide user-friendly messages for common errors
      if (e.code == 'email-already-in-use') {
        return Result.failure(
            'The email address is already in use by another account.');
      }
      return Result.failure(e.message ?? "An error occurred while updating.");
    } catch (e) {
      _log.e("An unexpected error occurred during profile update", error: e);
      return Result.failure("An unexpected error occurred.");
    }
  }

  // FIX: Implemented the refreshUserData method.
  @override
  Future<Result<app_user.User>> refreshUserData() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure("No user is signed in to refresh.");
      }
      await user.reload();
      final refreshedUser = _firebaseAuth.currentUser!;
      return Result.success(app_user.User.fromFirebaseUser(refreshedUser));
    } on FirebaseAuthException catch (e) {
      _log.e("Failed to refresh user data: ${e.code} - ${e.message}");
      return Result.failure(e.message ?? "Your session may be invalid.");
    } catch (e) {
      _log.e("An unexpected error occurred while refreshing user data",
          error: e);
      return Result.failure("An unexpected error occurred.");
    }
  }
}
