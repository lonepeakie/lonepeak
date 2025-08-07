import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/services/auth/firebase/auth_service.dart';
import 'package:lonepeak/providers/app_state_provider.dart';

final authStateStreamProvider = StreamProvider<User?>((ref) {
  final authService = ref.read(authServiceProvider);
  return authService.authStateChanges;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.when(
    data: (user) => user != null,
    loading: () => false,
    error: (_, __) => false,
  );
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateStreamProvider);
  return authState.when(
    data: (user) => user,
    loading: () => null,
    error: (_, __) => null,
  );
});

final authStateProvider = Provider<AuthState>((ref) {
  return AuthState(ref);
});

class AuthState {
  AuthState(this._ref) {
    _appState = _ref.read(appStateProvider);
    _ref.listen(isAuthenticatedProvider, (previous, next) {
      if (next && previous != next) {
        _appState.initAppData();
      }
    });
  }

  final Ref _ref;
  late final AppState _appState;

  bool get isAuthenticated => _ref.read(isAuthenticatedProvider);
  User? get currentUser => _ref.read(currentUserProvider);
}
