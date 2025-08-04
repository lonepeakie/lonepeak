import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/providers/app_state_provider.dart';

/// Provider for estate selection screen user data
final estateSelectUserProvider =
    StateNotifierProvider<EstateSelectUserProvider, AsyncValue<User?>>((ref) {
      final usersRepository = ref.watch(usersRepositoryProvider);
      final appState = ref.watch(appStateProvider);
      return EstateSelectUserProvider(usersRepository, appState);
    });

/// Provider for current user's estate (if any)
final userEstateProvider = FutureProvider<String?>((ref) async {
  final userState = ref.watch(estateSelectUserProvider);
  return userState.when(
    data: (user) => user?.estateId,
    loading: () => null,
    error: (_, __) => null,
  );
});

class EstateSelectUserProvider extends StateNotifier<AsyncValue<User?>> {
  EstateSelectUserProvider(this._usersRepository, this._appState)
    : super(const AsyncValue.data(null)) {
    loadUser();
  }

  final UsersRepository _usersRepository;
  final AppState _appState;
  User? _cachedUser;

  /// Load current user data
  Future<void> loadUser() async {
    state = const AsyncValue.loading();

    try {
      final userId = _appState.getUserId();
      if (userId == null) {
        state = AsyncValue.error(
          Exception('User ID is null - user not authenticated'),
          StackTrace.current,
        );
        return;
      }

      final result = await _usersRepository.getUser(userId);
      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to load user: ${result.error}'),
          StackTrace.current,
        );
        return;
      }

      if (result.data == null) {
        state = AsyncValue.error(
          Exception('User not found'),
          StackTrace.current,
        );
        return;
      }

      _cachedUser = result.data;
      state = AsyncValue.data(_cachedUser);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Get cached user (synchronous)
  User? get cachedUser => _cachedUser;

  /// Update user data
  Future<void> updateUser(User user) async {
    try {
      final result = await _usersRepository.updateUser(user);

      if (result.isFailure) {
        throw Exception('Failed to update user: ${result.error}');
      }

      _cachedUser = user;
      state = AsyncValue.data(_cachedUser);
    } catch (error) {
      throw error;
    }
  }

  /// Refresh user data from repository
  Future<void> refreshUser() async {
    _cachedUser = null;
    await loadUser();
  }

  /// Clear cached user data
  void clearUser() {
    _cachedUser = null;
    state = const AsyncValue.data(null);
  }

  /// Check if user has an estate
  bool get hasEstate {
    return _cachedUser?.estateId?.isNotEmpty ?? false;
  }

  /// Get user's estate ID
  String? get estateId {
    return _cachedUser?.estateId;
  }

  /// Check if user is new (no estate)
  bool get isNewUser {
    return !hasEstate;
  }
}
