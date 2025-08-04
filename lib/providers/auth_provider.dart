import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_credentials.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/domain/features/user_sigin_feature.dart';
import 'package:lonepeak/utils/log_printer.dart';

/// Authentication provider for login, signup, and logout operations
final authProvider = StateNotifierProvider<AuthProvider, AsyncValue<bool>>((
  ref,
) {
  final userSignInFeature = ref.watch(userSiginFeatureProvider);
  return AuthProvider(userSignInFeature);
});

/// Provider for checking if user is currently authenticated
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  // This would depend on your auth implementation
  // You might need to add a method to check current auth state
  return false; // Placeholder - implement based on your auth system
});

class AuthProvider extends StateNotifier<AsyncValue<bool>> {
  AuthProvider(this._userSignInFeature) : super(const AsyncValue.data(false));

  final UserSiginFeature _userSignInFeature;
  final _log = Logger(printer: PrefixedLogPrinter('AuthProvider'));

  /// Sign in with Google OAuth
  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final result = await _userSignInFeature.logInAndAddUserIfNotExists(
        AuthType.google,
      );

      if (result.isSuccess) {
        _log.i('Google sign-in successful: ${result.data}');
        state = const AsyncValue.data(true);
        return true;
      } else {
        _log.e('Google sign-in failed: ${result.error}');
        state = AsyncValue.error(
          Exception('Google sign-in failed: ${result.error}'),
          StackTrace.current,
        );
        return false;
      }
    } catch (error, stackTrace) {
      _log.e('Google sign-in error: $error');
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmail(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final credentials = EmailCredentials(
        email: email,
        password: password,
        isSignUp: false,
      );

      final result = await _userSignInFeature.logInAndAddUserIfNotExists(
        AuthType.email,
        credentials: credentials,
      );

      if (result.isSuccess) {
        _log.i('Email sign-in successful: ${result.data}');
        state = const AsyncValue.data(true);
        return true;
      } else {
        _log.e('Email sign-in failed: ${result.error}');
        state = AsyncValue.error(
          Exception('Email sign-in failed: ${result.error}'),
          StackTrace.current,
        );
        return false;
      }
    } catch (error, stackTrace) {
      _log.e('Email sign-in error: $error');
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmail(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final credentials = EmailCredentials(
        email: email,
        password: password,
        isSignUp: true,
      );

      final result = await _userSignInFeature.logInAndAddUserIfNotExists(
        AuthType.email,
        credentials: credentials,
      );

      if (result.isSuccess) {
        _log.i('Email sign-up successful: ${result.data}');
        state = const AsyncValue.data(true);
        return true;
      } else {
        _log.e('Email sign-up failed: ${result.error}');
        state = AsyncValue.error(
          Exception('Email sign-up failed: ${result.error}'),
          StackTrace.current,
        );
        return false;
      }
    } catch (error, stackTrace) {
      _log.e('Email sign-up error: $error');
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Sign out the current user
  Future<bool> signOut() async {
    state = const AsyncValue.loading();

    try {
      final result = await _userSignInFeature.logOut();

      if (result.isSuccess) {
        _log.i('Sign-out successful');
        state = const AsyncValue.data(false);
        return true;
      } else {
        _log.e('Sign-out failed: ${result.error}');
        state = AsyncValue.error(
          Exception('Sign-out failed: ${result.error}'),
          StackTrace.current,
        );
        return false;
      }
    } catch (error, stackTrace) {
      _log.e('Sign-out error: $error');
      state = AsyncValue.error(error, stackTrace);
      return false;
    }
  }

  /// Reset authentication state
  void resetAuthState() {
    state = const AsyncValue.data(false);
  }

  /// Get current authentication status
  bool get isAuthenticated {
    return state.value ?? false;
  }
}
