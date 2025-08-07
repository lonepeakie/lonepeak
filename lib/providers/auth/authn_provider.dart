import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:lonepeak/data/repositories/auth/auth_credentials.dart';
import 'package:lonepeak/data/repositories/auth/auth_type.dart';
import 'package:lonepeak/domain/features/user_sigin_feature.dart';
import 'package:lonepeak/providers/auth/auth_state_provider.dart';
import 'package:lonepeak/utils/log_printer.dart';

// User scoping provider - when this changes, all user-scoped providers are recreated
final currentUserIdProvider = StateProvider<String?>((ref) => null);

final authProvider = StateNotifierProvider<AuthProvider, AsyncValue<bool>>((
  ref,
) {
  final userSignInFeature = ref.watch(userSiginFeatureProvider);
  return AuthProvider(userSignInFeature, ref);
});

class AuthProvider extends StateNotifier<AsyncValue<bool>> {
  AuthProvider(this._userSignInFeature, this._ref)
    : super(const AsyncValue.data(false));

  final UserSiginFeature _userSignInFeature;
  final Ref _ref;
  final _log = Logger(printer: PrefixedLogPrinter('AuthProvider'));

  Future<bool> signInWithGoogle() async {
    state = const AsyncValue.loading();

    try {
      final result = await _userSignInFeature.logInAndAddUserIfNotExists(
        AuthType.google,
      );

      if (result.isSuccess) {
        _log.i('Google sign-in successful: ${result.data}');

        // Set the current user ID to trigger user-scoped provider recreation
        await _setCurrentUserId();

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

        // Set the current user ID to trigger user-scoped provider recreation
        await _setCurrentUserId();

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

        // Set the current user ID to trigger user-scoped provider recreation
        await _setCurrentUserId();

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

  Future<bool> signOut() async {
    state = const AsyncValue.loading();

    try {
      _log.i('Starting sign-out process');

      // Clear the current user ID - this will automatically recreate all user-scoped providers
      _ref.read(currentUserIdProvider.notifier).state = null;

      final result = await _userSignInFeature.logOut();

      if (result.isSuccess) {
        _log.i('Sign-out successful - all user-scoped providers cleared');
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

  /// Helper method to set current user ID after successful authentication
  Future<void> _setCurrentUserId() async {
    try {
      // Get current user from the user sign-in feature's auth repository
      // We'll use the auth state provider instead to get the current user
      final authStateAsync = _ref.read(authStateStreamProvider);
      authStateAsync.when(
        data: (user) {
          if (user != null) {
            final userId =
                user.email ?? user.uid; // Use email or uid as user ID
            _ref.read(currentUserIdProvider.notifier).state = userId;
            _log.i('Current user ID set to: $userId');
          }
        },
        loading: () => _log.w('Auth state still loading when setting user ID'),
        error:
            (error, _) =>
                _log.e('Error getting auth state for user ID: $error'),
      );
    } catch (e) {
      _log.e('Error setting current user ID: $e');
    }
  }

  void resetAuthState() {
    state = const AsyncValue.data(false);
  }

  bool get isAuthenticated {
    return state.value ?? false;
  }
}
