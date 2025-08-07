import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/providers/auth/auth_state_provider.dart';
import 'package:lonepeak/providers/auth/authn_provider.dart';

// User-scoped provider - automatically recreates when currentUserIdProvider changes
final userProvider = StateNotifierProvider<UserProvider, AsyncValue<User?>>((
  ref,
) {
  // Watch the current user ID - provider will be recreated when this changes
  final currentUserId = ref.watch(currentUserIdProvider);

  final usersRepository = ref.watch(usersRepositoryProvider);
  final appState = ref.watch(appStateProvider);
  final authState = ref.watch(authStateProvider);
  final authNotifier = ref.watch(authProvider.notifier);

  return UserProvider(
    usersRepository: usersRepository,
    appState: appState,
    authState: authState,
    authNotifier: authNotifier,
    currentUserId: currentUserId, // Pass the current user ID
  );
});

class UserProvider extends StateNotifier<AsyncValue<User?>> {
  UserProvider({
    required this.usersRepository,
    required this.appState,
    required this.authState,
    required this.authNotifier,
    required this.currentUserId,
  }) : super(const AsyncValue.loading()) {
    // Only load user if we have a valid user ID
    if (currentUserId != null) {
      loadUser();
    } else {
      // No user ID means no user
      state = const AsyncValue.data(null);
    }
  }

  final UsersRepository usersRepository;
  final AppState appState;
  final AuthState authState;
  final AuthProvider authNotifier;
  final String? currentUserId; // User ID that scopes this provider

  // Use state.value instead of cached field
  User? get currentUser => state.value;

  Future<User?> loadUser() async {
    // Use the currentUserId from the provider parameter
    final userId = currentUserId;

    if (userId == null) {
      state = const AsyncValue.data(null);
      return null;
    }

    state = const AsyncValue.loading();

    try {
      final result = await usersRepository.getUser(userId);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to fetch user: ${result.error}'),
          StackTrace.current,
        );
        return null;
      }

      final user = result.data;
      state = AsyncValue.data(user);
      return user;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<User?> getUser() async {
    if (state.hasValue && state.value != null) {
      return state.value;
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

      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  void clearUserProfile() {
    state = const AsyncValue.data(null);
  }

  Future<User?> refreshUser() async {
    return await loadUser();
  }
}
