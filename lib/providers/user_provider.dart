import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/providers/core/user_scoped_provider.dart';

// User-scoped provider - using the helper function
final userProvider = createUserScopedProvider<UserProvider, User?>((
  currentUserId,
  ref,
) {
  final usersRepository = ref.watch(usersRepositoryProvider);
  final appState = ref.watch(appStateProvider);

  return UserProvider(
    usersRepository: usersRepository,
    appState: appState,
    currentUserId: currentUserId,
  );
});

class UserProvider extends UserScopedStateNotifier<User?>
    with UserScopedProviderMixin<User?> {
  UserProvider({
    required this.usersRepository,
    required this.appState,
    required String? currentUserId,
  }) : super(currentUserId, const AsyncValue.loading());

  final UsersRepository usersRepository;
  final AppState appState;

  @override
  void initializeWithUser() {
    loadUser();
  }

  @override
  void initializeWithoutUser() {
    state = const AsyncValue.data(null);
  } // User ID that scopes this provider

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
