import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/app_user.dart';
import 'package:lonepeak/data/repositories/auth/auth_repository.dart';
import 'package:lonepeak/data/repositories/auth/auth_state.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/data/repositories/result.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_client.dart';
import 'package:lonepeak/utils/log_printer.dart';

class AuthStateNotifier extends StateNotifier<AuthState> {
  AuthStateNotifier() : super(AuthState(isAuthenticated: false));

  void setAuthenticated() {
    state = AuthState(isAuthenticated: true);
  }

  void clearAuthentication() {
    state = AuthState(isAuthenticated: false);
  }
}

class AuthRepositoryFirebase extends AuthRepository {
  AuthRepositoryFirebase({
    required AuthClient authClient,
    required this.authStateNotifier,
  }) : _authClient = authClient;

  final AuthClient _authClient;
  final AuthStateNotifier authStateNotifier;
  final _log = Logger(printer: AppPrefixPrinter('AuthRepositoryFirebase'));

  @override
  Future<bool> isAuthenticated(AuthType authType) async {
    switch (authType) {
      case AuthType.google:
        final isAuthenticated = await _authClient.isAuthenticatedGoogle();
        if (isAuthenticated) {
          authStateNotifier.setAuthenticated();
        } else {
          authStateNotifier.clearAuthentication();
        }
        return isAuthenticated;
    }
  }

  @override
  Future<Result<AppUser>> signIn(AuthType authType) async {
    switch (authType) {
      case AuthType.google:
        try {
          User? user = await _authClient.signInGoogle();
          if (user == null) {
            _log.e('Failed to sign in with Google');
            return Result.failure('Failed to sign in with Google');
          }
          authStateNotifier.setAuthenticated();
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
        final result = await _authClient.signOutGoogle();
        if (result) {
          authStateNotifier.clearAuthentication();
        }
        return result;
    }
  }
}
