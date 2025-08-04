import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lonepeak/data/repositories/users/users_repository.dart';
import 'package:lonepeak/data/repositories/users/users_repository_firebase.dart';
import 'package:lonepeak/domain/features/estate_features.dart';
import 'package:lonepeak/domain/features/user_sigin_feature.dart';
import 'package:lonepeak/domain/models/user.dart';
import 'package:lonepeak/providers/app_state_provider.dart';
import 'package:lonepeak/providers/auth_state_provider.dart';

/// Provider for current user profile data
final userProfileProvider =
    StateNotifierProvider<UserProfileProvider, AsyncValue<User?>>((ref) {
      final userSiginFeature = ref.watch(userSiginFeatureProvider);
      final usersRepository = ref.watch(usersRepositoryProvider);
      final estateFeatures = ref.watch(estateFeaturesProvider);
      final appState = ref.watch(appStateProvider);
      final authState = ref.watch(authStateProvider);

      return UserProfileProvider(
        userSiginFeature: userSiginFeature,
        usersRepository: usersRepository,
        estateFeatures: estateFeatures,
        appState: appState,
        authState: authState,
      );
    });

class UserProfileProvider extends StateNotifier<AsyncValue<User?>> {
  UserProfileProvider({
    required this.userSiginFeature,
    required this.usersRepository,
    required this.estateFeatures,
    required this.appState,
    required this.authState,
  }) : super(const AsyncValue.data(null));

  final UserSiginFeature userSiginFeature;
  final UsersRepository usersRepository;
  final EstateFeatures estateFeatures;
  final AppState appState;
  final AuthState authState;

  User? _cachedUser;

  /// Get the currently cached user (synchronous access)
  User? get currentUser => _cachedUser;

  /// Get user profile from cache if available, otherwise fetch from repository
  Future<User?> getUserProfile() async {
    final currentUserId = authState.currentUser?.email;

    if (currentUserId == null) {
      state = AsyncValue.error(
        Exception('No authenticated user found'),
        StackTrace.current,
      );
      return null;
    }

    if (_cachedUser != null) {
      state = AsyncValue.data(_cachedUser);
      return _cachedUser;
    }

    state = const AsyncValue.loading();

    try {
      final result = await usersRepository.getUser(currentUserId);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to fetch user profile: ${result.error}'),
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

  /// Update user profile in cache and repository
  Future<void> updateUserProfile(User user) async {
    try {
      state = const AsyncValue.loading();

      final result = await usersRepository.updateUser(user);

      if (result.isFailure) {
        state = AsyncValue.error(
          Exception('Failed to update user profile: ${result.error}'),
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

  /// Sign out user and clear profile data
  Future<void> signOut() async {
    try {
      state = const AsyncValue.loading();

      // TODO: Implement sign out logic when available
      // final result = await userSiginFeature.signOut();

      // Clear cached data
      _cachedUser = null;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Leave current estate
  Future<void> leaveEstate() async {
    if (_cachedUser == null) return;

    try {
      state = const AsyncValue.loading();

      // TODO: Implement leave estate logic when available
      // final result = await estateFeatures.leaveEstate(_cachedUser!);

      // Refresh user data after leaving estate
      await getUserProfile();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Clear cached user data
  void clearUserProfile() {
    _cachedUser = null;
    state = const AsyncValue.data(null);
  }

  /// Refresh user profile from repository
  Future<User?> refreshUserProfile() async {
    _cachedUser = null;
    return await getUserProfile();
  }
}
