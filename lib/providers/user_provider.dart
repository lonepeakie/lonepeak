import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/providers/auth_provider.dart';
import 'package:lonepeak/providers/auth_state_provider.dart';

final userProvider = StateNotifierProvider<UserProvider, AsyncValue<User?>>((
  ref,
) {
  final usersRepository = ref.watch(usersRepositoryProvider);
  final appState = ref.watch(appStateProvider);
  final authState = ref.watch(authStateProvider);
  final authNotifier = ref.watch(authProvider.notifier);

  return UserProvider(
    usersRepository: usersRepository,
    appState: appState,
    authState: authState,
    authNotifier: authNotifier,
  );
});

class UserProvider extends StateNotifier<AsyncValue<User?>> {
  UserProvider({
    required this.usersRepository,
    required this.appState,
    required this.authState,
    required this.authNotifier,
  }) : super(const AsyncValue.data(null)) {
    loadUser();
  }

  final UsersRepository usersRepository;
  final AppState appState;
  final AuthState authState;
  final AuthProvider authNotifier;

  User? _cachedUser;

  User? get currentUser => _cachedUser;

  Future<User?> loadUser() async {
    final currentUserId = authState.currentUser?.email;

    if (currentUserId == null) {
      state = AsyncValue.error(
        Exception('No authenticated user found'),
        StackTrace.current,
      );
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final result = await usersRepository.getUser(currentUserId);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to fetch user: ${result.error}'),
          StackTrace.current,
        );
        return null;
      }

      final user = result.data;
      _cachedUser = user;
      state = AsyncValue.data(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<User?> getUser() async {
    if (_cachedUser != null) {
      state = AsyncValue.data(_cachedUser);
      return _cachedUser;
    }
    return await loadUser();
  }

  Future<void> updateUser(User user) async {
    try {
      state = const AsyncValue.loading();

      final result = await usersRepository.updateUser(user);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to update user: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      _cachedUser = user;
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();

      // Use the auth provider's sign out logic
      final success = await authNotifier.signOut();

      if (success) {
        // Clear cached data
        _cachedUser = null;
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(
          Exception('Sign out failed'),
          StackTrace.current,
        );
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  void clearUserProfile() {
    _cachedUser = null;
    state = const AsyncValue.data(null);
  }

  Future<User?> refreshUser() async {
    _cachedUser = null;
    return await loadUser();
  }
}
